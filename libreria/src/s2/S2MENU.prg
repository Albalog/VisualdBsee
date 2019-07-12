#include "gra.ch"
#include "xbp.ch"
#include "dfStd.ch"
#include "Common.ch"
#include "dfXBase.ch"
#include "Appevent.ch"
#include "dfWin.ch"
#include "DFMENU.CH"

// S2Menu: Gestione Menu
// ---------------------
CLASS S2Menu FROM XbpMenuBmp
   EXPORTED:
   VAR id, methods, menuArray //, itemHighLighted
   METHOD popUp, create //, handleEvent
ENDCLASS

// 
// // Gestisce anche l'evento di evidenziazione voce di menu
// METHOD S2Menu:handleEvent(nEvent, mp1, mp2)
//    DO CASE
//       CASE nEvent == xbeMenu_HighLight
//          IF ! EMPTY(::itemHighLighted)
//             EVAL(::itemHighLighted, mp1, mp2, self)
//          ENDIF
//       OTHERWISE
//          ::XbpMenu:handleEvent(nEvent, mp1, mp2)
//    ENDCASE
// RETURN self


METHOD S2Menu:Create(oParent, aPP, lVisible, aMethods, aMenuArray)
   LOCAL nInd
   LOCAL aMtd
   LOCAL cPrompt := ""

   ::XbpMenuBmp:Create(oParent, aPP, lVisible)

   IF ! EMPTY( aMethods )

      ::methods := aMethods

      FOR nInd := 1 TO LEN(::methods)
         aMtd := ::methods[nInd]

         cPrompt := ALLTRIM(S2HotCharCvt(STRTRAN(aMtd[MTD_MSG], "@")))

         // Tolgo il carattere "@" che era usato in vecchie versioni di DbSee
         // Tolgo spazi iniziali e finali
         // Converto hotkey Dbsee in hotkey Windows

         IF ! EMPTY(aMtd[MTD_ACT])
            cPrompt += CHR(9)+dbAct2Mne(aMtd[MTD_ACT])
         ENDIF

         ::addItem( { cPrompt, ;
                      {|n| ::setParent():handleAction(::methods[n][MTD_ACT])} } )
      NEXT
   ENDIF

   ::menuArray := aMenuArray

RETURN self

METHOD S2Menu:popUp(cState, oXbp, aPos, nItm, nCtrl)
   LOCAL nInd
   LOCAL aMtd
   LOCAL lEnabled := .F.
   LOCAL aMnu, nN, bcod, nWhen

   IF ! EMPTY( ::methods )
      // Controllo quali metodi sono abilitati
      FOR nInd := 1 TO LEN( ::methods )
         aMtd := ::methods[nInd]
         IF (aMtd[MTD_WHEN] == NIL .OR. EVAL(aMtd[MTD_WHEN], cState)) .AND. ;
            (aMtd[MTD_RUN ] == NIL .OR. EVAL(aMtd[MTD_RUN ]))

            ::enableItem( nInd )

         ELSE
            ::disableItem( nInd )
         ENDIF
      NEXT
   ENDIF

   /////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////
   //Luca 17/06/2015 mantis 1242
   // Controllo quali menu sono abilitati
   IF !EMPTY( ::menuArray   )  .AND. LEN(   ::menuArray)   >=2 .AND.; 
      !EMPTY( ::menuArray[2])  .AND. LEN(   ::menuArray[2])>=4 .AND.;
      !EMPTY(::menuArray[2][4])
      nN       := 0
      aMnu     := ::menuArray[2][4]
      IF !EMPTY(aMnu)
         //FOR nInd := LEN( ::methods ) + 2 TO ::numItems() 
         FOR nInd := IIF(!EMPTY(::methods), LEN( ::methods ), 0) + 2 TO ::numItems() 
             nN++
             IF LEN(aMnu) >= nN .AND. LEN(aMnu[nN]) >= 10 
                aMtd  := aMnu[nN]

                bcod  := aMtd[10]
                IF bcod == NIL
                   ::enableItem( nInd )
                   LOOP
                ENDIF 

                nWhen  := EVAL(bcod, cState)
                IF !VALTYPE(nWhen) == "N"
                   ::enableItem( nInd )
                   LOOP
                ENDIF 
                IF !nWhen  ==  MN_ON 
                   ::disableItem( nInd )
                   LOOP
                ENDIF 

                bcod  := aMtd[12 ] 
                IF bcod == NIL
                   IF nWhen ==  MN_ON 
                      ::enableItem( nInd )
                   ELSE 
                      ::disableItem( nInd )
                   ENDIF 
                   LOOP
                ENDIF 

                nWhen  := EVAL(bcod, cState)
                IF !VALTYPE(nWhen) == "L"
                   LOOP
                ENDIF 

                IF nWhen 
                   ::enableItem( nInd )
                ELSE
                   ::disableItem( nInd )
                ENDIF
             ENDIF
         NEXT 
      ENDIF
   ENDIF
   /////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////


   // Controllo che almeno un sottomenu sia abilitato
   nInd := 0
   DO WHILE ++nInd <= ::numItems() .AND. ! (lEnabled := ::isItemEnabled(nInd))
   ENDDO

RETURN IIF( lEnabled, ::XbpMenuBmp:popUp(oXbp, aPos, nItm, nCtrl), .F. )


