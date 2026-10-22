#!/usr/bin/env bash
# Render the rack and save a frame, so a person can look at the weapons.
#   tools/screenshot.sh                 # screenshots/rack.png: every weapon side on
#   tools/screenshot.sh smg             # screenshots/smg.png: one weapon close up
#   tools/screenshot.sh --all           # rack plus one frame per weapon
#   tools/screenshot.sh --view m4 knife   # screenshots/view-m4.png: hip, draw, aim, fire, recoil, reload
#   tools/screenshot.sh --world m4        # screenshots/world-m4.png: a watcher's view of a person
# Not --headless: Godot's headless driver renders nothing, and a black PNG looks like a result.
# The scene saves its own viewport (--shot), so no screen grabber is needed; xvfb-run gives it
# a display (the GPU boxes' shim does the same). Run it as `heavy -- tools/screenshot.sh`.
set -uo pipefail
cd "$(dirname "$0")/.."
IDS="m4 sniper knife pistol shotgun smg frag vss"
mkdir -p screenshots
touch screenshots/.gdignore

shoot() {
    local weapon="$1" out="$2"
    xvfb-run -a -s "-screen 0 1280x720x24" timeout 90 godot --path . --resolution 1280x720 \
        res://examples/zz_rack.tscn -- ${weapon:+--weapon "$weapon"} --shot "$PWD/$out" >/dev/null 2>&1
    if [ -s "$out" ]; then echo "wrote $out"; else echo "capture failed: $out" >&2; fi
}

# A contact sheet of the view model (--view) or of a watcher's view of a person (--world).
sheet() {
    local mode="$1" weapon="$2" out="screenshots/$1-$2.png"
    xvfb-run -a -s "-screen 0 1280x720x24" timeout 120 godot --path . --resolution 1280x720 \
        res://examples/zz_view.tscn -- --weapon "$weapon" --shot "$PWD/$out" $([ "$mode" = world ] && echo --world) >/dev/null 2>&1
    if [ -s "$out" ]; then echo "wrote $out"; else echo "capture failed: $out" >&2; fi
}

case "${1:-}" in
    --view)  shift; for w in "${@:-m4}"; do sheet view "$w"; done ;;
    --world) shift; for w in "${@:-m4}"; do sheet world "$w"; done ;;
    "")    shoot "" screenshots/rack.png ;;
    --all) shoot "" screenshots/rack.png; for w in $IDS; do shoot "$w" "screenshots/$w.png"; done ;;
    *)     shoot "$1" "screenshots/$1.png" ;;
esac
