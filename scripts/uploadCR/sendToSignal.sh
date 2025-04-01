# /bin/bash
# SCRIPT NON FONCTIONNEL


CA_URL = "$1"
CHOR_URL = "$1"
MY_NUMBER="+33635200911"
DEST="+33786394111"

# ======================= Création des messages de partage =======================

final_message="
[CE MESSAGE EST AUTOMATIQUE]
Voici les liens pour les comptes-rendus du CA et du Chorale :
Lien du Compte-Rendu CA : $CA_URL
Lien du Compte-Rendu Choriste : $CHOR_URL
"

csv_message="
[CE MESSAGE EST AUTOMATIQUE]
Version CSV des tâches du CA
"

txt_message="
[CE MESSAGE EST AUTOMATIQUE]
Version TXT des tâches du CA
"


# ======================= Envoi sur Signal =======================

# Construire le chemin du sous-script
# sub_script="$script_dir/signalCli/signal-cli"

# "$sub_script" send -u $MY_NUMBER -m "$final_message" "$DEST"

# "$sub_script" -u -MY_NUMBER send -m "$csv_message" -a "$PWD/output.csv" "$DEST"

# "$sub_script" -u -MY_NUMBER send -m "$txt_message" -a "$PWD/output.txt" "$DEST"

# echo "Liens envoyés avec succès sur Signal."