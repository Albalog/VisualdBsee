//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "FileIO.ch"
#INCLUDE "dfFile.ch"
#INCLUDE "dfReport.ch"

STATIC aFL := {}, nFL := 0

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFOpen( cFile, nMode, cSep, nLen, lSkipRem ) // Apertura file
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nHandle

DEFAULT nMode    TO FO_READ +FO_EXCLUSIVE // Apro in lettura Esclusiva
DEFAULT cSep     TO CRLF
DEFAULT nLen     TO FL_BUFFERLEN
DEFAULT lSkipRem TO .F.

cFile := Upper( cFile )

nHandle := FOpen( cFile, nMode )

IF nHandle # F_ERROR
   aAdd( aFL, { cFile, nHandle, "", "", 0, 0, .F., cSep, LEN(cSep), nLen, lSkipRem  })
   nFL := LEN(aFl)
   dfFTop()
ENDIF

RETURN nHandle

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFCreate( cFile, nMode, cSep, nLen, lSkipRem ) // Creazione file
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nHandle

DEFAULT nMode    TO FC_NORMAL              // Creo normale
DEFAULT cSep     TO CRLF
DEFAULT nLen     TO FL_BUFFERLEN
DEFAULT lSkipRem TO .F.

cFile := Upper( cFile )

nHandle := FCREATE( cFile, nMode )

IF nHandle # F_ERROR
   aAdd( aFL, { cFile, nHandle, "", "", 0, 0, .F., cSep, LEN(cSep), nLen, lSkipRem  })
   nFL := LEN(aFl)
ENDIF

RETURN nHandle

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFClose( nHandle )              // Chiude il file
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nErr := F_ERROR
LOCAL nAct := nFl

IF nHandle # NIL
   nAct := aScan( aFL, {|aSub| aSub[FL_HANDLE]==nHandle } )
ENDIF

IF nAct > 0
   nErr := FClose( aFL[nAct][FL_HANDLE] )
   aDel( aFL, nAct )
   aSize( aFL, Len(aFL)-1 )
   IF nFL == nAct
      nFl := 0
   ENDIF
ENDIF

RETURN nErr

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFSelect( nHandle )    // Seleziona il file attivo
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nOldHan := nFL
nFL := aScan( aFL, {|aSub| aSub[FL_HANDLE]==nHandle } )
IF nFL == 0                // Se non riesce a posizionarlo rimette il Vecchio
   nFL := nOldHan
ENDIF
RETURN nOldHan             // torna comunque il Vecchio

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFActual()
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
RETURN aFL[nFL]

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFRead()               // Legge una riga
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
RETURN aFL[nFL][FL_LINE]

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFEof()                // Torna l'eof
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
RETURN aFL[nFL][FL_EOF]

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFPos()                // Torna la posizione attuale
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nActual := dfFActual()
RETURN FSEEK( nActual[FL_HANDLE], 0, FS_RELATIVE ) -;
        ( LEN(nActual[FL_BUFFER])+nActual[FL_SEPLEN]+LEN(nActual[FL_LINE]) )

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
PROCEDURE dfFGoto( nPos )        // Va all'offset
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nActual := dfFActual()
FSEEK( nActual[FL_HANDLE], nPos, FS_SET ) // Go Top
nActual[FL_LINE]   := ""
nActual[FL_OFFSET] := nPos
nActual[FL_EOF]    := .F.
nActual[FL_BUFFER] := SPACE(nActual[FL_RECLEN])
nActual[FL_BUFPOS] := 0
dfFSkip()
RETURN

// Da controllare
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
PROCEDURE dfFUp()                // Va all'offset
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nActual := dfFActual()
LOCAL nPos    := MAX( dfFPos()-(nActual[FL_SEPLEN]+nActual[FL_RECLEN]), 0 )
LOCAL cBuf, nAT

FSEEK( nActual[FL_HANDLE], nPos, FS_SET )

cBuf := SPACE( nActual[FL_RECLEN] )
        FREAD( nActual[FL_HANDLE], @cBuf, nActual[FL_RECLEN] )
nAT  := RAT( nActual[FL_SEPCHAR], cBuf )
IF nAT>0
   nAT += nActual[FL_SEPLEN]
ENDIF
nPos := FSEEK( nActual[FL_HANDLE], 0, FS_RELATIVE )-(nActual[FL_RECLEN]-nAT+1)

dfFGoto( nPos )
RETURN
