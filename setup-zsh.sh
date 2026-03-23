#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║       BLACKARCH ZSH SETUP — INSTALLER & SHELL SWITCHER                 ║
# ║       Installs zsh, plugins, tools, deploys .zshrc, sets default shell ║
# ╚══════════════════════════════════════════════════════════════════════════╝
# Usage:
#   chmod +x setup-zsh.sh
#   ./setup-zsh.sh          → interactive (asks before each step)
#   ./setup-zsh.sh --yes    → non-interactive (auto-confirm everything)
#   ./setup-zsh.sh --help   → show help
# ──────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── colours ─────────────────────────────────────────────────────────────
R='\033[1;196m'; G='\033[1;82m'; C='\033[1;51m'; Y='\033[1;226m'
M='\033[1;207m'; D='\033[0;245m'; B='\033[1;255m'; X='\033[0m'
OK="${G}[+]${X}"; INFO="${C}[*]${X}"; WARN="${Y}[!]${X}"; ERR="${R}[-]${X}"

# ── script path (so we find .zshrc in same dir) ──────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_SRC="${SCRIPT_DIR}/.zshrc"

# ── config ───────────────────────────────────────────────────────────────
YES_MODE=false
SKIP_TOOLS=false
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(eval echo "~$TARGET_USER")
LOG_FILE="/tmp/zsh-setup-$(date +%F-%H%M%S).log"

# ── parse args ───────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --yes|-y)       YES_MODE=true ;;
    --skip-tools)   SKIP_TOOLS=true ;;
    --help|-h)
      echo ""
      echo "  ${B}BlackArch ZSH Setup${X}"
      echo ""
      echo "  Usage: $0 [options]"
      echo ""
      echo "  Options:"
      printf "    ${C}%-20s${X} %s\n" "--yes, -y"       "Auto-confirm all prompts"
      printf "    ${C}%-20s${X} %s\n" "--skip-tools"    "Skip optional tool installs"
      printf "    ${C}%-20s${X} %s\n" "--help, -h"      "Show this help"
      echo ""
      exit 0 ;;
  esac
done

# ── helpers ──────────────────────────────────────────────────────────────
log()    { echo -e "$*" | tee -a "$LOG_FILE"; }
info()   { log "${INFO} $*"; }
ok()     { log "${OK}  $*"; }
warn()   { log "${WARN} $*"; }
err()    { log "${ERR}  $*"; exit 1; }
section(){ echo -e "\n${D}══════════════════════════════════════════════════${X}"; log "  ${M}◆${X} ${B}$*${X}"; echo -e "${D}══════════════════════════════════════════════════${X}\n"; }

ask() {
  # ask <question> → returns 0 (yes) or 1 (no)
  $YES_MODE && return 0
  echo -ne "${Y}[?]${X} $* [Y/n] "
  read -r ans
  [[ "${ans,,}" =~ ^(y|yes|)$ ]]
}

need_root() {
  [[ $EUID -eq 0 ]] || err "This step needs root. Re-run with sudo or use --yes as root."
}

pkg_installed() { pacman -Q "$1" &>/dev/null; }

pacman_install() {
  local pkgs=("$@")
  local to_install=()
  for p in "${pkgs[@]}"; do
    pkg_installed "$p" || to_install+=("$p")
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    info "Installing: ${to_install[*]}"
    sudo pacman -S --noconfirm --needed "${to_install[@]}" 2>&1 | tee -a "$LOG_FILE"
  else
    ok "Already installed: ${pkgs[*]}"
  fi
}

yay_install() {
  local pkgs=("$@")
  local to_install=()
  for p in "${pkgs[@]}"; do
    pkg_installed "$p" || to_install+=("$p")
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    info "AUR install: ${to_install[*]}"
    if command -v yay &>/dev/null; then
      yay -S --noconfirm --needed "${to_install[@]}" 2>&1 | tee -a "$LOG_FILE"
    elif command -v paru &>/dev/null; then
      paru -S --noconfirm --needed "${to_install[@]}" 2>&1 | tee -a "$LOG_FILE"
    else
      warn "No AUR helper found (yay/paru). Skipping: ${to_install[*]}"
    fi
  else
    ok "Already installed: ${pkgs[*]}"
  fi
}

# ── banner ───────────────────────────────────────────────────────────────
clear
echo -e "
  ${R}▓▒░${X} ${B}BLACKARCH ZSH SETUP${X} ${D}─────────────────────────────────────────${X}
  ${D}Target user   :${X} ${G}${TARGET_USER}${X}
  ${D}Target home   :${X} ${G}${TARGET_HOME}${X}
  ${D}Log file      :${X} ${G}${LOG_FILE}${X}
  ${D}Auto-confirm  :${X} ${G}${YES_MODE}${X}
  ${D}Skip tools    :${X} ${G}${SKIP_TOOLS}${X}
  ${D}─────────────────────────────────────────────────────────────────${X}
"

# ══════════════════════════════════════════════════════════════════════════
# STEP 1 — Install ZSH
# ══════════════════════════════════════════════════════════════════════════
section "STEP 1 — Install ZSH"

if pkg_installed zsh; then
  ok "zsh is already installed: $(zsh --version)"
else
  if ask "Install zsh?"; then
    need_root
    pacman_install zsh
    ok "zsh installed: $(zsh --version)"
  else
    warn "Skipping zsh install — rest of setup may fail"
  fi
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 2 — Install ZSH plugins (pacman)
# ══════════════════════════════════════════════════════════════════════════
section "STEP 2 — ZSH Plugins"

PLUGINS=(
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-completions
)

if ask "Install zsh plugins via pacman? (syntax-highlighting, autosuggestions, history-search, completions)"; then
  need_root
  pacman_install "${PLUGINS[@]}"
  ok "ZSH plugins installed"
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 3 — Install core terminal tools
# ══════════════════════════════════════════════════════════════════════════
section "STEP 3 — Core Terminal Tools"

CORE_TOOLS=(
  bat          # better cat
  eza          # better ls (eza, replaces exa)
  fd           # better find
  ripgrep      # better grep
  fzf          # fuzzy finder
  zoxide       # smarter cd
  tmux         # terminal multiplexer
  neovim       # editor
  wget
  curl
  git
  tree
  jq           # JSON processor
  python-pip
  python-ipdb
  rlwrap
  socat
  netcat       # traditional netcat
  ncat         # nmap's netcat
  inetutils    # for hostname etc
  whois
  dnsutils
  tldr         # quick man pages
  direnv       # per-project envs
  rsync
)

if ask "Install core terminal tools? (bat, eza, fd, ripgrep, fzf, zoxide, tmux, nvim, ...)"; then
  need_root
  pacman_install "${CORE_TOOLS[@]}"
  ok "Core tools installed"
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 4 — Install pentesting tools (pacman)
# ══════════════════════════════════════════════════════════════════════════
section "STEP 4 — Pentesting Tools"

PENTEST_TOOLS=(
  nmap
  masscan
  gobuster
  ffuf
  feroxbuster
  nikto
  sqlmap
  hydra
  hashcat
  john
  aircrack-ng
  responder
  impacket
  evil-winrm
  bloodhound
  neo4j
  metasploit
  burpsuite
  wireshark-qt
  tcpdump
  netdiscover
  arp-scan
  smbclient
  enum4linux
  crackmapexec
  wordlists
)

if ask "Install pentesting tools via pacman? (nmap, gobuster, ffuf, hydra, hashcat, metasploit, ...)"; then
  need_root
  # Install available ones, skip missing
  for pkg in "${PENTEST_TOOLS[@]}"; do
    if pkg_installed "$pkg"; then
      info "  already installed: $pkg"
    else
      sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null && ok "  installed: $pkg" || warn "  not found in repos: $pkg (install manually)"
    fi
  done
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 5 — Install optional Go / Python tools
# ══════════════════════════════════════════════════════════════════════════
section "STEP 5 — Optional Tools (Go, Python)"

if ! $SKIP_TOOLS; then

  # Go tools
  if command -v go &>/dev/null && ask "Install Go-based recon tools? (subfinder, httpx, nuclei, amass)"; then
    info "Installing Go tools..."
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest  2>&1 | tail -1
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest             2>&1 | tail -1
    go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest        2>&1 | tail -1
    go install github.com/owasp-amass/amass/v4/...@master                     2>&1 | tail -1
    ok "Go tools installed → $HOME/go/bin/"
  fi

  # Python tools
  if command -v pip &>/dev/null && ask "Install Python pentest tools? (impacket extras, updog, bloodhound-python, certipy)"; then
    pip install --quiet --break-system-packages \
      bloodhound \
      certipy-ad \
      updog \
      pyinstaller \
      pwntools \
      2>&1 | tail -5
    ok "Python tools installed"
  fi

else
  info "Skipping optional tools (--skip-tools)"
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 6 — Create directory structure
# ══════════════════════════════════════════════════════════════════════════
section "STEP 6 — Create Operator Directory Structure"

DIRS=(
  "$TARGET_HOME/tools"
  "$TARGET_HOME/payloads"
  "$TARGET_HOME/engagements"
  "$TARGET_HOME/loot"
  "$TARGET_HOME/wordlists"
  "$TARGET_HOME/.zsh/cache"
)

if ask "Create operator directories? (~/tools, ~/payloads, ~/engagements, ~/loot)"; then
  for d in "${DIRS[@]}"; do
    mkdir -p "$d"
    ok "  $d"
  done
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 7 — Deploy .zshrc
# ══════════════════════════════════════════════════════════════════════════
section "STEP 7 — Deploy .zshrc"

ZSHRC_DEST="$TARGET_HOME/.zshrc"

if [[ ! -f "$ZSHRC_SRC" ]]; then
  warn ".zshrc not found at $ZSHRC_SRC"
  warn "Make sure .zshrc is in the same directory as this script"
else
  if ask "Deploy .zshrc to $ZSHRC_DEST?"; then
    # Backup existing
    if [[ -f "$ZSHRC_DEST" ]]; then
      BAK="${ZSHRC_DEST}.bak.$(date +%F-%H%M%S)"
      cp "$ZSHRC_DEST" "$BAK"
      warn "Backed up existing .zshrc → $BAK"
    fi

    cp "$ZSHRC_SRC" "$ZSHRC_DEST"

    # Fix ownership if running as root for another user
    if [[ $EUID -eq 0 && "$TARGET_USER" != "root" ]]; then
      chown "$TARGET_USER:$TARGET_USER" "$ZSHRC_DEST"
    fi

    ok ".zshrc deployed → $ZSHRC_DEST"
  fi
fi

# Create empty .zshrc.local if it doesn't exist
if [[ ! -f "$TARGET_HOME/.zshrc.local" ]]; then
  cat > "$TARGET_HOME/.zshrc.local" <<'EOF'
# ── LOCAL OVERRIDES ──────────────────────────────────────────
# Machine-specific settings, API keys, VPN aliases
# This file is sourced at the end of .zshrc
# Never commit this file to git
# ─────────────────────────────────────────────────────────────

# Example:
# export SHODAN_API_KEY="your_key_here"
# export VPN_CONFIG="$HOME/vpn/htb.ovpn"
# alias vpn-htb='sudo openvpn $VPN_CONFIG &'
# alias vpn-off='sudo pkill openvpn'
EOF
  ok "Created empty ~/.zshrc.local (for secrets / local overrides)"
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 8 — tmux config
# ══════════════════════════════════════════════════════════════════════════
section "STEP 8 — tmux Config"

TMUX_CONF="$TARGET_HOME/.tmux.conf"

if ask "Install a clean tmux config? (status bar, mouse support, vim keys)"; then
  cat > "$TMUX_CONF" <<'TMUX'
# ── tmux config ────────────────────────────────────────────────
set -g default-terminal "xterm-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
set -g history-limit 50000
set -g mouse on
set -sg escape-time 0
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Prefix → Ctrl+A (like screen)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Split panes
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# Pane navigation (vim-style)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Pane resize
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded"

# Copy mode (vim keys)
setw -g mode-keys vi
bind v copy-mode
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-and-cancel

# ── Status bar ────────────────────────────────────────────────
set -g status on
set -g status-interval 5
set -g status-position bottom
set -g status-style "bg=#1a1a2e,fg=#f8f8f2"
set -g status-left-length 40
set -g status-right-length 80

set -g status-left "#[fg=#50fa7b,bold]⬡ #S #[fg=#6272a4]│ "
set -g status-right "#[fg=#6272a4]│ #[fg=#ffb86c]%a %d %b #[fg=#6272a4]│ #[fg=#50fa7b,bold]%H:%M #[fg=#6272a4]│ #[fg=#8be9fd]#h"

setw -g window-status-format         "#[fg=#6272a4] #I:#W "
setw -g window-status-current-format "#[fg=#ff79c6,bold,bg=#282a36] #I:#W #[bg=#1a1a2e]"

# Pane borders
set -g pane-border-style        "fg=#3d3d5c"
set -g pane-active-border-style "fg=#ff79c6"

# Message style
set -g message-style "fg=#f8f8f2,bg=#ff79c6,bold"
TMUX
  ok "tmux config written → $TMUX_CONF"
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 9 — Set ZSH as default shell
# ══════════════════════════════════════════════════════════════════════════
section "STEP 9 — Set ZSH as Default Shell"

ZSH_PATH=$(command -v zsh 2>/dev/null || echo "/usr/bin/zsh")
CURRENT_SHELL=$(getent passwd "$TARGET_USER" | cut -d: -f7)

info "Current shell for $TARGET_USER: $CURRENT_SHELL"
info "ZSH binary: $ZSH_PATH"

if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
  ok "ZSH is already the default shell for $TARGET_USER"
else
  if ask "Set $ZSH_PATH as default shell for $TARGET_USER?"; then
    # Make sure zsh is in /etc/shells
    if ! grep -q "$ZSH_PATH" /etc/shells; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
      info "Added $ZSH_PATH to /etc/shells"
    fi

    if [[ $EUID -eq 0 ]]; then
      chsh -s "$ZSH_PATH" "$TARGET_USER"
    else
      chsh -s "$ZSH_PATH"
    fi

    ok "Default shell changed to ZSH for $TARGET_USER"
    warn "Log out and back in (or run 'exec zsh') for the change to take effect"
  fi
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 10 — fzf keybindings setup
# ══════════════════════════════════════════════════════════════════════════
section "STEP 10 — fzf Keybindings"

if command -v fzf &>/dev/null; then
  # Arch installs fzf keybindings to /usr/share/fzf/
  if [[ ! -f /usr/share/fzf/key-bindings.zsh ]]; then
    if ask "Generate fzf keybindings via fzf --zsh?"; then
      fzf --zsh > "$TARGET_HOME/.fzf.zsh" 2>/dev/null || true
      ok "fzf bindings → ~/.fzf.zsh"
    fi
  else
    ok "fzf keybindings already at /usr/share/fzf/key-bindings.zsh"
  fi
else
  warn "fzf not found — install it first (step 3)"
fi

# ══════════════════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════════════════
echo ""
echo -e "  ${R}▓▒░${X} ${B}SETUP COMPLETE${X}"
echo -e "  ${D}═══════════════════════════════════════════════════════════${X}"
echo -e "  ${G}[+]${X} Log saved → ${C}${LOG_FILE}${X}"
echo ""
echo -e "  ${Y}Next steps:${X}"
echo -e "  ${D}1.${X} ${G}exec zsh${X}           — reload shell now"
echo -e "  ${D}2.${X} ${G}source ~/.zshrc${X}     — or just source the config"
echo -e "  ${D}3.${X} Edit ${G}~/.zshrc.local${X}   — add API keys, VPN aliases, etc."
echo -e "  ${D}4.${X} ${G}tmux${X}               — start a tmux session"
echo -e "  ${D}5.${X} ${G}help-rt${X}            — view red team quick reference"
echo ""
echo -e "  ${D}Installed plugins source paths:${X}"
echo -e "  ${D}  /usr/share/zsh/plugins/zsh-syntax-highlighting/${X}"
echo -e "  ${D}  /usr/share/zsh/plugins/zsh-autosuggestions/${X}"
echo -e "  ${D}  /usr/share/zsh/plugins/zsh-history-substring-search/${X}"
echo ""
