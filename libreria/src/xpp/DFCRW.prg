#include "dll.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "gra.ch"
#include "xbp.ch"
#include "dfReport.ch"
#include "dfXbase.ch"
#include "dfMsg1.ch"
#include "XBPDEV.CH"


#ifdef _TEST_
   PROCEDURE AppSys
   RETURN

   FUNCTION Main(cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7)
      local o:=dfCrystalReport():new(cPar1)
      o:preview(, "prova")
   RETURN NIL
#endif


CLASS dfCrystalReport
   PROTECTED:
      METHOD setError

   EXPORTED:
      VAR cRepName
      VAR nErrCode
      VAR cErrMsg
      VAR bOnPrint
      VAR bOnExport
      VAR bOnPreview

      METHOD init

      SYNC METHOD preview
      SYNC METHOD print
      SYNC METHOD exportTo
ENDCLASS

METHOD dfCrystalReport:init(cRepName)
   DEFAULT cRepName TO dfCRWPath()+M->ENVID+".RPT"
   ::nErrCode := 0
   ::cErrMsg  := ""
   ::cRepName := cRepName
RETURN self

METHOD dfCrystalReport:setError(nJob)
   LOCAL textHandle, textLen, errText

   ::nErrCode := 0
   ::cErrMsg  := ""

   IF nJob != NIL
      textHandle:=0
      textLen:=0
      errText:=""
      ::nErrCode := PEGetErrorCode( nJob )

      IF ::nErrCode != 0
         PEGetErrorText( nJob, @textHandle, @textLen )

         errText := SPACE( textLen )
         PEGetHandleString( textHandle, @errText, textLen )
         // Va meglio cosi Luca
         //::cErrMsg := LEFT(errText, textLen-1) // tolgo il CHR(0) finale
         ::cErrMsg := ALLTRIM(LEFT(errText, textLen-2)) // tolgo il CHR(0) finale
      ENDIF
   ENDIF
RETURN self


// cRepName = file .RPT
// cRepTitle = Titolo finestra
// cRepFormula = formula di filtro crystal report
// oFlag = Flag di anteprima (oggetto di classe XbpCRWPrinterO)
// aTabLocation = array di file .DBF da usare per la stampa es {"c:\pippo.dbf"}
// oCrwPrinter = stampante da usare (oggetto di classe S2CRWPrinter() va usato esattamente come XbpPrinter() )
// aOpt = array opzioni vedi PeSetPrintOptions
METHOD dfCrystalReport:preview(cRepName, cRepTitle, cRepFormula, ;
                               xFlag, aTabLocation, oCRWPrinter, aOpt)

   LOCAL nRet
   LOCAL oDlg
   LOCAL cDir
   LOCAL oParent 

   DEFAULT cRepName TO ::cRepName
   IF EMPTY(cRepName); RETURN -1; ENDIF

   IF ! FILE(cRepName); RETURN -1; ENDIF

   oParent := S2FormCurr()

   // Azzero errori
   ::setError()

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Salvo path e Directory corrente
   cDir   := dfPathGet()

   dfPushAct()

   DEFAULT cRepTitle TO ""

   oDlg := S2CRWPreviewDialog():new()
   oDlg:title := dbMMrg(STRTRAN(cRepTitle,dfHot()))

   oDlg:Create()

   oDlg:tbConfig()

   oDlg:show()

   // now add container
   oDlg:Open(cRepName, cRepFormula, xFlag, aTabLocation, oCRWPrinter, ::bOnPreview, aOpt)
   SetAppFocus( oDlg )

   IF oDlg:getError() == 0
      oDlg:tbInk()
      nRet := 0

      // questo dovrebbe essere un workaround al seguente problema
      // se si fa anteprima e poi si fa esportazione, la finestrella
      // di richiesta esportazione Š visualizzata "sotto" la finestra
      // di menu.. ma il workaroudn non funziona..

      IF ! EMPTY(oParent)
         IF oParent:isDerivedFrom("XbpDialog")
            oParent:=oParent:drawingArea
         ENDIF
         PESetDialogParentWindow(oDlg:getJob(), oParent:getHWnd()) 
      ENDIF
   ELSE
      // C'Š stato un errore
      ::setError(oDlg:getJob())
      nRet := oDlg:getError()
   ENDIF

   oDlg:tbEnd()

   oDlg:destroy()

   dfPopAct()
   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Ripristino path e Directory corrente
   dfPathSet( cDir )
RETURN nRet

// cRepName = file .RPT
// nRepCopy  = numero di copie
// cRepFormula = formula di filtro crystal report
// aTabLocation = array di file .DBF da usare per la stampa es {"c:\pippo.dbf"}
// oCrwPrinter = stampante da usare (oggetto di classe S2CRWPrinter() va usato esattamente come XbpPrinter() )
// aOpt = array opzioni vedi PeSetPrintOptions
METHOD dfCrystalReport:print(cRepName, nRepCopy, cRepFormula, ;
                             aTabLocation, oCRWPrinter, aOpt)
   LOCAL nJob        := 0
   LOCAL lResult     := .F. 
   LOCAL nCopy       := 0
   LOCAL lOpenEngine := .F.
   LOCAL lOpenJob    := .F.
   LOCAL nRet        := 0
   LOCAL cDir
   LOCAL nN          := 0
   LOCAL nRepMAX
   //Default con il ciclo
   LOCAL lPrintWithCiclo := .T.

   DEFAULT cRepName TO ::cRepName

   DEFAULT nRepCopy    TO 1
   DEFAULT cRepFormula TO ""
   DEFAULT oCRWPrinter TO dfCRWPrinterObject()


   IF EMPTY(cRepName) ; RETURN -1; ENDIF
   IF ! FILE(cRepName); RETURN -1; ENDIF

   ////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////
   //Modifica Luca del 2/12/2010 per risolvere problema del numero di copie da stampare
   //Mantis 2123
   ////////////////////////////////////////////////////////////
   IF !EMPTY(dfSet("XbaseCrystalPrintwithLoop"))
      lPrintWithCiclo := dfSet("XbaseCrystalPrintwithLoop") == "YES" 
   ENDIF 
   ////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////



   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Salvo path e Directory corrente
   cDir   := dfPathGet()

   // Azzero errori
   ::setError()

   BEGIN SEQUENCE

      IF PEOpenEngine() < 1; BREAK; ENDIF
      lOpenEngine := .T.

      nJob := PEOpenPrintJob(cRepName)
      IF nJob < 1; BREAK; ENDIF

      lOpenJob := .T.


      IF !lPrintWithCiclo .AND. nRepCopy > 1
         IF oCRWPrinter:setNumCopies()     == NIL .OR.;
            oCRWPrinter:setCollationMode() == NIL
            //Controllo che la stampante selezionata supporti il multipagina (anche se questa verifica non Š detto che sia veritiera...)
            lPrintWithCiclo   := .T.
         ENDIF 
      ENDIF 

      //Luca 13/11/2014 
      //Mantis 2256 - Errore: raddoppia le copie con fascicolatore attivo.
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      IF lPrintWithCiclo .AND. nRepCopy > 1
         IF !EMPTY(oCRWPrinter:setCollationMode()) .AND.; 
            oCRWPrinter:setCollationMode() == XBPPRN_COLLATIONMODE_ON 
            lPrintWithCiclo := .F.
         ENDIF 
      ENDIF 
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////

      ////////////////////////////////////////////////////////////
      //Mantis 2123
      IF lPrintWithCiclo
         //dfalert("Uso il ciclo di Stampa Crystal")
         nRepMAX := nRepCopy
         oCRWPrinter:setNumCopies(1)
      ELSE 
         //dfalert("NON Uso il ciclo di Stampa Crystal")
         nRepMAX :=  1
         oCRWPrinter:setNumCopies(nRepCopy)
         IF ! EMPTY(aOpt) .AND. LEN(aOpt) >= 4
            aOpt[3] :=  1
         ENDIF 
      ENDIF 
      ////////////////////////////////////////////////////////////

      FOR nN := 1 TO nRepMAX 
      ////////////////////////////////////////////////////////////

          IF ! EMPTY(oCRWPrinter) .AND. oCRWPrinter:devName != NIL
             _DFCRW_PESELECTPRINTER(nJob, ;
                                    oCRWPrinter:devName, ;
                                    oCRWPrinter:devPort, ;
                                    oCRWPrinter:devDriver, ;
                                    oCRWPrinter:getDMHandle())
          ENDIF

          __PESetTableLocation(nJob, aTabLocation)

          IF ! EMPTY(ALLTRIM(cRepFormula))
             lResult := PESetSelectionFormula( nJob, cRepFormula )
          ENDIF

          IF ! EMPTY(aOpt)
             __PESetPrintOptions(nJob, aOpt)
          ENDIF


          ////////////////////////////////////////////////////////////
          ////////////////////////////////////////////////////////////
          //Mantis 2123
          //lResult := (PEOutputToPrinter(nJob, nRepCopy) > 0 )
          //Modifica Luca del 2/12/2010 per risolvere problema del numero di copie da stampare
          //SE viene fatto il ciclo FOR allora indico a Crystal di fare una sola stampa ad ogni ciclo.
          IF lPrintWithCiclo
             lResult := (PEOutputToPrinter(nJob, 1) > 0 )
          ELSE
             lResult := (PEOutputToPrinter(nJob, nRepCopy) > 0 )
          ENDIF 
          ////////////////////////////////////////////////////////////
          ////////////////////////////////////////////////////////////



          IF ! lResult
             BREAK
          ENDIF

          ////////////////////////////////////////////////////////////
          //Mantis 2123
          ////////////////////////////////////////////////////////////
          //IF VALTYPE(::bOnPrint) == "B" .AND. ;
          //   ! EVAL(::bOnPrint, nJob, ;
          //          cRepName, nRepCopy, cRepFormula, ;
          //          aTabLocation, oCRWPrinter )
          //   BREAK
          //ENDIF
          //Modifica Luca del 2/12/2010 per risolvere problema del numero di copie da stampare
          IF VALTYPE(::bOnPrint) == "B" .AND. ;
             ! EVAL(::bOnPrint, nJob, ;
                    cRepName, IIF(lPrintWithCiclo,nN,nRepCopy), cRepFormula, ;
                    aTabLocation, oCRWPrinter )
             BREAK
          ENDIF
          ////////////////////////////////////////////////////////////
          ////////////////////////////////////////////////////////////

          IF PEStartPrintJob( nJob, .T.) < 1
             BREAK
          ENDIF

      ////////////////////////////////////////////////////////////
      NEXT 
      ////////////////////////////////////////////////////////////
   RECOVER
      // C'Š stato un errore
      ::setError(nJob)

   END SEQUENCE

   IF lOpenJob
      PEClosePrintJob( nJob)
      lOpenJob := .F.
   ENDIF

   IF lOpenEngine
      PECloseEngine()
      lOpenEngine := .F.
   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Ripristino path e Directory corrente
   dfPathSet( cDir )
RETURN ::nErrCode

// Funziona ma Š meglio gestire la struttura xExp con funzioni in C
METHOD dfCrystalReport:exportTo(cRepName, xExp, cRepFormula, ;
                                aTabLocation, oCRWPrinter, aOpt)
   LOCAL nJob        := 0
   LOCAL lResult     := .F. 
   LOCAL nCopy       := 0
   LOCAL lOpenEngine := .F.
   LOCAL lOpenJob    := .F.
   LOCAL nRet        := 0
   LOCAL cDir
   LOCAL oParent
   LOCAL hWnd

   DEFAULT cRepName TO ::cRepName

   DEFAULT cRepFormula TO ""

   IF ! FILE(cRepName)
      RETURN -1
   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Salvo path e Directory corrente
   cDir   := dfPathGet()

   // Azzero errori
   ::setError()

   BEGIN SEQUENCE

      IF PEOpenEngine() < 1; BREAK; ENDIF
      lOpenEngine := .T.

      nJob := PEOpenPrintJob(cRepName)
      IF nJob < 1; BREAK; ENDIF

      lOpenJob := .T.

      IF ! EMPTY(oCRWPrinter) .AND. oCRWPrinter:devName != NIL
         _DFCRW_PESELECTPRINTER(nJob, ;
                                oCRWPrinter:devName, ;
                                oCRWPrinter:devPort, ;
                                oCRWPrinter:devDriver, ;
                                oCRWPrinter:getDMHandle())
      ENDIF

      __PESetTableLocation(nJob, aTabLocation)

      IF ! EMPTY(ALLTRIM(cRepFormula))
         lResult := PESetSelectionFormula( nJob, cRepFormula )
      ENDIF

      IF ! EMPTY(aOpt)
         __PESetPrintOptions(nJob, aOpt)
      ENDIF

      IF VALTYPE(xExp) == "A" 
         IF VALTYPE(::bOnExport) == "B" .AND. ;
            ! EVAL(::bOnExport, nJob, ;
                   cRepName, xExp, cRepFormula, ;                                         
                   aTabLocation, oCRWPrinter)
            BREAK
         ENDIF

         IF LEN(xExp)>=3
            // xExp[1] == ID formato esportazione S2UXFxxxxx vedi s2crwpri.ch
            // xExp[2] == ID tipo destinazione    S2UXDxxxxx vedi s2crwpri.ch
            // xExp[3] == nomefile da creare
            hWnd:= _getHWnd()
            lResult := dfCRWStartExport(nJob, hWnd, xExp[1], xExp[2], xExp[3])

            // sono errori che sono impostati dalle PExxxx
            IF lResult == -5 .OR. lResult == -6
               BREAK
            ENDIF
         ENDIF
      ELSE
         IF xExp == NIL

            // questo dovrebbe essere un workaround al seguente problema
            // se si fa anteprima e poi si fa esportazione, la finestrella
            // di richiesta esportazione Š visualizzata "sotto" la finestra
            // di menu.. ma il workaroudn non funziona..
            hWnd:= _getHWnd()
            IF PESetDialogParentWindow(nJob, hWnd) == 0
               BREAK
            ENDIF
            xExp := SPACE(200)
            lResult := (PeGetExportOptions(nJob, @xExp) > 0)

            IF ! lResult
               BREAK
            ENDIF
         ENDIF

         lResult := (PEExportTo(nJob, @xExp) > 0 )

         IF ! lResult
            BREAK
         ENDIF

         IF VALTYPE(::bOnExport) == "B" .AND. ;
            ! EVAL(::bOnExport, nJob, ;
                   cRepName, xExp, cRepFormula, ;                                         
                   aTabLocation, oCRWPrinter)
            BREAK
         ENDIF

         IF PEStartPrintJob( nJob, .T.) < 1
            BREAK
         ENDIF
      ENDIF
   RECOVER
      // C'Š stato un errore
      ::setError(nJob)

   END SEQUENCE

   IF lOpenJob
      PEClosePrintJob( nJob)
      lOpenJob := .F.
   ENDIF

   IF lOpenEngine
      PECloseEngine()
      lOpenEngine := .F.
   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Ripristino path e Directory corrente
   dfPathSet( cDir )

RETURN ::nErrCode

STATIC FUNCTION _gethWnd(oParent)
   LOCAL n:=AppDesktop():getHwnd()

   // questo dovrebbe essere un workaround al seguente problema
   // se si fa anteprima e poi si fa esportazione, la finestrella
   // di richiesta esportazione Š visualizzata "sotto" la finestra
   // di menu.. ma il workaroudn non funziona..
   DEFAULT oParent TO S2FormCurr()
   IF ! EMPTY(oParent)
      IF oParent:isDerivedFrom("XbpDialog")
         oParent:=oParent:drawingArea
      ENDIF
      n := oParent:getHWnd()
   ENDIF
RETURN n

// METHOD dfCrystalReport:print(cRepName, nRepCopy, cRepFormula, ;
//                              aTabLocation, oCRWPrinter)
//    LOCAL nJob, lResult
//    LOCAL nCopy := 0
//    LOCAL lOpenEngine := .F.
//    LOCAL lOpenJob    := .F.
//    LOCAL nRet        := 0
// 
//    DEFAULT cRepName TO ::cRepName
// 
//    DEFAULT nRepCopy    TO 1
//    DEFAULT cRepFormula TO ""
// 
//    IF ! FILE(cRepName)
//       RETURN -1
//    ENDIF
// 
//    // Azzero errori
//    ::setError()
// 
//    FOR nCopy := 1 TO nRepCopy
// 
//       IF PEOpenEngine() < 1
//          EXIT
//       ENDIF
// 
//       lOpenEngine := .T.
// 
//       nJob := PEOpenPrintJob(cRepName)
// 
//       IF nJob < 1
//          EXIT
//       ENDIF
// 
//       lOpenJob := .T.
// 
//       IF ! EMPTY(oCRWPrinter)
//          _DFCRW_PESELECTPRINTER(nJob, ;
//                                 oCRWPrinter:devName, ;
//                                 oCRWPrinter:devPort, ;
//                                 oCRWPrinter:devDriver, ;
//                                 oCRWPrinter:getDMHandle())
// 
//          //PeSelectPrinter(nJob, ::cDriver,  ::cPrinter, ::cPort, 0)
//          //dfalert("todo: imposta la stampante "+oCrwPrinter:devName)
//       ENDIF
// 
//       __PESetTableLocation(nJob, aTabLocation)
// 
//       IF ! EMPTY(ALLTRIM(cRepFormula))
//          lResult := PESetSelectionFormula( nJob, cRepFormula )
//       ENDIF
// 
//       lResult := (PEOutputToPrinter(nJob, 1) > 0 )
// 
//       IF ! lResult
//          EXIT
//       ENDIF
// 
//       IF PEStartPrintJob( nJob, .T.) < 1
//          EXIT
//       ENDIF
// 
//       IF lOpenJob
//          PEClosePrintJob( nJob)
//          lOpenJob := .F.
//       ENDIF
// 
//       IF lOpenEngine
//          PECloseEngine()
//          lOpenEngine := .F.
//       ENDIF
//    NEXT
// 
//    IF nCopy <= nRepCopy // c'Š stato un errore?
//       ::setError(nJob)
//    ENDIF
// 
//    IF lOpenJob
//       PEClosePrintJob( nJob)
//       lOpenJob := .F.
//    ENDIF
// 
//    IF lOpenEngine
//       PECloseEngine()
//       lOpenEngine := .F.
//    ENDIF
// 
// RETURN ::nErrCode

CLASS S2CRWPreviewDialog FROM S2Dialog
   PROTECTED:
      VAR lEventLoop
      VAR oCRWContainer

   EXPORTED:
      VAR oStatic

      METHOD resize //, findImage
      METHOD Init, Create, destroy, tbInk //, Show
      METHOD keyboard
      METHOD breakEventLoop

      INLINE METHOD Open(cRepName, cRepFormula, xFlag, aTabLocation, oCRWPrinter, bOnPreview, aOpt)
      RETURN ::oCRWContainer:Open(cRepName, cRepFormula, xFlag, aTabLocation, oCRWPrinter, bOnPreview, aOpt)

      INLINE METHOD getContainer(); RETURN ::oCRWContainer
      INLINE METHOD getJob(); RETURN ::oCRWContainer:nJob
      INLINE METHOD getError(); RETURN ::oCRWContainer:nErrCode
ENDCLASS

METHOD S2CRWPreviewDialog:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nScreenSize
   LOCAL oCRWContainer

   ::S2Dialog:init(0, 0, MAXROW(), MAXCOL(), ;
                   oParent, oOwner, aPos, aSize, aPP, lVisible)

   ::border    := XBPDLG_SIZEBORDER
   ::title     := ""
   ::maxButton := .T.
   ::titleBar  := .T.
   ::clipChildren := .T.
   ::close := {|| ::breakEventLoop() }
   ::lEventLoop := .T.

   ::drawingArea:clipChildren := .T.
   ::drawingArea:setColorBG( XBPSYSCLR_DIALOGBACKGROUND  )
   //::drawingArea:setColorBG( GRA_CLR_PALEGRAY   )
   //::drawingArea:resize := {|aO, aN, self| ;
   //                          ::oStatic:setSize({::drawingArea:currentSize()[1]-0,;
   //                                             ::drawingArea:currentSize()[2]-0}, .T.) }
   #ifndef _NOFONT_
   ::drawingArea:setFontCompoundName( "8.Helv" )
   #endif

   ::oStatic:= XbpStatic():new( ::drawingArea, , { 0, 0 }, ::drawingArea:currentSize() )
   ::oStatic:type := XBPSTATIC_TYPE_TEXT
   ::oStatic:clipChildren := .T.
   ::oStatic:setColorBG( GRA_CLR_WHITE )

   // simone 8/3/06 workaround per xbase 1.90 come da email di Alaska Software
   // mantis 0000996: con xbase 1.90 le anteprime crystal reports non sono visibili
   // da supporto Alaska:
   //   It seems that the window created for the preview somehow gets positioned 
   //   incorrectly. I haven't found out what caused the change in behaviour. 
#if XPPVER < 01900000
   ::oStatic:resize := {|aO, aN, self| oCrwContainer:setSize(aN) }
#else
   // l'altra soluzione era di impostare ::oStatic:sizeRedraw := .T.
   ::oStatic:resize := {|aO, aN, self| oCRWContainer:setPos({0, 0}), oCrwContainer:setSize(aN) }
#endif

   ::oCRWContainer := XbpCRWContainer():New( ::oStatic )
   oCRWContainer := ::oCRWContainer

RETURN self

METHOD S2CRWPreviewDialog:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   // LOCAL cZoom
   // LOCAL aZoom

   DEFAULT aPos TO {0, S2WinStartMenuSize()[2]}
   DEFAULT aSize TO S2AppDesktopSize()

   ::S2Dialog:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oStatic:create()
   ::oCRWContainer:Create( ::oStatic )
   //aSize := ::drawingArea:currentSize()

RETURN self

METHOD S2CRWPreviewDialog:destroy()
   ::oCRWContainer:destroy()
   ::oStatic:destroy()
   ::S2Dialog:destroy()
RETURN self

METHOD S2CRWPreviewDialog:resize(aOld, aNew)
   aNew[1] -=10
   aNew[2] -=40

   ::oStatic:setSize(aNew, .T.)
   //::oCRWContainer:setSize(aNew, .T.)
   //::invalidateRect( {0, 0, aNew[1], aNew[2]} )
RETURN self


METHOD S2CRWPreviewDialog:keyboard(nKey)
   DO CASE
      CASE nKey == xbeK_ESC
         ::breakEventLoop()
    /*
      CASE nKey == xbeK_HOME

      CASE nKey == xbeK_END

      CASE nKey == xbeK_CTRL_UP
         //::zoomOut()
         //::viewPreview:zoom( ::viewPreview:zoomFactor - ZOOM_FACTOR )

      CASE nKey == xbeK_CTRL_DOWN
         //::zoomIn()
         //::viewPreview:zoom( ::viewPreview:zoomFactor + ZOOM_FACTOR )

      CASE nKey == xbeK_LEFT
      CASE nKey == xbeK_RIGHT
      CASE nKey == xbeK_PGUP .OR. nKey == xbeK_UP
      CASE nKey == xbeK_PGDN .OR. nKey == xbeK_DOWN
     */
      OTHERWISE
         ::oCRWContainer:HandleAllMsgs()
         //::S2Dialog:keyboard(nKey)
   ENDCASE
RETURN self

METHOD S2CRWPreviewDialog:breakEventLoop()
   ::lEventLoop := .F.
RETURN self

METHOD S2CRWPreviewDialog:tbInk()
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL nEvent2, mp12, mp22, oXbp2
   LOCAL bEval

   DO WHILE ::lEventLoop
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp, 1, self )

      #ifdef _S2DEBUG_
         S2DebugOut(oXbp, nEvent, mp1, mp2)
      #endif

      IF oXbp == NIL
         // No more pending events, now we have to handle to system events.
         // However, the call to HandleAllMsgs() is required.

         ::oCRWContainer:HandleAllMsgs()
      ELSE
         IF nEvent == xbeP_Keyboard
	    // Simone 23/04/2004 GERR 3833
            // Toglie dalla coda dei messaggi i messaggi keyboard doppi
            dfIgnoreKbdEvent(mp1, mp2, oXbp)
           /*
            DO WHILE .T.
               nEvent2 := dfNextAppEvent(@mp12, @mp22, @oXbp2)

               IF nEvent2 == nEvent .AND. mp12 == mp1 .AND. mp22 == mp2 .AND. ;
                  oXbp2 != oXbp

                  AppEvent(@mp12, @mp22, @oXbp2)
               ELSE

                  EXIT
               ENDIF

            ENDDO
           */
         ENDIF

         oXbp:handleEvent( nEvent, mp1, mp2 )
      ENDIF
   ENDDO

RETURN self

