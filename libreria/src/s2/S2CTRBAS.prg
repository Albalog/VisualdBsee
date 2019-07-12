#include "dfCtrl.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "Font.ch"
#include "dfMenu.ch"
#include "dfXBase.ch"
#include "Common.ch"
#include "AppEvent.ch"
#include "dfxres.ch"
#include "dfLook.ch"

// disattiva ottimizzazioni pag 0
//#define _PAGE_ZERO_STD_

#ifdef _IGNORE_THIS_PROPERTIES_
CLASS S2CtrlProperties

HIDDEN:
   METHOD CvtParam()

   CLASS VAR PropertyOk SHARED

PROTECTED:
   VAR cKey

   METHOD HasProperties()
   //DEFERRED METHOD LoadProperties()


EXPORTED:
   // Torna il font di default
   INLINE METHOD getDefaultFont(cFont); RETURN S2ApplicationFont(cFont)

   VAR cId
   VAR oForm
   CLASS METHOD InitClass()
   METHOD Init(), GetProperty()
ENDCLASS

CLASS METHOD S2CtrlProperties:InitClass()
BEGIN SEQUENCE
   IF ::PropertyOk != NIL; BREAK; ENDIF

   ::PropertyOk := .F.

   IF ! FILE("DBPROP"+dfDbfExt()); BREAK; ENDIF
   IF ! FILE("DBPROP1"+dfIndExt()); BREAK; ENDIF
   IF ! dfUseFile("DBPROP", NIL, .F.); BREAK; ENDIF

   DBPROP->(ORDLISTADD("DBPROP1"))
   ::PropertyOk := .T.
END SEQUENCE

RETURN self

METHOD S2CtrlProperties:Init(oForm, cId)
   ::oForm := oForm
   ::cId   := cId

   IF ::PropertyOk
      ::cKey  := UPPER( PAD(::oForm:FormName, LEN(DBPROP->FORMNAME)) + ;
                        PAD(::cID           , LEN(DBPROP->CTRLID  ))   )
   ELSE
      ::cKey  := ""
   ENDIF
RETURN self

METHOD S2CtrlProperties:HasProperties(cClass)
RETURN ::PropertyOk .AND. ;
       DBPROP->(DBSEEK( ::cKey )) .AND. ;
       ALLTRIM(DBPROP->CTRLCLASS) == cClass

METHOD S2CtrlProperties:GetProperty(cProp)
   LOCAL xRet := NIL
   IF ::PropertyOk .AND. DBPROP->(DBSEEK( ::cKey + UPPER(PAD(cProp, LEN(DBPROP->PROPERTY))) ))
      xRet := ::CvtParam(DBPROP->VALUE, DBPROP->TYPE, DBPROP->LEN)
   ENDIF
RETURN xRet

METHOD S2CtrlProperties:CvtParam(cValue, cType, nLen)
   LOCAL xVal
   DO CASE
      CASE cType == "N"
         xVal := VAL(ALLTRIM(cValue))
      CASE cType == "L"
         xVal := ! ALLTRIM(cValue) == "F"
      CASE cType == "C"
         xVal := PADR(cValue, nLen)
      CASE cType == "D"
         xVal := CTOD(ALLTRIM(cValue))
   ENDCASE
RETURN xVal
#endif

// Control con tasti aggiuntivi
// ----------------------------
CLASS S2PfkCtrl
   EXPORTED:
      VAR aMethod

      INLINE METHOD Init(aMtd)
         ::aMethod := aMtd
      RETURN self

      INLINE METHOD handleAction( cAct, cState )
         DEFAULT cState TO ::FormFather():cState
      RETURN dfMtdEval( ::aMethod, cState, ::FormFather(), cAct )

      DEFERRED METHOD FormFather()
ENDCLASS


// I control che possono avere l'help associato
// devono ereditare da questa classe
CLASS S2CtrlHelp
   EXPORTED:
      INLINE METHOD SetHelpID(cId)
         M->SUBID:=cId
      RETURN self
ENDCLASS

// Control che permette l'edit dei dati
// ------------------------------------
CLASS S2EditCtrl FROM S2CtrlHelp
   EXPORTED:
      VAR varname

      INLINE METHOD Init(cVarName)
         ::varname := cVarName
      RETURN self

      INLINE METHOD SetFocus(cID)
         M->SUBID := cId
      RETURN self

ENDCLASS

// Gruppo di ricalcolo
// -------------------
CLASS S2CompGrp
   PROTECTED:
      METHOD CompExe
   EXPORTED:
      VAR cCompGrp, bCompExp, cCompRef, aCompRef, lCalcLoop
      METHOD Init, CompExpExe, HasCompGrp, AddCtrl
ENDCLASS

METHOD S2CompGrp:Init(cGrp, bExp)
   DEFAULT cGrp TO ""
   DEFAULT bExp TO {|| .T. }

   ::cCompGrp := cGrp
   ::bCompExp := bExp
   ::cCompRef := ""
   ::aCompRef := NIL
   ::lCalcLoop:= .F.
RETURN self

METHOD S2CompGrp:CompExpExe()
   LOCAL aID, nInd, oObj

   IF ! ::lCalcLoop
      // Evito il loop
      ::lCalcLoop := .T.

      IF ::aCompRef == NIL

         ::aCompRef := {}

         aID := dfStr2Arr(::cCompRef, "-")

         FOR nInd := 1 TO LEN(aID)
            IF ! EMPTY(aID[nInd]) .AND. ! aID[nInd] $ "--"
               oObj := ::formFather():SearchObj( aID[nInd] )[1]
               IF oObj != NIL .AND. ASCAN( ::aCompRef, {|x|x==oObj} ) == 0
                  AADD(::aCompRef, oObj)
               ENDIF
            ENDIF
         NEXT

      ENDIF

      FOR nInd := 1 TO LEN(::aCompRef)
         ::CompExe(::aCompRef[nInd])
      NEXT
      // AEVAL(::aCompRef, {|x| ::CompExe(x)})

      ::lCalcLoop := .F.
   ENDIF

RETURN self

METHOD S2CompGrp:CompExe(x)
   EVAL(x:bCompExp)
   x:DispItm()
   // ha un gruppo di ricalcolo
   IF x:isDerivedFrom("S2CompGrp") .AND. ;
      x:hasCompGrp()
      x:CompExpExe()
   ENDIF
RETURN self

METHOD S2CompGrp:HasCompGrp()
RETURN ! EMPTY( ::cCompRef )

METHOD S2CompGrp:AddCtrl( cId )

   ::cCompRef += cId
   ::cCompRef := "-" + dfChkGrp(::cCompRef) + "-"

RETURN self


// Definizioni delle classi di oggetti che simulano quelli DOS
// -----------------------------------------------------------
//    #define CTRL_SAY          1     // SAY           S2Static
//    #define CTRL_BOX          2     // BOX           S2Static
//    #define CTRL_FUNCTION     3     // FUNCTION      S2Func
//    #define CTRL_GET          4     // GET           S2Get
//    #define CTRL_CMB          5     // COMBOBOX
//    #define CTRL_TEXT         6     // TEXTBOX
//    #define CTRL_CHECK        7     // CHECKBOX
//    #define CTRL_RADIO        8     // RADIOBUTTON
//    #define CTRL_BUTTON       9     // PUSHBUTTON
//    #define CTRL_LISTBOX     10     // LISTBOX
//    #define CTRL_SPIN        11     // SPINBUTTON
//
//    Classe per MENU                                  S2Menu

// Qui deve essere definita una classe per ogni tipologia di control di
// dbSee. La classe deve ereditare dalla classe S2Control e dalla
// Xbase Part che simula l'oggetto di dbSee
//
// Nella classe S2Control sono definite le caratteristiche comuni a tutti
// i controls ed il riferimento al control array:
//    #define FORM_CTRL_TYP       1   // Control TYPE
//    #define FORM_CTRL_ID        2   //         ID
//    #define FORM_CTRL_RID       3   //         REFRESH ID        ""
//    #define FORM_CTRL_PAGE      4   //         PAGE               1
//    #define FORM_CTRL_STABLE    5   //         STABLE            .F.
//    #define FORM_CTRL_DISPLAYIF 6   //         DISPLAY IF      {||.T.}

#ifdef _IGNORE_THIS_PROPERTIES_
CLASS S2Control FROM S2CtrlProperties
#else
CLASS S2Control //FROM S2CtrlProperties
#endif

   PROTECTED:
      METHOD CtrlArrInit
      VAR bCansetFocus

   EXPORTED:
      // Torna il font di default
      INLINE METHOD getDefaultFont(cFont); RETURN S2ApplicationFont(cFont)

#ifdef _IGNORE_THIS_PROPERTIES_
#else
      VAR cId
      VAR oForm
#endif

      INLINE METHOD CtrlArrStable(aCtrl); RETURN aCtrl[FORM_CTRL_STABLE]
      INLINE METHOD isShortCut(); RETURN .F.
      INLINE METHOD GetBCansetFocus();  RETURN ::bCansetFocus

      INLINE METHOD SetBCansetFocus(bBlock)
         LOCAL bOld := ::bCansetFocus
         IF VALTYPE(bBlock) == "B"
            ::bCansetFocus := bBlock
         ENDIF
      RETURN bOld

      VAR aCtrl, nType, nPage, cRefID, bDispIf, aPage0
      METHOD Init, ChgHotKey, IsId, isIdGrp, isRefrGrp, isCtrlGrp
      METHOD CanShow
      INLINE METHOD FormFather(); RETURN ::oForm
      INLINE METHOD IsOnCurrentForm(); RETURN S2FormCurr() == ::oForm 

      METHOD UpdControl
      METHOD UpdObjFont
      METHOD CanSetPage // gerr 3653 simone 24/3/03

      METHOD ShowItem
        

 //  INLINE METHOD HandleAction(); RETURN .F.

ENDCLASS

METHOD S2Control:ShowItem(); RETURN .F.

METHOD S2Control:CtrlArrInit(aCtrl, oFormFather)

   aCtrl[FORM_CTRL_STABLE] := .T.

   DEFAULT aCtrl[FORM_CTRL_PAGE]      TO 1

   DEFAULT aCtrl[FORM_CTRL_DISPLAYIF] TO {||.T.}
   aCtrl[FORM_CTRL_ID] := UPPER(ALLTRIM(aCtrl[FORM_CTRL_ID]))

   // Sistemo i refresh ID
   aCtrl[FORM_CTRL_RID] := "-" +dfChkGrp(aCtrl[FORM_CTRL_RID]) +"-"
   IF aCtrl[FORM_CTRL_RID]=="--"
      aCtrl[FORM_CTRL_RID] := "-"
   ENDIF

RETURN

METHOD S2Control:updControl(aCtrl)

   DEFAULT aCtrl TO ::aCtrl

   ::aCtrl      := aCtrl

   ::nType      := ::aCtrl[FORM_CTRL_TYP]
   ::cRefId     := ::aCtrl[FORM_CTRL_RID]
   ::bDispIf    := ::aCtrl[FORM_CTRL_DISPLAYIF]
RETURN self

// Aggiorna il font di un oggetto, chiamato nella UpdControl
METHOD S2Control:UpdObjFont(cFont, oObj)
   LOCAL lChg := .F.
   LOCAL cOld

   DEFAULT oObj TO self

   cOld := oObj:setFontCompoundName()

   IF ! EMPTY(cFont) .AND. ;
      (EMPTY(cOld) .OR. ! UPPER(cFont) == UPPER(cOld))

      oObj:setFontCompoundName(cFont)
      lChg := .T.
   ENDIF
RETURN lChg

METHOD S2Control:Init(aCtrl, nPage, oFormFather)

   // ESEGUO l'inizializzazione di questo oggetto, altrimenti
   // esegue il metodo ridefinito negli oggetti ereditati!
   ::S2Control:CtrlArrInit(aCtrl, oFormFather)
#ifdef _IGNORE_THIS_PROPERTIES_
   ::S2CtrlProperties:init(oFormFather, aCtrl[FORM_CTRL_ID])
#else
   ::cId := aCtrl[FORM_CTRL_ID]
   ::oForm := oFormFather
#endif

   ::aCtrl      := aCtrl
   ::nType      := aCtrl[FORM_CTRL_TYP]

   // ::oForm      := oFormFather
   // ::cId        := aCtrl[FORM_CTRL_ID]

   ::cRefId      := aCtrl[FORM_CTRL_RID]
   ::nPage       := nPage
   ::bDispIf     := aCtrl[FORM_CTRL_DISPLAYIF]
   ::aPage0      := NIL
   ::bCansetFocus:= NIL
RETURN self

// Con questo metodo posso modificare a piacimento cosa controllare
// (se aCtrl[FORM_CTRL_DISPLAYIF] o ::bDispIf)
METHOD S2Control:CanShow()
RETURN EVAL( ::bDispIf )

METHOD S2Control:ChgHotKey(cPrompt)
RETURN S2HotCharCvt(cPrompt)

METHOD S2Control:IsId(cId)
RETURN UPPER(ALLTRIM(::cId)) == UPPER(ALLTRIM(cId))

METHOD S2Control:IsIdGrp(cGrp)
   LOCAL lRet := .T.
   IF ! cGrp == "#"
      lRet := UPPER(::cId) $ cGrp
   ENDIF
RETURN lRet

METHOD S2Control:IsRefrGrp(cGrp)
   LOCAL lRet := .T.
   IF ! cGrp == "#"
      lRet := UPPER(cGrp)+"-" $ UPPER(::cRefId)
   ENDIF
RETURN lRet

METHOD S2Control:IsCtrlGrp(nGrp)
   LOCAL lRet := .T.
   IF ! nGrp == 0
      lRet := nGrp == ::nType
   ENDIF
RETURN lRet

METHOD S2Control:CanSetPage()
   // per i control su multipagina attivo solo quelli sulla 1^ pagina
   //LOCAL lAllPage := dfSet("XbaseAutoChangePage") == "YES"
   LOCAL lAllPage := ! EMPTY(::oForm) .AND. ::oForm:lAllPage
   IF lAllPage
   #ifdef _PAGE_ZERO_STD_
      lAllPage := (EMPTY(::aPage0) .OR. ::nPage==1)
   #endif
   ELSE
      lAllPage := .T.
   ENDIF
RETURN lAllPage