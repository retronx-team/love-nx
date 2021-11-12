# ![love-nx icon](icon.jpg)
**love-nx** is a port of the [LÖVE](https://love2d.org/) game engine to Nintendo Switch homebrew.

## Usage
### Running games
Put a LÖVE archive named `game.love` in the same folder as the NRO file of the latest release. Additionally, you can directly drop the contents of the archive in the folder, as long as it contains a `main.lua` file.

You can also add a file association for `.love` files to [nx-hbmenu](https://github.com/switchbrew/nx-hbmenu). Copy the contents from [here](extras/nx-hbmenu) to the root of your microSD card, and merge folders if asked. Make sure no `game.love` or `main.lua` file is present when using this method, otherwise they will load instead.

## Development
### Build dependencies
For building, you need the devkitA64 from devkitPro setup, along with switch portlibs and libnx.
Documentation to setup that can be found [here](https://switchbrew.org/wiki/Setting_up_Development_Environment).

### Packaging games
To produce self-contained NRO files, download the latest release, and run the following commands:

```
# Customize $APP_* vars to your liking

mkdir romfs
cp game.love romfs/game.love # Your game here
"$DEVKITPRO/tools/bin/nacptool" --create "$APP_TITLE" "$APP_AUTHOR" "$APP_VERSION" game.nacp
"$DEVKITPRO/tools/bin/elf2nro" love.elf "game.nro" --icon="$APP_ICON" --nacp="game.nacp" --romfsdir="romfs"
```

### Compiling from source
Run one the following command from the project root to build:

```
./build.sh
```

NRO and ELF files will be located in the `dist` folder.

## Known limitations
* Message boxes only log to stdout because of a lack of message box support on the Switch.
