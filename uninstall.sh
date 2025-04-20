#!/bin/bash

#MS_ALIAS="uninstall"
#MS_SYSTEM

# Fonction d'aide
show_help() {
  echo "Script de désinstallation pour les alias scriptés."
  echo ""
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help        Affiche ce message d'aide."
  echo "  -y, --yes         Ignore les confirmations et procède directement à la suppression."
  echo ""
  echo "Le script supprime le répertoire ~/.scripted_aliases et retire les lignes correspondantes dans le fichier de configuration (bashrc ou zshrc)."
  echo "Une confirmation est demandée avant chaque suppression, sauf si l'option -y est utilisée."
}

# Vérification des arguments
YES_FLAG=false
while [[ "$1" == -* ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -y|--yes)
      YES_FLAG=true
      shift
      ;;
    *)
      show_help
      exit 1
      ;;
  esac
done

# Vérification si le répertoire .scripted_aliases existe
SCRIPTED_ALIASES_DIR="$HOME/.scripted_aliases"
if [ ! -d "$SCRIPTED_ALIASES_DIR" ]; then
  echo "Le répertoire $SCRIPTED_ALIASES_DIR n'existe pas. Rien à désinstaller."
  exit 1
fi

# Demander confirmation avant de procéder à la suppression si l'option -y n'est pas utilisée
if [ "$YES_FLAG" = false ]; then
  echo "Le répertoire $SCRIPTED_ALIASES_DIR va être supprimé."
  read -p "Êtes-vous sûr de vouloir continuer ? (y/N) : " confirmation
  if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
    echo "Annulation de la désinstallation."
    exit 0
  fi
fi

# Suppression du répertoire .scripted_aliases
echo "Suppression du répertoire $SCRIPTED_ALIASES_DIR..."
rm -rf "$SCRIPTED_ALIASES_DIR"

# Détection de l'interpréteur de commande (bash ou zsh)
SHELL_NAME=$(basename "$SHELL")
if [[ "$SHELL_NAME" == "bash" ]]; then
  RC_FILE="$HOME/.bashrc"
elif [[ "$SHELL_NAME" == "zsh" ]]; then
  RC_FILE="$HOME/.zshrc"
else
  echo "Shell non supportée. Utilisation de bash ou zsh attendue."
  exit 1
fi

# Vérification si les lignes à supprimer existent dans le fichier de configuration
if ! grep -q "#AUTO : SCRIPTED_ALIASES IMPORT" "$RC_FILE"; then
  echo "La ligne '#AUTO : SCRIPTED_ALIASES IMPORT' n'a pas été trouvée dans $RC_FILE."
fi

if ! grep -q "source \$HOME/.scripted_aliases/autocompletion.sh" "$RC_FILE"; then
  echo "La ligne 'source \$HOME/.scripted_aliases/autocompletion.sh' n'a pas été trouvée dans $RC_FILE."
fi

# Demander confirmation avant de supprimer les lignes dans .bashrc ou .zshrc si l'option -y n'est pas utilisée
if [ "$YES_FLAG" = false ]; then
  echo "Les lignes suivantes vont être supprimées de $RC_FILE :"
  echo "#AUTO : SCRIPTED_ALIASES IMPORT"
  echo "source \$HOME/.scripted_aliases/autocompletion.sh"
  read -p "Êtes-vous sûr de vouloir continuer ? (y/N) : " confirmation
  if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
    echo "Annulation de la désinstallation des lignes."
    exit 0
  fi
fi

# Suppression des lignes dans .bashrc ou .zshrc
echo "Suppression des lignes dans $RC_FILE..."
sed -i '/#AUTO : SCRIPTED_ALIASES IMPORT/d' "$RC_FILE"
sed -i '/source $HOME\/.scripted_aliases\/autocompletion.sh/d' "$RC_FILE"

# Confirmation de la suppression
echo "Désinstallation terminée avec succès."
