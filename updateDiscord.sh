#!/bin/bash

#alias="updateDiscord"

# Fonction pour extraire la version de Discord installée
get_installed_version() {
    dpkg -s discord | grep '^Version:' | cut -d ' ' -f 2
}

# Fonction pour extraire la dernière version disponible en ligne
get_latest_version() {
    final_url=$(curl -Ls -o /dev/null -w %{url_effective} https://discord.com/api/download/stable?platform=linux&format=deb)
    echo "$final_url" | grep -oP '(?<=/discord-)[^_]*(?=\.deb)'
}

# Vérifie si Discord est installé
if dpkg -s discord &> /dev/null
then
    current_version=$(get_installed_version)
    latest_version=$(get_latest_version)

    echo "Installed version: $current_version"
    echo "Latest version: $latest_version"

    if [ "$current_version" == "$latest_version" ]
    then
        echo "Discord is up to date"
    else
        echo "Updating Discord..."
        wget "https://discord.com/api/download/stable?platform=linux&format=deb" -O ~/Downloads/discord.deb
        cd ~/Downloads
        sudo apt install ./discord.deb -y
        rm ~/Downloads/discord.deb
    fi
else
    echo "Discord is not installed. Installing..."
    wget "https://discord.com/api/download/stable?platform=linux&format=deb" -O ~/Downloads/discord.deb
    cd ~/Downloads
    sudo apt install ./discord.deb
    rm ~/Downloads/discord.deb
fi