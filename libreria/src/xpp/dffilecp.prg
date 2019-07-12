//*****************************************************************************
//Progetto       : dBsee for Xbase++
//Descrizione    : Invio Email
//Programmatore  : Simone Degl'Innocenti
//*****************************************************************************

#include "common.ch"
#include "dll.ch"


// ------------------------------------------------------
// Copia o muove un file, torna .t. o .f.
// inoltre per referenza in cTo torna il percorso e nome
// del file copiato
// ------------------------------------------------------
FUNCTION dfFileCopy(cFrom, cTo, lMove, lForce)
   LOCAL aFrom
   LOCAL aTo
   LOCAL cFunc
   LOCAL cAtr
   LOCAL lRet

   DEFAULT lMove  TO .F.
   DEFAULT lForce TO .F.

   cFunc := IIF(lMove, "MoveFileA", "CopyFileA")

   // Se ho indicato un percorso
   // es. S2FileCopia("C:\AUTOEXEC.BAT", "F:\APPS\")
   // imposto il nome del file da quello di copia
   aTo := dfFNameSplit(cTo)
   IF EMPTY(aTo[3])
      aFrom := dfFNameSplit(cFrom)
      aTo[3] := aFrom[3]
      aTo[4] := aFrom[4]

      cTo := aTo[1]+aTo[2]+aTo[3]+aTo[4]
   ENDIF

   lRet := DllCall("KERNEL32.DLL", DLL_STDCALL, cFunc, cFrom, cTo, 0) != 0

   // SD 28/05/2002 
   // Se ho un problema durante la copia e il file di destinazione 
   // esiste gi… ed Š in sola lettura tolgo l'attributo di sola lettura
   // e ci riprovo (a volte succede con il SETUP.EXE!)
   IF lForce .AND. ! lRet .AND. FILE(cTo) .AND. "R" $ (cAtr:=UPPER( dfGetFileAtr(cTo) ))
      dfSetFileAtr(cTo, "r")
      lRet := DllCall("KERNEL32.DLL", DLL_STDCALL, cFunc, cFrom, cTo, 0) != 0
   ENDIF

RETURN lRet

