#!/bin/bash

# Nom du fichier pour lequel vérifier les liens
FILE_NAME="README.md"

# Expression régulière pour extraire les liens URL
URL_REGEX="http[s]?:\/\/[^)]+"

# Extraire tous les liens URL et les stocker dans un tableau
URLS=($(grep -Eo $URL_REGEX $FILE_NAME))

# Pour chaque URL...
for url in ${URLS[*]}
do
  # Utilisez curl pour obtenir le code de statut HTTP
  status=$(curl --write-out "%{http_code}" --silent --output /dev/null $url)

  # Vérifiez si le code de statut est dans la plage 200-399 (succès)
  if [[ $status -ge 200 && $status -lt 400 ]]
  then
    echo "Le lien $url fonctionne bien, statut $status"
  else
    echo "Erreur: Le lien $url ne fonctionne pas, statut $status"
  fi
done

