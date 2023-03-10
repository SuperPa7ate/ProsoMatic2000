#Le principe de ce script est de pouvoir comparer les mesures de pitch de deux fichiers audio. Praat ne permettant pas de faire des fonctions, il s'agit du même morceau de code répété deux fois.
#En entrée : son : fichier wav, texte : fichier textgrid (passé sur easyalign au préalable)
#Traitement : Mesure du pitch au début et à la fin de chaque syllabe pour les deux fichiers, calcul du pourcentage d'évolution entre les deux mesures, puis comparaison des pourcentages obtenus entre le fichier 1 et le fichier 2.
#Sortie : un txt avec quelques informations et un CSV avec une colonne pour les syllabes, une pour les mesures de pourcentage du premier fichier, une pour les mesures de pourcentage du second fichier, et enfin un flag de "similarité" d'évolution entre les deux fichiers (seuil de 10% arbitraire)

#Disclaimer : ceci n'est qu'une ébauche de concept de comparaison de pitch, je n'ai malheureusement pas trouvé tant de papiers qui en traitaient, ceci est purement exploratoire. 
#Disclaimer 2 : pour ce script, on part du principe que les audios ont le même textgrid (autrement dit que deux locuteurs différents disent la même chose)

clearinfo

writeInfoLine: "Lancement du script, attachez vos ceintures."

#entrée
#Dans le cadre de ProsoMatic, il faudrait aller chercher les fichiers ainsi que les TextGrid directement au chemin d'accès (type "...\ProSomatic-main\projet\static\exercices\prince\exemple\prince_1.wav")
fichierWav1$="prince_1.wav"
fichierWav2$="prince_2.wav"
txtgrd1$="prince_1.TextGrid"
txtgrd2$="prince_2.TextGrid"

#fichier de sortie
#De la même manière que plus haut, préciser un chemin d'accès pour l'écriture du fichier (type "...ProSomatic-main\projet\static\sorties_praat\sortie.txt")
sortie$="sortie.txt"
appendInfoLine: "Le fichier de sortie est ", sortie$
writeFileLine: sortie$


#lecture des entrées

appendInfoLine: "lecture des fichiers : ", fichierWav1$, "et", fichierWav2$, "ainsi que leur TextGrid respectif"

son = Read from file: fichierWav1$
son2 = Read from file: fichierWav2$
txtgrd1= Read from file: txtgrd1$
txtgrd2= Read from file: txtgrd2$


#Paramétrage des objets (pour le pitch et le nombre de syllabes pour chaque fichier audio)
selectObject: son
pitch=To Pitch: 0, 75, 600

selectObject: txtgrd1
syll=2
nbSyll = Get number of intervals: syll
appendInfoLine: txtgrd1$, "nb de syll ", nbSyll


selectObject: son2
pitch2=To Pitch: 0, 75, 600

selectObject: txtgrd2
syll2=2
nbSyll2 = Get number of intervals: syll2
appendInfoLine: txtgrd2$, "nb de syll ", nbSyll2

#Début du traitement à proprement parlé
    #Initialisation de deux compteurs (un pour chaque fichier)
    #Nécessaire à cause du fonctionnement des arrays dans Praat (évite d'avoir des emplacements null)
    nb_de_syllabes_avec_label=0
    nb_de_syllabes_avec_label2=0
    
    #Parcours de 1 au nombre de syllabe du fichier 1 (considéré comme étant le fichier exemple)
    for i from 1 to nbSyll 

        #Traitement du premier fichier (fichierWav1$)
        #Récupération de l'ensemble des labels de la Tier syllabe (+ affichage dans le log des syllabes)
        selectObject: txtgrd1
        label$ = Get label of interval: syll, i
        appendInfoLine: "tour n°", i, "label=", label$

        #Condition pour ne pas traiter les labels vides        
        if label$<>"_"

            #Mise à jour du compteur + array qui contient la liste des labels non-vides (on part du principe que les deux audios ont le même découpage syllabique/contiennent le même nombre de syllabes)
            nb_de_syllabes_avec_label=nb_de_syllabes_avec_label+1
            syllabes$[nb_de_syllabes_avec_label] = label$

            #Ecriture du label en cours de traitement dans le fichier de sortie
            appendFileLine: sortie$, "label=", label$ 

            #Récupération des données temporelles de chaque syllabe
            tempsDebut= Get starting point: syll, i
            tempsFin = Get end point: syll, i
            appendFileLine: sortie$, "Le segment dure ", round((tempsFin-tempsDebut)*1000)," ms"
            
            #Mesure du pitch aux bornes temporelles
            selectObject: pitch
            f0_deb = Get value at time: tempsDebut, "Hertz", "linear"
            f0_fin = Get value at time: tempsFin, "Hertz", "linear"
            
            #Calcul de pourcentage entre les deux mesures de f0 si les deux variables le permettent + stockage dans un array
                if f0_deb>0 and f0_fin>0
                    f0_pourcent=(f0_fin-f0_deb)/f0_deb
                    pourcentage1[nb_de_syllabes_avec_label]=f0_pourcent

            #si l'une des deux mesures est manquantes (easyalign ne place pas toujours les bornes exactement au début du signal, on peut donc se retrouver avec des mesures vides "--undefined--") on met une valeur par défaut (pour conserver le lien avec l'index des labels)
                else
                    pourcentage1[nb_de_syllabes_avec_label]=666
                endif
            
            #Ecriture dans la sortie
            appendFileLine: sortie$, "f0_deb= ", f0_deb, tab$, "f0_fin= ", f0_fin
        endif


        #Traitement du second fichier (fichierWav2$)
        #C'est un quasi copié collé du code au-dessus
        selectObject: txtgrd2
        label2$ = Get label of interval: syll2, i

        appendInfoLine: "tour n°", i, "label2=", label2$

        if label2$<>"_"
        
            nb_de_syllabes_avec_label2=nb_de_syllabes_avec_label2+1
            appendFileLine: sortie$, "label=", label2$ 

            tempsDebut2= Get starting point: syll2, i
            tempsFin2 = Get end point: syll2, i
            appendFileLine: sortie$, "Le segment dure ", round((tempsFin2-tempsDebut2)*1000)," ms"
            
            selectObject: pitch2
            f0_deb2 = Get value at time: tempsDebut2, "Hertz", "linear"
            f0_fin2 = Get value at time: tempsFin2, "Hertz", "linear"
            
            if f0_deb2>0 and f0_fin2>0
                f0_pourcent2=(f0_fin2-f0_deb2)/f0_deb2
                pourcentage2[nb_de_syllabes_avec_label2]=f0_pourcent2
            else
                pourcentage2[nb_de_syllabes_avec_label2]=666
            endif
        endif
    endfor

    #Une fois toutes les syllabes traitées pour les deux fichiers, on peut faire un """calcul de similarité""" entre les deux (on prend les pourcentages calculés pour les deux et on regarde si l'évolution est raccord à +-10%) + écriture dans un fichier CSV
    #De la même manière que plus haut, préciser un chemin d'accès pour l'écriture du fichier (type "...ProSomatic-main\projet\static\sorties_praat\sortie_csv.csv")

    csv$="sortie_csv.csv"
    writeFileLine: csv$, "syllabe, pourcentage fichier 1, pourcentage fichier 2, similarité ? (y/n)"
    flagY=0
    flagN=0

    for i from 1 to nb_de_syllabes_avec_label
        appendInfoLine: syllabes$[i]
        appendInfoLine: pourcentage1[i]
        appendInfoLine: pourcentage2[i]

        if pourcentage2[i]>pourcentage1[i]*0.75 and pourcentage2[i]<pourcentage1[i]*1.25
            appendFileLine: csv$, syllabes$[i],",", pourcentage1[i],",", pourcentage2[i],",", "y"
            appendInfoLine: "La syllabe :", syllabes$[i], ". Similarité d'évolution entre les deux fichiers audio."
            flagY= flagY+1
        else
            appendFileLine: csv$, syllabes$[i], ",", pourcentage1[i], ",", pourcentage2[i], ",", "n"
            appendInfoLine: "La syllabe :", syllabes$[i], ". La prosodie des deux fichiers diffèrent."
            flagN=flagN+1
        endif
    endfor

    #Calcul du pourcentage de similarité global entre les deux fichiers
    similarite=flagY/(flagY+flagN)
    if similarite >= 0.75
        appendInfoLine: "Les deux fichiers sont similaires à ", similarite, "%. Nos calculs sont très savants."
    else
        appendInfoLine: "La prosodie n'est pas assez similaire (", similarite, "%). Tout a été calculé. Mais je suis mauvais en maths."
    endif

# Effacer les objets chargés pour le traitement
select all
Remove