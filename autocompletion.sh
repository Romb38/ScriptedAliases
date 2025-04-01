_mycommand_completions() {
    local cur opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts=$(cat /home/romb38/Documents/Scripts/commands.txt)  # Mettez le chemin vers votre fichier de commandes ici

    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
}
complete -F _mycommand_completions ms
