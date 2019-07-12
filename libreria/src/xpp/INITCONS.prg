// Le applicazioni CONSOLE hanno un problema. Perdono l'handle corrente alla
// console. FAR ne fa le spese, e questo FIX sistema il problema

#Include "dll.ch"

STATIC hBuffer := 0

Init procedure InitConsoleApp()
    // Save active screen buffer handle, -11 = STD _ OUTPUT _ HANDLE
    HBuffer := DllCall("Kernel32", DLL_STDCALL, "GetStdHandle", -11)
Return

Exit procedure ExitConsoleApp()
    // Restore initial active screen buffer
    DllCall( "Kernel32", DLL_STDCALL, "SetConsoleActiveScreenBuffer", hBuffer )
Return

// DMM Serve solo per caricare le due procedure
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE InitConsole(); RETURN
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
