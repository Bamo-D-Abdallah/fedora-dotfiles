#!/usr/bin/env bash
set -Eeuo pipefail

# =========================
# Fedora Bootstrap (DNF5/4)
# =========================

# -------- Config / Debug --------
DEBUG="${DEBUG:-0}"      # set DEBUG=1 to echo extra info
ME="${SUDO_USER:-$USER}"

# -------- Resolve script paths --------
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LISTS="${LISTS:-$REPO_DIR/lists}"

[[ "$DEBUG" == "1" ]] && {
  echo "==> DEBUG: REPO_DIR=$REPO_DIR"
  echo "==> DEBUG: LISTS=$LISTS"
}

# -------- Sanity: Fedora only --------
if ! grep -qi 'fedora' /etc/os-release; then
  echo "This script targets Fedora." >&2
  exit 1
fi

# -------- Helpers --------
is_dnf5() {
  command -v dnf5 >/dev/null 2>&1 || dnf --version 2>/dev/null | grep -qiE 'DNF5|libdnf5'
}
have_file() { [[ -s "$1" ]]; }
trim_line() {
  # stdin -> trimmed line (no CRLF, no inline comments)
  sed -E 's/#.*$//; s/[[:space:]]+$//; s/^[[:space:]]+//; s/\r$//'
}

# -------- System update & base tools --------
echo "==> System update & base tools"
sudo dnf -y upgrade

if is_dnf5; then
  sudo dnf -y install curl git dnf5-plugins || true
else
  sudo dnf -y install curl git dnf-plugins-core || true
fi

# -------- RPM Fusion (Free + Nonfree) --------
echo "==> Enabling RPM Fusion (Free + Nonfree)"
REL=$(rpm -E %fedora)
sudo dnf -y install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${REL}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${REL}.noarch.rpm" || true

# -------- COPRs --------
echo "==> Enabling COPRs"
COPR_FILE="$LISTS/copr.txt"
if have_file "$COPR_FILE"; then
  while IFS= read -r raw; do
    copr="$(printf '%s' "$raw" | trim_line)"
    [[ -z "$copr" ]] && continue
    if [[ ! "$copr" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]]; then
      echo "  !! Skipping invalid COPR entry: '$raw'"
      continue
    fi
    echo "  -> Enabling COPR $copr"
    sudo dnf -y copr enable "$copr" || true
  done < "$COPR_FILE"
fi

# -------- Third-party repos (conditional) --------
echo "==> Enabling third-party repos"

DNF_LIST="$LISTS/dnf.txt"
wants_pkg() {
  # does dnf.txt list the given package?
  [[ -s "$DNF_LIST" ]] && grep -qx "$1" "$DNF_LIST"
}

# Brave
if wants_pkg "brave-browser"; then
  if ! sudo dnf repolist | grep -q 'brave-browser'; then
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc || true
    sudo tee /etc/yum.repos.d/brave-browser.repo >/dev/null <<'EOF'
[brave-browser]
name=Brave Browser
baseurl=https://brave-browser-rpm-release.s3.brave.com/$basearch/
enabled=1
gpgcheck=1
gpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
EOF
  fi
fi

# Google Chrome
if wants_pkg "google-chrome-stable"; then
  if ! sudo dnf repolist | grep -q 'google-chrome'; then
    sudo tee /etc/yum.repos.d/google-chrome.repo >/dev/null <<'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
  fi
fi

# Docker CE repo (only if requested)
if wants_pkg "docker-ce" || wants_pkg "docker-ce-cli" || wants_pkg "containerd.io"; then
  if ! sudo dnf repolist 2>/dev/null | grep -q 'docker-ce-stable'; then
    if is_dnf5; then
      sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo || true
    else
      sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo || true
    fi
  fi
fi

# Rebuild cache after adding repos
sudo dnf makecache || true


# ====== Install DNF packages (simple, loud, per-pkg) ======
echo "==> Installing DNF packages"

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LIST_FILE="$REPO_DIR/lists/dnf.txt"

if [[ -s "$LIST_FILE" ]]; then
  echo "  -> Using list: $LIST_FILE"
  sudo -v || true

  # Normalizer: strip BOM/CRLF/inline comments/whitespace
  normalize() {
    sed -E '1s/^\xEF\xBB\xBF//; s/#.*$//; s/[[:space:]]+$//; s/^[[:space:]]+//' \
    | tr -d '\r'
  }

  PKGS=()
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    line="$(printf '%s' "$raw" | normalize)"
    [[ -z "$line" ]] && continue

    # Auto-fix a couple common misnames
    [[ "$line" == "blueman-manager"    ]] && line="blueman"
    [[ "$line" == "nm-applet"          ]] && line="NetworkManager-applet"

    PKGS+=("$line")
  done < "$LIST_FILE"

  echo "  -> Parsed package lines: ${#PKGS[@]}"
  ((${#PKGS[@]})) && printf '     - %s\n' "${PKGS[@]}"

  if ((${#PKGS[@]})); then
    echo "==> Installing ${#PKGS[@]} packages"
    for pkg in "${PKGS[@]}"; do
      echo "  -> $pkg"
      if ! sudo dnf -y install "$pkg"; then
        echo "  !! Failed: $pkg" >&2
      fi
    done
  fi
else
  echo "  !! No non-empty file at $LIST_FILE"
fi

# -------- Enable Docker service if installed --------
echo "==> Enabling Docker service"
if command -v docker >/dev/null 2>&1; then
  sudo systemctl enable --now docker || true
  sudo usermod -aG docker "$ME" || true
fi

# -------- Flatpak remotes --------
echo "==> Installing Flatpak remotes"
FP_REMOTES="$LISTS/flatpak-remotes.txt"
if have_file "$FP_REMOTES"; then
  while IFS= read -r raw; do
    read -r name url <<<"$(printf '%s' "$raw" | trim_line)"
    [[ -z "${name:-}" || -z "${url:-}" ]] && continue
    if ! flatpak remotes --columns=name | grep -qx "$name"; then
      flatpak remote-add --if-not-exists "$name" "$url"
    fi
  done < "$FP_REMOTES"
fi

# -------- Flatpak apps --------
echo "==> Installing Flatpak apps"
FP_APPS="$LISTS/flatpak.txt"
if have_file "$FP_APPS"; then
  while IFS= read -r raw; do
    line="$(printf '%s' "$raw" | trim_line)"
    [[ -z "$line" ]] && continue
    app="${line%% *}"; origin="${line#"$app"}"; origin="$(echo "$origin" | xargs || true)"
    flatpak install -y "${origin:-flathub}" "$app" || true
  done < "$FP_APPS"
fi

# -------- Global NPM packages --------
echo "==> Installing global NPM packages"
NPM_LIST="$LISTS/npm-global.txt"
if have_file "$NPM_LIST"; then
  if command -v npm >/dev/null 2>&1; then
    while IFS= read -r raw; do
      pkg="$(printf '%s' "$raw" | trim_line)"
      [[ -z "$pkg" ]] && continue
      sudo -u "$ME" npm install -g "$pkg" || true
    done < "$NPM_LIST"
  else
    echo "  (npm not found; skipping npm-global.txt)"
  fi
fi

# -------- Optional: Synth-shell (disabled by default) --------
# echo "==> Installing Synth-shell"
# mkdir -p ~/Downloads
# pushd ~/Downloads >/dev/null
# rm -rf synth-shell || true
# git clone --recursive https://github.com/andresgongora/synth-shell.git
# cd synth-shell && chmod 700 ./setup.sh && ./setup.sh
# popd >/dev/null
# rm -rf ~/Downloads/synth-shell || true

# -------- Optional: Fonts (JetBrains Mono from repo assets) --------
echo "==> Installing JetBrains Mono (if present in repo assets)"
mkdir -p ~/.local/share/fonts
if [[ -d "$REPO_DIR/assets/fonts/JetBrainsMono" ]]; then
  cp -r "$REPO_DIR/assets/fonts/JetBrainsMono" ~/.local/share/fonts/
  fc-cache -f ~/.local/share/fonts
else
  echo "JetBrainsMono not found at $REPO_DIR/assets/fonts/JetBrainsMono — skipping."
fi

# -------- Done --------
cat <<'DONE'

✅ Bootstrap finished.

- COPRs and third-party repos enabled as requested.
- DNF packages installed (per-package logging above).
- Docker enabled if present; relog to pick up docker group.
- Flatpak remotes/apps processed.
- Global npm packages installed if listed.
- JetBrains Mono copied if found in repo assets.

Re-run anytime; operations are idempotent.

DONE
