#!/bin/bash

#MS_IGNORE

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo "Git is not installed. Please install it before installing ScriptedAliases"
  exit 1
fi

# Creation of $HOME/.scripted_aliases folder
SCRIPTED_ALIASES_DIR="$HOME/.scripted_aliases"
if [ ! -d "$SCRIPTED_ALIASES_DIR" ]; then
  echo "Creation of $SCRIPTED_ALIASES_DIR folder..."
  mkdir -p "$SCRIPTED_ALIASES_DIR"
else
  echo "The folder $SCRIPTED_ALIASES_DIR already exist."
fi

# Clone git repository in $HOME/.scripted_aliases
echo "Clonage du repository ScriptAliases dans $SCRIPTED_ALIASES_DIR..."
git clone https://github.com/Romb38/ScriptedAliases.git "$SCRIPTED_ALIASES_DIR"

# Detect command interpretor
SHELL_NAME=$(basename "$SHELL")
if [[ "$SHELL_NAME" == "bash" ]]; then
  RC_FILE="$HOME/.bashrc"
elif [[ "$SHELL_NAME" == "zsh" ]]; then
  RC_FILE="$HOME/.zshrc"
else
  echo "Shell not supported. Please us bash or zsh."
  exit 1
fi

# Adding installation file in bashrc/zshrc
if ! grep -q "#AUTO : SCRIPTED_ALIASES IMPORT" "$RC_FILE"; then
  echo "Adding source commands to $RC_FILE..."
  echo -e "\n#GENERATED : SCRIPTED_ALIASES IMPORT\nsource \$HOME/.scripted_aliases/autocompletion.sh" >> "$RC_FILE"
else
  echo "Source commands are already in $RC_FILE."
fi

# Adding $HOME/.scripted_aliases (recursively) to aliases repository
if [ -f "$SCRIPTED_ALIASES_DIR/source.sh" ]; then
  echo "Adding $HOME/.scripted_aliases to aliases repository..."
  $SCRIPTED_ALIASES_DIR/ms_system/manage_dir.sh add -r $SCRIPTED_ALIASES_DIR
  echo "Execution of ms source..."
  source "$SCRIPTED_ALIASES_DIR/source.sh"
else
  echo "Sourcing source file not found in $SCRIPTED_ALIASES_DIR."
fi

echo "Setup sucessful.\n"
echo "Please restart terminal to conclude installation"
echo "Or run :"
echo "      source $HOME/.bashrc (if you're using bash)"
echo "      source $HOME/.zshrc  (if you're using zsh)"
