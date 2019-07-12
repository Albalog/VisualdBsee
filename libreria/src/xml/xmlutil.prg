#include "common.ch"

// passare nConv per conversione vocali o caratteri speciali
// es dfStr2Xml("ciao", 3)
// es dfStr2Xml("ciao", 3)

FUNCTION dfStr2Xml(cString, nConv)
   LOCAL n
   LOCAL cCh
   LOCAL nAsc

   DEFAULT nConv TO 1


   //E' da migliorare
   // Simone 20/06/2005 
   // mantis  0000775: report creati con Report Manager in formato XML non stampa correttamente i caratteri apice e virgolette
   // spostata la conversione carattere & al primo posto

   ////////////////////////////////////////////
   //Luca xl 4591 02/07/2015
   ////////////////////////////////////////////
   IF CHR(96) $ cString
      cString := STRTRAN(cString,chr(96), "'")
   ENDIF
   ////////////////////////////////////////////

   IF "&" $ cString
      cString := STRTRAN(cString,"&", "&amp;")
   ENDIF
   IF '"' $ cString
      cString := STRTRAN(cString,'"', "&quot;")
   ENDIF
   IF "<" $ cString
      cString := STRTRAN(cString,"<", "&lt;")
   ENDIF
   IF ">" $ cString
      cString := STRTRAN(cString,">", "&gt;")
   ENDIF

   ///////////////////////////////////////////////
   //Aggiunte da Luca il 21/11/2006 
   ///////////////////////////////////////////////
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#232;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#233;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#242;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#249;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#236;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#224;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#163;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#231;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#176;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#167;")
   ENDIF
   IF "�" $ cString
   cString := STRTRAN(cString,"�", "&#200;")
   ENDIF
   IF (cCh := dfEuroChar() ) $ cString
      cString := STRTRAN(cString,cCh, "&#8364;")
   ENDIF
   ////////////////////////////////////////////

/* simone 14/3/08 
   commentato perche inutile, le vocali vengono convertite sopra
   //Spostato su da: Luca  il 21/11/2006 
   IF nConv[2]   // test bit 1
      // conversione vocali
      cString := strtran(cstring, "�", "a'")
      cString := strtran(cstring, "�", "e'")
      cString := strtran(cstring, "�", "e'")
      cString := strtran(cstring, "�", "i'")
      cString := strtran(cstring, "�", "o'")
      cString := strtran(cstring, "�", "u'")
   ENDIF
*/

   //Spostato su da: Luca  il 21/11/2006 
   IF "'" $ cString
   cString := STRTRAN(cString,"'", "&apos;")
   ENDIF


   IF nConv[1] 
      FOR n := 1 TO LEN(cString)
         nAsc := asc(cString[n])

         IF nAsc <32    .AND.;
            !nAsc ==  7 .AND.;
            !nAsc ==  8 .AND.;
            !nAsc ==  9 .AND.;
            !nAsc == 10 .AND.;
            !nAsc == 11 .AND.;
            !nAsc == 13 .AND.;
            !nAsc == 16 .AND.;
            !nAsc == 17 .AND.;
            !nAsc == 27 

            nAsc := 32
            cCh  := " "
            cString := STUFF(cString, n, 1, cCh)
         ENDIF

         IF nAsc <32 .or. nAsc > 127
            cCh := "&#"+alltrim(str(nAsc))+";"
            cString := STUFF(cString, n, 1, cCh)
         ENDIF
      NEXT
   ENDIF
/*
      FOR n := 1 TO LEN(cString)
         IF asc(cString[n]) <32   .AND.;
            !asc(cString[n]) ==  7 .AND.;
            !asc(cString[n]) ==  8 .AND.;
            !asc(cString[n]) ==  9 .AND.;
            !asc(cString[n]) == 10 .AND.;
            !asc(cString[n]) == 11 .AND.;
            !asc(cString[n]) == 13 .AND.;
            !asc(cString[n]) == 16 .AND.;
            !asc(cString[n]) == 17 .AND.;
            !asc(cString[n]) == 27 
            cCh := " "
            cString := STUFF(cString, n, 1, cCh)
         ENDIF
      NEXT

      FOR n := 1 TO LEN(cString)
         IF asc(cString[n]) <32 .or. asc(cString[n]) > 127
            cCh := "&#"+alltrim(str(asc(cString[n])))+";"
            cString := STUFF(cString, n, 1, cCh)
         ENDIF
      NEXT
   ENDIF
*/

   IF nConv[3] .AND. "�" $ cString   // test bit 2
      cString := strtran(cString, "�", "o")
   ENDIF
RETURN cString


FUNCTION dfXml2Str(cString)
   LOCAL n, n2
   LOCAL cCh
   IF "&" $ cString
      cString := STRTRAN(cString,"&quot;", '"')
      cString := STRTRAN(cString,"&apos;", "'" )
      cString := STRTRAN(cString,"&lt;", "<")
      cString := STRTRAN(cString,"&gt;", ">")
      cString := STRTRAN(cString,"&amp;", "&")

      ////////////////////////////////////////////
      //Aggiunti da luca
      ////////////////////////////////////////////
      cString := STRTRAN(cString,"&#232;","�" )
      cString := STRTRAN(cString,"&#233;","�" )
      cString := STRTRAN(cString,"&#242;","�" )
      cString := STRTRAN(cString,"&#249;","�" )
      cString := STRTRAN(cString,"&#236;","�" )
      cString := STRTRAN(cString,"&#224;","�" )
      cString := STRTRAN(cString,"&#163;","�" )
      cString := STRTRAN(cString,"&#231;","�" )
      cString := STRTRAN(cString,"&#176;","�" )
      cString := STRTRAN(cString,"&#167;","�" )
      cString := STRTRAN(cString,"&#200;","�" )
      cString := STRTRAN(cString,"&#8364;",dfEuroChar() )
      ////////////////////////////////////////////
      
      // conversione &#codice;
      DO WHILE (n:=AT("&#", cString)) > 0
         n2 := AT(";", cString, n+1)
         IF n2 == 0
            EXIT
         ENDIF
         cCH := chr( val( SUBSTR(cString, n+2, n2-n-2)) )
         cString := STUFF(cString, n, n2-n+1, cCh)
      ENDDO
   ENDIF
RETURN cString

