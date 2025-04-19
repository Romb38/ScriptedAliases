#!/bin/bash

#MS_IGNORE

# Récupérer le chemin absolu du répertoire où se trouve le script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Vérifier si l'alias est fourni en tant qu'argument
if [ $# -lt 1 ]; then
    echo "Usage: ms <alias> [<param1> <param2> ...]"
    exit 1
fi

alias="$1"
shift  # Supprimer le premier argument (l'alias) de la liste des arguments

# Vérifier si le fichier aliases.txt existe
if [ ! -f "$SCRIPT_DIR/aliases.txt" ]; then
    echo "Le fichier aliases.txt n'existe pas."
    exit 1
fi

# Récupérer le chemin du fichier correspondant à l'alias
file_path=$(grep "^$alias=" "$SCRIPT_DIR/aliases.txt" | cut -d '=' -f 2)

# Vérifier si l'alias est trouvé
if [ -z "$file_path" ]; then
    echo "Alias '$alias' non trouvé dans aliases.txt."
    exit 1
fi

# Vérifier si le fichier correspondant existe
if [ ! -f "$file_path" ]; then
    echo "Fichier correspondant à l'alias '$alias' ($file_path) non trouvé."
    exit 1
fi

# Vérifier si le fichier contient #isSudo
if grep -q "^#isSudo" "$file_path"; then
    sudo bash "$file_path" "$@"
else
    bash "$file_path" "$@"
fi
