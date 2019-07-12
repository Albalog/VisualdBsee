#include "common.ch"
#include "xbp.ch"
#include "appevent.ch"

CLASS ImplementAutoFillText FROM ImplementAutoFill
EXPORTED:
   INLINE METHOD init(oXbp)
       LOCAL b := {|cBuff,o,nKey, cDel, oSelf|_WordsGet(NIL,oXbp,cBuff, cDel)}
       ::ImplementAutoFill:init(b, oXbp)
   RETURN self

   INLINE METHOD TextAdd(cTxt)
   RETURN _WordsAdd(NIL, ::oXbp, cTxt)
ENDCLASS

// ritorna ARRAY per riempire elenco dei suggerimenti
//static function findstr(cStr, oObj, nKey)
//   LOCAL xRet, n 
//   xRet    := checkword(ALLTRIM(cStr))
//   IF ! VALTYPE(xRet) == "A"
//      RETURN cStr  
//   ENDIF
//   FOR n := 1 TO LEN(xRet)
//      xRet[n] := PAD(xRet[n], LEN(cStr))
//   NEXT
//RETURN {cSTR, xRet}   

//STATIC FUNCTION FindStr(cBuff)
//   IF LEN(cBuff) < 20
//      RETURN NIL
//   ENDIF
//
//RETURN cBuff

//STATIC FUNCTION FindStr(cBuff)
//   LOCAL aDir:=DIRECTORY(trim(cBuff)+"*.*"),cdir
//   IF LEN(aDir) == 1
//      cDir := PAD(aDir[1][1], LEN(cBuff))
//   ELSE
//      cDir := {}
//      aeval(aDir, {|x|aadd(cDir, x[1])})
//      cDir := {cBuff, cDir}
//   ENDIF
//RETURN cDir

STATIC FUNCTION _WordsGet(cForm, xID, cBuff, cDel)
   LOCAL aWords, c := UPPER(TRIM(cBuff))
   LOCAL aRet := {cBuff, {}}
   LOCAL n, x, nDel

   x := LEN(c)
   aWords := _Words(cForm, xID)

   IF ! EMPTY(cDel) .AND. (nDel := ASCAN(aWords, {|x| x==cDel})) >0
      AREMOVE(aWords, nDel)
   ENDIF

   FOR n := 1 TO LEN(aWords)
      IF LEFT(UPPER(aWords[n]), x)==c
        AADD(aRet[2], aWords[n])
      ENDIF
   NEXT
//   IF LEN(aRet[2])==1  // se c'Š solo 1 parola
//      RETURN aRet[2][1]
//   ENDIF

   aRet[1]:=NIL

RETURN aRet

STATIC FUNCTION _WordsAdd(cForm, xID, cWord)
   LOCAL aWords, c := UPPER(TRIM(cWord))
   aWords := _Words(cForm, xID)
   IF ASCAN(aWords, {|x|UPPER(x) ==c}) == 0
      AADD(aWords, TRIM(cWord))
      ASORT(aWords)
   ENDIF
RETURN NIL

STATIC FUNCTION _WordsDel(cForm, xID, cWord)
   LOCAL aWords, c := UPPER(TRIM(cWord)), n
   aWords := _Words(cForm, xID)
   IF (n:=ASCAN(aWords, {|x|UPPER(x) ==c})) != 0
      AREMOVE(aWords, n)
   ENDIF
RETURN NIL

STATIC FUNCTION _Words(cForm, xID)
   STATIC arr := {}
   LOCAL k, n

   DEFAULT cForm TO m->EnvID
   IF VALTYPE(xID) =="O"
      xID := xID:cID
   ENDIF
   DEFAULT xID TO "--"

   k := UPPER(var2char(cForm)+"_"+var2char(xID))
   n := ASCAN(arr, {|x|x[1]==k})
   IF n == 0
      AADD(arr, {k, {}})
      n := LEN(arr)
   ENDIF

RETURN arr[n][2]

#ifdef _SPELLER_

// Controlla una parola facendo il controllo ortografico
// usa la DLL EDXSPELL.DLL

#include "dll.ch"

#define EDX__WORDFOUND 1
#define EDX__WORDNOTFOUND 2
#define EDX__ERROR 4

STATIC FUNCTION checkword(c)
   local x:=space(40)
   local cbuff:=space(200)
   local n
   local cres
   local ndll := dllload("edxspell.dll")
   local i, aword
   local aguess := {}
   local xRet := .F.

//n := dllcall("edxspell.dll", DLL_STDCALL, "edx$dll_version", @cbuff, 190)
//? n, cbuff
   if empty(c)
      return .F.
   endif

   c:= trim(c)
   aWord := tokenize(c)
   for i := 1 to len(aword)
      x := aword[i]
      //? "Parola:", x
      cbuff:=space(200)
      n := dllcall("edxspell.dll", DLL_STDCALL, "edx$dic_lookup_word", trim(x), @cbuff, 190, "EDXDIC.DIC")
      if n == EDX__WORDFOUND
         //? "ok"
         xRet := .T.
      elseif n == EDX__WORDNOTFOUND
         //? "non trovata, suggerimenti:"
         cRes := SPACE(200)
         do while (n:=dllcall("edxspell.dll", DLL_STDCALL, "edx$spell_guess", @cRes, @cbuff, 190)) == EDX__WORDFOUND
             aadd(aGuess, trim(dfGetCString(cRes)))
             //? "-", trim(cres)
             cRes := SPACE(200)
         enddo
         xRet := aGuess
      endif
      if n == EDX__ERROR
         //? "Errore:", cbuff
         xRet := .F.
      endif
   next
RETURN xRet

// divide una frase in diverse parole
static function tokenize(c)
   local aRet := {}
   local i
   local n
   local x := ""
   local cTokens := CHR(9)+CHR(13)+CHR(10)+CHR(34)+" .()',$!%^&*{}[]?/||;:+-<>~"
   n :=len(c)
   for i := 1 to n
     if c[i] $ cTokens
        if ! empty(x)
           aadd(aRet, x)
        endif
        x:= ""
     else
        x+=c[i]
     endif
   next
   if ! empty(x)
      aadd(aRet, x)
   endif
return aRet
#endif


// oXbp deve implementare i metodi
// - editBuffer
// - queryMarked
// - setData
// - setMarked
CLASS ImplementAutoFill
   PROTECTED
        VAR oXbp
        VAR oLsb

   EXPORTED:
	VAR bAutoFill
	
	INLINE METHOD init(bAutoFill,oXbp)
           ::bAutoFill := bAutoFill
           ::oXbp      := oXbp
	RETURN self

        INLINE METHOD destroy()
           ::closeListbox()
           ::bAutoFill := NIL                
           ::oXbp      := NIL
        RETURN self                       

        INLINE METHOD listBoxVisible()
        RETURN ::oLsb != NIL


	INLINE METHOD closeListbox()
	   IF ::oLsb != NIL
	      ::oLsb:hide()
	      ::oLsb:destroy()
	      ::oLsb := NIL
	   ENDIF
	RETURN self

	INLINE METHOD lsbKeyboard(nKey)
	   IF nKey == xbeK_ESC
	      ::closeListbox()

	   ELSEIF nKey == xbeK_DEL .AND. ::oLsb != NIL .AND. LEN(::oLsb:getData()) > 0
	      ::autoFill(nKey)
           ENDIF
	RETURN self

	INLINE METHOD lsbItemSel()
           LOCAL n
           IF ::oLsb == NIL
              RETURN self
           ENDIF

	   n := ::oLsb:getData()
	   IF EMPTY(n)
              RETURN self
           ENDIF
           n := ::oLsb:getItem(n[1])

           ::closeListbox()
//Maudp 04/11/2010 XL 2474 In caso di selezione dalla lista di autofill,  non riportava gli eventuali spazi
//           ::oXbp:setData(n)
           ::oXbp:setData(n, .T.)
           ::oXbp:setMarked({LEN(TRIM(n))+1,LEN(TRIM(n))+1})
	RETURN self

	METHOD autoFill
        METHOD showListBox
ENDCLASS

METHOD ImplementAutoFill:showListBox(aList)
   LOCAL oObj, aPos, aSize
   LOCAL oLsb, xFont
   IF ::oLsb == NIL
       oObj := ::oXbp

       aPos := oObj:currentPos()
       aSize:= oObj:currentSize()
       aPos := dfCalcAbsolutePosition({0, aSize[2]-24}, oObj)
       aSize[1] += 26 // larghezza scrollbar
       aSize[2] := 100
       aPos[1] += 2
       aPos[2] -= aSize[2]+2
       oLsb := XbpListBox():new(AppDesktop(), NIL, aPos, aSize)
       oLsb:create()
       xFont := oObj:setFont()
       DO CASE
          CASE EMPTY(xFont)

          CASE VALTYPE(xFont) $ "CM"
             oLsb:setFontCompoundName(xFont)

          CASE VALTYPE(xFont) $ "O"
             oLsb:setFont(xFont)
       ENDCASE

       oLsb:keyboard:= {|n| ::lsbKeyboard(n)}
       oLsb:itemSelected := {|| ::lsbItemSel()}
       ::oLsb := oLsb
   ELSE
       oLsb := ::oLsb
   ENDIF

   oLsb:clear()
   AEVAL(aList, {|x| oLsb:addItem(x)})

RETURN self


METHOD ImplementAutoFill:autoFill(nKey,oXbp,bAutoFill,cString)
   LOCAL cFind, aMarked, xFind, cDel

   DEFAULT bAutoFill TO ::bAutoFill

   IF bAutoFill == NIL 
      RETURN self
   ENDIF

//   IF nKey==xbeK_DEL
//    nKey=xbeK_DEL
//   ENDIF
   IF ::oLsb != NIL .AND. nKey == xbeK_ESC
      ::closeListbox()

   ELSEIF ::oLsb != NIL .AND. (nKey == xbeK_ENTER .OR. nKey == xbeK_RETURN)
      IF EMPTY(::oLsb:getData())
         ::closeListBox()
       //  PostAppEvent(xbeP_Keyboard, nKey, NIL, ::oXbp)
      ELSE
      ::lsbItemSel()
//         nKey := NIL // evito gestione standard
      ENDIF

   ELSEIF ::oLsb != NIL .AND. (nKey == xbeK_UP .OR. nKey == xbeK_DOWN)
      IF EMPTY(::oLsb:getData())
         PostAppEvent(xbeP_Keyboard, xbeK_HOME, NIL, ::oLsb)
      ELSE
         PostAppEvent(xbeP_Keyboard, nKey, NIL, ::oLsb)
      ENDIF

   ELSEIF (nKey >=32 .AND. nKey<=65535) .OR. ;
       (::oLsb != NIL .AND. nKey==xbeK_DEL .AND. LEN(::oLsb:getData())>0) // se delete con listbox aperta e selezionata
      DEFAULT oXbp TO ::oXbp

      cDel := NIL
      IF nKey == xbeK_DEL
         cDel := ::oLsb:getItem( ::oLsb:getData()[1] )
      ENDIF

      DEFAULT cString TO oXbp:editBuffer()
      xFind := EVAL(bAutoFill, cString, oXbp, nKey, cDel, self)
      IF ! EMPTY(xFind)	    
         cFind := xFind
         IF VALTYPE(xFind) == "A" 
            IF LEN(xFind) >= 2 .AND. ! EMPTY(xFind[2])

               cFind := xFind[1]  // 1^ elem. = testo nell'SLE
               // show listbox
               //-------------
               ::showListBox(xFind[2]) // 2^ elem= array testi
               //-------------
               /*
               n:=ASCAN(xFind, oXbp:editBuffer()) 
               IF n > 0
                 cFind := xFind[n]
               ENDIF
               */
            ELSE
               cFind := NIL
               ::closeListbox()
            ENDIF
         ELSEIF ::oLsb != NIL
            ::closeListbox()
         ENDIF

         IF ! EMPTY(cFind) 
            aMarked := oXbp:queryMarked()	
     
            oXbp:setData(cFind)
            aMarked :={aMarked[1],LEN(TRIM(cFind))+1}
            //aMarked :={LEN(TRIM(cFind))+1,aMarked[1]}
            /*
            IF aMarked[2] < aMarked[1]
               cFind := aMarked[1]
               aMarked[1]:=aMarked[2]
               aMarked[2]:=cFind
            ENDIF
            */
            oXbp:setMarked(aMarked)
         ENDIF
      ENDIF    
   ENDIF
RETURN self


