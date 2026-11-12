#!/bin/zsh
# Mue (convertisseur de fichiers, version de départ) — installation ou mise à jour, sans compte GitHub et sans outil à installer :
#   curl -fsSL https://raw.githubusercontent.com/LucasHRCHatReply/mue-releases/main/installer.sh | zsh
# Le script télécharge la dernière version publiée, vérifie l'empreinte SHA-256, l'identifiant et l'équipe de signature
# (codesign --verify --deep --strict), puis lance install.sh du zip : Mue.app va dans ~/Applications, la quarantaine est
# levée sur Mue.app seulement, l'app est lancée. Une instance de Mue qui tourne est quittée d'abord. Les réglages (~/Library/Application Support/Mue) ne sont jamais touchés.
set -uo pipefail
TEAM="JT9FY7PP7K"
BUNDLE_ID="fr.lucashi.mue"
ZIP_URL="https://github.com/LucasHRCHatReply/mue-releases/releases/latest/download/Mue.zip"
fail() { echo "\nÉCHEC : $*" >&2; exit 1; }
step() { echo "\n[$1/3] $2"; }

echo "Mue : convertisseur de fichiers, version de départ."
step 1 "Ce Mac convient-il ?"
macos=$(sw_vers -productVersion)
(( ${macos%%.*} >= 15 )) || fail "Mue demande macOS 15 ou plus (ce Mac : $macos)."
[[ "$(sysctl -n hw.optional.arm64 2>/dev/null)" == "1" ]] || fail "Mue ne tourne que sur les Mac à puce Apple (M1 ou plus récent)."
echo "  macOS $macos : ok"

step 2 "Téléchargement et contrôle"
WORK=$(mktemp -d "${TMPDIR:-/tmp}/mue-install.XXXXXX") || fail "dossier temporaire impossible"
trap 'rm -rf "$WORK"' EXIT
curl -fL --silent --show-error -o "$WORK/Mue.zip" "$ZIP_URL" || fail "téléchargement impossible (réseau coupé, ou aucune version publiée) : $ZIP_URL"
if curl -fL --silent -o "$WORK/Mue.zip.sha256" "$ZIP_URL.sha256" 2>/dev/null && [[ -s "$WORK/Mue.zip.sha256" ]]; then
  want=$(awk '{print $1; exit}' "$WORK/Mue.zip.sha256"); have=$(shasum -a 256 "$WORK/Mue.zip" | awk '{print $1}')
  [[ "$want" == "$have" ]] || fail "l'empreinte SHA-256 du zip ne correspond pas à celle publiée : installation refusée."
  echo "  empreinte SHA-256 : conforme"
else
  fail "l'empreinte SHA-256 publiée est introuvable : installation refusée."
fi
ditto -x -k "$WORK/Mue.zip" "$WORK/contenu" || fail "le zip est illisible"
DIR=$(ls -d "$WORK"/contenu/Mue-* 2>/dev/null | head -1)
[[ -n "$DIR" && -d "$DIR/Mue.app" && -f "$DIR/install.sh" ]] || fail "le zip n'a pas le contenu attendu (Mue-X.Y.Z/Mue.app et install.sh)."
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DIR/Mue.app/Contents/Info.plist" 2>/dev/null)" == "$BUNDLE_ID" ]] || fail "identifiant de l'app inattendu : installation refusée."
got=$(codesign -dv "$DIR/Mue.app" 2>&1 | sed -n 's/^TeamIdentifier=//p')
[[ "$got" == "$TEAM" ]] || fail "l'app n'est pas signée par l'équipe attendue ($TEAM) mais par « ${got:-aucune} » : installation refusée."
codesign --verify --deep --strict "$DIR/Mue.app" 2>/dev/null || fail "la signature de Mue.app est invalide : installation refusée."
NEW=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$DIR/Mue.app/Contents/Info.plist")
echo "  Mue $NEW, signature valide, équipe $TEAM : ok  ($(du -h "$WORK/Mue.zip" | cut -f1))"

step 3 "Installation"
zsh "$DIR/install.sh" "$@" "$DIR/Mue.app" || fail "l'installation a échoué (voir le message ci-dessus)."
echo "\nTerminé."
