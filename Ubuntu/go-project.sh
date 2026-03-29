#!/bin/bash

# [ go-project.sh ] 🇮🇩 Versi Bahasa Indonesia
# Scaffolder Project Profesional untuk Developer Indonesia
# Fitur: Arrow-key selection, placeholder input, & robust validation.

# --- UTILITAS ---

# Validasi nama project (huruf, angka, dash, underscore)
validate_project_name() {
    local name=$1
    if [[ -z "$name" ]]; then
        echo -e "${RED}Eror: Nama project tidak boleh kosong.${RESET}"
        return 1
    fi
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${RED}Eror: Nama project hanya boleh berisi huruf, angka, dash (-), dan underscore (_).${RESET}"
        return 1
    fi
    if [[ -d "$name" ]]; then
        echo -e "${RED}Eror: Folder '$name' sudah ada. Silakan pilih nama lain.${RESET}"
        return 1
    fi
    return 0
}

# Cek versi Node.js
check_node_version() {
    local min_version=$1
    if command -v node &> /dev/null; then
        local current_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$current_version" -lt "$min_version" ]; then
            echo -e "${YELLOW}Peringatan: Framework ini memerlukan Node.js versi $min_version+. (Versi Anda: v$current_version)${RESET}"
            read -p "Tetap lanjutkan? (y/n): " cont
            [[ "$cont" =~ ^[Yy]$ ]] || return 1
        fi
    fi
    return 0
}

# Cek & Instal Dependensi Otomatis
check_and_install_dependency() {
    local dep=$1
    local install_cmd=$2
    local desc=$3
    
    if ! command -v "$dep" &> /dev/null; then
        echo -e "${RED}Dependensi Hilang: $desc ($dep) belum terinstall.${RESET}"
        read -p "Ingin menginstall $dep sekarang via sudo apt? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Sedang menginstall $dep... Mohon tunggu.${RESET}"
            sudo apt update && eval "$install_cmd"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ $dep berhasil terinstall!${RESET}"
                return 0
            else
                echo -e "${RED}✗ Gagal menginstall $dep. Periksa koneksi internet atau hak akses sudo Anda.${RESET}"
                return 1
            fi
        else
            echo -e "${RED}Proses dibatalkan. Project gagal dibuat.${RESET}"
            return 1
        fi
    fi
    return 0
}

# --- MENU INTERAKTIF (PANAH) ---

select_option() {
    local options=("$@")
    local current_index=0
    local options_count=${#options[@]}
    local key=""

    tput civis # Sembunyikan kursor
    trap "tput cnorm; echo; exit" INT TERM # Kembalikan kursor jika dibatalkan (Ctrl+C)

    while true; do
        echo -e "${YELLOW}Gunakan Panah Atas/Bawah & Enter untuk memilih:${RESET}"
        for i in "${!options[@]}"; do
            if [ "$i" -eq "$current_index" ]; then
                echo -e " ${CYAN}➜ [ ${WHITE}${options[$i]}${CYAN} ]${RESET}"
            else
                echo -e "   ${options[$i]}"
            fi
        done

        IFS= read -rsn3 key
        case "$key" in
            $'\e[A') ((current_index--)); [ "$current_index" -lt 0 ] && current_index=$((options_count - 1)) ;;
            $'\e[B') ((current_index++)); [ "$current_index" -ge "$options_count" ] && current_index=0 ;;
            "") break ;;
        esac

        tput cuu $((options_count + 1))
        tput ed
    done

    tput cnorm # Tampilkan kursor kembali
    return "$current_index"
}

# --- LOGIKA UTAMA ---

go-project() {
    echo -e "${MAGENTA}╔══════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}║${YELLOW}        ULTIMATE PROJECT SCAFFOLDER         ${MAGENTA}║${RESET}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════╝${RESET}"

    local frameworks=("Nuxt.js (Vue)" "Next.js (React)" "Angular (Google)" "Laravel (PHP)" "Keluar")
    select_option "${frameworks[@]}"
    local choice=$?

    case $choice in
        0|1|2) # Framework berbasis Node.js
            if check_and_install_dependency "npm" "sudo apt install -y nodejs npm" "Node.js & NPM"; then
                check_node_version 18 || return
                # Input dengan Default Value (Lebih stabil dari placeholder)
                while true; do
                    echo -en "${CYAN}Nama Project (Default: my-app): ${RESET}"
                    read p_name
                    p_name=${p_name:-my-app} # Jika kosong, pakai my-app
                    validate_project_name "$p_name" && break
                done

                case $choice in
                    0) echo -e "${CYAN}Memulai instalasi Nuxt...${RESET}"; npx nuxi@latest init "$p_name" ;;
                    1) echo -e "${CYAN}Memulai instalasi Next.js...${RESET}"; npx create-next-app@latest "$p_name" ;;
                    2) echo -e "${CYAN}Memulai instalasi Angular...${RESET}"; npx @angular/cli new "$p_name" ;;
                esac
                
                if [ $? -eq 0 ]; then
                    echo -e "\n${GREEN}✨ Berhasil! Jalankan 'cd $p_name' untuk mulai coding.${RESET}"
                fi
            fi
            ;;
        3) # Laravel berbasis PHP
            if check_and_install_dependency "composer" "sudo apt install -y composer php-xml php-curl php-zip" "PHP Composer"; then
                while true; do
                    echo -en "${CYAN}Nama Project (Default: laravel-app): ${RESET}"
                    read p_name
                    p_name=${p_name:-laravel-app} # Jika kosong, pakai laravel-app
                    validate_project_name "$p_name" && break
                done

                echo -e "${CYAN}Memulai instalasi Laravel via Composer...${RESET}"
                composer create-project laravel/laravel "$p_name"
                
                if [ $? -eq 0 ]; then
                    echo -e "\n${GREEN}✨ Berhasil! Jalankan 'cd $p_name' untuk mulai coding.${RESET}"
                fi
            fi
            ;;
        4) echo -e "${CYAN}Sampai jumpa!${RESET}"; return ;;
    esac
}
