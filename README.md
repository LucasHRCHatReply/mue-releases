# Mue pour macOS

Mue convertit vos fichiers sur le Mac, sans les envoyer nulle part : pas de site gratuit qui baisse la qualité, ajoute
un filigrane ou bloque après un essai. On dépose un ou plusieurs fichiers, Mue propose seulement les formats possibles,
et le résultat s'écrit à côté de l'original, qui n'est jamais modifié ni écrasé.

- **Images** (HEIC, JPEG, PNG, TIFF, GIF, BMP, WebP) → JPEG, PNG, HEIC, TIFF ou PDF ; réduire la taille ; retirer
  le lieu et la date ; plusieurs images → un seul PDF.
- **Vidéos** (MOV, MP4, M4V) → MP4 H.264, MP4 HEVC ou MOV, en 1080p, 720p ou 480p ; GIF animé ; le son seul en M4A ;
  une image fixe en PNG.
- **Sons** (MP3, WAV, AIFF, M4A, CAF) → M4A, WAV, AIFF ou CAF.
- **Documents** (Word, RTF, HTML, texte, ODT) → PDF, Word, RTF, texte ou HTML ; **PDF** → une image par page, ou son texte.

Tout passe par les outils intégrés à macOS : aucun compte, aucune télémétrie, aucun accès au réseau pour convertir.
macOS ne sait pas lire le WebM ni le MKV : Mue le dit au lieu d'essayer.

**Version de départ.** C'est une première version (0.1.0) : elle fait ce qui est écrit dans les notes de la Release et
rien de plus, et elle a pu être essayée sur très peu de Mac.

Ce dépôt ne contient que les versions à installer. Le code source n'est pas public.

## Ce qu'il faut

- un Mac à puce Apple (M1 ou plus récent) ;
- macOS 15 ou plus.

## Installer

Dans Terminal (Cmd + Espace, « Terminal »), une seule commande :

```
curl -fsSL https://raw.githubusercontent.com/LucasHRCHatReply/mue-releases/main/installer.sh | zsh
```

Le script télécharge la dernière version, vérifie l'empreinte SHA-256 du zip, l'identifiant de l'app et sa signature
(équipe Apple `JT9FY7PP7K`, `codesign --verify --deep --strict`), copie l'app dans ~/Applications, pose la commande
`mue` dans ~/.local/bin, puis ouvre l'app. Relancer la même commande installe une version plus récente.

Autre voie : télécharger `Mue.dmg` dans les [Releases](../../releases/latest), l'ouvrir, glisser Mue sur
Applications. Le disque est signé, non notarisé : au premier lancement, clic droit sur l'app › Ouvrir.

## En ligne de commande

```
mue photo.heic --vers jpg
mue film.mov --vers mp4 --definition 720 --qualite moyenne
mue scan1.png scan2.png --vers pdf --un-pdf
mue --formats film.mov
```

Dans le Finder : clic droit sur un fichier › Ouvrir avec › Mue.
