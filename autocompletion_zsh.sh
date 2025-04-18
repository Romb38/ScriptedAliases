_mycommand_completions() {
    local cur opts
    cur="${words[CURRENT]}"  # Récupère le mot actuellement tapé
    opts=$(cat /home/romb38/Documents/Scripts/commands.txt)  # Récupère les mots du fichier

    # Utilisation de 'compadd' pour ajouter des options depuis le fichier
    compadd $opts
}
compdef _mycommand_completions ms