// Classe per workaround su stampanti Acrobat PDF Writer 3.0
// che nella forms() restituisce la descrizione del FORM a NIL
// e puï creare errore (non ä testato se con questa classe funziona!)

#define UNKNOWN_MSG "(sconosciuto)"

CLASS S2Printer FROM XbpPrinter
   PROTECTED:
      METHOD normalizeArray()

   EXPORTED:
      METHOD forms()
      METHOD paperBins()
      METHOD setupDialog()
      METHOD startDoc()
      //////////////////////////////////////
      //Mantis 1019 Luca 23/03/2006
      METHOD List()
      //////////////////////////////////////
ENDCLASS

//Mantis 1019 Luca 23/03/2006
//Riferimento Erorre xbase 3008
//If no printers are installed on a machine, calling XbpPrinter:list()
//yields NIL instead of an array.
METHOD S2Printer:List()
   LOCAL aRet
   LOCAL oErr

   oErr := ERRORBLOCK({|o|break(o)})
   BEGIN SEQUENCE
      aRet := ::XbpPrinter:List()
      IF aRet == NIL
         aRet := {}
      ENDIF
   RECOVER
      dbMsgErr("Error in Windows Printer List!!!")
      aRet := {}
   END SEQUENCE
   ERRORBLOCK(oErr)

RETURN aRet
// Per workaround su alcune stampanti (PDF Writer) che
// hanno a NIL il secondo elemento
METHOD S2Printer:normalizeArray(aArray)
   IF VALTYPE(aArray) == "A"
      AEVAL(aArray,{|x| IIF( VALTYPE(x[2]) $ "CM", NIL, ;
                           x[2]:=UNKNOWN_MSG) }, NIL, NIL,.T.)
   ENDIF
RETURN aArray

METHOD S2Printer:forms()
   LOCAL aForms := ::XbpPrinter:forms()
   ::normalizeArray(@aForms)
RETURN aForms

METHOD S2Printer:paperBins()
   LOCAL aBins := ::XbpPrinter:paperBins()
   ::normalizeArray(@aBins)
RETURN aBins

// Simone 05/01/05 gerr 4308 
// in ambiente CITRIX+THINPRINT se il JobName contiene 
// la stringa ":n" con n=numero nel indica la stampante da usare
// e puï creare problemi. Il settaggio permette di togliere il :
// es. XbasePrintJobNameRemoveChars=:
//
METHOD S2Printer:startDoc(cJobName)
   LOCAL cDisabled
   IF PCOUNT() > 0
      cDisabled := dfSet("XbasePrintJobNameRemoveChars")
      IF VALTYPE(cJobName) $ "CM" .AND. ! EMPTY(cDisabled)
         cJobName := TRIM(dfRemChr(cJobName, cDisabled))
      ENDIF
      ::XbpPrinter:startDoc(cJobName)
   ELSE
      ::XbpPrinter:startDoc()
   ENDIF
RETURN self

// Workaround perchä alcuni driver di stampanti con BUG
// possono cambiare la cartella corrente!
// come ad esempio il driver: HP OfficeJet G 85 (multifunzione)
METHOD S2Printer:setupDialog()
   LOCAL cDir

   // Ricordo dov'ero
   cDir   := dfPathGet()

   // chiamo il menu standard
   ::XbpPrinter:setupDialog()

   // Mi rimetto a posto
   dfPathSet(cDir)
RETURN self


