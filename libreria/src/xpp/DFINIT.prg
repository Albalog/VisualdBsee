#include "dll.ch"
#include "dfStd.ch"
#include "Common.ch"

STATIC oInitStack

STATIC FUNCTION CanShow()
#ifndef _WAA_
  RETURN ! dfIsTerminal()
#else
  RETURN .F. 
#endif


PROCEDURE dfInitScreenInit()
   LOCAL oTemp

   IF CanShow() .AND. oInitStack == NIL
      oTemp := _call()
      IF EMPTY(oTemp)
         oInitStack := S2Stack():new()
      ELSE
         oInitStack := oTemp
      ENDIF
   ENDIF
RETURN

FUNCTION dfInitScreenOn()
   LOCAL oInit
   LOCAL aInfo
   IF CanShow()
      dfInitScreenInit()

      //IF oInitStack:isEmpty()
         aInfo := dfInitScreenInfo()

         oInit := S2InitScreen():new(aInfo[1], aInfo[2], aInfo[3]):On("")

         oInitStack:push(oInit)
      //ELSE
      //   oInit := oInitStack:top()
      //ENDIF
      SetAppFocus(oInit)
   ENDIF
RETURN NIL

FUNCTION dfInitScreenStep()
   IF CanShow()
      RETURN oInitStack:top():DoStep()
   ENDIF
RETURN NIL

FUNCTION dfInitScreenOff()
   LOCAL oInit 
   //local i, aerr:={}
   IF CanShow()
      oInit := oInitStack:pop()
      IF ! EMPTY(oInit)

         // i := 0
         // while ( !Empty(ProcName(i)) )
         //    AADD( aErr, "chiamato da " +Trim(ProcName(i)) + ;
         //                "(" + ALLTRIM(STR(ProcLine(i))) + ")  " )
         //    i++
         // end
         // dfArrWin(,,,,aErr,"ERROR")

         oInit:Off()
      ENDIF
   ENDIF
RETURN NIL

FUNCTION dfInitScreenOpen()
   IF CanShow()
      dfInitScreenInit()
      RETURN ! oInitStack:isEmpty()
   ENDIF
RETURN .F.

FUNCTION dfInitScreenUpd(cMsg)
   IF CanShow()
      oInitStack:top():update(cMsg)
   ENDIF
RETURN NIL


#define DLLNAME "DBSCREEN.DLL"
#define FUNCNAME "_DFINITSCREENOBJECT"

STATIC FUNCTION _Call()
   LOCAL oRet
   LOCAL nHandle
   nHandle := DllLoad(DLLNAME)
   IF nHandle != 0
      oRet := &( FUNCNAME )()
      //oRet := DllCall(nHandle, NIL, FUNCNAME)
   ENDIF
RETURN oRet

// #ifdef _XBASE15_
//    LOCAL aFunctions
//
//    // Make sure DLL is loaded
//    IF DllInfo( DLLNAME, DLL_INFO_LOADED )
//       nHandle := DllInfo( DLLNAME, DLL_INFO_HANDLE )
//    ELSE
//       nHandle := DllLoad( DLLNAME )
//    ENDIF
//
//    IF nHandle != 0
//       // Retrieve function list and prefix
//       aFunctions := DllInfo( nHandle, DLL_INFO_FUNCLIST )
//
//       IF AScan( aFunctions, FUNCNAME ) > 0
//          // Call function dynamically
//          oRet := &( FUNCNAME )()
//       ENDIF
//
//       // IF DllInfo( nHandle, DLL_INFO_UNLOADABLE )
//       //    DllUnload( nHandle )
//       // ENDIF
//
//    ENDIF
// #else
//    nHandle := DllLoad(DLLNAME)
//    IF nHandle != 0
//       oRet := DllCall(nHandle, NIL, FUNCNAME)
//    ENDIF
// #endif
//
// RETURN oRet


