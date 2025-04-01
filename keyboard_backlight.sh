#!/bin/bash

#alias="kl"
#isSudo

# Fichier de contrôle du rétroéclairage du clavier
BACKLIGHT_PATH="/sys/class/leds/dell::kbd_backlight/brightness"

# Vérifier si le script est exécuté en root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté avec sudo ou en root."
    exit 1
fi

# Afficher l'aide
usage() {
    echo "Usage: $(basename "$0") [OPTION]"
    echo "  -l, --low       Rétroéclairage faible"
    echo "  -m, --medium    Rétroéclairage elevé"
    echo "  -o, --off       Désactiver le rétroéclairage"
    echo "  -H, --help      Afficher cette aide"
    exit 0
}

# Vérifier les arguments
if [[ $# -eq 0 ]]; then
    usage
fi

case "$1" in
    -l|--low)
        echo 1 > "$BACKLIGHT_PATH"
        ;;
    -m|--medium)
        echo 2 > "$BACKLIGHT_PATH"
        ;;
    -o|--off)
        echo 0 > "$BACKLIGHT_PATH"
        ;;
    -H|--help)
        usage
        ;;
    *)
        echo "Option invalide: $1"
        usage
        ;;
esac
