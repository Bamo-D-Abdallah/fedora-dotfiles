#!/usr/bin/env bash
set -euo pipefail

# List paths
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LISTS="$REPO_DIR/lists"

# Sanity check
if ! grep -qi 'fedora' /etc/os-release; then
  echo "This script targets Fedora." >&2
  exit 1
fi

ME="${SUDO_USER:-$USER}"

echo "==> System update & base tools"
sudo dnf -y upgrade
sudo dnf -y install curl git dnf-plugins-core

# ---------- RPM Fusion (for VLC/codecs) ----------
echo "==> Enabling RPM Fusion (Free + Nonfree)"
REL=$(rpm -E %fedora)
sudo dnf -y install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${REL}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${REL}.noarch.rpm" || true

# ---------- Enable COPRs ----------
echo "==> Enabling COPRs"
if [[ -s "$LISTS/copr.txt" ]]; then
  while read -r copr; do
    [[ -z "$copr" ]] && continue
    sudo dnf -y copr enable "$copr" || true
  done < "$LISTS/copr.txt"
fi

# ---------- Conditional third-party repos ----------
echo "==> Enabling third-party repos"
# Brave
if grep -qx 'brave-browser' "$LISTS/dnf.txt"; then
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
if grep -qx 'google-chrome-stable' "$LISTS/dnf.txt"; then
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

# ---- Docker CE repo (DNF4/5 compatible) ----
needs_docker_repo=false
for pkg in docker-ce docker-ce-cli containerd.io; do
  if grep -qx "$pkg" "$LISTS/dnf.txt"; then needs_docker_repo=true; break; fi
done

if $needs_docker_repo; then
  if ! sudo dnf repolist 2>/dev/null | grep -q 'docker-ce-stable'; then
    if dnf --version 2>/dev/null | head -1 | grep -qi 'dnf5'; then
      # DNF5 path
      sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    else
      # DNF4 path
      sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    fi
  fi
fi

# ---------- Install DNF packages ----------
echo "==> Installing DNF packages"
if [[ -s "$LISTS/dnf.txt" ]]; then
  mapfile -t DNF_PKGS < <(grep -vE '^\s*(#|$)' "$LISTS/dnf.txt")
  if ((${#DNF_PKGS[@]})); then
    sudo dnf -y install "${DNF_PKGS[@]}" || true
  fi
fi

# ---------- Enable Docker if installed ----------
echo "==> Enabling Docker service"
if command -v docker >/dev/null 2>&1; then
  sudo systemctl enable --now docker || true
  sudo usermod -aG docker "$ME" || true
fi

# ---------- Install Flatpak remotes ----------
echo "==> Installing Flatpak remotes"
if [[ -s "$LISTS/flatpak-remotes.txt" ]]; then
  while read -r name url; do
    [[ -z "${name:-}" || -z "${url:-}" ]] && continue
    if ! flatpak remotes --columns=name | grep -qx "$name"; then
      flatpak remote-add --if-not-exists "$name" "$url"
    fi
  done < "$LISTS/flatpak-remotes.txt"
fi

# ---------- Install Flatpaks ----------
echo "==> Installing Flatpak apps"
if [[ -s "$LISTS/flatpak.txt" ]]; then
  while read -r app origin; do
    [[ -z "${app:-}" ]] && continue
    flatpak install -y "${origin:-flathub}" "$app" || true
  done < "$LISTS/flatpak.txt"
fi

# ---------- Install global NPM packages ----------
echo "==> Installing global NPM packages"
if [[ -s "$LISTS/npm-global.txt" ]]; then
  if command -v npm >/dev/null 2>&1; then
    while read -r pkg; do
      [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
      sudo -u "$ME" npm install -g "$pkg" || true
    done < "$LISTS/npm-global.txt"
  else
    echo "npm not found; skipping npm-global.txt"
  fi
fi

# Install Synth-shell
cd ~/Downlaods
git clone --recursive https://github.com/andresgongora/synth-shell.git
cd synth-shell
chmod 700 ./setup.sh
./setup.sh
cd ~/Downloads/
rm -rf synth-shell


# Completion message
cat <<'DONE'

✅ Bootstrap finished.

- Hyprland & its stack are installed (Hyprpaper, Hyprlock, Waybar, etc.)
- Docker installed and enabled. Add yourself to the docker group.
- Browsers: Brave and Google Chrome installed.
- Obsidian & Anki via Flatpak.
- AGS installed globally via npm if listed.
- Log out/in to pick up Docker group changes.

Re-run this script any time; it's idempotent.

DONE
