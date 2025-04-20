#!/bin/bash

#MS_ALIAS="where"

# Vérifie que l'alias est bien fourni
if [ $# -ne 1 ]; then
  echo "Utilisation : $0 <alias>"
  exit 1
fi

alias_name="$1"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
alias_file="$script_dir/aliases.txt"

# Vérifie que le fichier existe
if [ ! -f "$alias_file" ]; then
  echo "Le fichier '$alias_file' est introuvable dans le dossier du script."
  exit 2
fi

# Recherche de l'alias et extraction du chemin
chemin=$(grep "^${alias_name}=" "$alias_file" | cut -d'=' -f2-)

if [ -n "$chemin" ]; then
  echo "$chemin"
else
  echo "Cet alias n'existe pas"
  exit 3
fi
