#!/bin/bash

# ======================= Préparation =======================

# Infos de connexion
BASE_URL="https://fichiers.rainbowswingers.net/ocs/v2.php/apps/files_sharing/api/v1/shares"

USERNAME="rainbowca"
PASSWORD="DJ8oF-x2yy8-bqKmW-ReYwX-HfAnx"

CA_filepath="$1"
CHOR_filepath="$2"
# Récupérer le répertoire du script principal
script_dir="$(dirname "$(realpath "$0")")"

# ======================= Création des liens de partage de données =======================

CA_filepath="${CA_filepath#/mnt/webdav/}"
CHOR_filepath="${CHOR_filepath#/mnt/webdav/}"

create_share_link() {
    local path="$1"

    # Requête POST avec l'en-tête OCS-APIRequest
    response=$(curl -s -u "$USERNAME:$PASSWORD" -X POST "$BASE_URL" \
        -H "OCS-APIRequest: true" \
        -d "path=$path" \
        -d 'shareType=3' \
        -d 'permissions=1')

    # Extraire l'URL avec grep
    echo "$response" | grep -oP '(?<=<url>)[^<]+'
}

CA_URL=$(create_share_link "$CA_filepath")
CHOR_URL=$(create_share_link "$CHOR_filepath")

# ======================= Création des listes des tâches =======================

python3 $script_dir/parserTasks/generateTasksList.py -c -t


# ======================= Affichage des informations =======================
echo "
==========================

Voici les liens du CR du CA passé en paramètre :
Lien CA : $CA_URL
Lien CHOR : $CHOR_URL

==========================

Les fichiers générés sont dans le répertoire $PWD
"

# ======================= Envoyer les liens sur signal =======================
# read -p "Voulez-vous envoyer les liens sur Signal ? [Y/n] : " response2
#     if [[ ! "$response2" =~ [Yy] ]]; then
#         exit 0
#     fi

# $script_dir/sendToSignal.sh "$CA_URL" "$CHOR_URL"