/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStationID()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cComputer:="", aDir

DO CASE
   CASE !EMPTY( cComputer:=NETNAME() )
        cComputer := "NetName : " +cComputer

   CASE !EMPTY( aDir := DIRECTORY( "C:\", "V" ) )
        cComputer := "Volume Name: " +aDir[1,1]

   CASE dfDskSer(3)>0
        cComputer := "HardDisk Serial : " +LTRIM(STR( dfDskSer(3) ))

   CASE !EMPTY( cComputer:=dfStaHdr() )
        cComputer := "Station Address : " +cComputer

   CASE !EMPTY( cComputer:=dfRomBios() )
        cComputer := "BIOS Date : " +cComputer

ENDCASE

RETURN cComputer
