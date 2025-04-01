#Made by Romb38
#Version 1.0
#Date: 2021-01-25


def parsing_texFile(lines):
    """
    Prends des lignes et ressort le texte entre les blocs \\begin{task} et \end{task} avec les prénoms

    @param lines Toutes les lignes du fichier
    @return Tableau des lignes écrit de façon planes (sans commandes)
    """
    flag = False
    toWrite = []

    for line in lines:
        if "\\begin{task}" in line and not(line.startswith("%")):
            flag = True
            nom = "[A définir] "
            if "[" in line and "]" in line:
                nom = "[" + line.split("[")[1].split("]")[0] + "] "
            chn = nom
        elif "\\end{task}" in line:
            toWrite.append(chn.replace("\n", ""))
            flag = False
        elif flag:
            words = line.strip().split()
            cleaned_words = []
            for word in words:
                if not (word.startswith("\\") and "{" in word):
                    word = word.split("\\")[0]
                    word = word.replace("}", "")
                    cleaned_words.append(word)
            chn += " ".join(cleaned_words) + "\n"

    return toWrite

def toTxt(toWrite,path="."):
    """
    Ecrit dans un fichier texte les tâches à faire en fonctions des noms proposés

    @param toWrite Tableau des tâches à écrire
    @param path Chemin où écrire le fichier
    """
    with open(path+"/output.txt", "w") as f:
        for line in toWrite:
            if line:
                f.write(line)
                f.write("\n")
    return

def getNames(line):
    """
    Récupère les noms entre crochet et en fait une liste

    @param line Ligne à analyser
    @return Liste des noms
    """
    return line[line.find("[")+1:line.find("]")].replace(" ","").replace("Adéfinir","A définir").split(",")

def preTreatment(toWrite):
    """
    Pré-traitement pour le fichier CSV 

    @param toWrite Tableau des tâches à écrire
    @return Tableau des tâches à écrire corrigé pour le CSV
    """
    out = []
    
    for i in range(len(toWrite)):
        #On récupère les noms
        names = getNames(toWrite[i])

        #On recopie pour chaque nom la tâche en mettant les autres noms dans la colonne "Avec"
        for n in names:
            #Pour les noms potentiel, on retire les parenthèses
            n = n.replace("(","")
            n = n.replace(")","")
            
            #On retire les noms de la tâche pour ne pas les répéter
            task = "["+n+"]"+toWrite[i][toWrite[i].find("]") + 1:]

            #On ajoute les autres noms dans la colonne "Avec"
            if len(names)>1:
                task+= ";"+", ".join([x for x in names if x != n])
            out.append(task)
    return out

def toCSV(toWrite,path="."):
    """
    Ecrit dans un fichier CSV les tâches à faire en fonctions des noms proposés

    @param toWrite Tableau des tâches à écrire
    @param path Chemin où écrire le fichier
    """
    toWrite = preTreatment(toWrite)
    with open(path+"/output.csv", "w") as f:
        f.write("Nom;Tâche;Avec\n")
        for line in toWrite:
            if line:
                chn = line.replace("[","")
                chn = chn.replace("]",";")
                f.write(chn)
                f.write("\n")
    return

def getTexFile(folder_path):
    """
    Trouve et renvoie les lignes du fichier main.tex présent dans le dossier
    @param path: Chemin du dossier
    @return: lignes du fichier main.tex
    """
    import os
    for file in os.listdir(folder_path):
        if file.endswith(".tex") and file.startswith("main"):
            with open(folder_path+"/"+file) as f:
                return f.readlines()
    return []

def main():
        """
        FONCTION DE TEST, N'EST PAS UTILISEE
        """
        from tkinter import filedialog
        file_path = filedialog.askopenfilename(filetypes=[("Fichiers LaTeX", "*.tex")])
        if not(file_path):
            return
        file = open(file_path)
        lines = file.readlines()
        file.close()
        
        # On parse le fichier latex
        toWrite = parsing_texFile(lines)
        
        # On écrit les fichiers résultats
        toCSV(toWrite)
        toTxt(toWrite)

        return

if __name__ == "__main__":
    main()