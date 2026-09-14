#!/usr/bin/env bash
set -Eeuo pipefail

# Creates the exact root-level ZIP consumed by the Deploy to Oracle Cloud button.
readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="${1:-v1.0.0}"
readonly OUT="$ROOT/dist/my-ai-staff-oci-stack-${VERSION}.zip"

rm -rf "$ROOT/dist"
mkdir -p "$ROOT/dist"
(cd "$ROOT" && zip -qr "$OUT" . -x 'dist/*' -x '.terraform/*')
echo "$OUT"
