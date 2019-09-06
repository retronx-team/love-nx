# PhysicsFS - https://icculus.org/physfs/

A portable, flexible file i/o abstraction.

Version 3.0.1 for Nintendo Switch Homebrew (using libnx)

## Building for Switch

```bash
rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../Toolchain.cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$DEVKITPRO/portlibs/switch \
    -DPHYSFS_BUILD_SHARED=OFF -DPHYSFS_BUILD_TEST=OFF
make
sudo make install

```

Please see the [docs](docs/) directory for documentation.
Please see [LICENSE.txt](LICENSE.txt) for licensing information.
