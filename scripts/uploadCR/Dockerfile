# Utiliser une image de base Debian
FROM debian:latest

# Mettre à jour les paquets et installer les dépendances
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    davfs2 \
    texlive-full \
    python3 \
    python3-pip \
    bash

# Déclarer les variables d'environnement sensibles
ENV CA_USERNAME="rainbowca"
ENV CA_PASSWORD="DJ8oF-x2yy8-bqKmW-ReYwX-HfAnx"

# Ajouter la clé GPG officielle de Docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Ajouter le dépôt Docker officiel aux sources apt
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker CLI
RUN apt-get update && apt-get install -y docker-ce-cli

# Copier les fichiers du projet
COPY . /app

# Installer les dépendances Python si nécessaires
COPY parserTasks/requirements.txt /app/parserTasks/requirements.txt
RUN pip3 install -r /app/parserTasks/requirements.txt

# Définir les droits d'accès
RUN chmod +x /app/*.sh

# Créer le point de montage pour davfs2
RUN mkdir /mnt/nextcloud && echo "use_locks 0" >> /etc/davfs2/davfs2.conf

# Copier le fichier secrets pour davfs2 (modifie si nécessaire)
COPY secrets /etc/davfs2/secrets
RUN chmod 600 /etc/davfs2/secrets

# Définir le répertoire de travail
WORKDIR /app

# Définir le point d'entrée
ENTRYPOINT ["./createCR_PDF.sh"]
