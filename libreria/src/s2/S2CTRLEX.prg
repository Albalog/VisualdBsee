#include "gra.ch"
#include "xbp.ch"
#include "dfStd.ch"
#include "Common.ch"
#include "dfXBase.ch"
#include "Appevent.ch"
#include "dfSet.ch"

MEMVAR ACT, A, SA

#define S2GROUPBOX_OFFSET_TOP    9
#define S2GROUPBOX_OFFSET_LEFT   5

#define PAL_IDX_INIT    100
CLASS S2GroupBoxWithFocus FROM S2StaticX //XbpStatic
   EXPORTED:
      VAR caption, oCaption, aOffSet
      VAR nHiliteColorFG, nHiliteColorBG, nDehiliteColorFG, nDehiliteColorBG
      METHOD Init, Create //, destroy
      METHOD show, hide, hilite, dehilite, enable, disable, dispItm
      METHOD SetCoords, getTextSize, resize, setSize
      ACCESS METHOD GetCaption VAR caption
      ASSIGN METHOD setCaption VAR caption

      DEFERRED METHOD findStyle
ENDCLASS

METHOD S2GroupBoxWithFocus:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPP
   ::S2StaticX:Init(oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::type := ::findStyle()

   IF ::getType() == XBPSTATIC_TYPE_GROUPBOX
      //::oCaption := XbpStatic():new(self, self, aPos, NIL, aPP, lVisible )
      ::oCaption := XbpStatic():new(self, self, aPos, NIL, NIL, lVisible )
      ::oCaption:caption  := ""
      ::oCaption:autoSize := .T.
      ::oCaption:type     := XBPSTATIC_TYPE_TEXT



   ENDIF


   //////////////////////////////////////////////////////////////////////
   //Aggiunto settaggio per allinemanto a destra o centro delle listbox
   //////////////////////////////////////////////////////////////////////
   IF dfSet("XbaseBoxHeaderAlign") != NIL
      IF UPPER(dfSet("XbaseBoxHeaderAlign")) == "LEFT"
         ::S2StaticX:headerAlign := GRA_HALIGN_LEFT
      ELSEIF UPPER(dfSet("XbaseBoxHeaderAlign")) == "CENTER"
         ::S2StaticX:headerAlign := GRA_HALIGN_CENTER
      ENDIF
   ENDIF  
   //////////////////////////////////////////////////////////////////////


   ::aOffSet           := {0,0}

   ::nHiliteColorFG    := XBPSYSCLR_HILITEFOREGROUND 
   ::nHiliteColorBG    := XBPSYSCLR_HILITEBACKGROUND 

   // Prendo il colore da Pres.param o valore standard o default
   oPP := S2PresParameter():new(aPP)
   ::nDehiliteColorFG := oPP:get(XBP_PP_FGCLR)
   ::nDehiliteColorBG := oPP:get(XBP_PP_BGCLR)
   DEFAULT ::nDehiliteColorFG  TO ::setColorFG() // GRA_CLR_BLACK 
   DEFAULT ::nDehiliteColorBG  TO ::setColorBG() // XBPSYSCLR_DIALOGBACKGROUND 
 
   IF ::getType() == XBPSTATIC_TYPE_GROUPBOX
      DEFAULT ::nDehiliteColorFG  TO GRA_CLR_BLACK 
      DEFAULT ::nDehiliteColorBG  TO XBPSYSCLR_DIALOGBACKGROUND 
   ELSE
      // simone 1/6/05
      // mantis 0000760: abilitare nuovi stili per i controls
      IF ! EMPTY(dfSet(AI_XBASEGRPBOXFONT))
         ::setHFontCompoundName( dfSet(AI_XBASEGRPBOXFONT) )
      ENDIF
      IF ! EMPTY(dfSet("XbaseBoxHeaderColorBG"))
          S2ItmSetColors({|n|NIL}, {|n| ::headerColorBG := n}, .T., dfSet("XbaseBoxHeaderColorBG"))
      ENDIF
      IF ! EMPTY(dfSet("XbaseBoxColorBG"))
          S2ItmSetColors({|n|NIL}, {|n| ::setColorBG(n)}, .T., dfSet("XbaseBoxColorBG"))
      ENDIF
      IF ! EMPTY(dfSet("XbaseBoxBorderColor"))
          S2ItmSetColors({|n|NIL}, {|n| ::borderColor := n}, .T., dfSet("XbaseBoxBorderColor"))
      ENDIF

      // colori per HILITE/DEHILITE
      // simone 20/09/08
      // mantis 0001944: poter impostare colori dei browse e
      // mantis 0001692: rivedere colori listbox evidenziate 
      // imposta colori box con focus
      IF ! EMPTY(dfSet("XbaseBoxHiliteColorBG"))
          S2ItmSetColors({|n|NIL}, {|n| ::nHiliteColorBG := n}, .T., dfSet("XbaseBoxHiliteColorBG"))
      ELSE
         // simone 20/09/08
         // per compatibilit… con funzionamento precedente...
         // uso XBASEBOXCOLORBG se non Š definito XBASEBOXHILITECOLORBG
      IF ! EMPTY(dfSet("XbaseBoxColorBG"))
          S2ItmSetColors({|n|NIL}, {|n| ::nHiliteColorBG := n}, .T., dfSet("XbaseBoxColorBG"))
      ENDIF
      ENDIF
      DEFAULT ::nDehiliteColorBG  TO ::headerColorBG
   ENDIF
RETURN self

METHOD S2GroupBoxWithFocus:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   // Simone 27/06/2005
   // mantis 0000793: migliorare visualizzazione listbox/editbox su form con bitmap background
   // in caso di form con bitmap background l'header non ha i colori corretti
   ::dehilite()
   
   ::S2StaticX:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   IF ! EMPTY( ::oCaption )
      ::oCaption:Create( self, self, aPos, aSize, aPP, lVisible )

      IF ::caption != NIL .AND. ! ::caption == ""
         // Calcolo la differenza in pixel fra le dimensioni che ritorna la
         // getTextSize e quelle impostate automaticamente dall'XbpStatic
         aSize := ::oCaption:currentSize()
         aPos  := ::getTextSize( ::oCaption:caption )

         ::aOffset := {aSize[1]-aPos[1], aSize[2]-aPos[2]}
         ::SetCoords( .T. )
      ENDIF

      ::oCaption:toFront()
   ENDIF
RETURN self

METHOD S2GroupBoxWithFocus:enable()
   LOCAL lRet := ::S2StaticX:enable()
   IF ! EMPTY( ::oCaption )
      ::oCaption:enable()
   ENDIF
RETURN lRet

METHOD S2GroupBoxWithFocus:disable()
   LOCAL lRet
   ::dehilite()
   lRet := ::S2StaticX:disable()
   IF ! EMPTY( ::oCaption )
      ::oCaption:disable()
   ENDIF
RETURN lRet

METHOD S2GroupBoxWithFocus:SetCaption( xVar )
   LOCAL cRet
   IF EMPTY( ::oCaption )
      ::S2StaticX:setCaption( dbMMrg(STRTRAN(xVar,dfHot())) )
   ELSE
      cRet := ::oCaption:SetCaption( dbMMrg(STRTRAN(xVar,dfHot())) )
   ENDIF
   ::caption := xVar
   ::setCoords()  // Aggiorno le dimensioni
RETURN cRet

METHOD S2GroupBoxWithFocus:GetCaption()
RETURN ::caption // ::oCaption:caption

METHOD S2GroupBoxWithFocus:DispItm()
   ::setCaption(::caption)
RETURN ::show()

METHOD S2GroupBoxWithFocus:show()
   LOCAL lRet := ::S2StaticX:show()

   IF ! EMPTY( ::oCaption )
      ::oCaption:show()
   ENDIF
RETURN lRet

METHOD S2GroupBoxWithFocus:hide()
   LOCAL lRet := ::S2StaticX:hide()
   IF ! EMPTY( ::oCaption )
      ::oCaption:hide()
   ENDIF
RETURN lRet

METHOD S2GroupBoxWithFocus:hilite()
   IF EMPTY( ::oCaption )
      ::headerColorBG := ::nHiliteColorBG
      ::invalidateRect()
   ELSE
      ::oCaption:setColorFG( ::nHiliteColorFG )
      ::oCaption:setColorBG( ::nHiliteColorBG )
   ENDIF
RETURN self

METHOD S2GroupBoxWithFocus:dehilite()
   IF EMPTY( ::oCaption )
      ::headerColorBG := ::nDehiliteColorBG
      // simone 24/8/06 
      // miglioramento per evitare refresh brutti quando la form ancora non è visibile
      IF ::isVisible()
         ::invalidateRect()
      ENDIF
   ELSE
      ::oCaption:setColorFG( ::nDehiliteColorFG )
      ::oCaption:setColorBG( ::nDehiliteColorBG )
   ENDIF
RETURN self

METHOD S2GroupBoxWithFocus:SetCoords( lForceRepos )
   LOCAL aDim := {}
   LOCAL aSize:= {}
   LOCAL nVOffset

   IF ! EMPTY(::oCaption) .AND. ::status() == XBP_STAT_CREATE // solo se Š gi… creato

      DEFAULT lForceRepos TO .F.

      aDim := ::getTextSize( ::oCaption:caption )
      aSize:= ::oCaption:currentSize()

      aDim[1] += ::aOffset[1]
      aDim[2] += ::aOffset[2]

      IF lForceRepos .OR. aSize[1] != aDim[1] .OR. aSize[2] != aDim[2]

         // Simone 27/06/2005
         // Mantis 0000793: migliorare visualizzazione listbox/editbox su form con bitmap background 
         // in caso di form con bitmap background l'header non Š visualizzato correttamente
         IF lForceRepos .OR. ;
            ! ::FormFather():hasBitmapBG() .OR. ;  // se ha bitmap in background
            aSize[1] < aDim[1] .OR. ;              // ridimensiono solo se necessito di maggiore spazio!
            aSize[2] < aDim[2]

            // Reimposta la grandezza
            aSize := aDim

            // Reimposta la posizione mettendola nel mezzo alla linea superiore
            nVOffset := INT(aDim[2]/2)
            aDim  := ::currentPos()

            aDim[1] := S2GROUPBOX_OFFSET_LEFT
            aDim[2] := (::currentSize()[2]-nVOffset-S2GROUPBOX_OFFSET_TOP)

            
            #ifdef _XBASE15_
               ::oCaption:setPosAndSize(aDim, aSize, .F.)
            #else
               ::oCaption:setPos(aDim, .F.)
               ::oCaption:setSize(aSize, .F.)
            #endif
            ::invalidateRect()
//         ASIZE(aDim, 4)
//         aDim[3] := aDim[1]+aSize[1]+10
//         aDim[4] := aDim[2]+aSize[2]+10
//         aDim[1] -= 10
//         aDim[2] -= 10
//         ::invalidateRect(aDim)
         ENDIF

      ENDIF
   ENDIF
RETURN self

METHOD S2GroupBoxWithFocus:resize(aOld, aNew)
   ::S2StaticX:resize(aOld, aNew)
   ::SetCoords(.T.)
RETURN self

METHOD S2GroupBoxWithFocus:setSize(aNew, lUpdate)
   DEFAULT lUpdate TO .T.
   ::S2StaticX:setSize(aNew, lUpdate)
   ::SetCoords(.T.)
RETURN self

METHOD S2GroupBoxWithFocus:GetTextSize(cMsg)
   LOCAL nMaxWidth  := 0
   LOCAL nMaxHeight := 0
   LOCAL aDim
   LOCAL oPS
   LOCAL nWidth
   LOCAL nHeight
   LOCAL aStr
   LOCAL nInd

IF cMsg != NIL .AND. ! cMsg == "" .AND. ! EMPTY( ::oCaption )
   // Calcolo la dimensione della stringa
   oPS := ::oCaption:lockPS()

   IF oPS != NIL
      IF dfAnd(::oCaption:options, XBPSTATIC_TEXT_WORDBREAK) == 0

         // -----------------------
         // Testo su una sola linea
         // -----------------------

         aDim := GraQueryTextBox(oPS, cMsg)
         nMaxWidth  := MAX(aDim[3][1], aDim[4][1]) - MIN(aDim[1][1], aDim[2][1])
         nMaxHeight := MAX(aDim[3][2], aDim[4][2]) - MIN(aDim[1][2], aDim[2][2])

      ELSE

         // ----------------
         // Testo multilinea
         // ----------------

         aStr := dfStr2Arr(cMsg, CRLF)

         FOR nInd := 1 TO LEN(aStr)
            aDim := GraQueryTextBox(oPS, IIF(aStr[nInd] == "", " ", aStr[nInd]))

            nWidth  := MAX(aDim[3][1], aDim[4][1]) - MIN(aDim[1][1], aDim[2][1])
            nHeight := MAX(aDim[3][2], aDim[4][2]) - MIN(aDim[1][2], aDim[2][2])

            nMaxWidth  := MAX(nMaxWidth, nWidth)
            nMaxHeight += nHeight

         NEXT


      ENDIF
      ::oCaption:unlockPS(oPS)
   ENDIF
ENDIF

RETURN {nMaxWidth, nMaxHeight}

CLASS S2GetNumeric
   PROTECTED
      METHOD dfClcVal
   EXPORTED
      METHOD dfPutBuf, dfGetFirst
ENDCLASS

METHOD S2GetNumeric:dfPutBuf(oGet, cPict)
   LOCAL nPos
   LOCAL nOldPos := oGet:POS
   LOCAL cOldBuf := oGet:BUFFER

   DO CASE
      // Simone 27/3/08
      // mantis 0000667: Migliorare la libreria e la gestione delle GET numeriche.
      CASE M->Sa$",."
             // non faccio niente,devo solo rifare display
      CASE M->Sa=="+"
           IF AT("-",oGet:Buffer) > 0
              oGet:buffer = STRTRAN(oGet:buffer,"-"," ")
           ENDIF

      CASE M->Sa=="-"
           IF AT("-",oGet:Buffer) = 0
              IF (nPos := RAT(" ",oGet:buffer) ) > 0
                 oGet:buffer = STUFF(oGet:buffer, nPos, 1, "-")
              ENDIF
           ENDIF

      CASE A==xbeK_DEL .OR. A==xbeK_BS
           IF !(SUBSTR(oGet:Buffer,oGet:pos,1) $ " -")
              IF oGet:DECPOS > 0 .AND. oGet:DECPOS < LEN(oGet:BUFFER)
                 IF oGet:pos > oGet:DECPOS
                    IF A==xbeK_BS
                       oGet:Pos--
                       IF oGet:pos == oGet:decPos
                          oGet:Pos--
                       ENDIF
                    ENDIF
                    oGet:buffer := LEFT(oGet:buffer,oGet:pos-1) +SUBSTR(oGet:buffer,oGet:pos+1)+"0"
                 ELSE
                    oGet:buffer := " " + LEFT(oGet:buffer,oGet:pos-1)+SUBSTR(oGet:buffer,oGet:pos+1)
                 ENDIF
              ELSE
                 oGet:buffer := " " + LEFT(oGet:buffer,oGet:pos-1)+SUBSTR(oGet:buffer,oGet:pos+1)
              ENDIF
           ENDIF

      OTHERWISE
           IF oGet:DECPOS > 0 .AND. oGet:DECPOS < LEN(oGet:BUFFER)
              IF oGet:pos > oGet:DECPOS
                 oGet:buffer := LEFT( LEFT(oGet:buffer , oGet:pos-1)+ M->Sa + SUBSTR(oGet:buffer,oGet:pos), LEN(oGet:BUFFER) )
                 IF oGet:POS < LEN(oGet:buffer)
                 oGet:Pos++
                 ENDIF
              ELSE
                 IF RAT(" ",oGet:buffer) > 0
                    oGet:buffer := LEFT( SUBSTR(oGet:buffer ,2,oGet:pos-1) + M->Sa + SUBSTR(oGet:buffer,oGet:pos+1), LEN(oGet:BUFFER) )
                 ENDIF
              ENDIF
           ELSE
              IF RAT(" ",oGet:buffer) > 0
                 oGet:buffer := LEFT( SUBSTR(oGet:buffer ,2,oGet:pos-1) + M->Sa + SUBSTR(oGet:buffer,oGet:pos+1), LEN(oGet:BUFFER) )
              ENDIF
           ENDIF
   ENDCASE

   ::dfClcVAL( oGet, nOldPos, cOldBuf, cPict )

RETURN self

METHOD S2GetNumeric:dfClcVAL( oGet, nOldPos, cOldBuf, cPict )
   LOCAL cStr, nintvalue, ndecvalue, nPos, lPos := .T.
   LOCAL cDecValue := ""
   LOCAL nNum
   // cStr = STRTRAN( STRTRAN(oGet:buffer," ","") ,".","")
   // IF (nPos:=AT(",",cStr)) > 0
   //    nintvalue  = VAL(  LEFT(cStr,nPos-1))
   //    ndecvalue  = VAL(SUBSTR(cStr,nPos+1))
   // ELSE
   //    nintvalue  = VAL(cStr)
   //    ndecvalue  = 0
   // ENDIF

   IF oGet:decPos > 0 .AND. oGet:decPos < LEN(oGet:buffer)

      cStr = STRTRAN( STRTRAN(LEFT(oGet:buffer, oGet:decPos-1)," ","") ,".","")
      nintvalue  = VAL( cStr )

      cDecValue := STRTRAN(SUBSTR(oGet:buffer, oGet:decPos+1), " ", "0")
      // cStr = STRTRAN( STRTRAN(LEFT(oGet:buffer, oGet:decPos+1)," ","") ,".","")
      // ndecvalue  = VAL( cStr )
   ELSE
      cStr = STRTRAN( STRTRAN(oGet:buffer," ","") ,".","")
      nintvalue  = VAL(cStr)
      ndecvalue  = 0
      cDecValue := ""
   ENDIF

   IF AT("-",oGet:buffer)>0
      lPos := .F.
   ENDIF

   nNum := ALLTRIM(STR(nIntValue))+"."+cDecValue
   nNum := VAL(nNum)

   nNum := ABS(nNum)
   IF ! lPos
      nNum := -nNum
   ENDIF
   oGet:Buffer := TRANSFORM(nNum, cPict)

   // Simone 27/3/08
   // mantis 0000667: Migliorare la libreria e la gestione delle GET numeriche.
   // mentre si scrive "0,00" con pict @Z 999.999
   IF EMPTY(nNum) .AND. EMPTY(oGet:buffer) .OR. ;
      ALLTRIM(oGet:Buffer) $ "-" .AND. ;
      oGet:decPos > 0 .AND. oGet:decPos < LEN(oGet:buffer) .AND. ;
      oGet:pos >= oGet:decPos-1
      oGet:buffer := STRTRAN( TRANSFORM(IIF(lPos,1,-1), cPict), "1","0")
   ENDIF

   // oGet:Buffer := TRANSFORM(nIntValue+VAL(IF(lPos,"0.","-0.")+;
   //                STRTRAN(STR(nDecValue)," ","0")),cPict)

   IF "*"$oGet:Buffer .AND. !dfRecourse()
      oGet:POS    := nOldPos
      oGet:BUFFER := cOldBuf
      ::dfClcVAL( oGet, NIL, NIL, cPict )
   ELSE
      IF !lPos .AND. nNum==0
      // IF !lPos .AND. VAL(oGet:Buffer)==0
         IF oGet:decPos > 0
            oGet:Buffer := SPACE( LEN(oGet:Buffer) )
            oGet:Buffer := STUFF(oGet:Buffer,oGet:DECPOS-2,1,"-")
         ELSE
            oGet:Buffer := SPACE( LEN(oGet:Buffer) -1)+"-"
         ENDIF
      ENDIF
   ENDIF

RETURN self

METHOD S2GetNumeric:dfGetFirst( lFirstChar, nKey, oGet )
   LOCAL aFirst := {xbeK_RETURN} //xbeK_LEFT, xbeK_RIGHT, xbeK_UP, xbeK_DOWN,
RETURN lFirstChar               .AND.;
       ASCAN(aFirst, nKey) == 0 .AND.;
       nKey >= 32 .AND. nKey <= 255 .AND. ;
       "K"$UPPER(oGet:PICTURE)