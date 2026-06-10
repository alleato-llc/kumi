#!/usr/bin/env bash
#
# Builds every example and writes its page into docs/ (committed; ready to
# serve via GitHub Pages later). Each example prints its HTML to stdout, so the
# build chatter on stderr doesn't pollute the files.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p docs

for demo in report invoice article gallery; do
    out="docs/$([ "$demo" = gallery ] && echo index || echo "$demo").html"
    swift run -c release "$demo" > "$out"
    echo "wrote $out"
done
