#include "dll.ch"

#define WM_CHANGEUISTATE   0x127
#define UIS_INITIALIZE     0x3   // Hide/show cues depending on last 
                                 // input event
#define UIS_SET            0x1   // (Always) Hide keyboard cues
#define UIS_CLEAR          0x2   // (Always) Show keyboard cues
#define UISF_HIDEACCEL     0x2   // Modify "Hide cue" setting

// workaround per hotkey sui pulsanti nascosti con XP
FUNCTION dfWinXPSetShowFocus(oWin)
   DLLCALL( "USER32.DLL", DLL_STDCALL, "SendMessageA", oWin:GetHWND(), ;
            WM_CHANGEUISTATE, UIS_CLEAR + UISF_HIDEACCEL*65536, 0 )
RETURN .T.