#ifndef LOVE_NX_H
#define LOVE_NX_H

#include "config.h"

#ifdef LOVE_NX

#include <string>
#include <SDL.h>

extern "C" {
	#include <switch.h>
}

namespace love
{
namespace nx
{

int showMessageBox(const std::string &title, const std::string &message);
bool openURL(const std::string &url);
std::string getExecutablePath();
std::string getUserDirectory();
void setSDLWindow(SDL_Window* w);
void fakeMouseEvents(const SDL_Event &e);
std::string getLoveInResources(bool &fused);

} // android
} // nx

#endif // LOVE_NX
#endif // LOVE_NX_H