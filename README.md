# Configuration Collector

Ce script collecte les informations de la machine virtuelle pour un aperçu de l'environnement.

## Exemple d'utilisation

```console
root@vm:~$ ./intm-report.sh
[sudo] Mot de passe de intm :
- Bios ok
- Informations d&apos;utilisation actuelle ok
- Dsitribution ok
- Vérification de la configuration ok
- Récupération de la mémoire ok
- Informations d&apos;utilisation actuelle ok
- Liste des périphériques ok
- Informations détaillées sur le microprocesseur ok
- Informations sur le périphérique SCSI ok
- Informations de partition ok
- Périphériques USB ok
- Dispositifs PCI ok
- Appareils montés ok
- Adresses IPs ok
- Les routeurs ok
- Espace partitionné ok
- Liste des services ok
- System Control Services ok
- Sockets status ok
- RedHat/Fedora/RHEL ok
- RedHat/CentOS ok
- Debian ok
- Ubuntu ok
- FreeBSD/OpenBSD ok
- Gentoo ok
- Arch ok
- Cygwin ok
- Slackware ok
- OpenSuSE ok
- Enviroment ok
Voulez-vous une analyse du processus avec erreur? ? [y/N] y
Installation de libreries
Lecture des listes de paquets... Fait
Construction de l&apos;arbre des dépendances
Lecture des informations d&apos;état... Fait
sysstat est déjà la version la plus récente (12.2.0-2).
strace est déjà la version la plus récente (5.5-3ubuntu1).
Les paquets suivants ont été installés automatiquement et ne sont plus nécessaires :
  libfprint-2-tod1 libllvm9
Veuillez utiliser « sudo apt autoremove » pour les supprimer.
0 mis à jour, 0 nouvellement installés, 0 à enlever et 17 non mis à jour.
- Swap ok
Nom de processus ? {nom}
Monitoring PID {PID detected}
Lancer votre processus
Attendez la fin et appuyez sur une touche
Kill task strace {pid}
Kill task top {pid}
Kill task iostat {pid}
  adding: strace.log (deflated 5%)
  adding: IOstat.log (deflated 86%)
  adding: top_report.log (deflated 78%)
  adding: info.md (deflated 84%)
Envoyer le fichier: logs-{time stamp}.zip
root@vm:~$ _
```

## Fichiers

- ***info.md*** : Informations general système
  - Informations d'utilisation actuelle
    - Distribution
  - Récupération de la mémoire
  - Informations d'utilisation actuelle
  - Liste des périphériques
  - Informations détaillées sur le microprocesseur
  - Informations de partition
  - Périphériques USB
  - Dispositifs PCI
  - Appareils montés
  - Adresses IPs
  - Les routeurs
  - Espace partitionné
  - Liste des services
  - System Control Services
  - Paquets
    - RedHat/Fedora/RHEL
    - RedHat/CentOS
    - Debian
    - Ubuntu
    - FreeBSD/OpenBSD
    - Gentoo
    - Arch
    - Cygwin
    - Slackware
    - OpenSuSE
  - Environment
  - Swap
  - Commandes non disponibles
  - Errors
- ***IOstat.log*** : Rapporter les statistiques de l'unité centrale (CPU) et les statistiques d'entrée / sortie pour les périphériques et les partitions.
- ***strace.log*** : Tracez les appels et les signaux système
- ***top_report.log*** : Journal de afficher les processus Linux
