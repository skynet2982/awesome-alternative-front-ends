#!/usr/bin/env bash
#
# Vérifie que le site de chaque outil listé dans README.md répond toujours.
# Chaque outil est repéré via son lien en gras : [**Nom**](url).
#
# Usage: ./check_url.sh [fichier_de_sortie.tsv]
# Sortie: un fichier TSV (ok|broken \t code_http \t nom \t url) et un résumé sur stdout.
# Code de sortie: 0 si tous les liens répondent, 1 si au moins un lien est cassé.

set -uo pipefail

FILE_NAME="README.md"
OUTPUT_FILE="${1:-link_check_results.tsv}"
USER_AGENT="Mozilla/5.0 (compatible; AwesomeAltFrontEndsLinkChecker/1.0; +https://github.com/skynet2982/awesome-alternative-front-ends)"

: > "$OUTPUT_FILE"
exit_code=0

while IFS=$'\t' read -r name url; do
  [[ -z "$name" || -z "$url" ]] && continue

  status=$(curl \
    --silent --output /dev/null --write-out "%{http_code}" \
    --location --max-time 15 --retry 2 --retry-delay 3 \
    --user-agent "$USER_AGENT" \
    "$url")

  if [[ "$status" =~ ^[23][0-9][0-9]$ ]]; then
    result="ok"
    echo "OK    [$status] $name -> $url"
  else
    result="broken"
    exit_code=1
    echo "ECHEC [$status] $name -> $url"
  fi

  printf '%s\t%s\t%s\t%s\n' "$result" "$status" "$name" "$url" >> "$OUTPUT_FILE"
done < <(sed -nE 's/.*\[\*\*([^*]+)\*\*\]\(([^)]+)\).*/\1\t\2/p' "$FILE_NAME")

exit "$exit_code"
