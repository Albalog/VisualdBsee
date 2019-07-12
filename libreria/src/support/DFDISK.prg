* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDisk()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cPath := dfPathGet() 

   // simone 29/11/06
   // mantis 0001175: supportare percorsi UNC
   IF EMPTY(cPath) .OR. dfPathIsUNC(cPath) // se Š un percorso UNC
      RETURN 0
   ENDIF
RETURN ASC(CurDrive())
