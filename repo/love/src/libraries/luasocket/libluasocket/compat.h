#ifndef COMPAT_H
#define COMPAT_H

#include "lua.h"
#include "lauxlib.h"

#if LUA_VERSION_NUM==501 && !defined(__SWITCH__)
void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup);
#endif

#endif
