#!/bin/bash

set -eo pipefail

source "$( dirname "${BASH_SOURCE[0]}" )/_env.sh"

LUA_BIN="$(which luajit || which lua ||:)"

if [[ -z "$LUA_BIN" ]]; then
	echo "No lua interpreter found in PATH" 1>&2
	exit 1
fi

echo "Using lua interpreter $LUA_BIN"

cd "$ROOT_DIR/repo/love/src/scripts"

for f in *.lua; do
	if [[ -f "$f.h" ]]; then
		"$LUA_BIN" auto.lua "$f"
	fi
done

CHANGED_FILES="$(git status --porcelain --untracked-files=no)"
CHANGED_LUA_HEADERS="$(grep ".lua.h" <<< "$CHANGED_FILES" ||:)"

if [[ -n "$CHANGED_LUA_HEADERS" ]]; then
	echo -e "Unsynced lua headers found:\n$CHANGED_LUA_HEADERS" 1>&2
	exit 2
fi
