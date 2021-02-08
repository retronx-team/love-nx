# Sets the following variables:
#
#  SDL2_FOUND
#  SDL2_INCLUDE_DIR
#  SDL2_LIBRARY

find_package(PkgConfig QUIET)
pkg_check_modules(PC_SDL2 QUIET sdl2)

set(SDL2_SEARCH_PATHS
	/usr/local
	/usr
	)

find_path(SDL2_INCLUDE_DIR
	NAMES SDL.h
	HINTS ${PC_SDL2_INCLUDEDIR} ${PC_SDL2_INCLUDE_DIRS}
	PATH_SUFFIXES include include/SDL2
	PATHS ${SDL2_SEARCH_PATHS})

find_library(SDL2_LIBRARY
	NAMES SDL2
	HINTS ${PC_SDL2_LIBDIR} ${PC_SDL2_LIBRARY_DIRS}
	PATH_SUFFIXES lib
	PATHS ${SDL2_SEARCH_PATHS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SDL2 DEFAULT_MSG SDL2_LIBRARY SDL2_INCLUDE_DIR)

mark_as_advanced(SDL2_INCLUDE_DIR SDL2_LIBRARY)
