#!/bin/bash

#alias="source"

# Récupérer le chemin absolu du répertoire où le script est situé
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Étape 1: Donne la permission d'exécution à tous les fichiers .sh du dossier
chmod u+x "$SCRIPT_DIR"/*.sh

# Étape 2: Récupère les alias des fichiers .sh et les stocke dans un fichier aliases.txt
shopt -s nullglob
sh_files=("$SCRIPT_DIR"/*.sh)
alias_count=0
no_alias_files=()

echo "# Liste des aliases récupérés des fichiers .sh" > "$SCRIPT_DIR"/aliases.txt
echo "" > "$SCRIPT_DIR"/commands.txt

for file in "${sh_files[@]}"; do
    # Ignorer le fichier run_alias.sh
    if [[ $file == "$SCRIPT_DIR/run_alias.sh" ]]; then
        continue
    fi
    
    alias_line=$(grep -m 1 '^#alias=' "$file")
    if [[ -n $alias_line ]]; then
        alias_count=$((alias_count+1))
        alias_name=$(echo "$alias_line" | sed 's/^#alias=//;s/"//g')
        echo "$alias_name=$file" >> "$SCRIPT_DIR"/aliases.txt  # Modification ici
        echo "$alias_name" >> "$SCRIPT_DIR"/commands.txt
        # Appliquer l'auto-complétion pour ce fichier
        complete -W "$alias_name" "./$file"
    else
        no_alias_files+=("$file")
    fi
done

if [[ $alias_count -eq 0 ]]; then
    echo "Aucun alias trouvé dans les fichiers .sh du dossier."
else
    echo "Terminé. $alias_count alias récupérés et enregistrés"
fi

if [[ ${#no_alias_files[@]} -gt 0 ]]; then
    echo "Aucun alias trouvé dans les fichiers suivants :"
    for file in "${no_alias_files[@]}"; do
        echo "$file"
    done
fi
