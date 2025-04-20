#!/bin/bash

#MS_ALIAS="md"
#MS_SYSTEM

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_FILE="$SCRIPT_DIR/../scripts_directory.txt"

# Si le fichier n'existe pas, avertir et sortir
if [[ ! -f "$SCRIPTS_FILE" ]]; then
  echo "Le fichier scripts_directory.txt n'existe pas."
  echo "Lance la commande suivante pour l'initialiser :"
  echo "   ms source"
  exit 1
fi

show_help() {
  echo "Utilisation : $0 [commande] [-r] [chemin]"
  echo ""
  echo "Commandes disponibles :"
  echo "  list                       Liste les répertoires enregistrés"
  echo "  add [-r] <chemin>          Ajoute un répertoire ou tous les sous-répertoires"
  echo "  remove [-r] <chemin>       Supprime un répertoire ou tous ceux qui en dépendent"
  echo "  reset                      Supprime tous les répertoires"
  echo "  help                       Affiche cette aide"
}

list_dirs() {
  echo "Répertoires enregistrés dans scripts_directory.txt :"
  nl -w2 -s'. ' "$SCRIPTS_FILE"
}

add_dir() {
  local recursive=false
  if [[ $1 == "-r" ]]; then
    recursive=true
    shift
  fi

  local base="${1/#\~/$HOME}"
  base="$(realpath -m "$base")"

  if [[ ! -d "$base" ]]; then
    echo "Erreur : le répertoire '$base' n'existe pas."
    exit 1
  fi

  if [[ $recursive == true ]]; then
    echo "Recherche récursive dans : $base"
    find "$base" -type d | while read -r dir; do
      add_single_dir "$dir"
    done
  else
    add_single_dir "$base"
  fi
}

add_single_dir() {
  local dir="$1"
  if grep -Fxq "$dir" "$SCRIPTS_FILE"; then
    echo "Déjà présent : $dir"
  else
    echo "$dir" >> "$SCRIPTS_FILE"
    echo "Ajouté : $dir"
  fi
}

remove_dir() {
  local recursive=false
  if [[ $1 == "-r" ]]; then
    recursive=true
    shift
  fi

  local base="${1/#\~/$HOME}"
  base="$(realpath -m "$base")"

  if [[ ! -d "$base" ]]; then
    echo "Erreur : le répertoire '$base' n'existe pas."
    exit 1
  fi

  if ! grep -qF "$base" "$SCRIPTS_FILE"; then
    echo "Erreur : le répertoire '$base' n'est pas dans scripts_directory.txt."
    exit 1
  fi

  if [[ $recursive == true ]]; then
    echo "Suppression récursive de tous les chemins commençant par : $base"
    grep -Fxv -e "$base" "$SCRIPTS_FILE" | grep -v "^$base/" > "$SCRIPTS_FILE.tmp"
  else
    echo "Suppression de : $base"
    grep -Fxv "$base" "$SCRIPTS_FILE" > "$SCRIPTS_FILE.tmp"
  fi

  mv "$SCRIPTS_FILE.tmp" "$SCRIPTS_FILE"
  echo "Supprimé (avec récursivité = $recursive) : $base"
}

reset_file() {
  echo "$SCRIPT_DIR" > "$SCRIPTS_FILE"
  echo "Fichier réinitialisé avec : $SCRIPT_DIR"
}

# Gérer les arguments
case "$1" in
  list) list_dirs ;;
  add) shift; [[ -z $1 ]] && echo "Chemin manquant." && exit 1; add_dir "$@" ;;
  remove) shift; [[ -z $1 ]] && echo "Chemin manquant." && exit 1; remove_dir "$@" ;;
  reset) reset_file ;;
  help | "") show_help ;;
  *) echo "Commande inconnue : $1"; show_help; exit 1 ;;
esac
