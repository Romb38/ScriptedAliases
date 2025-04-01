#!/bin/bash


#alias="uploadCR"

# Variables
WEBDAV_URL="https://fichiers.rainbowswingers.net/remote.php/dav/files/rainbowca"
MOUNT_POINT="/mnt/webdav"
current_directory="$PWD"

# ======================= Démontage =======================

# Fonction pour démonter le WebDAV
unmount_webdav() {
    # Vérifie si le point de montage est monté
    if mountpoint -q "$MOUNT_POINT"; then
        # Tente de démonter le WebDAV
        if sudo umount "$MOUNT_POINT"; then
            echo "WebDAV démonté avec succès."
        else
            echo "Erreur : Impossible de démonter le WebDAV."
        fi
    fi
}


trap "unmount_webdav && exit 1" SIGINT
trap "unmount_webdav && exit 1" EXIT



# ======================= Préparation =======================

# Vérifier si davfs2 est installé
if ! apt search davfs 2>/dev/null | grep -E 'davfs2.*\[installed\]'; then
    echo "Erreur : davfs2 n'est pas installé. Veuillez l'installer avec : sudo apt install davfs2"
    exit 1
fi

# Créer le point de montage si nécessaire
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Création du répertoire $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
    sudo chown $(id -u):$(id -g) "$MOUNT_POINT"
fi

# ======================= Montage =======================

sudo mount -t davfs "$WEBDAV_URL" "$MOUNT_POINT" -o uid=$(id -u),gid=$(id -g) || {
    echo "Erreur : Impossible de monter le WebDAV."
    exit 1
}

echo "WebDAV monté avec succès sur $MOUNT_POINT"


# ======================= Opérations Locales =======================

# Fonction pour récupérer l'année scolaire
get_academic_year() {
    # Obtenir l'année actuelle
    current_year=$(date +%Y)
    # Obtenir le mois et le jour actuels
    month_day=$(date +%m-%d)

    # Vérifier si la date est après le 1er septembre
    if [[ "$month_day" > "09-01" ]]; then
        echo "$current_year-$((current_year + 1))"
    else
        echo "$((current_year - 1))-$current_year"
    fi
}

# Fonction pour demander une date et la convertir au format AAAA-MM-JJ
get_CA_date() {
    while true; do
        read -p "Veuillez entrer la date du CA (JJ/MM/AAAA) : " input_date

        # Vérifier le format de la date
        if [[ "$input_date" =~ ^([0-2][0-9]|3[01])\/(0[1-9]|1[0-2])\/([0-9]{4})$ ]]; then
            day=${input_date:0:2}
            month=${input_date:3:2}
            year=${input_date:6:4}

            # Convertir au format AAAA-MM-JJ
            formatted_date="$year-$month-$day"
            echo $formatted_date
            break
        else
            echo "Erreur : Format de date invalide. Veuillez entrer la date au format JJ/MM/AAAA."
        fi
    done
}


# -------------------- Variables de chemin --------------------

main_tex_path=""
token_ca_path=""
chor_path=""
ca_date="$1"
if [[ "$ca_date" == "-1" ]]; then
    echo "Aucune date n'a été fournie."
    ca_date=$(get_CA_date)
fi
academic_year=$(get_academic_year)

# -------------------- Vérifier si les fichiers sont présents en local --------------------
# On vérifie que :
# - main.tex existe (il s'agit du fichier source latex de Overleaf)
# - Un fichier contenant 'CA' dans son nom existe (il s'agit du compte-rendu CA)
# - Un fichier contenant 'CHOR' dans son nom existe (il s'agit du compte-rendu Choriste)

# Vérifier si main.tex existe
if [[ -f "$current_directory/main.tex" ]]; then
    main_tex_path="$current_directory/main.tex"
else
    echo "Erreur : le fichier main.tex n'existe pas dans le répertoire courant."
    exit 1
fi

# Vérifier si un fichier contenant 'CA' dans son nom existe
for file in "$current_directory"/*CA*; do
    if [[ -f "$file" ]]; then
        token_ca_path="$file"
        break  # Sortir de la boucle après avoir trouvé le premier fichier
    fi
done

if [[ -z "$token_ca_path" ]]; then
    echo "Erreur : Aucun fichier contenant 'CA' dans son nom n'existe dans le répertoire courant."
    exit 1
fi

# Vérifier si un fichier contenant 'CHOR' dans son nom existe
for file in "$current_directory"/*CHOR*; do
    if [[ -f "$file" ]]; then
        chor_path="$file"
        break  # Sortir de la boucle après avoir trouvé le premier fichier
    fi
done

if [[ -z "$chor_path" ]]; then
    echo "Erreur : Aucun fichier contenant 'CHOR' dans son nom n'existe dans le répertoire courant."
    exit 1
fi

# ======================= Opérations sur NextCloud =======================

# -------------------- Chemin des fichiers sur NextCloud --------------------
# /!\ Si les chemins changent, il faut les mettre à jour ici /!\

CA_filepath="$MOUNT_POINT/${academic_year}/Compte-rendus CA"
CHOR_filepath="$MOUNT_POINT/www/Fichiers Choristes/Vie associative/Compte-rendus des réunions CA/fichiers"


ca_date_folder="$CA_filepath/$ca_date"

if [ -e "$ca_date_folder" ]; then
    echo "Warning : Le dossier $ca_date existe déjà. Il contient peut-être des fichiers."
    read -p "Voulez-vous continuer ? [Y/n] : " response
    if [[ ! "$response" =~ [Yy] ]]; then
        echo "Opération annulée."
        exit 0  # Terminer le programme si l'utilisateur ne veut pas continuer
    fi
else
    # Créer le dossier de la date
    sudo mkdir -p "$ca_date_folder"  # Créer le répertoire si nécessaire
    echo "Fichier $ca_date créé avec succès."
fi

CA_filepath=$ca_date_folder

# -------------------- Opération sur le NextCloud --------------------

cp "$main_tex_path" "$CA_filepath/main.tex"
cp "$token_ca_path" "$CA_filepath/CR_${ca_date}_CA.pdf"
cp "$chor_path" "$CA_filepath/CR_${ca_date}_VersionChoriste.pdf"
cp "$chor_path" "$CHOR_filepath/Compte-rendu CA ${ca_date}.pdf"

echo "Fichiers copiés avec succès sur NextCloud."

unmount_webdav


# ======================= Générer les fichiers auxiliaires =======================

# Récupérer le répertoire du script principal
script_dir="$(dirname "$(realpath "$0")")"

# Construire le chemin du sous-script
sub_script="$script_dir/generateLinks.sh"

# Appeler le sous-script
"$sub_script" "$CA_filepath/CR_${ca_date}_CA.pdf" "$CHOR_filepath/Compte-rendu CA ${ca_date}.pdf"    