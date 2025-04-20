#!/bin/bash

#MS_IGNORE

# Vérification si Git est installé
if ! command -v git &> /dev/null; then
  echo "Git n'est pas installé. Veuillez l'installer d'abord."
  exit 1
fi

# Création du dossier .scripted_aliases
SCRIPTED_ALIASES_DIR="$HOME/.scripted_aliases"
if [ ! -d "$SCRIPTED_ALIASES_DIR" ]; then
  echo "Création du répertoire $SCRIPTED_ALIASES_DIR..."
  mkdir -p "$SCRIPTED_ALIASES_DIR"
else
  echo "Le répertoire $SCRIPTED_ALIASES_DIR existe déjà."
fi

# Clonage du dépôt Git dans le répertoire .scripted_aliases
echo "Clonage du repository ScriptAliases dans $SCRIPTED_ALIASES_DIR..."
git clone https://github.com/Romb38/ScriptedAliases.git "$SCRIPTED_ALIASES_DIR"

# Détection de l'interpréteur de commande (bash ou zsh)
SHELL_NAME=$(basename "$SHELL")
if [[ "$SHELL_NAME" == "bash" ]]; then
  RC_FILE="$HOME/.bashrc"
elif [[ "$SHELL_NAME" == "zsh" ]]; then
  RC_FILE="$HOME/.zshrc"
else
  echo "Shell non supportée. Utilisez bash ou zsh."
  exit 1
fi

# Ajout de la ligne source dans .bashrc ou .zshrc (si elle n'existe pas déjà)
if ! grep -q "#AUTO : SCRIPTED_ALIASES IMPORT" "$RC_FILE"; then
  echo "Ajout de la commande de source dans $RC_FILE..."
  echo -e "\n#AUTO : SCRIPTED_ALIASES IMPORT\nsource \$HOME/.scripted_aliases/autocompletion.sh" >> "$RC_FILE"
else
  echo "Les lignes d'importation sont déjà présentes dans $RC_FILE."
fi

# Exécution du fichier de complétion
echo "Exécution du fichier autocompletion.sh..."
source "$SCRIPTED_ALIASES_DIR/autocompletion.sh"

# Exécution du fichier source.sh si présent
if [ -f "$SCRIPTED_ALIASES_DIR/source.sh" ]; then
  echo "Exécution du fichier source.sh..."
  source "$SCRIPTED_ALIASES_DIR/source.sh"
else
  echo "Fichier source.sh introuvable dans $SCRIPTED_ALIASES_DIR."
fi

source "$RC_FILE"

echo "Installation terminée avec succès."
