
SCRIPT_PATH="$(dirname $0)"
FILE_NAME=${1:-report.md}
OUTPUT_FILE="$SCRIPT_PATH/$FILE_NAME"

if [ $# -eq 0 ]
  then
    echo -e "Générer dans un fichier [\e[34m$FILE_NAME\e[0m] : "
    read -p " > " OUTPUT_FILE_SELECTED
    if [[ ! -z "$OUTPUT_FILE_SELECTED" ]] 
        then 
            OUTPUT_FILE=$SCRIPT_PATH$OUTPUT_FILE_SELECTED
    fi 
fi

OUTPUT_FILE_DATA=$SCRIPT_PATH/$(basename "$OUTPUT_FILE" ".md")".data"

echo "Chemin complet (report): $OUTPUT_FILE"
echo "Chemin complet:(data) $OUTPUT_FILE_DATA"
echo -n "" > "$OUTPUT_FILE_DATA"
echo -e "# Informations système\n" > "./$OUTPUT_FILE"
echo -n -e "Créé en $(date +%F-%H%M%S)\nBy user" >> "./$OUTPUT_FILE"
whoami >> "./$OUTPUT_FILE"
echo -e "" >> "./$OUTPUT_FILE"

I_AM=$(whoami)

COMMANDS_NO_AVAILABLE="## Commandes non disponibles\n\n"

function getInformation ()
{
    TITLE=$1
    CMD_NAME=$2
    CMD_LINE=${3:-$2}
    if [[ $I_AM != 'root' ]]; then
        CMD_LINE="sudo $CMD_LINE"
    fi
    VALUE="$($CMD_LINE 2> err.txt)"
    echo -n "- $TITLE " | sed -r 's/\\b\# //'
    echo -e "-- START $CMD_NAME" >> "$OUTPUT_FILE_DATA"
    if [[ $VALUE ]]; then
        echo -e "## $TITLE\n\n\`\`\`text\n$VALUE\n\`\`\`\n\n" >> "./$OUTPUT_FILE"
        echo -e "$VALUE" >> "$OUTPUT_FILE_DATA"
        echo -e "\e[32mok\e[0m"
    else
        echo -e "\e[31mX\e[0m"
        COMMANDS_NO_AVAILABLE+="- $CMD_NAME\n"
    fi
    echo -e "-- END $CMD_NAME" >> "$OUTPUT_FILE_DATA"
}

function getNotSudoInformation ()
{
    TITLE=$1
    CMD_NAME=$2
    CMD_LINE=${3:-$2}
    VALUE="$($CMD_LINE 2> err.txt)"
    echo -n "- $TITLE " | sed -r 's/\\b\# //'
    if [[ $VALUE ]]; then
        echo -e "## $TITLE\n\n\`\`\`text\n$VALUE\n\`\`\`\n\n" >> "./$OUTPUT_FILE"
        echo -e "\e[32mok\e[0m"
    else
        echo -e "\e[31mX\e[0m"
        COMMANDS_NO_AVAILABLE+="- $CMD_NAME\n"
    fi
}

# Bios
getInformation "Bios" 'dmidecode' 'dmidecode -q'

# Nom du système d'exploitation
getInformation "Informations d'utilisation actuelle" 'uname' "uname -a"
getInformation "\b# Dsitribution" 'dsitro' "cat /etc/os-release"

# Vérification de la configuration
getInformation "Vérification de la configuration" 'chkconfig'

# Récupération de la mémoire
getInformation "Récupération de la mémoire" 'free' "free -h"

# Informations d'utilisation actuelle
getInformation "Informations d'utilisation actuelle" 'top' "top -b -n 1"

# Liste des périphériques
getInformation "Liste des périphériques" 'lshw' "lshw -short"

# Informations détaillées sur le microprocesseur
getInformation "Informations détaillées sur le microprocesseur" 'lscpu'

# Informations sur le périphérique SCSI
getInformation "Informations sur le périphérique SCSI" 'lsscsi'

# Informations de partition
getInformation "Informations de partition" 'lsblk' "lsblk -f"

# Périphériques USB
getInformation "Périphériques USB" 'lsusb'

# Dispositifs PCI
getInformation "Dispositifs PCI" 'lspci'

# Appareils montés
getInformation "Appareils montés" 'findmnt'

# Adresses IPs
getInformation "Adresses IPs" 'ip addr'

# Les routeurs
getInformation "Les routeurs" 'ip route'

# Liens réseau
getInformation "Liens réseau" 'ip link' "ip link"

# Espace partitionné
getInformation "Espace partitionné" 'df' "df -h"

# Appareils de montage
getInformation "Appareils de montage" 'mount'

# Liste des services
getInformation "Liste des services" 'service' "service --status-all"
getInformation "\b# System Control Services" 'systemctl' "systemctl --all"

# Sockets status
getInformation "Sockets status" 'ss' "ss -ltup"

# État du pare-feu
getInformation "État du pare-feu" 'ufw' "ufw status"

# Paquets
echo -e "## Paquets\n" >> "./$OUTPUT_FILE"

## RedHat/Fedora/RHEL
getInformation "\b# RedHat/Fedora/RHEL" 'rpm' "rpm -qa"

## RedHat / CentOS
getInformation "\b# RedHat/CentOS" 'dnf' "dnf list installed"

## Debian/Ubuntu
getInformation "\b# Debian" 'dpkg' "dpkg --get-selections"
getInformation "\b# Ubuntu" 'apt' "apt list --installed"

## FreeBSD /OpenBSD
getInformation "\b# FreeBSD/OpenBSD" 'pkg_info'

## Gentoo
getInformation "\b# Gentoo" 'equery' "equery list or eix -I"

## Arch
getInformation "\b# Arch" 'pacman' "pacman -Q"

## Cygwin
getInformation "\b# Cygwin" 'cygcheck' "cygcheck --check-setup --dump-only"

## Slackware
getInformation "\b# Slackware" 'slapt-get' "slapt-get --installed"

## OpenSuSE
getInformation "\b# OpenSuSE" 'zypper' "zypper se --installed-only"

echo -e "## Logiciels\n" >> "./$OUTPUT_FILE"

# Tous les logiciels
getNotSudoInformation "\b# Tous les logiciels" 'compgen' "compgen -c"
getInformation "\b# Root logiciel" 'sudo ls' "ls ${PATH//:/ }"
getInformation "\b# User logiciel" 'ls' "ls ${PATH//:/ }"
getNotSudoInformation "\b# Desktop apps" 'ShareApps' "ls /usr/share/applications"

# Error report
echo -e $COMMANDS_NO_AVAILABLE >> "./$OUTPUT_FILE"

echo -e "## Errors\n" >> "./$OUTPUT_FILE"

cat err.txt >> "./$OUTPUT_FILE"

rm -f err.txt

sed -i $'s/ \b//' "./$OUTPUT_FILE"
