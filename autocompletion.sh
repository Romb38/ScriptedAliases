#!/bin/bash

#MS_IGNORE

SCRIPT_DIR="$HOME/.scripted_aliases"

ms() {
  bash "$SCRIPT_DIR/run_alias.sh" "$@"
}

concat_lines() {
  local file="$1"
  
  if [ ! -f "$file" ]; then
    echo "File $file doesn't exists. Please check installation" >&2
    return 1
  fi
  
  local result
  result=$(awk 'NF' "$file" | tr '\n' ' ' | sed 's/  */ /g')
  echo "$result"
}

_ms_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  # Stop autocomplete on first args
  if [ $COMP_CWORD -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(concat_lines "$SCRIPT_DIR/commands.txt")" -- "$cur") )
  else
    COMPREPLY=( $(compgen -f -- "$cur") )
  fi
}

# Autocompletion activation for ms
complete -F _ms_completion ms
