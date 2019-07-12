// rudimentale conversione della sintassi Xbase->Crystal
// converte una stringa con una espressione filtro Xbase
// in una espressione formula di Crystal Reports
//
// simone 24/8/04 funzionerebbe, per• in crystal l'alias 
// pu• essere diverso da quello in dbsee.. cioŠ l'alias ANAGRAF->CODCLI
// viene tradotto in {anagraf.codcli}, per• in crystal l'alias invece
// di ANAGRAF potrebbe essere AnaRpt1. e quindi ho un errore in runtime.

#translate ISVALIDCHAR(<x>) => (UPPER(<x>) $ "_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")

FUNCTION dfExp2CrwFormula(cFilter, nJob)
   LOCAL cRet := cFilter
   LOCAL aAlias := {}
   LOCAL cAlias, cField, n, nLeft, nRight

   cRet := dfSTRTRAN(cRet, "==", " = ")
   cRet := dfSTRTRAN(cRet, "#" , " <> ")
   cRet := dfSTRTRAN(cRet, "!=", " <> ")
   cRet := dfSTRTRAN(cRet, "$" , " in ")

   cRet := dfSTRTRAN(cRet, ["], ['])

   cRet := dfSTRTRAN(cRet, ".AND.", " and ")
   cRet := dfSTRTRAN(cRet, ".OR.", " or ")
   cRet := dfSTRTRAN(cRet, ".NOT.", " not ")
// questo Š pericoloso cambiarlo perche potrebbe essere un esclamativo 
// in una stringa (es. "ciao!" $ anagraf->commento)
//   cRet := dfSTRTRAN(cRet, "!", " not ")  


   cRet := dfSTRTRAN(cRet, ".T.", " TRUE ")
   cRet := dfSTRTRAN(cRet, ".F.", " FALSE ")

   cRet := dfSTRTRAN(cRet, "ALLTRIM(", "Trim("     )
   cRet := dfSTRTRAN(cRet, "UPPER("  , "UpperCase(")
   cRet := dfSTRTRAN(cRet, "LOWER("  , "LowerCase(")
   cRet := dfSTRTRAN(cRet, "LEN("    , "Length("   )

   // Elenco alias indicati nel report
   IF nJob != NIL
      aAlias := __PEGetTableList(nJob)
   ENDIF

   // converte campi dal formato alias->field 
   // nel formato crystal {alias.field}
   DO WHILE .T.
      n := AT("->", cRet)

      IF n == 0 
         EXIT
      ENDIF

      // alias
      nLeft := n-1
      DO WHILE nLeft >= 1 .AND. ISVALIDCHAR(cRet[nLeft])
         nLeft--
      ENDDO
      nLeft++

      cAlias := SUBSTR(cRet, nLeft, n-nLeft)

      // se nel report ho un solo alias allora uso quello
      IF LEN(aAlias) == 1
         cAlias := aAlias[1]
      ENDIF

      // field
      n += 2
      nRight := n
      DO WHILE nRight <= LEN(cRet) .AND. ISVALIDCHAR(cRet[nRight]) 
         nRight++
      ENDDO
      nRight--

      cField := SUBSTR(cRet, n, nRight-n+1)

      cRet := STUFF(cRet, nLeft, nRight-nLeft+1, "{"+cAlias+"."+cField+"}")
   ENDDO
RETURN cRet
