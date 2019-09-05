#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"

APP_NAME="love"
APP_TITLE="LÖVE"
APP_AUTHOR="LÖVE team; port by p-sam"
APP_VERSION="$(git describe --dirty --always --tags)"
APP_ICON="$ROOT_DIR/icon.jpg"
