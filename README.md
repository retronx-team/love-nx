LÖVE Switch Port
==================

<p align="center"><img src="icon.jpg"></p>

## Usage

### Running game

Put a LÖVE archive named `game.love` in the same folder as the NRO file of the latest release.
Additionally, you can directly drop the contents of the archive in the folder, as long as it contains a `main.lua` file.

## Development

### Build dependencies

For building, you need the devkitA64 from devkitPro setup, along with switch portlibs and libnx.
Documentation to setup that can be found [here](https://switchbrew.org/wiki/Setting_up_Development_Environment).

### Packaging games

To produce self-contained game NRO files, download the latest release, and run the following commands:

```
# Customize $APP_* vars to your liking

mkdir romfs
cp game.love romfs/game.love # Your game here
"$DEVKITPRO/tools/bin/nacptool" --create "$APP_TITLE" "$APP_AUTHOR" "$APP_VERSION" game.nacp
"$DEVKITPRO/tools/bin/elf2nro" love.elf "game.nro" --icon="$APP_ICON" --nacp="game.nacp" --romfsdir="romfs"
```

**Note:** All the required tools to package a game can also be compiled [from this repo](https://github.com/switchbrew/switch-tools)

### Compiling from source

Run one the following command from the project root to build:

```
./build.sh
```

NRO and ELF files will be located in the `dist` folder.

## Known differences with PC

* `love.window.showMessageBox()` logs arguments to stdout
* Using LuaJIT v2.1 instead of v2.0
