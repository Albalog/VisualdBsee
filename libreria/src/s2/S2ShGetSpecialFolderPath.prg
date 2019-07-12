#include "common.ch"
#include "dll.ch"

#ifndef _CSIDL_DEFINED_
   #define _CSIDL_DEFINED_

   #define CSIDL_ALTSTARTUP    0x1D // * CSIDL_ALTSTARTUP - File system directory that corresponds to the user's nonlocalized Startup program group. (All Users\Startup?)
   #define CSIDL_APPDATA    0x1A // * CSIDL_APPDATA - File system directory that serves as a common repository for application-specific data. A common path is C:\WINNT\Profiles\username\Application Data.
   #define CSIDL_BITBUCKET    0xA // * CSIDL_BITBUCKET - Virtual folder containing the objects in the user's Recycle Bin.
   #define CSIDL_COMMON_ALTSTARTUP    0x1E // * CSIDL_COMMON_ALTSTARTUP - File system directory that corresponds to the nonlocalized Startup program group for all users. Valid only for Windows NT systems.
   #define CSIDL_COMMON_APPDATA    0x23 // * CSIDL_COMMON_APPDATA - Version 5.0. Application data for all users. A common path is C:\WINNT\Profiles\All Users\Application Data.
   #define CSIDL_COMMON_DESKTOPDIRECTORY    0x19 // * CSIDL_DESKTOPDIRECTORY - File system directory used to physically store file objects on the desktop (not to be confused with the desktop folder itself). A common path is C:\WINNT\Profiles\username\Desktop
   #define CSIDL_COMMON_DOCUMENTS    0x2E // * CSIDL_COMMON_DOCUMENTS - File system directory that contains documents that are common to all users. A common path is C:\WINNT\Profiles\All Users\Documents. Valid only for Windows NT systems.
   #define CSIDL_COMMON_FAVORITES    0x1F // * CSIDL_COMMON_FAVORITES - File system directory that serves as a common repository for all users// favorite items. Valid only for Windows NT systems.
   #define CSIDL_COMMON_PROGRAMS    0x17 // * CSIDL_COMMON_PROGRAMS - File system directory that contains the directories for the common program groups that appear on the Start menu for all users. A common path is c:\WINNT\Profiles\All Users\Start Menu\Programs. Valid only for Windows NT systems.
   #define CSIDL_COMMON_STARTMENU    0x16 // * CSIDL_COMMON_STARTMENU - File system directory that contains the programs and folders that appear on the Start menu for all users. A common path is C:\WINNT\Profiles\All Users\Start Menu. Valid only for Windows NT systems.
   #define CSIDL_COMMON_STARTUP    0x18 // * CSIDL_COMMON_STARTUP - File system directory that contains the programs that appear in the Startup folder for all users. A common path is C:\WINNT\Profiles\All Users\Start Menu\Programs\Startup. Valid only for Windows NT systems.
   #define CSIDL_COMMON_TEMPLATES    0x2D // * CSIDL_COMMON_TEMPLATES - File system directory that contains the templates that are available to all users. A common path is C:\WINNT\Profiles\All Users\Templates. Valid only for Windows NT systems.
   #define CSIDL_COOKIES    0x21 // * CSIDL_COOKIES - File system directory that serves as a common repository for Internet cookies. A common path is C:\WINNT\Profiles\username\Cookies.
   #define CSIDL_DESKTOPDIRECTORY    0x10 // * CSIDL_COMMON_DESKTOPDIRECTORY - File system directory that contains files and folders that appear on the desktop for all users. A common path is C:\WINNT\Profiles\All Users\Desktop. Valid only for Windows NT systems.
   #define CSIDL_FAVORITES    0x6 // * CSIDL_FAVORITES - File system directory that serves as a common repository for the user's favorite items. A common path is C:\WINNT\Profiles\username\Favorites.
   #define CSIDL_FONTS    0x14 // * CSIDL_FONTS - Virtual folder containing fonts. A common path is C:\WINNT\Fonts.
   #define CSIDL_HISTORY    0x22 // * CSIDL_HISTORY - File system directory that serves as a common repository for Internet history items.
   #define CSIDL_INTERNET_CACHE    0x20 // * CSIDL_INTERNET_CACHE - File system directory that serves as a common repository for temporary Internet files. A common path is C:\WINNT\Profiles\username\Temporary Internet Files.
   #define CSIDL_LOCAL_APPDATA    0x1C // * CSIDL_LOCAL_APPDATA - Version 5.0. File system directory that serves as a data repository for local (non-roaming) applications. A common path is C:\WINNT\Profiles\username\Local Settings\Application Data.
   #define CSIDL_PROGRAMS    0x2 // * CSIDL_PROGRAMS - File system directory that contains the user's program groups (which are also file system directories). A common path is C:\WINNT\Profiles\username\Start Menu\Programs.
   #define CSIDL_PROGRAM_FILES    0x26 // * CSIDL_PROGRAM_FILES - Version 5.0. Program Files folder. A common path is C:\Program Files.
   #define CSIDL_PROGRAM_FILES_COMMON    0x2B // * CSIDL_PROGRAM_FILES_COMMON - Version 5.0. A folder for components that are shared across applications. A common path is C:\Program Files\Common. Valid only for Windows NT and Windows© 2000 systems.
   #define CSIDL_PERSONAL    0x5 // * CSIDL_PERSONAL - File system directory that serves as a common repository for documents. A common path is C:\WINNT\Profiles\username\My Documents.
   #define CSIDL_RECENT    0x8 // * CSIDL_RECENT - File system directory that contains the user's most recently used documents. A common path is C:\WINNT\Profiles\username\Recent. To create a shortcut in this folder, use SHAddToRecentDocs. In addition to creating the shortcut, this function updates the shell's list of recent documents and adds the shortcut to the Documents submenu of the Start menu.
   #define CSIDL_SENDTO    0x9 // * CSIDL_SENDTO - File system directory that contains Send To menu items. A common path is c:\WINNT\Profiles\username\SendTo.
   #define CSIDL_STARTUP    0x7 // * CSIDL_STARTUP - File system directory that corresponds to the user's Startup program group. The system starts these programs whenever any user logs onto Windows NT or starts Windows© 95. A common path is C:\WINNT\Profiles\username\Start Menu\Programs\Startup.
   #define CSIDL_STARTMENU    0xB // * CSIDL_STARTMENU - File system directory containing Start menu items. A common path is c:\WINNT\Profiles\username\Start Menu.
   #define CSIDL_SYSTEM    0x25 // * CSIDL_SYSTEM - Version 5.0. System folder. A common path is C:\WINNT\SYSTEM32.
   #define CSIDL_TEMPLATES    0x15 // * CSIDL_TEMPLATES - File system directory that serves as a common repository for document templates.
   #define CSIDL_WINDOWS    0x24 // * CSIDL_WINDOWS - Version 5.0. Windows directory or SYSROOT. This corresponds to the %windir% or %SYSTEMROOT% environment variables. A common path is C:\WINNT.

#endif

#define MAX_PATH 260

// trova i percorsi predefiniti di windows
FUNCTION S2SHGetSpecialFolderPath(nCsidl, lCreate)
   LOCAL cPath := SPACE(MAX_PATH)
   LOCAL n

   DEFAULT lCreate TO .F.

   n := DllCall("Shell32.dll", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, nCsidl, lCreate)
   IF n == 0
      // errore
      cPath := NIL
   ELSE
      cPath := dfGetCString(cPath)
   ENDIF
RETURN cPath

