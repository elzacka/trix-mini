#!/bin/sh
# winget manifests for a published release: dist/winget/manifests/e/elzacka/TrixMini/<version>/, the layout of microsoft/winget-pkgs.
set -eu
cd "$(dirname "$0")/.."
VERSION=${1:?usage: scripts/winget.sh <version>}
TAG=v$VERSION
ID=elzacka.TrixMini
SCHEMA=1.12.0
OUT=dist/winget/manifests/e/elzacka/TrixMini/$VERSION
URL=https://github.com/elzacka/trix-mini/releases/download/$TAG/Trix-Mini-Windows.zip

TMP=$(mktemp -d)
gh release download "$TAG" -R elzacka/trix-mini -p Trix-Mini-Windows.zip -D "$TMP"
SHA=$(shasum -a 256 "$TMP/Trix-Mini-Windows.zip" | cut -d' ' -f1 | tr a-f A-F)
DATE=$(gh release view "$TAG" -R elzacka/trix-mini --json publishedAt -q '.publishedAt[:10]')
mkdir -p "$OUT"

cat > "$OUT/$ID.yaml" <<EOF
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.version.$SCHEMA.schema.json
PackageIdentifier: $ID
PackageVersion: $VERSION
DefaultLocale: en-US
ManifestType: version
ManifestVersion: $SCHEMA
EOF

cat > "$OUT/$ID.installer.yaml" <<EOF
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.installer.$SCHEMA.schema.json
PackageIdentifier: $ID
PackageVersion: $VERSION
InstallerType: zip
NestedInstallerType: portable
NestedInstallerFiles:
- RelativeFilePath: Trix Mini\\Trix Mini.exe
  PortableCommandAlias: trix-mini
UpgradeBehavior: uninstallPrevious
Commands:
- trix-mini
ReleaseDate: $DATE
Installers:
- Architecture: x64
  InstallerUrl: $URL
  InstallerSha256: $SHA
ManifestType: installer
ManifestVersion: $SCHEMA
EOF

cat > "$OUT/$ID.locale.en-US.yaml" <<EOF
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.defaultLocale.$SCHEMA.schema.json
PackageIdentifier: $ID
PackageVersion: $VERSION
PackageLocale: en-US
Publisher: elzacka
PublisherUrl: https://github.com/elzacka
PublisherSupportUrl: https://github.com/elzacka/trix-mini/issues
PackageName: Trix Mini
PackageUrl: https://github.com/elzacka/trix-mini
License: MIT
LicenseUrl: https://github.com/elzacka/trix-mini/blob/main/LICENSE
ShortDescription: Tray app with your own keyboard shortcuts and a cheat sheet, read from Markdown files you edit. No network.
Moniker: trix-mini
Tags:
- cheat-sheet
- keyboard-shortcuts
- markdown
- portable
- tray
ReleaseNotesUrl: https://github.com/elzacka/trix-mini/releases/tag/$TAG
ManifestType: defaultLocale
ManifestVersion: $SCHEMA
EOF

ls "$OUT"
