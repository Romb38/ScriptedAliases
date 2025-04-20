#!/bin/bash

#MS_IGNORE

# Source constant file
source "$HOME/.scripted_aliases/constants.sh"

ms() {
  bash "$PROJECT_ROOT_DIRECTORY/run_alias.sh" "$@"
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
    COMPREPLY=( $(compgen -W "$(concat_lines "$PROJECT_ROOT_DIRECTORY/commands.txt")" -- "$cur") )
  else
    COMPREPLY=( $(compgen -f -- "$cur") )
  fi
}

# Autocompletion activation for ms
complete -F _ms_completion ms
