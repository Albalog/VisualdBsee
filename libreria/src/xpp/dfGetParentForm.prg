// come la getparentform anche per xbase 1.82
FUNCTION dfGetParentForm( oChild )
 LOCAL oParent

#if XPPVER < 01900000

   IF ValType(oChild) != "O"
      RETURN NIL
   ENDIF

   oParent := oChild:SetParent()

   DO WHILE oParent != NIL .AND. ;
            oParent:IsDerivedFrom("XbpDialog") == .F. .AND.;
            oParent:IsDerivedFrom("XbpCrt")    == .F.
      oParent := oParent:SetParent()
   ENDDO
#else
   // uso la funzione standard da Xbase++ 1.90 in poi
   oParent := GetParentForm(oChild)
#endif
RETURN oParent
