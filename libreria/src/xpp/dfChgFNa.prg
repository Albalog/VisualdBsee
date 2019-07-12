// Torna un nome di file che pu• essere creato
// es.
// ? dfChgFName("come stai? io sto bene!") -> "come stai- io sto bene"
// perche creare un file che contiene un "?" non Š possibile

FUNCTION dfChgFName(cFile)
   // caratteri non consentiti in un nome di file
   cFile := STRTRAN(cFile, "/", "-")
   cFile := STRTRAN(cFile, "\", "-")
   cFile := STRTRAN(cFile, ":", "-")
   cFile := STRTRAN(cFile, "*", "-")
   cFile := STRTRAN(cFile, "?", "-")
   cFile := STRTRAN(cFile, "|", "-")
   cFile := STRTRAN(cFile, ">", "[")
   cFile := STRTRAN(cFile, "<", "]")
   cFile := STRTRAN(cFile, '"', "'")
RETURN cFile