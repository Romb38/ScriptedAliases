#!/bin/bash

#MS_ALIAS="ls"
#MS_SYSTEM

# Récupérer le chemin du dossier où se trouve le script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Lire le fichier commands.txt situé dans le même dossier que le script
cat "$SCRIPT_DIR/commands.txt"
