#!/usr/bin/env bash
#
# Renders every example into a directory (default: docs/, for local preview;
# CI passes _site/). Each example prints its HTML to stdout, so build chatter
# on stderr doesn't pollute the files.
#
#   Examples/render.sh            # → docs/
#   Examples/render.sh _site      # → _site/
set -euo pipefail
cd "$(dirname "$0")/.."
out="${1:-docs}"
mkdir -p "$out"

for demo in report invoice article gallery; do
    file="$out/$([ "$demo" = gallery ] && echo index || echo "$demo").html"
    swift run "$demo" > "$file"
    echo "wrote $file"
done
