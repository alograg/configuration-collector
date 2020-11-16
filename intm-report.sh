#!/usr/bin bash

clear

SCRIPT_PATH="$(dirname $0)"
FILE_NAME=${1:-info.md}
OUTPUT_FILE="$SCRIPT_PATH/$FILE_NAME"

echo -e "# Informations système\n" > "./$OUTPUT_FILE"
echo -n -e "Créé en $(date +%F-%H%M%S)\nBy user " >> "./$OUTPUT_FILE"
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
    if [[ $VALUE ]]; then
        echo -e "## $TITLE\n\n\`\`\`console\n$VALUE\n\`\`\`\n\n" >> "./$OUTPUT_FILE"
        echo -e "\e[32mok\e[0m"
    else
        echo -e "\e[31mX\e[0m"
        COMMANDS_NO_AVAILABLE+="- $CMD_NAME\n"
    fi
}

function addInformation ()
{
    CMD_LINE=$1
    if [[ $I_AM != 'root' ]]; then
        CMD_LINE="sudo $CMD_LINE"
    fi
    VALUE="$($CMD_LINE 2> err.txt)"
    if [[ $VALUE ]]; then
        echo -e "\`\`\`console\n$VALUE\n\`\`\`\n\n" >> "./$OUTPUT_FILE"
    fi
}

# Bios
getInformation "Bios" 'dmidecode' 'dmidecode -q | head -n 100'

# Nom du système d'exploitation
getInformation "Informations d'utilisation actuelle" 'uname' "uname -a"
getInformation "\b# Distribution" 'dsitro' "cat /etc/os-release"

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

# Espace partitionné
getInformation "Espace partitionné" 'df' "df -h"

# Liste des services
getInformation "Liste des services" 'service' "service --status-all"
getInformation "\b# System Control Services" 'systemctl' "systemctl --all"

# Sockets status
getInformation "Sockets status" 'ss' "ss -ltup | sort"

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

# Enviroment vars
getInformation "Environment" 'printenv'

## Test command
if command -v httpd &> /dev/null
then
    read -p "C'est un problème avec Apache (httpd) ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        getInformation "\b# Apache" 'Apache' "httpd -S -M -t -D DUMP_INCLUDES"
        addInformation "httpd -v"
    fi
fi

if command -v mongod &> /dev/null
then
    read -p "C'est un problème avec MongoDB ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        getInformation "\b# MongoDB" 'MongoDB' "mongod --version"
        addInformation "mongod --sysinfo"
        read -p "Nom de base de donnée ? " MONGO_DATABASE
        addInformation "mongo ${MONGO_DATABASE} --eval 'db.stats()'"
        addInformation "mongo ${MONGO_DATABASE} --eval 'db.serverStatus()'"
    fi
fi

if command -v mongod &> /dev/null
then
    read -p "C'est un problème avec PostgreSQL ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        getInformation "\b# PostgreSQL" 'PostgreSQL' "psql --version"
        addInformation "cat /var/lib/postgresql/data/postgresql.conf"
        read -p "Postgres user ? " PSQL_USER
        addInformation "psql -U ${PSQL_USER} -c '\help'"
        addInformation "psql -U ${PSQL_USER} -c 'SELECT * FROM pg_stat_activity ORDER BY backend_start DESC LIMIT 250'"
    fi
fi

read -p "Voulez-vous une analyse du processus avec erreur? ? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Installation de libreries"
    sudo apt-get -y install strace sysstat
    getInformation "Swap" 'Swap' "sysctl vm.swappiness"
    read -p "Nom de processus ? " PROCES_NAME
    PROCESS_ID=$(ps -C ${PROCES_NAME} -o pid= | head -n 1)
    echo "Monitoring PID" $PROCESS_ID
    sudo strace -c -f -p $PROCESS_ID 1>> strace.log 2>&1 &
    top -d5 -n5 -b >> top_report.log &
    iostat -x -k -N -d 5 20 >> IOstat.log &
    echo "Lancer votre processus"
    read -p "Attendez la fin et appuyez sur une touche" -n 1 -r
    PID_TO_KILL=$(ps -C strace -o pid= | head -n 1)
    echo "Kill task strace " $PID_TO_KILL
    sudo kill $PID_TO_KILL
    PID_TO_KILL=$(ps -C top -o pid= | head -n 1)
    echo "Kill task top " $PID_TO_KILL
    kill $PID_TO_KILL
    PID_TO_KILL=$(ps -C iostat -o pid= | head -n 1)
    echo "Kill task iostat " $PID_TO_KILL
    kill $PID_TO_KILL

fi

# Error report
echo -e $COMMANDS_NO_AVAILABLE >> "./$OUTPUT_FILE"

echo -e "## Errors\n" >> "./$OUTPUT_FILE"

cat err.txt >> "./$OUTPUT_FILE"

rm -f ./err.txt

sed -i $'s/ \b//' "./$OUTPUT_FILE"

## Compresser les fichiers
ZIP_FILE="logs-$(date +%F-%H%M%S).zip"
zip -rm $ZIP_FILE . -i '*.log'  -i '*.md'

echo "Envoyer le fichier: $ZIP_FILE"
