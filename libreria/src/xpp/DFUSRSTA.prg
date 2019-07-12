FUNCTION dfUsrState( cState )
   LOCAL oForm := S2FormCurr()
   LOCAL cOld  := ""

   IF oForm == NIL
      RETURN cOld
   ENDIF 

     IF !IsMethod(oForm, "GetState" )
      RETURN cOld
     ENDIF 
     IF !IsMethod(oForm, "SetState" )
      RETURN cOld
     ENDIF 

     IF oForm != NIL
      cOld := oForm:GetState()
      IF cState != NIL
         oForm:SetState( cState )
      ENDIF
   ENDIF
RETURN cOld

