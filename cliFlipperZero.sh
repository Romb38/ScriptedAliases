#!/bin/bash

#alias="fcli"

# Vérifier si screen est installé
if ! command -v screen &> /dev/null
then
    echo "Screen n'est pas installé. Voulez-vous l'installer ? (y/n)"
    read -r answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        sudo apt-get update && sudo apt-get install screen -y
    else
        echo "Screen n'a pas été installé. Le programme va s'arrêter."
        exit 1
    fi
fi

# Liste des fichiers dans /dev/serial/by-id/
serial_devices=$(ls /dev/serial/by-id/ 2>/dev/null)

# Vérifier le nombre de périphériques trouvés
if [ -z "$serial_devices" ]; then
    echo "Flipper is not connected"
    exit 1
elif [ $(echo "$serial_devices" | wc -l) -eq 1 ]; then
    # Si un seul périphérique est trouvé, l'utiliser automatiquement
    selected_device=$serial_devices
else
    # Si plusieurs périphériques sont trouvés, demander à l'utilisateur de choisir
    echo "Plusieurs périphériques trouvés :"
    select selected_device in $serial_devices; do
        if [ -n "$selected_device" ]; then
            echo "Vous avez choisi : $selected_device"
            break
        else
            echo "Choix invalide, essayez encore."
        fi
    done
fi

# Lancer screen avec le périphérique choisi
screen /dev/serial/by-id/$selected_device