// Simone 28/8/06
// mantis 0001130: dare possibilità di impostare icone toolbar disabilitate/focused   
//
// Funzioni per gestire una immagine toolbar collegata.
// ad esempio se l'immagine standard della toolbar=new.bmp 
// con queste funzioni posso collegare alla new.bmp una 
// immagine disabilitata (new_disabled.bmp) ed una focused (new_focus.bmp)
//
// dfSetRelatedImage(1, "add.bmp", "add_disabled.bmp")
// dfSetRelatedImage(2, "add.bmp", "add_focus.bmp")
//
// dfSetRelatedImage(1, "mod.bmp", "mod_disabled.bmp")
// dfSetRelatedImage(2, "mod.bmp", "mod_focus.bmp")


/*
FUNCTION dfGetRelatedImage(nType, xId)
   LOCAL c
   c:="XbaseIcon"+IIF(nType == 1, "Disabled_", "Focused_")+ALLTRIM( dfAny2Str(xId) )
   c:=dfSet(c)
   IF EMPTY(c)
      c := xID
   ENDIF
RETURN c
*/   

    
STATIC aImg := {{}, {}}

// dfGetRelatedImage()
// ritorna l'immagine collegata
// nType=1 disabilitata
// nType=2 focused
// xId = ID immagine (numero o nome immagine)
// nPos = by reference ritorna la posizione (0=immagine non esistente)
// 
// xRet = ID immagine collegata (numero o nome) (se non trovata=xID)
FUNCTION dfGetRelatedImage(nType, xId, nPos)
   LOCAL xRet := NIL

   IF VALTYPE(xID) $ "CM"
      xID := UPPER(ALLTRIM(xID))
   ENDIF

   nPos := ASCAN(aImg[nType], {|x| VALTYPE(x[1])==VALTYPE(xID) .AND. ;
                                   x[1]== xID})
   IF nPos > 0
      xRet := aImg[nType][nPos][2]
   ENDIF
RETURN xRet

// dfSetRelatedImage()
// imposta una immagine collegata
// nType=1 disabilitata
// nType=2 focused
// xId = ID immagine (numero o nome immagine)
// xRel = ID immagine collegata (numero o nome immagine)
//
// xRet = ID immagine precedente collegata (numero o nome) (se non trovata=xID)
FUNCTION dfSetRelatedImage(nType, xId, xRel)
   LOCAL nPos 
   LOCAL xRet

   IF VALTYPE(xID) $ "CM"
      xID := UPPER(ALLTRIM(xID))
   ENDIF

   xRet := dfGetRelatedImage(nType, xID, @nPos)
   IF nPos == 0
      AADD(aImg[nType], {xID, xRel})
   ELSE
      aImg[nType][nPos][2] := xRel
   ENDIF
RETURN xRet
