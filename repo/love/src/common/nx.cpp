#include "nx.h"

#ifdef LOVE_NX

#include <unistd.h>
#include <sys/stat.h>

extern char** __system_argv;
static char g_cwd[FS_MAX_PATH] = {0};
static int64_t g_trackingTouchId = -1;
static SDL_Window* g_currentWindow = nullptr;
static bool g_romfsInited = false;

extern "C" {
	int SDL_SendMouseMotion(SDL_Window* window, Uint32 mouseID, int relative, int x, int y);
	int SDL_SendMouseButton(SDL_Window* window, Uint32 mouseID, Uint8 state, Uint8 button);

	void userAppInit(void)
	{
		socketInitializeDefault();
		nxlinkStdio();
		appletSetGamePlayRecordingState(1);
		getcwd(g_cwd, FS_MAX_PATH);

		Result rc = romfsInit();
		if(R_SUCCEEDED(rc))
		{
			g_romfsInited = true;
		}
		else
		{
			printf("romfsInit: 0x%x\n", rc);
		}
		appletLockExit();
	}

	void userAppExit(void)
	{
		if(g_romfsInited) {
			romfsExit();
		}
		socketExit();
		appletUnlockExit();
	}
}

namespace love
{
namespace nx
{

int showMessageBox(const std::string &title, const std::string &message) {
	printf("***** MSGBOX *****\n%s\n%s\n******************\n", title.c_str(), message.c_str());
	return 1;
}

bool openURL(const std::string &url)
{
	 return false;
}

std::string getExecutablePath()
{
	return std::string(__system_argv[0]);
}

std::string getUserDirectory()
{
	return std::string(g_cwd);
}

void setSDLWindow(SDL_Window* w) {
	g_currentWindow = w;
}

void fakeMouseEvents(const SDL_Event &e) {
	if (!g_currentWindow)
	{
		return;
	}
	int w, h;
	SDL_GetWindowSize(g_currentWindow, &w, &h);

	switch (e.type)
	{
		case SDL_FINGERDOWN:
		case SDL_FINGERUP:
		case SDL_FINGERMOTION:
			if(g_trackingTouchId == -1 || g_trackingTouchId == e.tfinger.fingerId)
			{
				int posX = (int)(e.tfinger.x * (float)w);
				int posY = (int)(e.tfinger.y * (float)h);

				posX = std::max(0, posX);
				posY = std::max(0, posY);
				posX = std::min(w - 1, posX);
				posY = std::min(h - 1, posY);

				if(e.type == SDL_FINGERDOWN)
				{
					g_trackingTouchId = e.tfinger.fingerId;
					SDL_SendMouseMotion(g_currentWindow, SDL_TOUCH_MOUSEID, 0, posX, posY);
					SDL_SendMouseButton(g_currentWindow, SDL_TOUCH_MOUSEID, SDL_PRESSED, SDL_BUTTON_LEFT);
				}
				else if(e.type == SDL_FINGERUP)
				{
					g_trackingTouchId = -1;
					SDL_SendMouseButton(g_currentWindow, SDL_TOUCH_MOUSEID, SDL_RELEASED, SDL_BUTTON_LEFT);
				} else {
					SDL_SendMouseMotion(g_currentWindow, SDL_TOUCH_MOUSEID, 0, posX, posY);
				}
			}

		default:
			break;
	}
}

std::string getLoveInResources(bool &fused) {
	fused = true;

	struct stat buf;
	if(g_romfsInited) {
		struct stat buf;
		if(stat("romfs:/game.love", &buf) == 0) {
			return "romfs:/game.love";
		}
	}

	if(stat("game.love", &buf) == 0) {
		return "./game.love";
	}

	if(stat("main.lua", &buf) == 0) {
		return ".";
	}

	fused = false;
	return "";
}

} // nx
} // love

#endif // LOVE_NX
