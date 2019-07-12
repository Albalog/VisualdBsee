FUNCTION dfUsrMsg( cMsg )
#ifndef _WAA_

   // Workaround per dfusrmsg prima della prima form
   IF dfInitScreenOpen()
      dfInitScreenUpd(cMsg)
   ELSEIF S2FormCurr() != NIL .AND. S2FormCurr():isDerivedFrom("S2Form")
      S2FormCurr():SetMsg( cMsg )
   ENDIF
#endif
RETURN NIL
