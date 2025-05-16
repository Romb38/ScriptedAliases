#!/bin/bash

#MS_ALIAS="ls"
#MS_SYSTEM

# Récupérer le chemin du dossier où se trouve le script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Lire le fichier commands.txt situé dans le dossier parent du script
cat "$PARENT_DIR/commands.txt"
