#!/bin/bash

#MS_IGNORE

SCRIPT_DIR="$HOME/Documents/Scripts"

ms() {
  bash "$SCRIPT_DIR/run_alias.sh" "$@"
}

concat_lines() {
  local file="$1"
  
  if [ ! -f "$file" ]; then
    echo "Le fichier $file n'existe pas." >&2
    return 1
  fi
  
  local result
  result=$(awk 'NF' "$file" | tr '\n' ' ' | sed 's/  */ /g')
  echo "$result"
}

_ms_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  if [ $COMP_CWORD -eq 1 ]; then
    # Autocomplétion personnalisée uniquement pour le 1er argument
    COMPREPLY=( $(compgen -W "$(concat_lines "$SCRIPT_DIR/commands.txt")" -- "$cur") )
  else
    # Autocomplétion par défaut (fichiers, dossiers, commandes, etc.)
    COMPREPLY=( $(compgen -f -- "$cur") )
  fi
}

# Active l'autocomplétion sur la commande ms
complete -F _ms_completion ms
