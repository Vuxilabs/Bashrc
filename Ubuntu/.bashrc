# ~/.bashrc - POWER FULL CLI CONFIGURATION
# Optimized for Speed, Productivity, and Aesthetics

# [1] SHELL OPTIONS
# ------------------------------------------------------------------------------
shopt -s histappend           # Append to history instead of overwriting
shopt -s checkwinsize         # Update window size after each command
shopt -s globstar             # Support ** globbing
shopt -s autocd               # Allow typing directory name to cd into it
shopt -s cdspell              # Correct minor typos in cd

# [2] HISTORY MANAGEMENT
# ------------------------------------------------------------------------------
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth        # Ignore duplicates and space-prefixed commands
export HISTIGNORE="ls:cd:exit:pwd:clear"
# Shared history across multiple terminals
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

# [3] COLORS & STYLING
# ------------------------------------------------------------------------------
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagacad

# Define standard colors (Raw escape sequences for echo and PS1)
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
MAGENTA="\e[1;35m"
CYAN="\e[1;36m"
WHITE="\e[1;37m"
RESET="\e[0m"

# [4] POWERFUL PROMPT (PS1)
# ------------------------------------------------------------------------------
# Function to get git branch with status color
parse_git_branch() {
    local branch=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
    if [ -n "$branch" ]; then
        local status=$(git status --porcelain 2>/dev/null)
        if [ -n "$status" ]; then
            echo -e "${RED}($branch*)${RESET}"  # Dirty
        else
            echo -e "${GREEN}($branch)${RESET}" # Clean
        fi
    fi
}

# ┌──(User@Host)─[Time]─(Path)
# └─(git_branch)$
# Use \[ \] only inside PS1 for non-printing characters
PS1="\n\[${CYAN}\]┌──(\[${GREEN}\]\u@\h\[${CYAN}\])─[\[${WHITE}\]\t\[${CYAN}\]]─(\[${YELLOW}\]\w\[${CYAN}\])\n\[${CYAN}\]└─ \$(parse_git_branch)\$ \[${RESET}\]"

# [5] ALIASES - THE SPEED DEMON
# ------------------------------------------------------------------------------
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Enhanced ls
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Utils
alias clr='clear'
alias q='exit'
alias h='history'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -m'
alias path='echo -e ${PATH//:/\\n}' # Show PATH in list format

# Quick System Commands
alias ports='netstat -tulanp'
alias myip='curl -s https://ifconfig.me && echo ""'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3'

# [6] FUNCTIONS - THE POWERHOUSE
# ------------------------------------------------------------------------------
# Create directory and enter it immediately
mcd() {
    mkdir -p "$1" && cd "$1"
}

# Smart Archive Extraction
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick Search in current directory
f() {
    find . -iname "*$1*"
}

# Show RAM usage by process
mem-usage() {
    ps aux | sort -rnk 4 | head -n 15
}

# [7] CUSTOM COMMANDS (SIMPLE CLI)
# ------------------------------------------------------------------------------
# Dashboard / Menu (Artisan Style)
menu() {
    echo -e "${YELLOW}Usage:${RESET}"
    echo -e "  command [options] [arguments]\n"
    
    echo -e "${YELLOW}Available Commands:${RESET}"

    echo -e " ${GREEN}menu${RESET}             Tampilkan menu bantuan ini (mirip artisan)"
    echo -e " ${GREEN}sysinfo${RESET}          Tampilkan rincian statistik sistem"
    echo -e " ${GREEN}go-project${RESET}       Inisialisasi project baru (Nuxt, Next, Laravel, dll)"
    
    echo -e "\n${YELLOW}Navigation:${RESET}"
    echo -e " ${GREEN}.. , ... , ....${RESET}  Naik 1, 2, atau 3 level direktori"
    echo -e " ${GREEN}-${RESET}               Kembali ke direktori sebelumnya"
    echo -e " ${GREEN}mcd [dir]${RESET}        Buat direktori baru dan langsung masuk"

    echo -e "\n${YELLOW}Files & Search:${RESET}"
    echo -e " ${GREEN}ll${RESET}               Lihat rincian file (alias untuk ls -lah)"
    echo -e " ${GREEN}la${RESET}               Lihat semua file termasuk yang tersembunyi"
    echo -e " ${GREEN}f [nama]${RESET}         Cari file berdasarkan nama di folder aktif"
    echo -e " ${GREEN}extract [file]${RESET}   Ekstrak otomatis berbagai format arsip"
    
    echo -e "\n${YELLOW}System & Network:${RESET}"
    echo -e " ${GREEN}mem-usage${RESET}        Tampilkan proses yang memakan RAM terbanyak"
    echo -e " ${GREEN}ports${RESET}            Tampilkan semua port yang terbuka"
    echo -e " ${GREEN}myip${RESET}             Tampilkan alamat IP publik Anda"
    echo -e " ${GREEN}speedtest${RESET}        Cek kecepatan koneksi internet"
    
    echo -e "\n${YELLOW}Utility:${RESET}"
    echo -e " ${GREEN}c${RESET}                Bersihkan layar terminal (clear)"
    echo -e " ${GREEN}h${RESET}                Tampilkan riwayat perintah (history)"
    echo -e " ${GREEN}path${RESET}             Tampilkan list path sistem Anda"
    echo -e " ${GREEN}q${RESET}                Keluar dari sesi terminal (exit)"
    echo ""
}

# System stats overview
sysinfo() {
    echo -e "${MAGENTA}╔══════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}║${YELLOW}  System Summary for ${WHITE}$(hostname)${YELLOW}                     ${MAGENTA}║${RESET}"
    echo -e "${MAGENTA}╠══════════════════════════════════════════════╝${RESET}"
    echo -e "${CYAN}  OS:      ${WHITE}$(uname -sr)"
    echo -e "${CYAN}  Uptime:  ${WHITE}$(uptime -p)"
    echo -e "${CYAN}  Users:   ${WHITE}$(who | wc -l)"
    echo -e "${CYAN}  Memory:  ${WHITE}$(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "${CYAN}  Load:    ${WHITE}$(cat /proc/loadavg | awk '{print $1" "$2" "$3}')"
    echo -e "${CYAN}  IP Info: ${WHITE}$(hostname -I | awk '{print $1}')"
}

# [8] AUTO-COMPLETION
# ------------------------------------------------------------------------------
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# [9] WELCOME MESSAGE (AESTHETICS)
# ------------------------------------------------------------------------------
# clear
echo -e "${BLUE}"
echo "██    ██ ██   ██      ██████  ██      ██"
echo "██    ██  ██ ██      ██       ██      ██"
echo "██    ██   ███       ██       ██      ██"
echo "██    ██  ██ ██      ██       ██      ██"
echo " ██████  ██   ██      ██████  ███████ ██"
echo "            Version 1.0.2 Updates 🚀                   "
echo -e "${RESET}"
echo -e "${GREEN}Halo \u, selamat datang di CLI buatanmu sendiri!${RESET}"
echo -e "${YELLOW}Ketik ${WHITE}'menu'${YELLOW} untuk melihat semua perintah atau ${WHITE}'sysinfo'${YELLOW} untuk status.${RESET}"
echo ""

# Integrasi Modul Baru
if [ -f "$(dirname "$BASH_SOURCE")/go-project.sh" ]; then
    source "$(dirname "$BASH_SOURCE")/go-project.sh"
fi

# Tambahkan NVM jika ada (dari bash original)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"