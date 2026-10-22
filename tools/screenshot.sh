#!/usr/bin/env bash
# Render the rack and save a frame, so a person can look at the weapons.
#   tools/screenshot.sh                 # screenshots/rack.png: every weapon side on
#   tools/screenshot.sh smg             # screenshots/smg.png: one weapon close up
#   tools/screenshot.sh --all           # rack plus one frame per weapon
# Not --headless: Godot's headless driver renders nothing, and a black PNG looks like a result.
# The scene saves its own viewport (--shot), so no screen grabber is needed; xvfb-run gives it
# a display (the GPU boxes' shim does the same). Run it as `heavy -- tools/screenshot.sh`.
set -uo pipefail
cd "$(dirname "$0")/.."
IDS="m4 sniper knife pistol shotgun smg frag"
mkdir -p screenshots
touch screenshots/.gdignore

shoot() {
    local weapon="$1" out="$2"
    xvfb-run -a -s "-screen 0 1280x720x24" timeout 90 godot --path . --resolution 1280x720 \
        res://examples/zz_rack.tscn -- ${weapon:+--weapon "$weapon"} --shot "$PWD/$out" >/dev/null 2>&1
    if [ -s "$out" ]; then echo "wrote $out"; else echo "capture failed: $out" >&2; fi
}

case "${1:-}" in
    "")    shoot "" screenshots/rack.png ;;
    --all) shoot "" screenshots/rack.png; for w in $IDS; do shoot "$w" "screenshots/$w.png"; done ;;
    *)     shoot "$1" "screenshots/$1.png" ;;
esac
