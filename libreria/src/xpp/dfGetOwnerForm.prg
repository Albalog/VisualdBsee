FUNCTION dfGetOwnerForm( oChild )
   LOCAL oOwner

   IF ValType(oChild) != "O"
      RETURN NIL
   ENDIF

   oOwner := oChild:SetOwner()

   DO WHILE oOwner != NIL .AND. ;
            oOwner:IsDerivedFrom("XbpDialog") == .F. .AND.;
            oOwner:IsDerivedFrom("XbpCrt")    == .F.
      oOwner := oOwner:SetOwner()
   ENDDO
RETURN oOwner
