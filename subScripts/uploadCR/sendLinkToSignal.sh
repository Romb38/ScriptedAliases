#!/bin/bash

# ======================= Préparation =======================

BASE_URL="https://fichiers.rainbowswingers.net/ocs/v2.php/apps/files_sharing/api/v1/shares"
USERNAME="rainbowca"
PASSWORD="DJ8oF-x2yy8-bqKmW-ReYwX-HfAnx"
CA_filepath="$1"
CHOR_filepath="$2"

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


echo "CA_URL: $CA_URL"
echo "CHOR_URL: $CHOR_URL"

# ======================= Envoi sur Signal =======================


