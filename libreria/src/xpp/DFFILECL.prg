// Trasposizione delle funzioni dfFxxxx in class
// in modo che sia pi— usabile in un THREAD
// Modifiche
// - 27/02/2002 SD
//   prima versione

#INCLUDE "Common.ch"
#INCLUDE "FileIO.ch"
#INCLUDE "dfFile.ch"
#INCLUDE "dfReport.ch"

CLASS dfFile
   PROTECTED:
      VAR aFl

   EXPORTED:
      INLINE METHOD init()   ; ::aFL := {}; RETURN self
      INLINE METHOD destroy(); ::close()  ; RETURN self

      METHOD open, create, close
      METHOD eof, pos, goto, skip, top, locate
      METHOD read, append, up
ENDCLASS


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Open(cFile, nMode, cSep, nLen, lSkipRem ) // Apertura file
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nHandle

   DEFAULT nMode    TO FO_READ +FO_EXCLUSIVE // Apro in lettura Esclusiva
   DEFAULT cSep     TO CRLF
   DEFAULT nLen     TO FL_BUFFERLEN
   DEFAULT lSkipRem TO .F.

   cFile := Upper( cFile )

   nHandle := FOpen( cFile, nMode )

   IF nHandle # F_ERROR
      ::aFL:= { cFile, nHandle, "", "", 0, 0, .F., cSep, LEN(cSep), nLen, ;
                lSkipRem  }
      ::Top()
   ENDIF

RETURN nHandle

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Create( cFile, nMode, cSep, nLen, lSkipRem ) // Creazione file
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nHandle

   DEFAULT nMode    TO FC_NORMAL              // Creo normale
   DEFAULT cSep     TO CRLF
   DEFAULT nLen     TO FL_BUFFERLEN
   DEFAULT lSkipRem TO .F.

   cFile := Upper( cFile )

   nHandle := FCREATE( cFile, nMode )

   IF nHandle # F_ERROR
      ::aFL := { cFile, nHandle, "", "", 0, 0, .F., cSep, LEN(cSep), nLen, ;
                 lSkipRem  }
   ENDIF

RETURN nHandle

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Close()              // Chiude il file
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nErr := F_ERROR

   IF ! EMPTY(::aFL) .AND. ! EMPTY(::aFL[FL_HANDLE])
      nErr := FClose( ::aFL[FL_HANDLE] )
   ENDIF
   ::aFL:= {}
RETURN nErr

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Eof()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN ::aFL[FL_EOF]

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Read()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN ::aFL[FL_LINE]

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Pos()                // Torna la posizione attuale
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN FSEEK( ::aFL[FL_HANDLE], 0, FS_RELATIVE ) -;
        ( LEN(::aFL[FL_BUFFER])+::aFL[FL_SEPLEN]+LEN(::aFL[FL_LINE]) )




* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Goto( nPos )        // Va all'offset
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   FSEEK( ::aFL[FL_HANDLE], nPos, FS_SET ) // Go Top
   ::aFL[FL_LINE]   := ""
   ::aFL[FL_OFFSET] := nPos
   ::aFL[FL_EOF]    := .F.
   ::aFL[FL_BUFFER] := SPACE(::aFL[FL_RECLEN])
   ::aFL[FL_BUFPOS] := 0
   ::Skip()
RETURN NIL

// Da controllare
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Up()                // Va all'offset
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nPos    := MAX( ::Pos()-(::aFL[FL_SEPLEN]+::aFL[FL_RECLEN]), 0 )
   LOCAL cBuf, nAT

   FSEEK( ::aFL[FL_HANDLE], nPos, FS_SET )

   cBuf := SPACE( ::aFL[FL_RECLEN] )
           FREAD( ::aFL[FL_HANDLE], @cBuf, ::aFL[FL_RECLEN] )
   nAT  := RAT( ::aFL[FL_SEPCHAR], cBuf )
   IF nAT>0
      nAT += ::aFL[FL_SEPLEN]
   ENDIF
   nPos := FSEEK( ::aFL[FL_HANDLE], 0, FS_RELATIVE )-(::aFL[FL_RECLEN]-nAT+1)

   ::Goto( nPos )
RETURN NIL

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Append( cStr )      // Append di una riga
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   FSEEK( ::aFL[FL_HANDLE], 0, FS_END )
   FWRITE( ::aFL[FL_HANDLE], cStr +::aFL[FL_SEPCHAR] )
RETURN NIL

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Locate( cStr, lContinue )       // Trova una stringa
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL lFound := .F.
   LOCAL nPos

   DEFAULT lContinue TO .F.

   IF lContinue
      ::Skip()
   ELSE
      ::Top()                      // Go TOP
   ENDIF

   cStr := ALLtRIM(UPPER(cStr))     // Normalizzo la stringa

   DO WHILE ! ::Eof()
      IF AT( cStr, UPPER(::Read()) ) # 0  // Found
         lFound := .T.
         EXIT
      ENDIF
      IF AT( cStr, UPPER(::aFL[FL_BUFFER]) ) == 0
         nPos := RAT( ::aFL[FL_SEPCHAR], ::aFL[FL_BUFFER] )
         ::aFL[FL_LINE]   := ""
         ::aFL[FL_BUFFER] := SUBSTR( ::aFL[FL_BUFFER], nPos+::aFL[FL_SEPLEN] )
      ENDIF
      ::Skip()
   ENDDO

RETURN lFound

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Top()               // Si posiziona al TOP
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   ::Goto( 0 )
RETURN NIL

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfFile:Skip()               // Esegue uno Skip avanti di una riga
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nPos
   LOCAL nLen
   LOCAL cBuf
   LOCAL nPosSep

   IF ! ::Eof()
      WHILE .T.
         IF (nPos := At( ::aFL[FL_SEPCHAR], ::aFL[FL_BUFFER] )) == 0    // nessuna riga

            ::aFL[FL_OFFSET] += ::aFL[FL_BUFPOS]

            fSeek( ::aFL[FL_HANDLE], ::aFL[FL_OFFSET], FS_SET )

            cBuf := SPACE(::aFL[FL_RECLEN])
            nLen := fRead( ::aFL[FL_HANDLE], @cBuf, ::aFL[FL_RECLEN] ) // Leggo

            ::aFL[FL_BUFFER] := cBuf

            DO CASE
               CASE nLen == ::aFL[FL_RECLEN]
                    nPos := At( ::aFL[FL_SEPCHAR], ::aFL[FL_BUFFER] )

               CASE nLen > 0
                    ::aFL[FL_BUFFER] := Left( ::aFL[FL_BUFFER], nLen )

                    nPos := At( ::aFL[FL_SEPCHAR], ::aFL[FL_BUFFER] )
                    IF nPos == 0
                       nPos := nLen +1
                    ENDIF

               OTHERWISE
                    ::aFL[FL_BUFFER] := ""
                    ::aFL[FL_EOF] := .T.
                    nPos := 1
            ENDCASE
            IF (nPosSep := RAT( ::aFL[FL_SEPCHAR], ::aFL[FL_BUFFER] )) #0
               ::aFL[FL_BUFPOS] := nPosSep + ::aFL[FL_SEPLEN]
            ELSE
               ::aFL[FL_BUFPOS] := nPos
            ENDIF
            ::aFL[FL_BUFPOS]--
         ENDIF
         ::aFL[FL_LINE]   := Left( ::aFL[FL_BUFFER], nPos-1 )
         ::aFL[FL_BUFFER] := SubStr( ::aFL[FL_BUFFER], nPos+::aFL[FL_SEPLEN] )
         IF ::aFL[FL_SKIPREM]
            IF ::aFL[FL_EOF] .OR. !dfFIsRem(::aFL[FL_LINE])
               EXIT
            ENDIF
         ELSE
            EXIT
         ENDIF
      ENDDO
   ENDIF

RETURN NIL
