#include "Common.ch"
#include "dfXbase.ch"
#include "dll.ch"

#define SPI_GETWORKAREA 48

DLLFUNCTION S2SystemParametersInfo(uiAction, uiParam, @pvParam, fWinIni);
            USING STDCALL FROM USER32.DLL NAME SystemParametersInfoA


FUNCTION S2AppDesktopChkSize()
   LOCAL aSize := AppDesktop():currentSize()
   LOCAL nRet

   DO CASE
      CASE aSize[1] == 640 .AND. aSize[2] == 480
         nRet := S2APPDESKTOPSIZE_640x480

      CASE aSize[1] == 800 .AND. aSize[2] == 600
         nRet := S2APPDESKTOPSIZE_800x600

      CASE aSize[1] == 1024 .AND. aSize[2] == 768
         nRet := S2APPDESKTOPSIZE_1024x768

      CASE aSize[1] == 1152 .AND. aSize[2] == 864 
         nRet := S2APPDESKTOPSIZE_1152x864

      CASE aSize[1] == 1280 .AND. aSize[2] == 1024
         nRet := S2APPDESKTOPSIZE_1280x1024

      OTHERWISE
         nRet := S2APPDESKTOPSIZE_UNKNOWN

   ENDCASE

RETURN nRet


FUNCTION S2AppDesktopSize( lReale )
   LOCAL aSize // := AppDesktop():currentSize()
   LOCAL aWSM

   DEFAULT lReale TO .T.

   IF lReale
      aSize := RealDesktopSize()
   ELSE
      aSize := AppDesktop():currentSize()

      // aWSM  := S2WinStartMenuSize()
      // aSize[2] -= aWSM[2]
   ENDIF

RETURN aSize

// Torna la dimesione del desktop senza la barra del menu AVVIO
// ha problemi con qualche Windows95
STATIC FUNCTION RealDesktopSize()
   LOCAL cRect := SPACE(16) // 16 = 4 LONG
   LOCAL aRet
   LOCAL aSize := {0,0,0,0}
   LOCAL nOk := S2SystemParametersInfo(SPI_GETWORKAREA, 0, @cRect, 0)

   IF nOk != 0
      aSize[1] := BIN2L(SUBSTR(cRect, 1, 4)) // LEFT
      aSize[2] := BIN2L(SUBSTR(cRect, 5, 4)) // TOP
      aSize[3] := BIN2L(SUBSTR(cRect, 9, 4)) // RIGHT
      aSize[4] := BIN2L(SUBSTR(cRect,13, 4)) // BOTTOM
   ENDIF

   aRet := {aSize[3]-aSize[1], aSize[4]-aSize[2]}

RETURN aRet

FUNCTION S2WinStartMenuSize()
   LOCAL aDesk := S2AppDesktopSize(.F.)
   LOCAL aReal := S2AppDesktopSize(.T.)
   LOCAL aRet

   DO CASE
      CASE aDesk[1] == aReal[1] .AND. ;
           aDesk[2] == aReal[2]

         // La barra Š invisibile
         aRet := {0,0}

      OTHERWISE
         aRet := {aDesk[1]-aReal[1], aDesk[2]-aReal[2]}

      // CASE aDesk[1] == aReal[1]
      //    // la barra Š orizzontale
      //    aRet := {aDesk[1], aDesk[2]-aReal[2]}
      //
      // OTHERWISE
      //    // la barra Š verticale
      //    aRet := {aDesk[1]-aReal[1], aDesk[2]}
      //
   ENDCASE
RETURN aRet
