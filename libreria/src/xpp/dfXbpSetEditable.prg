#include "dll.ch"

// imposta una XbpSle o XbpMle come editabile si/no
// senza dover fare il oXbp:configure()
// ritorna .T. = OK, .F. = errore
// es. 
//  oXbp:=XbpSle():new():create()
//  dfXbpSetEditable(oXbp, .F.)

#define EM_SETREADONLY 0x00CF

FUNCTION dfXbpSetEditable(oXbp, lEditable)
   oXbp:editable := lEditable
RETURN DLLCALL( "USER32.DLL", DLL_STDCALL, "SendMessageA", oXbp:GetHWND(), ;
                EM_SETREADONLY, IIF(lEditable, 1, 0), 0 ) != 0

