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

echo "** native openal-soft tools **"

mkdir -p "$BUILD_DIR/openal-soft-tools"
cd "$BUILD_DIR/openal-soft-tools"
cmake -G"Unix Makefiles" "$ROOT_DIR/repo/openal-soft/native-tools"
make -j$JOBS

echo "** env **"

source "$DEVKITPRO/switchvars.sh"
CFLAGS="$CFLAGS -I$PORTLIBS_PREFIX/include -D__SWITCH__ -I$DEVKITPRO/libnx/include"
function switch_cmake() {
	cmake -G"Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE="$DEVKITPRO/switch.cmake" \
		-DNX=1 \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="$CFLAGS $CPPFLAGS" \
		-DCMAKE_CXX_FLAGS="$CFLAGS" \
		-DCMAKE_AR="$DEVKITPRO/devkitA64/bin/aarch64-none-elf-gcc-ar" \
		"$@"
}

echo "** lua **"

mkdir -p "$BUILD_DIR/lua"
cp -auf "$ROOT_DIR/repo/lua/." "$BUILD_DIR/lua"
cd "$BUILD_DIR/lua"
make -C "$BUILD_DIR/lua" -f "$BUILD_DIR/lua/makefile" -j$JOBS liblua.a

echo "** openal-soft **"

mkdir -p "$BUILD_DIR/openal-soft"
cd "$BUILD_DIR/openal-soft"
switch_cmake "$ROOT_DIR/repo/openal-soft" \
	-DSIZEOF_LONG=8 \
	-DLIBTYPE=STATIC \
	-DALSOFT_NATIVE_TOOLS_PATH="$BUILD_DIR/openal-soft-tools" \
	-DALSOFT_DLOPEN:BOOL=OFF \
	-DALSOFT_UTILS:BOOL=OFF \
	-DALSOFT_EXAMPLES:BOOL=OFF \
	-DALSOFT_TESTS:BOOL=OFF \
	-DALSOFT_REQUIRE_NEON:BOOL=ON \
	-DALSOFT_REQUIRE_SDL2:BOOL=ON \
	-DALSOFT_BACKEND_WAVE:BOOL=OFF \
	-DALSOFT_BACKEND_SDL2:BOOL=ON
make #-j$JOBS

echo "** physfs **"

mkdir -p "$BUILD_DIR/physfs"
cd "$BUILD_DIR/physfs"
switch_cmake \
	-DPHYSFS_BUILD_SHARED=OFF -DPHYSFS_BUILD_TEST=OFF \
	"$ROOT_DIR/repo/physfs"
make -j$JOBS
CFLAGS="$CFLAGS -I$ROOT_DIR/repo/physfs/src"

echo "** LÖVE **"

mkdir -p "$BUILD_DIR/love"
cd "$BUILD_DIR/love"
switch_cmake \
	-DLOVE_JIT:BOOL=OFF \
	-DPHYSFS_LIBRARY="$BUILD_DIR/physfs/libphysfs.a" \
	-DOPENAL_LIBRARY="$BUILD_DIR/openal-soft/libopenal.a" \
	-DOPENAL_INCLUDE_DIR="$ROOT_DIR/repo/openal-soft/include" \
	-DLUA_LIBRARY="$BUILD_DIR/lua/liblua.a" \
	-DLUA_INCLUDE_DIR="$ROOT_DIR/repo/lua" \
	"$ROOT_DIR/repo/love"

make -j$JOBS

echo "** NRO **"

mkdir -p "$DIST_DIR"

cp -vf "$BUILD_DIR/love/love" "$DIST_DIR/$APP_NAME.elf"
"$DEVKITPRO/tools/bin/nacptool" --create "$APP_TITLE" "$APP_AUTHOR" "$APP_VERSION" "$DIST_DIR/$APP_NAME.nacp"
"$DEVKITPRO/tools/bin/elf2nro" "$DIST_DIR/$APP_NAME.elf" "$DIST_DIR/$APP_NAME.nro" --icon="$APP_ICON" --nacp="$DIST_DIR/$APP_NAME.nacp"
echo "Built $DIST_DIR/$APP_NAME.nro"
