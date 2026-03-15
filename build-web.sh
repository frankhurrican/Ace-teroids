#!/usr/bin/env bash
# build-web.sh — repackage and rebuild the Ace-teroids web build.
#
# Usage:
#   ./build-web.sh          # build only
#   ./build-web.sh --serve  # build then serve at http://localhost:8000

set -e
cd "$(dirname "$0")"

# 1. Repackage .love
echo "Packaging Ace-teroids.love..."
rm -f Ace-teroids.love
powershell -Command "Compress-Archive -Path main.lua,conf.lua,anim8.lua,src,assets -DestinationPath Ace-teroids.zip"
mv Ace-teroids.zip Ace-teroids.love

# 2. Rebuild web
echo "Building web build..."
love.js Ace-teroids.love docs/ --title "Ace-teroids" --memory 33554432

# 3. Restore coi-serviceworker.js (love.js clears the output directory)
cp coi-serviceworker.js docs/coi-serviceworker.js

# 4. Inject coi-serviceworker script tag
sed -i 's|  <head>|  <head>\n    <script src="coi-serviceworker.js"></script>|' docs/index.html

echo ""
echo "Build complete. Open http://localhost:8000 after starting a server."

# 5. Optionally serve
if [ "$1" = "--serve" ]; then
    echo "Serving at http://localhost:8000 ..."
    python -m http.server 8000 --directory docs
fi
