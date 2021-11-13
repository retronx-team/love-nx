#!/bin/bash

set -eo pipefail

source "$( dirname "${BASH_SOURCE[0]}" )/_env.sh"

if [[ -z "$DEVKITPRO" ]]; then
	echo "DEVKITPRO env var missing" 1>&2
	exit 1
fi

if [[ -z "$JOBS" ]]; then
	JOBS="$(nproc --all)"
fi

echo "** env **"

source "$DEVKITPRO/switchvars.sh"
CFLAGS="$CFLAGS -g -I$PORTLIBS_PREFIX/include  -I$PORTLIBS_PREFIX/include/SDL2 -D__SWITCH__ -I$DEVKITPRO/libnx/include"
export SDL2DIR="$PORTLIBS_PREFIX"

function switch_cmake() {
	cmake -G"Unix Makefiles" \
		-DCMAKE_TOOLCHAIN_FILE="$DEVKITPRO/cmake/Switch.cmake" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="$CFLAGS $CPPFLAGS" \
		-DCMAKE_CXX_FLAGS="$CFLAGS" \
		"$@"
}

echo "** luajit **"

mkdir -p "$BUILD_DIR/luajit"
cp -auf "$ROOT_DIR/repo/luajit/." "$BUILD_DIR/luajit"
make -C "$BUILD_DIR/luajit/src" -j$JOBS libluajit.a \
	CROSS="$TOOL_PREFIX" CFLAGS="" LDFLAGS="" LIBS="" TARGET_SYS="SWITCH" BUILDMODE="static" \
	XCFLAGS="-DLJ_TARGET_CONSOLE=1 -DLUAJIT_ENABLE_LUA52COMPAT -DLUAJIT_DISABLE_JIT -DLUAJIT_DISABLE_FFI -DLUAJIT_USE_SYSMALLOC" \
	TARGET_CFLAGS="$CFLAGS" TARGET_LDFLAGS="$LDFLAGS" TARGET_LIBS="$LIBS"

echo "** LÖVE **"

mkdir -p "$BUILD_DIR/love"
cd "$BUILD_DIR/love"
switch_cmake \
	-DPHYSFS_LIBRARY="$PORTLIBS_PREFIX/lib/libphysfs.a" \
	-DOPENAL_LIBRARY="$PORTLIBS_PREFIX/lib/libopenal.a" \
	-DLUAJIT_LIBRARY="$BUILD_DIR/luajit/src/libluajit.a" \
	-DLUAJIT_INCLUDE_DIR="$ROOT_DIR/repo/luajit/src" \
	"$ROOT_DIR/repo/love"

make -j$JOBS

echo "** NRO **"

mkdir -p "$DIST_DIR"

cp -vf "$BUILD_DIR/love/love" "$DIST_DIR/$APP_NAME.elf"
"$DEVKITPRO/tools/bin/nacptool" --create "$APP_TITLE" "$APP_AUTHOR" "$APP_VERSION" "$DIST_DIR/$APP_NAME.nacp"
"$DEVKITPRO/tools/bin/elf2nro" "$DIST_DIR/$APP_NAME.elf" "$DIST_DIR/$APP_NAME.nro" --icon="$APP_ICON" --nacp="$DIST_DIR/$APP_NAME.nacp"
echo "Built $DIST_DIR/$APP_NAME.nro"
