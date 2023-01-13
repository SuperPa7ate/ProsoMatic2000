# LISEZ-MOI - PROSOMATIC

## Notice utilisateur

### Objectif

<p>Prosomatic est une interface web proposant aux utilisateurs d'apprendre la prosodie d'une langue dans divers contextes.</p>
<p> Il fonctionne de la manière suivante : l'utilisateur se rend sur le site prosomatic. Il n'a pas besoin de créer de compte, il peut directement aller sur l'onglet "Commencer"
 et choisir le premier exercice. Une page s'affiche avec un lecteur audio. L'apprenant écoute l'échantillon audio, puis doit s'enregistrer afin de reproduire la prosodie. Une fois qu'il juge
 son enregistrement viable, il peut cliquer sur le bouton comparer. Le bouton comparer lancera une fonction python qui fait appel à un autre logiciel : Praat. Ce logiciel calculera 
 la similarité entre les deux échantillons audio, et retournera à l'utilisateur sa performance. </p>
 
 ### D'un point de vue théorique ###
 
 Le fichier enregistré par l'apprenant est stocké sur le serveur. Il peut donc être récupéré par Django et envoyé au script Praat. Le script Praat effectue une comparaison syllabes par syllabes des deux échantillons audios
 et renvoie les différences entre les deux. Une fois le script terminé, on stocke l'ensemble de ces différences dans un fichier, qui peut-être lu et utilisé par Python. Ce fichier permettra d'afficher les performances de l'utilisateur.
 
 ### Composition du Projet ###
 
 Le projet a été réalisé avec Django, donc l'arborescence des fichiers est celle du framework :
 
 Templates : Contient les différentes pages HTML utilisées
 
 Static : Différents fichiers statiques utilisés (Scripts Js, images, échantillons audios)
 
 MyApp : contient les différents fichiers de l'applications, dont Views.py qui permet d'utiliser des fonctions python et de les lier aux pages html.
 
 TALAO : Contient les différents options de l'application Django, dont Settings.py
 
 
 ### Pour de plus amples informations
 
 Voir le wiki : https://wiki.lezinter.net/_/Projets:ProsoMatic_2000_-_LUFFROY_Rapha%C3%ABl_%26_FERNANDEZ_Romain#Constat
