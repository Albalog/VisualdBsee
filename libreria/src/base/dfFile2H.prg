/******************************************************************************
Project     : dBsee 4.5
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
#include "dfStd.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFile2Html( cTitle, cOutPut )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL i,temps,showme,fld,tempn,typ,acur,temppic,printit,aligner,thevalue

DEFAULT cTitle  TO ""
DEFAULT cOutPut TO "output.htm"

SET PRINTER TO (cOutPut)
SET DEVICE  TO PRINTER

DEVOUT( "<html>" +CRLF )
DEVOUT( "<table border>" +CRLF )
DEVOUT( "  <caption> " + cTitle + " </caption>" +CRLF )

*--Display column headings (field names in this case)

DEVOUT( " <tr> " +CRLF )
i = 1
do while i <= fcount()
  temps = field(i) + space(10)
  temps = rtrim( upper(substr(temps,1,1))+lower(substr(temps,2)) )
  DEVOUT( "    <th> " + temps + " </th>" +CRLF  )
  i++
enddo
DEVOUT( " </tr>" +CRLF )

*--traverse table

DBGOTOP()
do while .not. eof()     && loop for each record
  DEVOUT( "  <tr>" +CRLF )  && indicates start of row
  i = 1
  do while i <= fcount()   && loop for each field
    fld      = field(i)
    typ      = upper(type(fld))
    showme   = " "      && init, this is the final field output
    thevalue = &fld     && evaluate it
    thevalue = ConvToAnsiCP( thevalue ) // conversione in ANSI (per caratteri accentati)
    do case
       case typ='C'
            showme = rtrim(thevalue)

       case typ='N'
            if thevalue = round(thevalue,0)   && no decimals
               showme = transform(thevalue,"###,###,###,###")
            else
               if thevalue = round(thevalue,2)   && 2 dec places
                 showme = transform(thevalue,"###,###,###,###.##")
               else  && lots of decimals (there are better ways to do this)
                 showme = transform(thevalue,"####,###,###.######")
               endif
            endif
            showme = ltrim(showme)

       case typ='D'
            showme = dtoc(thevalue)

       case typ='L'
            showme = iif(thevalue,'Yes','No')
    endcase

    IF EMPTY(showme)
       showme:="&nbsp;"
    ENDIF
    aligner = iif(typ="N"," align=right",space(0))   && align nums to right
    DEVOUT( "    <td"+aligner+"> " + showme + " </td>" +CRLF )

    i++
  enddo  && field loop
  DEVOUT( "  </tr>" +CRLF )    && end of row tag
  skip   && to next record
enddo    && record loop

DEVOUT( "</table>" +CRLF )   && indicate end of table
DEVOUT( "</html>  " )

SET PRINTER TO
SET DEVICE  TO SCREEN

RETURN .T.
