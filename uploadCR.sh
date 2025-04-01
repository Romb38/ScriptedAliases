#!/bin/bash

#alias="uploadCR"

# Obtenir le répertoire du script
script_dir="$(dirname "$(realpath "$0")")"

# Exécuter le script pour partager les CR
sudo "$script_dir/scripts/uploadCR/createCR_PDF.sh"