FUNCTION dfGraSetAttrString(oPS,aAt)
   IF oPS:isDerivedFrom( "dfPdf" )
      //Utilizzo SetAttrString della Classe Pdf
      RETURN  oPS:SetAttrString(aAt)
   ENDIF
RETURN GraSetAttrString(oPs,aAt)
