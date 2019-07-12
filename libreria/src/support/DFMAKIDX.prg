#include "dfStd.ch"
#include "dfSet.ch"
#include "XBP.ch"
#include "GRA.ch"

// Simone 8/apr/03 aggiunto timeout per far visualizzare 
// la progress bar solo dopo un tot di tempo (in secondi)

STATIC oDlg
STATIC oProgress


FUNCTION _dfMakeIndInit()
   oDlg := NIL
   oProgress := NIL
RETURN NIL

FUNCTION _dfMakeIndCreate(cTitle, nMax, nTimeOut)
   LOCAL oOwner := S2FormCurr()
   LOCAL lOk := .F.
   LOCAL nStyle

   // Cerco una finestra che abbia la zona dei messaggi attiva
   DO WHILE ! EMPTY(oOwner) .AND. ;
            (! oOwner:isDerivedFrom("S2Form") .OR. ;
             ! oOwner:ShowMessageArea         .OR. ;
             ! oOwner:getMessageArea():isVisible()    )
      oOwner:=oOwner:setOwner()
   ENDDO

   IF ! EMPTY(oOwner)
      oOwner := oOwner:getMessageArea()
   ELSE
      oDlg := XbpDialog():new(AppDesktop(), S2FormCurr(), NIL, {400,40}, NIL, .F. )

      oDlg:title := cTitle //"Ricostruzione indice"
      oDlg:titleBar := .T.
      oDlg:taskList := .F.
      oDlg:sysMenu  := .T.
      oDlg:create()

      S2WinCenter(oDlg)

      oOwner := oDlg:drawingArea
   ENDIF

   nStyle := dfSet(AI_XBASEINDEXWAITSTYLE)

   DO CASE
      CASE nStyle == AI_INDEXWAITSTYLE_NONE
        // niente!
         oProgress := NIL

      CASE nStyle == AI_INDEXWAITSTYLE_FANCY
         oProgress := GradientProgressBar():new(oOwner, oOwner, NIL, oOwner:currentSize(), NIL, .F. )

         nTimeOut := NIL // TIMEOUT NON SUPPORTATO

      OTHERWISE
         oProgress := _ThreadProgressBar():new(oOwner, oOwner, NIL, oOwner:currentSize(), NIL, .F. )
         oProgress:oDlg := oDlg

   ENDCASE
   IF oProgress != NIL
      oProgress:minimum := 1
      oProgress:maximum := nMax
      oProgress:create()

      IF VALTYPE(nTimeOut) == "N"
         oProgress:hide()
         oProgress:Thread:setStartTime( SECONDS()+nTimeOut )
      ELSE         
         oProgress:show()
      ENDIF
   //S2WinCenter(oProgress)
   ENDIF

   lOk := .T.

RETURN lOk

FUNCTION _dfMakeIndPB()
   IF oProgress != NIL 
      oProgress:increment()
   ENDIF
RETURN NIL

FUNCTION _dfMakeIndDestroy()
   IF oProgress != NIL
      oProgress:hide()
      oProgress:destroy()
      oProgress := NIL
   ENDIF

   IF oDlg != NIL
      oDlg:hide()
      oDlg:destroy()
      oDlg :=  NIL
   ENDIF
RETURN NIL

STATIC CLASS _ThreadProgressBar FROM ThreadProgressBar
EXPORTED
    VAR oDlg

    INLINE METHOD init( oParent, oOwner, aPos, aSize, aPP, lVisible )
      ::ThreadProgressBar:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
      //#ifndef _XBASE182_
       // Simone GERR 3379 e 3738
       // correzione malfunzionamento gestione thread in xbase 1.5-1.8
       // chiuso in xbase 1.82 ma forse non per bene!
       // PDR 5057
       Sleep(5)
      //#endif

    RETURN self

    INLINE METHOD display()
      IF ! ::isVisible()
         ::show()
      ENDIF

      IF ::oDlg != NIL 
         ::oDlg:show()
      ENDIF
      
      ::ThreadProgressBar:display()
    RETURN self

ENDCLASS
