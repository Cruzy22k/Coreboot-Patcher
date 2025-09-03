#!/bin/bash
set -euo pipefail # fail on any error
SCRIPT_VER=3.05.0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" 
DATA_DIR="$SCRIPT_DIR"
TOOLS_DIR="$(mktemp -d "${SCRIPT_DIR}/.tools.XXXXXXXXXX")"
export PATH="$TOOLS_DIR:$PATH"
trap 'rm -rf "$TOOLS_DIR"' EXIT
cp coreboot.rom coreboot.rom.bak
## This script takes the data from a backed up rom, and injects it into a mrchromebox rom. It includes hwid and vpd.
## Created with ♡ by cruzy, based on https://docs.mrchromebox.tech/docs/firmware/manual-flashing.html 



downloader() {
    echo "Downloading supporting packages"
    mkdir -p "$TOOLS_DIR"
    download_util() {
        local name="$1"
        local url="$2"
        
        echo "Checking for '$name'..."
        if [[ -x "$TOOLS_DIR/$name" ]]; then
            echo "'$name' already exists"
            return
        fi
        echo "Downloading '$name'..."
        cd "$TOOLS_DIR"
        if ! { wget --quiet --show-progress -O "$name.tar.gz" "$url" && tar -zxf "$name.tar.gz" && chmod +x "$name"; }; then
            echo -e "\e[31mError: Failed to download or set up '$name'. Please check your internet connection.\e[0m" >&2
            exit 1
        fi
        cd "$SCRIPT_DIR" # back to main
        echo -e "\e[32mSuccessfully set up '$name'.\e[0m"
    }

    download_util "flashrom" "https://mrchromebox.tech/files/util/flashrom_ups_libpci37_20240418.tar.gz"
    download_util "cbfstool" "https://mrchromebox.tech/files/util/cbfstool.tar.gz"
    download_util "gbb_utility" "https://mrchromebox.tech/files/util/gbb_utility.tar.gz"
    
    echo -e "\n\e[32mAll required utilities are ready.\e[0m"
    clear
    sleep 1
    clear # why tf won't it clear?
    
}
print_help() {
    cat <<EOF
Coreboot-Patcher (version $SCRIPT_VER)

This script injects hwid and vital product data from a backup rom into a mrchromebox coreboot rom.

Usage:
  ${0##*/} [options]

Options:
  -h, --help  View this help message

Make sure 'backup.rom' and 'coreboot.rom' are present in the script's directory.
EOF
}
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo -e "\e[31mUnknown option '$arg'.\e[0m" >&2
            echo "Use -h or --help for usage"
            exit 1
            ;;
    esac
done

inject_data() { 
    echo "Extracting RO_VPD from backup.rom..."
    cbfstool backup.rom read -r RO_VPD -f vpd.bin || { echo -e "\e[31mError: RO_VPD extraction failed!\e[0m" >&2; exit 1; }
    
    echo "Injecting RO_VPD into coreboot.rom..."
    cbfstool coreboot.rom write -r RO_VPD -f vpd.bin || { echo -e "\e[31mError: RO_VPD injection failed!\e[0m" >&2; exit 1; }
    
    echo -e "\e[32mSuccessfully transferred RO_VPD.\e[0m"


    echo "Attempting to add HWID"
    # First, try extracting HWID from mrchromebox backup
    if cbfstool backup.rom extract -n hwid -f hwid.txt 2>/dev/null; then
        echo "HWID found as a file in backup.rom. Injecting into new rom"
        cbfstool coreboot.rom add -n hwid -f hwid.txt -t raw || { echo -e "\e[31mError: Coreboot hwid injection failed!\e[0m" >&2; exit 1; }
        echo -e "\e[32mSuccessfully added your HWID.\e[0m"
    else
        # fallback is gbb extract
        echo "HWID file not found. Falling back to GBB Utility"
        gbb_utility backup.rom --get --hwid > hwid.txt || { echo -e "\e[31mError: Failed to extract hwid with gbb tool \e[0m" >&2; exit 1; }
        echo "Injecting gbb hwid into new rom"
        cbfstool coreboot.rom add -n hwid -f hwid.txt -t raw || { echo -e "\e[31mError: Stock firmware hwid injection failed!\e[0m" >&2; exit 1; }
        echo -e "\e[32mSuccessfully injected stock firmware hwid.\e[0m"
    fi
}

check_files() {
    if [[ ! -f "backup.rom" || ! -f "coreboot.rom" ]]; then
        echo -e "\e[31mError: Missing required files!\e[0m" >&2
        echo "Please make sure 'backup.rom ( your backup, probably made before you installed uefi full rom)' and 'coreboot.rom ( an empty coreboot uefi downloaded from https://github.com/MrChromebox/scripts/blob/main/sources.sh)' are present in the script's directory:" >&2
        echo "$DATA_DIR" >&2
        exit 1
    fi
    echo -e "\e[32mFound backup.rom and coreboot.rom.\e[0m"
    echo "Make sure that both of these files are the correct files for your device."
}

main() {
    cd "$DATA_DIR"
    clear
    check_files
    downloader
    echo "Coreboot patcher"
    echo "version: $SCRIPT_VER"
    echo -e "\e[32m---------------------------------------------------------------\e[0m"
    echo "This script injects HWID and VPD from a backup ROM into a MrChromebox ROM."
    echo ""
    echo -e "\e[32m<Coreboot Patcher>  Copyleft (C) 2024  Cruzy22k\e[0m"
    echo -e "\e[32mThis program comes with ABSOLUTELY NO WARRANTY.\e[0m"
    echo -e "This is free software, and you are welcome to redistribute it.\e[0m"
    inject_data
    
    echo "Your new rom 'modified_coreboot.rom' has been successfully injected!."
    echo -e "\nThe next step is to flash the modified ROM."
    echo "Proceeding with flashing. Ensure this is the correct machine!"
    echo -e "To flash your custom firmware run the following commands: "

    echo -e "\e[32mAMD devices: sudo ./flashrom -p internal -w coreboot.rom\e[0m"
    echo -e "\e[32mIntel devices: sudo ./flashrom -p internal --ifd -i bios -w coreboot.rom -N\e[0m"
    echo ""
    echo -e "Made with ♡ by Cruzy22k" 
    echo ":3"
    # cleanup
    mv coreboot.rom modified_coreboot.rom
    sudo rm vpd.bin && sudo rm hwid.txt
}

main














