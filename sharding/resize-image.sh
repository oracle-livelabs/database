#!/bin/bash
set -e
in="$1"; out="$2"; width="${3:-800}"
ffmpeg -i "$in" -vf "scale=${width}:-1" "$out"

