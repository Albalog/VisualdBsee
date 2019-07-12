/*******************************************************************************
Project     : dBsee 4.4
Description : Supporto per funzioni dBsee 3.0
Programmer  : Baccan Matteo
*******************************************************************************/
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dbGetW( nRow, nCol, cStr, uVar, cPic, cSaveScreen )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfGetW( nRow, nCol, cStr, @uVar, cPic, UPPER(cSaveScreen)=="S"  )
RETURN
