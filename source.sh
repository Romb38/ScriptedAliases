#!/bin/bash

# Récupérer le chemin absolu du répertoire où le script est situé
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_LIST_FILE="$SCRIPT_DIR/scripts_directory.txt"

# Si le fichier n'existe pas, on le crée et on y met le dossier courant
if [ ! -f "$SCRIPTS_LIST_FILE" ]; then
  echo "Fichier scripts_directory.txt non trouvé. Création avec $SCRIPT_DIR."
  echo "$SCRIPT_DIR" > "$SCRIPTS_LIST_FILE"
fi

# Initialisation
alias_count=0
no_alias_files=()
shopt -s nullglob

# Réinitialiser les fichiers de sortie
echo "# Liste des aliases récupérés des fichiers .sh" > "$SCRIPT_DIR/aliases.txt"
echo "" > "$SCRIPT_DIR/commands.txt"

# Fonction pour traiter un dossier donné
process_directory() {
  local dir="$1"
  local files=("$dir"/*.sh)

  chmod u+x "${files[@]}" 2>/dev/null

  for file in "${files[@]}"; do
    alias_line=$(grep -m 1 '^#alias=' "$file")
    if [[ -n $alias_line ]]; then
      alias_count=$((alias_count + 1))
      alias_name=$(echo "$alias_line" | sed 's/^#alias=//;s/"//g')
      echo "$alias_name=$file" >> "$SCRIPT_DIR/aliases.txt"
      echo "$alias_name" >> "$SCRIPT_DIR/commands.txt"
      complete -W "$alias_name" "./$file"
    else
      no_alias_files+=("$file")
    fi
  done
}

# Lire les répertoires depuis scripts_directory.txt et les traiter
while IFS= read -r dir; do
  [[ -z "$dir" || "$dir" =~ ^# ]] && continue
  # Expansion manuelle du ~ si nécessaire
  dir="${dir/#\~/$HOME}"
  process_directory "$dir"
done < "$SCRIPTS_LIST_FILE"

# Résumé
if [[ $alias_count -eq 0 ]]; then
  echo "Aucun alias trouvé dans les fichiers .sh."
else
  echo "Terminé. $alias_count alias récupérés et enregistrés."
fi

if [[ ${#no_alias_files[@]} -gt 0 ]]; then
  echo "Aucun alias trouvé dans les fichiers suivants :"
  for file in "${no_alias_files[@]}"; do
    echo "$file"
  done
fi
