#!/bin/bash

#alias="adminFolder"

create_folders_and_file() {
    # Vérifier si l'option -y est fournie
    if [[ "$1" == "-y" ]]; then
        confirmation="yes"
    else
        # Afficher un message d'avertissement
        echo "Ceci va créer 4 dossiers et 1 fichier. Êtes-vous sûr de vouloir continuer ? [y/n]"
        read confirmation
    fi

    # Convertir la réponse en minuscules pour une vérification insensible à la casse
    confirmation_lowercase=$(echo "$confirmation" | tr '[:upper:]' '[:lower:]')

    # Vérifier la réponse de l'utilisateur
    if [[ "$confirmation_lowercase" != "yes" && "$confirmation_lowercase" != "y" ]]; then
        echo "Opération annulée."
        exit 1
    fi

    # Créer les dossiers
    mkdir -p 0-Clear
    mkdir -p 1-toComplete
    mkdir -p 2-Completed
    mkdir -p Documents

    # Créer le fichier TODO.txt
    touch TODO.txt

    echo "Les dossiers et le fichier ont été créés avec succès."
}

# Vérifier si une commande est fournie en argument
if [[ $# -eq 0 ]]; then
    echo "Aucune commande spécifiée."
    exit 1
fi

# Analyser la commande
case "$1" in
    "create")
        create_folders_and_file "${@:2}"  # Passer les arguments restants à la fonction
        ;;
    "-h" | "--help")
        # Afficher l'aide
        echo "Utilisation : $0 <commande>"
        echo "Commandes disponibles :"
        echo "    create  - Crée les dossiers et le fichier"
        echo "    -h, --help  - Affiche cette aide"
        ;;
    *)
        echo "Commande non reconnue."
        exit 1
        ;;
esac
