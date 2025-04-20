# Scripted Aliases



## Installation

Pour installer cet utilitaire sur votre machine (attention à ce que vous piper dans bash !)

```bash
curl https://raw.githubusercontent.com/Romb38/ScriptedAliases/refs/heads/master/install.sh | bash
```

Ensuite redémarrer votre terminal ou faites :

```bash
# For ZSH users
source $HOME/.zshrc

# For bash users
source $HOME/.bashrc
```


## Usage

### Base

La commande de base est `ms`, elle vous permet d'intéragir avec tous les alias

### Gestion des répertoires d'alias

L'utilitaire source uniquement les dossier qui on été répertorié comme étant des répertoires d'alias. Pour les manipuler la commande est la suivante :

```bash
ms md
```

Avec les options suivantes
```bash
Commandes disponibles :
  list                       Liste les répertoires enregistrés
  add [-r] <chemin>          Ajoute un répertoire ou tous les sous-répertoires
  remove [-r] <chemin>       Supprime un répertoire ou tous ceux qui en dépendent
  reset                      Supprime tous les répertoires
  help                       Affiche cette aide
```

### Gestion des alias 
Pour ajouter un alias, vous devez
- Créer un fichier .sh avec votre code dedans dans un répertoire d'alias
- Ajouter a ce fichier le flag correspondant
- Exécuter `ms source`

### Flags disponible

- \#MS_ALIAS="<alias>" : Ce flag permet de définir l'alias pour votre script
- \#MS_SUDO : Ce flag indique que ce script doit être joué en tant que superutilisateur
- \#MS_IGNORE : Ce flag indique que ce script doit être ignoré lors du sourçage

## Les commandes par défaut

TODO

## Désinstallation

Pour désinstaller ScriptedAliases, utilisez la commandes suivante

```bash
ms uninstall
```