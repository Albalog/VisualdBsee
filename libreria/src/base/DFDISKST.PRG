/*******************************************************************************
Progetto       : dBsee 4.1
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "dfFloppy.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDiskStatus( cDrive )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

LOCAL nHandle, nRet := DISK_READY

IF (nHandle:=FCREATE( cDrive+":\NUL_____" ))<=0
   DO CASE
      CASE FERROR() == 3 ; nRet := DISK_NOFLOPPY
      CASE FERROR() == 5 ; nRet := DISK_NOWRITE
      OTHERWISE          ; nRet := DISK_UNKNOWNERROR
   ENDCASE
ELSE
   FCLOSE( nHandle )
   FERASE( cDrive+":\NUL_____" )
ENDIF

RETURN nRet
