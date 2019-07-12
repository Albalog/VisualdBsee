#include "Common.ch"
#include "Set.ch"
#include "dfSet.ch"
#include "dfStd.ch"
#include "dfCtrl.ch"
#include "dfXBase.ch"
#include "dfMsg.ch"
#include "dfMsg1.ch"
#include "xbp.ch"
#include "Inkey.ch"
#include "dftab.ch"
#include "dfWin.ch"
#include "dfMenu.ch"
#include "Font.ch"



PROCEDURE dfGet( nRow, nCol, uVar, cPic, cColor, cKey,nCoordMode)
   dfGetW( nRow, nCol, "", uVar, cPic, NIL, NIL, nCoordMode )
RETURN

//Inserita la possibilitÖ di avere un messaggio di help sulla get inserita
FUNCTION dfGetW( nRow, nCol, cPro, bGet, cPic, lSave, xOkAct,nCoordMode, cMsg)

   // STATIC aColor
   LOCAL cRealPic, nColGet, nRight, nRealLen, cType
   LOCAL xGet
   LOCAL oDlg
   LOCAL lCodeBlock
   LOCAL aSize
   LOCAL aPos
   LOCAL oCtrl
   LOCAL nInd
   LOCAL xGetSize
   LOCAL yGetSize

   //LOCAL aSize
   // DEFAULT aColor TO dfColor( "Form" )

   DEFAULT nCol  TO 0
   DEFAULT cMsg  TO ""
   DEFAULT cPic  TO ""
   DEFAULT lSave TO .T.
   DEFAULT nCoordMode   TO W_COORDINATE_ROW_COLUMN //S2CoordModeDefault()
   DEFAULT cMsg TO cPro


   ////////////////////////////////////////////////////////////////
   //Mantis 2244
   //Correzione allineamento Prompt della GET Automatico 
   ////////////////////////////////////////////////////////////////
   aSize := _GetSize(cPro)
   ////////////////////////////////////////////////////////////////
   IF !EMPTY(aSize) .AND. !EMPTY(aSize[1])
      nColGet  := aSize[1]   
   ELSE
      nColGet  := LEN(cPro) + 2 // +nCol
      ////////////////////////////////////////////////////////////////////
      //Modifica del 15/06/2010 Rif. xls 
      //Miglioramento grafico quando la Picture del campo ä molto grande
      IF nColGet>20
         nColGet := INT(nColGet* 0.85)
      ENDIF 
   ENDIF 
   ////////////////////////////////////////////////////////////////////
   cRealPic := cPic

   lCodeBlock := VALTYPE( bGet )=="B"

   IF lCodeBlock
      cType := VALTYPE(EVAL(bGet))
   ELSE
      cType := VALTYPE(     bGet )
   ENDIF

   cPic  := UPPER(ALLTRIM(cPic))

   DO CASE
      CASE "@S" $ cPic

           cRealPic := REPLICATE("X", VAL(STRTRAN(cPic,"@S","")))
           IF EMPTY cRealPic ASSIGN "@X"

           cRealPic := dfGetWPic( bGet, cRealPic, "X" )

      CASE LEFT(cPic,2)=="@J" .OR. LEFT(cPic,2)=="@0"

           cRealPic := SUBSTR(cPic,3)
           IF EMPTY cRealPic ASSIGN "@9"

           cRealPic := dfGetWPic( bGet, cRealPic, "9" )

      CASE LEN(cPic)==2 .AND. LEFT(cPic,1)=="@"

           cRealPic := dfGetWPic( bGet, cPic, "X" )
   ENDCASE

   // Nei numerici tolgo il @ZE in testa
   IF cType=="N"
      cRealPic := SUBSTR( cRealPic, MAX(AT( "9", cRealPic ),1) )
   ENDIF

   // Data con picture vuota
   IF EMPTY(cRealPic)
      DO CASE
         CASE cType=="C"; cRealPic := dfGetWPic( bGet, cPic, "X" )
         CASE cType=="D"; cRealPic := SET(_SET_DATEFORMAT)
         CASE cType=="L"; cRealPic := "!"
         CASE cType=="N"; cRealPic := dfGetWPic( bGet, cPic, "9" )
      ENDCASE
   ENDIF

   nRealLen := LEN(cRealPic)
   IF cType == "D"
      nRealLen := MAX( nRealLen, LEN(SET(_SET_DATEFORMAT)) )
   ENDIF

   //nRight   := nColGet +nRealLen + nCol
   nRight   := LEN(cPro) + 2 +nRealLen + nCol
   nRight   := MAX(nRight,15 ) 
   IF nRight > MAXCOL()-3

      // Modifica Studio 2000
      // cPic   := "@S" +ALLTRIM(STR(MAXCOL()-3-nColGet))
      cPic   := IIF(cPic == "@!", "@!S", "@S") +ALLTRIM(STR(MAXCOL()-3-nColGet))
      nRight := MAXCOL()-2
   ENDIF

   IF nRow==NIL
      nRow := INT(MAXROW()/2)-2
   ENDIF

   oDlg := S2Form():new( nRow, nCol, nRow+2, nRight+5, W_OBJ_FRM, ;
                         NIL, NIL, NIL, NIL, NIL, .F., nCoordMode )
   oDlg:titleBar := .T.
   oDlg:taskList := .F.
   oDlg:sysMenu  := .T.
   oDlg:ShowMessageArea := .F.
   oDlg:ShowToolBar     := .F.
   IF oDlg:UseMainToolbar()
      oDlg:ShowToolBar     := .T.
   ENDIF
   IF oDlg:UseMainStatusLine()
      oDlg:ShowMessageArea := .T.
   ENDIF

   oDlg:W_TITLE := dfStdMsg1(MSG1_DFGETW01)

   // oDlg:FormName := EnvId

   oDlg:W_MOUSEMETHOD := W_MM_PAGE + W_MM_ESCAPE+ W_MM_MOVE    // Inizializzazione ICONE per mouse

   IF EMPTY(xOkAct)
      ADDKEY "ret" TO oDlg:W_KEYBOARDMETHODS          ; // Tasto su List Box
            BLOCK   {|| dbAct2Kbd("wri")}             ; // Funzione sul tasto
            WHEN    {|s| .T. }                        ; // Condizione di stato di attivazione
            RUNTIME {||.T.}                           ; // Condizione di runtime
            MESSAGE dfStdMsg(MSG_DFGET02)
   ELSE
      xOkAct := dfStr2Arr(xOkAct, "-")  
      FOR nInd := 1 TO LEN(xOkAct)
         IF ! EMPTY(xOkAct[nInd])
            
// Tommaso 25/03/11 - Se tra le azioni ho passato anche wri ed esc aggiungo le icone sulla toolbar
            DO CASE 
               CASE xOkAct[nInd] == "esc"
                  ATTACH "Z1" TO MENU oDlg:W_MENUARRAY AS MN_LABEL  ; //
                          BLOCK    {||MN_SECRET}  ; // Condizione di stato di attivazione
                          PROMPT   dfStdMsg( MSG_FORMESC )           ; // Label
                          SHORTCUT "esc"                             ; // Azione (shortcut)
                          EXECUTE  {||M->Act:="esc"}                   ; // Funzione
                          MESSAGE  dfStdMsg( MSG_FORMESC )             // Message

               CASE xOkAct[nInd] == "wri"
                  ATTACH "Z2" TO MENU oDlg:W_MENUARRAY AS MN_LABEL  ; //
                          BLOCK    {||MN_SECRET}  ; // Condizione di stato di attivazione
                          PROMPT   dfStdMsg( MSG_FORMWRI )           ; // Label
                          SHORTCUT "wri"                             ; // Azione (shortcut)
                          EXECUTE  {||M->Act:="wri"}                    ; // Funzione
                          MESSAGE  dfStdMsg( MSG_FORMWRI )             // Message
               
               OTHERWISE
            ADDKEY xOkAct[nInd] TO oDlg:W_KEYBOARDMETHODS  ; // Tasto su List Box
                  BLOCK   {|| dbAct2Kbd("wri")}            ; // Funzione sul tasto
                  WHEN    {|s| .T. }                       ; // Condizione di stato di attivazione
                  RUNTIME {||.T.}                          ; // Condizione di runtime
                  MESSAGE dfStdMsg(MSG_DFGET02)
            ENDCASE
//            ADDKEY xOkAct[nInd] TO oDlg:W_KEYBOARDMETHODS          ; // Tasto su List Box
//                  BLOCK   {|| dbAct2Kbd("wri")}  ; // Funzione sul tasto
//                  WHEN    {|s| .T. }                    ; // Condizione di stato di attivazione
//                  RUNTIME {||.T.}                             ; // Condizione di runtime
//                  MESSAGE dfStdMsg(MSG_DFGET02)
         ENDIF
      NEXT
   ENDIF

//   ATTACH "_GET_" TO oDlg:W_CONTROL GET xGet AT   0.5, nColGet+0.3 ; // ATTGET.TMP
//                    COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
//                    PROMPT   cPro                     ; // Prompt
//                    PROMPTAT   0.5,  1                ; // Coordinate prompt
//                    PICTURESAY cPic                   ; // Picture in say
//                    VARNAME "_GET_"                   ; //
//                    MESSAGE  cMsg                     ; // Messaggio
//                    ACTIVE {||.T.}                     // Stato di attivazione
   
   ATTACH "_GET_" TO oDlg:W_CONTROL GET xGet AT   18, nColGet ; // ATTGET.TMP
                    SIZE       { LEN(cRealPic)* 6 ,  18}            ; // Dimensioni Campo get
                    COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                    ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                    COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                    PROMPT   cPro                     ; // Prompt
                    PROMPTAT   20,  0                ; // Coordinate prompt
                    PICTURESAY cPic                   ; // Picture in say
                    VARNAME "_GET_"                   ; //
                    MESSAGE  cMsg                     ; // Messaggio
                    ACTIVE {||.T.}                     // Stato di attivazione




                   // PROMPTFONT cPrompt    ; // Prompt Font Name (XBASE)

   tbConfig( oDlg )

   IF lCodeBlock
      xGet := EVAL(bGet)
   ELSE
      xGet := bGet
   ENDIF

   // Allargo un po' il campo
   // -----------------------
   oCtrl := oDlg:searchObj("_GET_")[1]




   IF oCtrl != NIL

      // Faccio il display per essere sicuro che le dimensioni siano
      // corrette... a video non si vede niente perchä la finestra
      // ancora non ä visibile
      oCtrl:DispItm()

      aSize    := oCtrl:currentSize()
      aSize[1] += 20
      xGetSize := aSize[1]
      yGetSize := aSize[2]

      IF oDlg:useMainToolbar()
         // imposto altezza fissa altrimenti cambia se c'Ë toolbar o no!
         oDlg:setSize({oDlg:currentSize()[1], 70})
         oCtrl:setPosAndSize({oCtrl:currentPos()[1], oCtrl:currentPos()[2]+10}, aSize)
      ELSE
         oCtrl:setSize(aSize)
      ENDIF

      ////////////////////////////////////////////////////////////////
      //Mantis 2244
      //Correzione allineamento Prompt della GET Automatico 
      ////////////////////////////////////////////////////////////////
      IF oCtrl:oPrompt <> NIL
         oCtrl:oPrompt:options := XBPSTATIC_TEXT_RIGHT
         oCtrl:oPrompt:autoSize := .T.
         aSize := oCtrl:oPrompt:currentSize()
         oCtrl:setPos({oDlg:currentSize()[1] - xGetSize -50,aSize[2]} )
         xGetSize := oCtrl:currentPos()[1]
         aPOS     := oCtrl:setParent():currentPos() 
         oCtrl:oPrompt:setPos( {xGetSize-aSize[1] -4 , aSize[2]} )
      ENDIF 
      ////////////////////////////////////////////////////////////////

   ENDIF

   oDlg:tbDisItm("#")

   oDlg:tbGet(NIL, DE_STATE_MOD)

   IF lCodeBlock
      EVAL(bGet, xGet)
   ELSE
      bGet := xGet
   ENDIF

   oDlg:tbEnd()
   oDlg:destroy()


RETURN NIL

STATIC FUNCTION dfGetWPic( bGet, cPic, cNew )
   LOCAL nRealLen

   IF VALTYPE( bGet )=="B"
      //nRealLen := LEN( TRANSFORM(EVAL(bGet),cPic) )
       nRealLen := LEN( dfAny2Str(EVAL(bGet),cPic) )
   ELSE
      //nRealLen := LEN( TRANSFORM(     bGet ,cPic) )
       nRealLen := LEN( dfAny2Str(     bGet ,cPic) )
   ENDIF

RETURN REPLICATE( cNew, nRealLen )


Static FUNCTION _GetSize(cCaption)
   LOCAL aSize, oXbp
   LOCAL bErr := ErrorBlock( {|e| break(e) } )
   LOCAL xO

   BEGIN SEQUENCE
    aSize := {0,0}

    // creo nuovo oggetto per calcolo dimensioni
    oXbp := XbpStatic():new(NIL, NIL, {-100,-100},NIL)
    oXbp:caption := cCaption
    // tolgo caratteri ~
    oXbp:caption  := STRTRAN(oXbp:caption, STD_HOTKEYCHAR, "")
    oXbp:autoSize := .T.
    oXbp:visible  := .F.
    oXbp:create()
    aSize := oXbp:currentSize()
    oXbp  := NIL 

   RECOVER USING xO
    aSize := {0,0}

   END SEQUENCE

   ErrorBlock(bErr)

RETURN  aSize