

// Tommaso + Simone 08/04/10 - Fuzione che controlla se un Path UNC Š una stampante
// Es. \\srv\shared\pluto     -> .F.
//     \\srv\shared\test.txt  -> .F.
//     \\srv\hp laserjet 5030 -> .T.
//     hp laserjet 5030       -> .F.
FUNCTION dfUncPathIsPrinter(cPath)
   LOCAL n:=0
   LOCAL aPrn := {}
   IF LEFT(cPath, 2)=="\\" 
      cPath:=UPPER(ALLTRIM(cPath))
      aPrn := S2WinPrnGetQueueName()
      n := ASCAN(aPrn, {|x|UPPER(ALLTRIM(x[2]))==cPath})
   ENDIF
RETURN n>0
