#!/bin/bash

#MS_ALIAS="source"
#MS_SYSTEM


# Détection du niveau de verbosité
verbosity=0
case "$1" in
  -v|--verbose) verbosity=1 ;;
  -vv|--vverbose) verbosity=2 ;;
  -vvv|--vvverbose) verbosity=3 ;;
esac

# Récupérer le chemin absolu du répertoire où le script est situé
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_LIST_FILE="$SCRIPT_DIR/scripts_directory.txt"

# Si le fichier n'existe pas, on le crée et on y met le dossier courant
if [ ! -f "$SCRIPTS_LIST_FILE" ]; then
  echo "Fichier scripts_directory.txt non trouvé. Création avec $SCRIPT_DIR."
  echo "$SCRIPT_DIR" > "$SCRIPTS_LIST_FILE"
  echo "$SCRIPT_DIR/ms_system" >> "$SCRIPTS_LIST_FILE"

fi

# Initialisation
alias_count=0
system_alias_count=0
no_alias_files=()
conflict_map=()
declare -A alias_to_file
declare -A alias_is_system
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
    # Ignorer les fichiers marqués #MS_IGNORE
    if grep -q '^#MS_IGNORE' "$file"; then
      continue
    fi

    # Vérifie la ligne d'alias
    alias_line=$(grep -m 1 '^#MS_ALIAS=' "$file")
    if [[ -n $alias_line ]]; then
      alias_name=$(echo "$alias_line" | sed 's/^#MS_ALIAS=//;s/"//g')
      is_system=false

      if grep -q '^#MS_SYSTEM' "$file"; then
        is_system=true
        alias_is_system["$alias_name"]=true
      fi

      if [[ -n "${alias_to_file[$alias_name]}" ]]; then
        conflict_map["$alias_name"]+="${alias_to_file[$alias_name]} $file "
        unset alias_to_file["$alias_name"]
        continue
      elif [[ -v conflict_map["$alias_name"] ]]; then
        conflict_map["$alias_name"]+="$file "
        continue
      fi

      alias_to_file["$alias_name"]="$file"
    else
      no_alias_files+=("$file")
    fi
  done
}

# Lire les répertoires depuis scripts_directory.txt
while IFS= read -r dir; do
  [[ -z "$dir" || "$dir" =~ ^# ]] && continue
  dir="${dir/#\~/$HOME}"
  process_directory "$dir"
done < "$SCRIPTS_LIST_FILE"

# Enregistrer les alias valides
for alias_name in "${!alias_to_file[@]}"; do
  file="${alias_to_file[$alias_name]}"
  echo "$alias_name=$file" >> "$SCRIPT_DIR/aliases.txt"
  echo "$alias_name" >> "$SCRIPT_DIR/commands.txt"
  complete -W "$alias_name" "./$file"

  if [[ "${alias_is_system[$alias_name]}" == "true" ]]; then
    ((system_alias_count++))
  else
    ((alias_count++))
  fi

  # Affichage selon le niveau de verbosité
  if (( verbosity >= 2 )); then
    display_name="$alias_name"
    if [[ "${alias_is_system[$alias_name]}" == "true" ]]; then
      display_name+=" (system)"
    fi

    if (( verbosity == 2 )); then
      echo "🔹 $display_name"
    elif (( verbosity == 3 )); then
      echo "🔹 $display_name => $file"
    fi
  fi
done

# Résumé
echo "Terminé."
if (( verbosity >= 1 )); then
  echo "$system_alias_count alias système"
  echo "$alias_count alias utilisateur trouvé"
fi

if [[ ${#no_alias_files[@]} -gt 0 ]]; then
  echo "Aucun alias trouvé dans les fichiers suivants :"
  for file in "${no_alias_files[@]}"; do
    echo "  - $file"
  done
fi

if [[ ${#conflict_map[@]} -gt 0 ]]; then
  echo "Conflit d'alias détecté pour les alias suivants :"
  for alias_name in "${!conflict_map[@]}"; do
    echo "  Alias : $alias_name"
    for file in ${conflict_map[$alias_name]}; do
      echo "    - $file"
    done
  done
fi
