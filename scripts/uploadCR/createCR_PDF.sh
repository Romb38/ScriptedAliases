#!/bin/bash

# ===================== ENTRYPOINT =====================


generate_pdf() {
    local pdf_name="$1"
    local script_dir="$(dirname "$(realpath "$0")")"
    local cls_file="$script_dir/templates/RainbowCR.cls"
    local tex_file="$PWD/main.tex"

    # Vérifie que le fichier de classe personnalisé existe
    if [[ ! -f "$cls_file" ]]; then
        echo "Erreur : Le fichier de classe '$cls_file' est introuvable." >&2
        exit 1
    fi

    # Vérifie que le fichier main.tex existe
    if [[ ! -f "$tex_file" ]]; then
        echo "Erreur : Le fichier 'main.tex' est introuvable dans le répertoire courant." >&2
        exit 1
    fi

    cp "$cls_file" "$PWD/"

    # Exécute le conteneur Docker pour compiler le fichier LaTeX
    if ! docker run --rm -v "$PWD":/workdir texlive/texlive pdflatex -interaction=nonstopmode -output-directory=/workdir main.tex >> /dev/null; then
        echo "Erreur : Échec de la compilation du fichier LaTeX." >&2
        exit 1
    fi

    mv "$PWD/main.pdf" "$PWD/$pdf_name"

    echo "PDF généré avec succès : $PWD/$(basename "$pdf_name")"

    rm -f "$PWD/RainbowCR.cls"
    rm -f "$PWD/main.aux" "$PWD/main.log" "$PWD/main.out" "$PWD/main.toc"
}

check_version() {
    local tex_file="$PWD/main.tex"
    local out=""

    # Vérifie que le fichier main.tex existe
    if [[ ! -f "$tex_file" ]]; then
        echo "Erreur : Le fichier 'main.tex' est introuvable dans le répertoire courant." >&2
        exit 1
    fi

    # Utilise sed pour ajouter ou enlever le % sur la ligne contenant \versionchoriste
    if grep -q "\\versionchoriste" "$tex_file"; then
        if grep -q "^\s*%.*\\versionchoriste" "$tex_file"; then
            # Enlève uniquement le % au début de la ligne contenant \versionchoriste
            sed -i '/^\s*%.*\\versionchoriste/s/^\s*%//g' "$tex_file"  # Enlève le % uniquement sur cette ligne
            out="Version_CHOR.pdf"
        else
            # Ajoute le % au début de la ligne contenant \versionchoriste
            sed -i '/\\versionchoriste/s/^/%/' "$tex_file"  # Ajoute le % uniquement sur cette ligne
            out="Version_CA.pdf"
        fi
    fi

    echo "$out"
}

get_date() {
    local tex_file="$PWD/main.tex"
    local date_value="-1"  # Valeur par défaut

    # Vérifie que le fichier main.tex existe
    if [[ ! -f "$tex_file" ]]; then
        echo "Erreur : Le fichier 'main.tex' est introuvable dans le répertoire courant." >&2
        exit 1
    fi

    # Recherche la chaîne %date=date et extrait la date
    if grep -q "%date=" "$tex_file"; then
        date_value=$(grep "%date=" "$tex_file" | sed 's/.*%date=\(.*\)/\1/')
        
        # Vérification du format de la date (YYYY-MM-DD)
        if ! [[ "$date_value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            date_value="-1"  # Date invalide
        fi
    fi

    echo "$date_value"
}

# Obtenir la date et vérifier les versions
date=$(get_date) || exit 1
name=$(check_version) || exit 1
echo "Génération de la version : $name"
generate_pdf "$name" || exit 1

# Répéter pour générer à nouveau
name=$(check_version) || exit 1
echo "Génération de la version : $name"
generate_pdf "$name" || exit 1

# Appel du script d'upload
"$(dirname "$(realpath "$0")")/uploadCRNextcloud.sh" "$date"
