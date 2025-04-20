#!/bin/bash

#MS_ALIAS="source"
#MS_SYSTEM


# Verbosity level detection
verbosity=0
case "$1" in
  -v|--verbose) verbosity=1 ;;
  -vv|--vverbose) verbosity=2 ;;
  -vvv|--vvverbose) verbosity=3 ;;
esac

# Get absolute path to script file
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_LIST_FILE="$SCRIPT_DIR/scripts_directory.txt"

# If aliases repository lists file doesn't exists, we create it with the ScriptedAliases root folder
if [ ! -f "$SCRIPTS_LIST_FILE" ]; then
  echo "Aliases repository list file does not exist. Generating default..."
  echo "$SCRIPT_DIR" > "$SCRIPTS_LIST_FILE"
  echo "File generated in $SCRIPT_DIR"
fi

# Initialisation
alias_count=0
system_alias_count=0
no_alias_files=()
conflict_map=()
declare -A alias_to_file
declare -A alias_is_system
shopt -s nullglob

# Reset outputed files
echo "# Aliases fetched from .sh files founded in aliases repository" > "$SCRIPT_DIR/aliases.txt"
echo "" > "$SCRIPT_DIR/commands.txt"

# Treatement of given directory
process_directory() {
  local dir="$1"
  local files=("$dir"/*.sh)

  chmod u+x "${files[@]}" 2>/dev/null

  for file in "${files[@]}"; do
    # Ignore file with #MS_IGNORE
    if grep -q '^#MS_IGNORE' "$file"; then
      continue
    fi

    # Check aliases list
    alias_line=$(grep -m 1 '^#MS_ALIAS=' "$file")
    if [[ -n $alias_line ]]; then
      alias_name=$(echo "$alias_line" | sed 's/^#MS_ALIAS=//;s/"//g')
      is_system=false

      if grep -q '^#MS_SYSTEM' "$file"; then
        is_system=true
        alias_is_system["$alias_name"]=true
      fi

      if [[ -n "${alias_to_file[$alias_name]}" ]]; then
        conflict_map["$alias_name"]+="${alias_to_file[$alias_name]} $file "
        unset alias_to_file["$alias_name"]
        continue
      elif [[ -v conflict_map["$alias_name"] ]]; then
        conflict_map["$alias_name"]+="$file "
        continue
      fi

      alias_to_file["$alias_name"]="$file"
    else
      no_alias_files+=("$file")
    fi
  done
}

# List aliases repository from scripts_directory.txt
while IFS= read -r dir; do
  [[ -z "$dir" || "$dir" =~ ^# ]] && continue
  dir="${dir/#\~/$HOME}"
  process_directory "$dir"
done < "$SCRIPTS_LIST_FILE"

# Save valid aliases
for alias_name in "${!alias_to_file[@]}"; do
  file="${alias_to_file[$alias_name]}"
  echo "$alias_name=$file" >> "$SCRIPT_DIR/aliases.txt"
  echo "$alias_name" >> "$SCRIPT_DIR/commands.txt"
  complete -W "$alias_name" "./$file"

  if [[ "${alias_is_system[$alias_name]}" == "true" ]]; then
    ((system_alias_count++))
  else
    ((alias_count++))
  fi

  # Display infos coressponding to verbosity level
  if (( verbosity >= 2 )); then
    display_name="$alias_name"
    if [[ "${alias_is_system[$alias_name]}" == "true" ]]; then
      display_name+=" (system)"
    fi

    if (( verbosity == 2 )); then
      echo "🔹 $display_name"
    elif (( verbosity == 3 )); then
      echo "🔹 $display_name => $file"
    fi
  fi
done

# Summary
echo "Finished."
if (( verbosity >= 1 )); then
  echo "$system_alias_count system alias(es) founded"
fi
echo "$alias_count user alias(es) founded"

if [[ ${#no_alias_files[@]} -gt 0 ]]; then
  echo "No alias found in following files :"
  for file in "${no_alias_files[@]}"; do
    echo "  - $file"
  done
fi

if [[ ${#conflict_map[@]} -gt 0 ]]; then
  echo "Follwing aliases are in conflict :"
  for alias_name in "${!conflict_map[@]}"; do
    echo "  Alias : $alias_name"
    for file in ${conflict_map[$alias_name]}; do
      echo "    - $file"
    done
  done
fi
