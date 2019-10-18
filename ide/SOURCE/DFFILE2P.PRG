// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Description : Centralised copy text file to printer function
// *****************************************************************************
#include "common.ch"
#include "dfmsg.ch"
#include "dfReport.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFile2Prn( cFile, cTitle, cDevice, cSetup )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle, cString,  nCount := 0, nFileLen, lRet := .T.
LOCAL nDevice, cRet := "", lDefault
LOCAL bErr, lLoop
LOCAL nStyle

DEFAULT cTitle  TO ""       // Title
DEFAULT cDevice TO "LPT1"   // Default device
DEFAULT cSetup  TO ""

lDefault := ( dfSet( AI_LOGMESSAGE )!=NIL )

// Simone 20/9/06
// mantis 0001144: abilitare percorsi UNC nelle funzioni di stampa diretta DOS
IF VALTYPE(cDevice) == "O"
   // simone 30/12/08
   // supporto stampa file diretta su oggetto stampante (xbase 1.90)
   #if XPPVER < 01900000
     RETURN .F.
   #endif
   nDevice := cDevice

ELSEIF  (LEFT(cDevice,2)=="\\" .AND. dfUncPathIsPrinter(cDevice) ) // Tommaso + Simone 08/04/10 - EXCEL 2058
//ELSEIF LEFT(cDevice, 2) == "\\"    // supporto percorsi UNC (es. \\massimo\aficio)
   nDevice := cDevice
ELSE
   cDevice := UPPER(cDevice)

   DO CASE
      CASE cDevice == "LPT2" ; nDevice := PRN_LPT2
      CASE cDevice == "LPT3" ; nDevice := PRN_LPT3
      CASE cDevice == "LPT4" ; nDevice := PRN_LPT4
      CASE cDevice == "LPT5" ; nDevice := PRN_LPT5
      CASE cDevice == "LPT6" ; nDevice := PRN_LPT6
      CASE cDevice == "LPT7" ; nDevice := PRN_LPT7
      CASE cDevice == "LPT8" ; nDevice := PRN_LPT8
      CASE cDevice == "LPT9" ; nDevice := PRN_LPT9
      CASE cDevice == "COM1" ; nDevice := PRN_COM1
      CASE cDevice == "COM2" ; nDevice := PRN_COM2
      CASE cDevice == "COM3" ; nDevice := PRN_COM3
      CASE cDevice == "COM4" ; nDevice := PRN_COM4
      OTHERWISE              ; nDevice := PRN_LPT1
   ENDCASE

ENDIF

WHILE .T.
   IF dfPrnChk(nDevice)     // Verifying printer
      EXIT
   ENDIF
   IF !dfYesNo( dfStdMsg(MSG_DFFILE2PRN01), !lDefault )
      lRet := .F.
      EXIT
   ENDIF
ENDDO

IF lRet

   nStyle := dfSet(AI_XBASEPRINTPROGRESSSTYLE)
   // Simone 06/10/08
   // mantis 0001977: velocizzare le stampe 
   IF nStyle == AI_PRINTPROGRESSSTYLE_FANCY_THREAD
      nStyle := AI_PRINTPROGRESSSTYLE_FANCY
   ENDIF

   DO CASE
      CASE nStyle ==AI_PRINTPROGRESSSTYLE_FANCY
         dfPIOn( dfStdMsg(MSG_DFFILE2PRN02), cTitle, .F., AI_PROGRESSSTYLE_FANCY)

      OTHERWISE

       dbFrameOn( (MAXROW()/2)-3, 20, (MAXROW()/2)+4, 60, cTitle )
       dbFrameDis( dfStdMsg(MSG_DFFILE2PRN02) )
       dbFrameDis( "" )
   ENDCASE

   // This solve a problem printing over Novel Network on port over LPT3
   //IF nDevice > PRN_LPT3 .AND. nDevice < PRN_COM1 .AND. EMPTY(cSetup)
   IF dfSet(AI_DOSPRINTDIRECT) .AND. VALTYPE(cDevice) != "O"
    #ifdef __XPP__
      // Simone 9/set/03 GERR 3930
      bErr := ERRORBLOCK({|e| break(e) })
      lLoop := .T.
      DO WHILE lLoop
         BEGIN SEQUENCE
            COPY FILE (cFile) TO (cDevice)
            lLoop := .F.
         RECOVER 
            ERRORBLOCK(bErr)
            IF !dfYesNo( dfStdMsg(MSG_DFFILE2PRN01), !lDefault )
               lRet := .F.
               lLoop := .F.
            ENDIF
            ERRORBLOCK({|e| break(e) })
         END SEQUENCE
      ENDDO
      ERRORBLOCK(bErr)
    #else
         COPY FILE (cFile) TO (cDevice)
    #endif

   ELSE
      //cCol:=dbFrameCol()

      // Simone 29/11/05 gerr 4542
      nFileLen := DIRECTORY(cFile)
      IF LEN(nFileLen) > 0
         nFileLen := nFileLen[1][2]
      ELSE
         //nFileLen := dfFileSize(cFile)
         lRet := .F.
      ENDIF


    #ifdef __XPP__
      // Simone 9/set/03 GERR 3930
      bErr := ERRORBLOCK({|e| break(e) })
      lLoop := .T.
      DO WHILE lLoop
         BEGIN SEQUENCE
            IF VALTYPE(cDevice)=="O"
#if XPPVER < 01900000
#else
               // sintassi valida da Xbase 1.90 
               SET PRINTER TO OBJECT cDevice
#endif
            ELSE
            SET PRINTER TO (cDevice)
            ENDIF
            lLoop := .F.

         RECOVER 
            ERRORBLOCK(bErr)
            IF !dfYesNo( dfStdMsg(MSG_DFFILE2PRN01), !lDefault )
               lRet := .F.
               lLoop := .F.
            ENDIF
            ERRORBLOCK({|e| break(e) })
         END SEQUENCE
      ENDDO
      ERRORBLOCK(bErr)
    #else
      SET PRINTER TO (cDevice)
    #endif
      IF lRet 
         SET DEVICE  TO PRINTER
         SETPRC(0,0)

         IF !EMPTY( cSetup )
            DEVOUT( cSetup )
         ENDIF

         nHandle:=dfFOpen( cFile )     // Open file
         WHILE !dfFEof()               // until not EOF()

            // SD: IF !dfPrnChk(nDevice) .OR.;   // Error
            // SD:    NEXTKEY()!=0               // Or keyboard break

            IF dfChkLocal( nDevice )

               dfClearType() //FW
               SET DEVICE TO SCREEN
               IF dfYesNo( dfStdMsg(MSG_DFFILE2PRN03), lDefault )
                  lRet := .F.  // SD: LINEE INVERTITE!
                  EXIT
               ENDIF
               SET DEVICE TO PRINTER
            ELSE
               cString:=dfFRead()      // Read line
               IF LEFT( ALLTRIM(cString), 1 )==NEWPAGE
                  cRet := ""
               ENDIF

               DEVOUT( cRet +RTRIM(cString) )  // Print

               nCount+=LEN(cString)+2

               DO CASE
                  CASE nStyle == AI_PRINTPROGRESSSTYLE_FANCY
                     dfPiStep( nCount, nFileLen )

                  OTHERWISE
                     dbFramePro( nCount, nFileLen )

               ENDCASE

               dfFSkip()
               IF EMPTY cRet ASSIGN CRLF
            ENDIF
         ENDDO
         dfFClose( nHandle )
         SET PRINTER TO
         SET DEVICE  TO SCREEN
      ENDIF
   ENDIF

   DO CASE
      CASE nStyle ==AI_PRINTPROGRESSSTYLE_FANCY
         dfPIOff()

      OTHERWISE
         dbFrameOff()
   ENDCASE
ENDIF

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfChkLocal( nDevice )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lOK

// Simone 20/9/06
// mantis 0001144: abilitare percorsi UNC nelle funzioni di stampa diretta DOS
IF VALTYPE(nDevice) $ "CMO" .OR. (nDevice > PRN_LPT3 .AND. nDevice < PRN_COM1)
   lOK := (NEXTKEY()!=0)
ELSE
   lOK := (!dfPrnChk(nDevice) .OR. NEXTKEY()!=0)
ENDIF

RETURN lOK

