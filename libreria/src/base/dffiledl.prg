/******************************************************************************
Project     : dBsee 4.5
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
#include "Directry.ch"
#include "dfWin.ch"
#include "dfCTRL.ch"
#include "dfMsg.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFileDlg( cPath, aWildCard )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cFile := "", aCTRL := {}, cmbcUnit, aUnit, cUnit := SPACE(2)
LOCAL LsbDir, cWildCard := PADR("*.*",20), cmbcWild
LOCAL aDir := {}

DEFAULT cPath     TO dfCurPath()+"\"
IF VALTYPE(aWildCard)=="A"
   cWildCard := aWildCard[1]
ELSE
   aWildCard := { cWildCard }
ENDIF

cPath := PADR( cPath, MAX(LEN(cPath),120) )

/* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

   Path

   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
ATTACH "cPath" TO aCTRL GET cPath AT   1,  5           ; // ATTGET.TMP
                 PICTURESAY "@S55!"                    ; // Picture in say
                 CONDITION {|ab|fcPath(ab,@cPath,cWildCard,LsbDir,aDir)};
                 PROMPT   dfStdMsg( MSG_DFFILEDLG01 )  ; // Prompt
                 PROMPTAT   1 ,  0                     ; // Coordinate prompt
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}    // Array dei colori

ATTACH "push" TO aCTRL GET AS PUSHBUTTON dfStdMsg( MSG_DFFILEDLG02 );
                          AT  0, 61, 2, 66;
                          FUNCTION {||dfTreeSel(@cPath,cWildCard,LsbDir,aDir)}

/* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

    Drive

   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
cmbcUnit := 0->(tbBrwNew(  5                      ,; // Prima  Riga
                          46                      ,; // Prima  Colonna
                          12                      ,; // Ultima Riga
                          51                      ,; // Ultima Colonna
                          W_OBJ_ARRAYBOX          )) // List-Box su ARRAY

cmbcUnit:W_COLORARRAY[AC_LSB_BACK  ]      := "N/W*"   // Colore fondo
cmbcUnit:W_COLORARRAY[AC_LSB_TOPLEFT]     := "W+/G"   //    "   bordo superiore
cmbcUnit:W_COLORARRAY[AC_LSB_BOTTOMRIGHT] := "B/G"    //    "   bordo inferiore
cmbcUnit:W_COLORARRAY[AC_LSB_PROMPT]      := "N/G"    //    "   prompt
cmbcUnit:W_COLORARRAY[AC_LSB_HILITE]      := "G+/G"   //    "   prompt selezionato
cmbcUnit:W_COLORARRAY[AC_LSB_HOTKEY]      := "G+/G"   //    "   hot key
cmbcUnit:COLORSPEC    := "N/W*"

aUnit := dfDiskArr()
ATTACH COLUMN "unit" TO cmbcUnit            ; // ATTCOL.TMP
                        BLOCK    {||tbGetArr(cmbcUnit,aUnit,NIL) }  ;
                        WIDTH     2                       ; // Larghezza colonna
                        PICTURE "XX"                      ; // Picture visualizzazione dato
                        COLOR  {"B+/W*","BG/W*","W+/BG"}    // Array dei colori
tbArrLen( cmbcUnit ,LEN(aUnit) )
ATTACH "cmbcUnit" TO aCTRL GET AS COMBO cUnit  ; // ATTCMB.TMP
                AT   4, 46                         ; // Coordinate dato in get
                PICTUREGET "XX"                    ; // Picture in get
                CONDITION {|ab|fcUnit(ab,@cPath,cWildCard,LsbDir,aDir)}       ; // Funzione When/Valid
                PROMPT dfStdMsg(MSG_DFFILEDLG03)   ; // Prompt
                PROMPTAT   3 , 46                  ; // Coordinate prompt
                LISTBOX cmbcUnit                   ; // Listbox-Box-Combo
                COLOR  {"N/G","G+/G","N/W*","W+/BG"} // Array dei colori


/* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

   Filter

   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
cmbcWild := 0->(tbBrwNew(  8                      ,; // Prima  Riga
                          46                      ,; // Prima  Colonna
                          15                      ,; // Ultima Riga
                          67                      ,; // Ultima Colonna
                          W_OBJ_ARRAYBOX          )) // List-Box su ARRAY

cmbcWild:W_COLORARRAY[AC_LSB_BACK  ]      := "N/W*"   // Colore fondo
cmbcWild:W_COLORARRAY[AC_LSB_TOPLEFT]     := "W+/G"   //    "   bordo superiore
cmbcWild:W_COLORARRAY[AC_LSB_BOTTOMRIGHT] := "B/G"    //    "   bordo inferiore
cmbcWild:W_COLORARRAY[AC_LSB_PROMPT]      := "N/G"    //    "   prompt
cmbcWild:W_COLORARRAY[AC_LSB_HILITE]      := "G+/G"   //    "   prompt selezionato
cmbcWild:W_COLORARRAY[AC_LSB_HOTKEY]      := "G+/G"   //    "   hot key
cmbcWild:COLORSPEC    := "N/W*"

ATTACH COLUMN "wild" TO cmbcWild            ; // ATTCOL.TMP
                        BLOCK    {||tbGetArr(cmbcWild,aWildCard,NIL) }  ;
                        PICTURE "XXXXXXXXXXXXXXXXXXXX"    ; // Picture visualizzazione dato
                        WIDTH     20                      ; // Larghezza colonna
                        COLOR  {"B+/W*","BG/W*","W+/BG"}    // Array dei colori
tbArrLen( cmbcWild ,LEN(aWildCard) )
ATTACH "cmbcWild" TO aCTRL GET AS COMBO cWildCard  ; // ATTCMB.TMP
                AT   7, 46                         ; // Coordinate dato in get
                COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                PICTUREGET "XXXXXXXXXXXXXXXXXXXX"                    ; // Picture in get
                CONDITION {|ab|fcWild(ab,cPath,cWildCard,LsbDir,aDir)}       ; // Funzione When/Valid
                PROMPT dfStdMsg(MSG_DFFILEDLG04)      ; // Prompt
                PROMPTAT   6 , 46                  ; // Coordinate prompt
                DATACHECK .F.                      ;
                LISTBOX cmbcWild                     // Listbox-Box-Combo


/* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

   Browse

   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
LsbDir := 0->(tbBrwNew(  3                         ,; // Prima  Riga
                         0                         ,; // Prima  Colonna
                        MAXROW()-7                 ,; // Ultima Riga
                        45                         ,; // Ultima Colonna
                        W_OBJ_ARRAYBOX             )) // List-Box su ARRAY

LsbDir:W_TITLE      := dfStdMsg(MSG_DFFILEDLG05)   // Titolo oggetto browse
LsbDir:W_COLORARRAY[AC_LSB_BACK  ]      := "N/W*"  // Colore fondo
LsbDir:W_COLORARRAY[AC_LSB_TOPLEFT]     := "W+/G"  //    "   bordo superiore
LsbDir:W_COLORARRAY[AC_LSB_BOTTOMRIGHT] := "B/G"   //    "   bordo inferiore
LsbDir:W_COLORARRAY[AC_LSB_PROMPT]      := "N/G"   //    "   prompt
LsbDir:W_COLORARRAY[AC_LSB_HILITE]      := "G+/G"  //    "   prompt selezionato
LsbDir:W_COLORARRAY[AC_LSB_HOTKEY]      := "G+/G"  //    "   hot key
LsbDir:COLORSPEC    := "N/W*"
LsbDir:W_LINECURSOR:= .T.

dfLoadDir(,cPath,cWildCard,LsbDir,aDir)

ADDKEY "ret" TO LsbDir:W_KEYBOARDMETHODS           ; // Tasto su List Box
       BLOCK   {||dfBrwInvio( aDir, @cPath, cWildCard, LsbDir,@cfile ) } ; // Funzione sul tasto
       MESSAGE ""

ATTACH COLUMN "exp00030001" TO LsbDir              ; // ATTCOL.TMP
                       BLOCK    {|| tbGetArr(LsbDir,aDir,1) }  ;
                       PICTURE "!!!!!!!!!!!!"      ; // Picture visualizzazione dato
                       PROMPT dfStdMsg(MSG_DFFILEDLG06); // Etichetta
                       WIDTH    12                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"} // ; // Array dei colori

ATTACH COLUMN "exp00030002" TO LsbDir              ; // ATTCOL.TMP
                       BLOCK    {|| tbGetArr(LsbDir,aDir,2) }  ;
                       PICTURE "!!!!!!!!!!!"       ; // Picture visualizzazione dato
                       PROMPT dfStdMsg(MSG_DFFILEDLG07); // Etichetta
                       WIDTH    11                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  //; // Array dei colori

ATTACH COLUMN "exp00030003" TO LsbDir              ; // ATTCOL.TMP
                       BLOCK    {|| tbGetArr(LsbDir,aDir,3) }  ;
                       PICTURE "99/99/99"          ; // Picture visualizzazione dato
                       PROMPT dfStdMsg(MSG_DFFILEDLG08); // Etichetta
                       WIDTH     8                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  //; // Array dei colori

ATTACH COLUMN "exp00030004" TO LsbDir              ; // ATTCOL.TMP
                       BLOCK    {|| tbGetArr(LsbDir,aDir,4) }  ;
                       PICTURE "99:99:99"          ; // Picture visualizzazione dato
                       PROMPT dfStdMsg(MSG_DFFILEDLG09); // Etichetta
                       WIDTH     8                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  //; // Array dei colori

ATTACH "LsbDir" TO aCTRL GET AS LISTBOX USING LsbDir   // ATTLSB.tmp


/* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

   Starting FORM

   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */

dfAutoForm( ,, aCTRL, dfStdMsg(MSG_DFFILEDLG10),,,.F. )
IF M->Act!="esc"
   dfBrwInvio( aDir, @cPath, cWildCard, LsbDir,@cfile)
ENDIF

RETURN cFile

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfLoadDir( lRefresh, cPath, cWildCard, LsbDir, aDir )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aRet   := {} ,;
      aTmp   := {} ,;
      nInd   := 0  ,;
      nStart := 0

DEFAULT lRefresh TO .F.

ASIZE( aDir, 0 )

aTmp := DIRECTORY( ALLTRIM(cPath) + "*.*", "D" )
nStart := IF( len(ALLTRIM(cPath))>3, 3, 1 )
aTmp := aSort( aTmp,nStart,,{|a,b|a[1] <= b[1] } )

FOR nInd := 1 TO len( aTmp )
    IF "D" $ aTmp[nInd,F_ATTR]
       AADD( aDir, { aTmp[nInd,F_NAME], "< SUB-DIR >", aTmp[nInd,F_DATE], aTmp[nInd,F_TIME], aTmp[nInd,F_ATTR] } )
       IF ALLTRIM( aTmp[nInd,F_NAME] ) == "."
          aDir[ len( aDir ), F_SIZE ] := "< ROOT    >"
       ENDIF
       IF ALLTRIM( aTmp[nInd,F_NAME] ) == ".."
          aDir[ len( aDir ), F_SIZE ] := "< UP--DIR >"
       ENDIF
    ENDIF
NEXT

aTmp := DIRECTORY( ALLTRIM(cPath) +ALLTRIM(cWildCard) )
aTmp := aSort( aTmp,,,{|a,b|a[1] <= b[1] } )

FOR nInd := 1 TO len( aTmp )
    AADD( aDir, { aTmp[nInd,F_NAME], NIL, aTmp[nInd,F_DATE], aTmp[nInd,F_TIME], aTmp[nInd,F_ATTR] } )
    aDir[ len( aDir ), F_SIZE ] := transform( aTmp[nInd,F_SIZE], "@ZE 999,999,999" )
NEXT
LsbDir:W_AI_LENGHT := LEN(aDir)

IF lRefresh
   lsbdir:RefreshAll()
   tbTop( lsbdir )
ENDIF

RETURN NIL

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION fcUnit(nPrePost,cPath,cWildCard,LsbDir,aDir)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET
   IF !EMPTY(tbGetVar(tbGetObj(),"cmbcUnit"))
      IF UPPER( LEFT(cPath,2) ) != UPPER( tbGetVar(tbGetObj(),"cmbcUnit") )

         cPath := PADR( tbGetVar( tbGetObj(), "cmbcUnit"  ) +"\", 60 )
         tbDisItm( tbGetObj(), "cPath" )
         dfLoadDir(.T.,cPath,cWildCard,LsbDir,aDir)
      ENDIF
   ENDIF
ENDIF

RETURN .T.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION fcWild(nPrePost,cPath,cWildCard,LsbDir,aDir)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC cPre
DO CASE
   CASE nPrePost == FORM_PREGET
        cPre := tbGetVar(tbGetObj(),"cmbcWild")

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET
        IF !EMPTY(tbGetVar(tbGetObj(),"cmbcWild"))
           IF cPre != UPPER( tbGetVar(tbGetObj(),"cmbcWild") )
              dfLoadDir(.T.,cPath,cWildCard,LsbDir,aDir)
           ENDIF
        ENDIF
ENDCASE

RETURN .T.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION fcPath(nPrePost,cPath,cWildCard,LsbDir,aDir)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC cPre
LOCAL lRet := .T.
DO CASE
   CASE nPrePost == FORM_PREGET
        cPre := cPath

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET
        IF !EMPTY(tbGetVar(tbGetObj(),"cPath"))
           cPath := PADR( dfPathchk(cPath), LEN(cPath) )
           tbDisItm( tbGetObj(), "cPath" )
           lRet := FILE(ALLTRIM(cPath)+"NUL")
           IF lRet
              IF cPre != UPPER( cPath )
                 dfLoadDir(.T.,cPath,cWildCard,LsbDir,aDir)
              ENDIF
           ELSE
              dbMsgErr( dfStdMsg(MSG_ERRSYS03) )
           ENDIF
        ENDIF
ENDCASE

RETURN lRet


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfTreeSel(cPath,cWildCard,LsbDir,aDir)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cNew := dfPathTree(LEFT(cPath,3))
IF !EMPTY(cNew)
   cPath := PADR(cNew,LEN(cPath))
   tbDisItm( tbGetObj(), "cPath" )
   dfLoadDir(.T.,cPath,cWildCard,LsbDir,aDir)
ENDIF
RETURN NIL


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfBrwInvio( aDir, cPath, cWildCard, LsbDir, cResult )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSel := tbRow( lsbdir ) ,;
      nInd := 0

IF nSel >= 1 .AND. nSel <= len( aDir )
   IF "D" $ aDir[nSel,F_ATTR]
      DO CASE
         CASE ALLTRIM(aDir[nSel,F_NAME]) == "."
              cPath := PADR( LEFT( cPath, 1 )+":\", 60 )
              tbDisItm( tbGetObj(), "cPath" )

         CASE ALLTRIM(aDir[nSel,F_NAME]) == ".."
              FOR nInd := len( ALLTRIM(cPath) )-1 TO 1 STEP -1
                  IF SUBSTR( ALLTRIM(cPath), nInd, 1 ) == "\"
                     cPath := PADR( LEFT( ALLTRIM(cPath), nInd ), 60 )
                     dfLoadDir(.T.,cPath,cWildCard,LsbDir,aDir)
                     EXIT
                  ENDIF
              NEXT
              tbDisItm( tbGetObj(), "cPath" )

         OTHERWISE
              cPath := PADR( ALLTRIM(cPath)+ALLTRIM(aDir[nSel,F_NAME])+"\", 60 )
              tbDisItm( tbGetObj(), "cPath" )

      ENDCASE

      dfLoadDir(.T.,cPath,cWildCard,LsbDir,aDir)

   ELSE
      fSetSelez(aDir, cPath, LsbDir,@cResult)
      dbAct2Kbd( "esc" )
   ENDIF
ENDIF

RETURN NIL

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION fSetSelez(aDir, cPath, LsbDir,cResult)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nInd := tbRow( lsbdir )

IF nInd >= 1 .AND.  nInd <= len( aDir ) .AND. !"D" $ aDir[ nInd, F_ATTR ]
   cResult := alltrim(cPath)+alltrim( aDir[ nInd, F_NAME ] )
ENDIF

RETURN NIL
