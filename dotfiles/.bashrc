# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH:$HOME/.local/bin/flutter/bin/:$HOME/.local/bin/cmdline-tools/bin"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

source ~/.git-prompt.sh

# Colors
MINT='\[\e[38;5;108m\]'      # path
BLUE='\[\e[38;5;75m\]'       # git: and ()
BOLDRED='\[\e[1;38;5;174m\]' # branch (bold red)
BAD='\[\e[38;5;196m\]'       # dirty indicator
RESET='\[\e[0m\]'

# Git helpers
git_branch() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
}

git_dirty() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  if ! git diff --quiet --ignore-submodules -- 2>/dev/null || \
     ! git diff --cached --quiet --ignore-submodules -- 2>/dev/null; then
    printf " ✗"
  fi
}

# Final PS1
PS1="${MINT}\w${RESET}$(git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    && printf " ${BLUE}git:${RESET}${BLUE}(${BOLDRED}$(git_branch)${BLUE})${RESET}${BAD}$(git_dirty)${RESET}") "



export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
export FLUTTER_HOME="$HOME/.local/bin/flutter"
export PATH="$FLUTTER_HOME/bin:$PATH"
