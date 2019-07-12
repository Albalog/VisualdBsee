#include "Font.ch"
#include "Gra.ch"
#include "Common.ch"
#include "dfReport.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "dfNet.ch"
#include "dfWinRep.ch"
#include "dfMsg1.ch"
#include "dfSet.ch"

STATIC aFont := {{}, {}}
STATIC aDefault  :=   { { PRN_NORMAL                         , ; // Attributo
                          "normal"                           , ; // Attributo in APPS.INI
                          "11.Courier New"                 } , ; // Font di default
                        { PRN_BOLD                           , ;
                          "bold"                             , ;
                          "11.Courier New Bold"            } , ;
                        { PRN_ITALIC                         , ;
                          "italic"                           , ;
                          "11.Courier New Italic"          } , ;
                        { PRN_BOLD+PRN_ITALIC                , ;
                          "boldItalic"                       , ;
                          "11.Courier New Bold Italic"     } , ;
                        { PRN_CONDENSED                      , ;
                          "condensed"                        , ;
                          "7.Courier New"                  } , ;
                        { PRN_CONDENSED+PRN_BOLD             , ;
                          "condensedBold"                    , ;
                          "7.Courier New Bold"             } , ;
                        { PRN_CONDENSED+PRN_ITALIC           , ;
                          "condensedItalic"                  , ;
                          "7.Courier New Italic"           } , ;
                        { PRN_CONDENSED+PRN_BOLD+PRN_ITALIC  , ;
                          "condensedBoldItalic"              , ;
                          "7.Courier New Bold Italic"      } }


// Eventuale aggiunta nome report in modo da poter impostare
// dei font diversi per ogni report e per ogni stampante
STATIC FUNCTION SetReportDeviceName(cDevice)
   LOCAL cEnv := ""
   LOCAL nMode
   LOCAL cEnvID := GetEnvId()

   IF cEnvID != NIL

      DEFAULT cDevice TO ""

      cEnv := UPPER(ALLTRIM(cEnvId))
      nMode := dfSet(AI_XBASEPRINTFONT)

      DO CASE
         CASE nMode == AI_PRINTFONT_REPORT
            // Memorizza i FONT per ogni REPORT
            // indipendentemente dalla stampante
            cEnv    := '[' + cEnv + ']'
            cDevice := cEnv

         CASE nMode == AI_PRINTFONT_PRN_REP    
            // Memorizza i FONT per ogni REPORT E PER OGNI STAMPANTE
            cEnv    := '[' + cEnv + ']'

            // Controllo che non sia gi… stato aggiunto
            IF ! LEFT(cDevice, LEN(cEnv)) == cEnv
               cDevice := cEnv+cDevice
            ENDIF

      ENDCASE
   ENDIF
RETURN cDevice

// Non posso leggere la variabile EnvID direttamente
// perchŠ ogni Thread ha il suo ambiente di var. private!
STATIC FUNCTION GetEnvId()
   LOCAL cRet := NIL
   LOCAL nPos := 0
   LOCAL oObj := ThreadObject()  // thread corrente

   IF EMPTY(oObj) .OR. VALTYPE(oObj:cargo) != "A"
      IF isMemVar("EnvId")
         cRet := M->EnvID
      ENDIF
   ELSE
      nPos:= ASCAN(oObj:cargo, {|x|x[1]=="ENVID"})
      IF nPos > 0
         cRet := oObj:cargo[nPos][2]
      ENDIF
   ENDIF

RETURN cRet
    
// Form di richiesta font.. da fare.

FUNCTION dfWinPrnFontDlg(oPrinter)
   LOCAL aFonts := ARRAY(DFWINREP_FD_LEN)
   LOCAL oFont
   LOCAL oPS
   LOCAL oDlg

   DEFAULT oPrinter TO dfWinPrinterObject()
   IF ! EMPTY(oPrinter)                      .AND. ;
      VALTYPE(oPrinter) == "O"               .AND. ;
      oPrinter:isDerivedFrom("XbpPrinter")   .AND. ;
      oPrinter:status() == XBP_STAT_CREATE

      oPS  := XbpPresSpace():new()
   #ifdef _XBASE15_
      // Simone 11/02/02
      // tolto perche la qualita diminuisce!
      // oPS:mode := XBPPS_MODE_HIGH_PRECISION
   #endif

      oPS:create(oPrinter, oPrinter:paperSize(), GRA_PU_LOMETRIC)

      oFont := dfWinPrnFont(NIL, oPS, PRN_NORMAL, .F. )
      aFonts[DFWINREP_FD_NORMAL] := dfFont2CompoundName(oFont)

      oFont := dfWinPrnFont(NIL, oPS, PRN_BOLD, .F. )
      aFonts[DFWINREP_FD_BOLD  ] := dfFont2CompoundName(oFont)

      oFont := dfWinPrnFont(NIL, oPS, PRN_CONDENSED, .F. )
      aFonts[DFWINREP_FD_CONDENSED] := dfFont2CompoundName(oFont)

      oFont := dfWinPrnFont(NIL, oPS, PRN_BOLD+PRN_CONDENSED, .F. )
      aFonts[DFWINREP_FD_BOLDCOND] := dfFont2CompoundName(oFont)

      oDlg := dfWinPrnFontDialog(dfStdMsg1(MSG1_DFWINPRN01)+oPrinter:devName, ;
                                 oPrinter, oPS, aFonts)

      IF oDlg:nAction == 1
         dfWinPrnFontClear(oPrinter:devName)
         dfWinPrnFontSet(oPrinter:devName, oDlg:aFonts)
      ENDIF
   ENDIF

RETURN .T.

FUNCTION dfFont2CompoundName(oFont)
RETURN IIF(EMPTY(oFont), "", ALLTRIM(STR(oFont:nominalPointSize))+"."+oFont:compoundName)

FUNCTION dfWinPrnFontClear( cDevice )
   LOCAL nType := 0, nPos

   // 04/03/2002 Simone: Aggiunta nome report
   SetReportDeviceName(@cDevice)

   IF ! EMPTY(cDevice)

      FOR nType := 1 TO LEN(aFont)
         nPos := ASCAN(aFont[nType], {|x| x[1] == cDevice})
         IF nPos != 0
            // Attenzione: il destroy non viene fatto.... Š giusto=
            DFAERASE(aFont[nType], nPos)
         ENDIF
      NEXT
   ENDIF
RETURN NIL

FUNCTION dfWinPrnFontSet( cDevice, aFonts )
   LOCAL lOk := .F.
   LOCAL cPath, cFile, cAlias, cType, nPos, nType, cFont
   LOCAL aType := {PRN_NORMAL              , ; // corrisponde a DFWINREP_FD_NORMAL
                   PRN_BOLD                , ; // corrisponde a DFWINREP_FD_BOLD
                   PRN_CONDENSED           , ; // corrisponde a DFWINREP_FD_CONDENSED
                   PRN_BOLD+PRN_CONDENSED    } // corrisponde a DFWINREP_FD_BOLDCOND

   // 04/03/2002 Simone: Aggiunta nome report
   SetReportDeviceName(@cDevice)

   IF ! EMPTY(cDevice) .AND. ! EMPTY(aFonts)

      cAlias := ALIAS()

      cFile := dbCfgPath("dbddpath") +"DBFONT"

      IF !dfRddFile( cFile +dfDbfExt( RDDSETDEFAULT() ) )
         DBCREATE( cFile   , {;
                             {"DEVICE"  , "C", 200, 0 },;
                             {"TYPE"    , "C", 50, 0 },;
                             {"FONT"    , "C", 100, 0 } ;
                             })
      ENDIF
      IF DFISSELECT( "DBFONT" )            .OR. ;
         dfUseFile( cFile, "DBFONT", .F. )

         IF DBFONT->(dfNet( NET_FILELOCK ))

            SELECT DBFONT

            FOR nType := 1 TO LEN(aFonts)

               nPos  := ASCAN(aDefault, {|x| x[1]==aType[nType] })
               cType := aDefault[nPos][2]
               cFont := aFonts[nType]

               LOCATE FOR ALLTRIM(UPPER(DBFONT->DEVICE))==ALLTRIM(UPPER(cDevice)) .AND. ;
                          ALLTRIM(UPPER(DBFONT->TYPE  ))==ALLTRIM(UPPER(cType))

               IF ! DBFONT->(FOUND())
                  DBFONT->(DBAPPEND())
                  DBFONT->DEVICE  := cDevice
                  DBFONT->TYPE    := cType
               ENDIF

               DBFONT->FONT    := cFont

            NEXT

            DBFONT->(DBCOMMIT())
            DBFONT->(dfNet( NET_FILEUNLOCK ))

         ENDIF
         DBFONT->(DBCLOSEAREA())

      ENDIF

      IF !EMPTY( cAlias )
         SELECT (cAlias)
      ENDIF

   ENDIF
RETURN lOk


// Torna un Font pronto per l'uso per un certo device
// (se device=NIL, Š la stampante di default)
// nAttr pu• essere una combinazione di PRN_BOLD e PRN_ITALIC
// se specificato torna un font congruo con gli attributi specificati

FUNCTION dfWinPrnFont( cDevice, oPS, nAttr, lGeneric)
   LOCAL  aVal, aFnt, oFont, nPos := 0, nType, nSearchAttr
   LOCAL cCompoundName
   LOCAL cDev
   LOCAL oDC

   IF EMPTY(cDevice)
      IF EMPTY(oPS)
         cDevice := dfWinPrinterDefault()
         oDC := S2Printer():new():create(cDevice)
         oPS := XbpPresSpace():new()
         oPS:create(oDC, oDC:paperSize(), GRA_PU_LOMETRIC)
      ELSE

         // Controllo per errore su NT!!
         IF EMPTY(oPS:device()) .OR. ! isMemberVar(oPS:device(), "devName")
            oFont := _defaultFont( cDevice, oPS, nAttr, lGeneric )
            cDevice := ""
         ELSE
            cDevice := oPS:device():devName
         ENDIF
      ENDIF
   ENDIF

   // DEFAULT cDevice TO dfWinPrinterDefault()

   DEFAULT nAttr   TO PRN_NORMAL
   DEFAULT lGeneric TO .T.
   nType := IIF(lGeneric, 1, 2)

   // 04/03/2002 Simone: Aggiunta nome report
   cDev := SetReportDeviceName(cDevice)

   IF ! EMPTY(cDev) //! EMPTY(cDevice)

      IF cDev != NIL  //cDevice != NIL
         nPos := ASCAN(aFont[nType], {|x| x[1] == cDev})
      ENDIF

      IF nPos == 0
         IF ! EMPTY(cDevice)
            aVal  := InitPrnFont(cDevice, oPS, lGeneric)
            aFnt := aVal[2]

            IF EMPTY(aFnt) .AND. ! lGeneric
               // In caso non esista un font e stia cercando un font
               // NON generico (cioŠ un font della stampante), cerco
               // un font GENERICO e lo assegno all'array dei font NON generici
               // -------------------------------------------------------------
               aVal  := InitPrnFont(cDevice, oPS, .T. )
               aFnt := aVal[2]
            ENDIF

            IF ! EMPTY(aFnt)
               // il font che viene aggiunto Š gi… creato e pronto per l'uso
               // cioŠ senza il destroy()
               AADD(aFont[nType], aVal)
            ENDIF
         ENDIF
      ELSE
         aFnt := aFont[nType][nPos][2]
      ENDIF


      // Cerco il font con gli attributi specificati, tranne il sottolineato
      nSearchAttr := dfAnd(nAttr, 0xFFFF - PRN_UNDERLINE)
      IF ! EMPTY(aFnt) .AND. ;
         (nPos := ASCAN(aFnt, {|x| x[2]==nSearchAttr })) > 0

         oFont := aFnt[nPos][1]

      ENDIF
   ENDIF

   // #ifdef _XBASE15_
   // IF ! EMPTY(oFont)
   //    // Impostare il font UNDERSCORE da problemi in anteprima di stampa
   //    // ---------------------------------------------------------------
   //    IF dfAnd(nAttr, PRN_UNDERLINE) > 0
   //       IF ! oFont:underScore
   //          oFont:underscore := .T.
   //          cCompoundName := ALLTRIM(STR(oFont:nominalPointSize))+"."+oFont:compoundName
   //          oFont:configure(cCompoundName)
   //       ENDIF
   //    ELSE
   //       IF oFont:underScore
   //          oFont:underscore := .F.
   //          cCompoundName := ALLTRIM(STR(oFont:nominalPointSize))+"."+oFont:compoundName
   //          oFont:configure(cCompoundName)
   //       ENDIF
   //    ENDIF
   // ENDIF
   // #endif

      // oFont:bold    := dfAnd(nAttr, PRN_BOLD) > 0
      // oFont:italic  := dfAnd(nAttr, PRN_ITALIC) > 0
      // oFont:underscore := dfAnd(nAttr, PRN_UNDERLINE) > 0
      //oFont:width   := IIF(dfAnd(nAttr, PRN_CONDENSED) > 0, 5, 10)

RETURN oFont


STATIC FUNCTION _defaultFont(cDevice, oPS, nAttr, lGeneric )
   STATIC aFnt := NIL
   LOCAL nSearchAttr
   LOCAL oFont
   LOCAL nPos
   LOCAL cFont

   DEFAULT nAttr   TO PRN_NORMAL
   lGeneric := .T.

   IF aFnt == NIL
      aFnt := {}
      AEVAL(aDefault, {|a| cFont := a[3], ;
                           oFont := XbpFont():new( oPS ), ;
                           oFont:create(cFont),;
                           AADD(aFnt, {oFont, a[1], cFont}) })

   ENDIF

   nSearchAttr := dfAnd(nAttr, 0xFFFF - PRN_UNDERLINE)
   IF ! EMPTY(aFnt) .AND. ;
      (nPos := ASCAN(aFnt, {|x| x[2]==nSearchAttr })) > 0

      oFont := aFnt[nPos][1]

   ENDIF
RETURN oFont


// UNDERLINE non Š inizializzato qui perchŠ Š un attributo del font
// ----------------------------------------------------------------
// Prende i font da apps.ini o da default.
// Esempio di apps.ini:
//   Epson Fx-1170.normal=12.draft 12cpi
//   Epson Fx-1170.bold=12.roman 12cpi

STATIC FUNCTION InitPrnFont( cDevice, oPSpace, lGeneric )
   LOCAL oDC, oPS, oFont, aFontList, imax, i, aRet := {}
   LOCAL nInd
   LOCAL nType
   LOCAL cFont

   IF oPSpace == NIL

      oDC := S2Printer():new():create(cDevice)
      oPS := XbpPresSpace():new()
   #ifdef _XBASE15_
      // Simone 11/02/02
      // tolto perche la qualita diminuisce!
      // oPS:mode := XBPPS_MODE_HIGH_PRECISION
   #endif
      oPS:create(oDC, oDC:paperSize(), GRA_PU_LOMETRIC)

   ELSE

      oPS := oPSpace

   ENDIF

   IF ! EMPTY(oPS:device()) .AND. oPS:device():status() == XBP_STAT_CREATE
      cDevice:=oPS:device():devName

      // 04/03/2002 Simone: Aggiunta nome report
      SetReportDeviceName(@cDevice)

      // GERR 3341
      IF lGeneric .AND. dfSet("XbasePreviewUsePrinterFont") == "YES"
         // Per il preview prova ad usare ugualmente i font della stampante 
         // e li usa solo se sono generici (truetype)
         FOR nInd := 1 TO LEN(aDefault)
             cFont := FindFont(cDevice, aDefault[nInd][2])
             IF Empty(cFont) // == NIL  
                cFont := aDefault[nInd][3]
             ENDIF
             oFont := XbpFont():new( oPS )
             oFont:create(cFont)
             IF ! oFont:generic  // il font non Š truetype uso un font di default
                oFont:destroy()

                cFont := aDefault[nInd][3]
                oFont := XbpFont():new( oPS )
                oFont:create(cFont)
             ENDIF
             AADD(aRet, {oFont, aDefault[nInd][1], cFont})
         NEXT

      ELSE
//////////////////////////////////////////////////////////////////////////////////////////
//  Cambiato con una Static Function per capire meglio il runtime .
//         AEVAL(aDefault, {|a| cFont := IIF(lGeneric, NIL, FindFont(cDevice, a[2])),;
//                              cFont := IIF(cFont==NIL, a[3], cFont), ;
//                              oFont := XbpFont():new( oPS ), ;
//                              oFont:create(cFont),;
//                              AADD(aRet, {oFont, a[1], cFont}) })

          aRet := _ArrDefaultFont(aDefault, oPS, lGeneric,cDevice )
//////////////////////////////////////////////////////////////////////////////////////////

      ENDIF
      // ChkFont(cDevice, aRet)
   ENDIF

   IF oPSpace == NIL
      oPS:destroy()
      oDC:destroy()
   ENDIF

   // 04/03/2002 Simone: Aggiunta nome report
   SetReportDeviceName(@cDevice)

RETURN {cDevice, aRet}

STATIC FUNCTION  _ArrDefaultFont(aDefault, oPS, lGeneric,cDevice )
  LOCAL nN    := 1
  LOCAL cFont := ""
  LOCAL oFont := NIL 
  LOCAL aRet  := {}
  FOR nN := 1 TO LEN(aDefault)
      cFont := IIF(lGeneric, NIL, FindFont(cDevice, aDefault[nN][2]))
      cFont := IIF(EMPTY(cFont), aDefault[nN][3], cFont)
      IF EMPTY(oPS)
         oPS := XbpPresSpace():new()
      ENDIF 
      oFont := XbpFont():new( oPS )
      oFont:create(cFont)
      AADD(aRet, {oFont, aDefault[nN][1], cFont}) 
  NExT

RETURN aRet

STATIC FUNCTION FindFont(cDevice, cType)
   LOCAL nSel
   LOCAL cFont := ""
   LOCAL cFile := dbCfgPath("dbddpath") +"DBFONT"

   ////////////////////////////////////
   //Mantis 1985
   IF EMPTY(cDevice)
      RETURN ""
   ENDIF 
   DEFAULT cType TO ""
   ////////////////////////////////////

   nSel := SELECT()

   IF DFISSELECT( "DBFONT" )            .OR. ;
      (dfRddFile( cFile +dfDbfExt( RDDSETDEFAULT() ) ) .AND. ;
       dfUseFile( cFile, "DBFONT", .F. ))

      cDevice := UPPER(ALLTRIM(cDevice))
      cType   := UPPER(ALLTRIM(cType))

      SELECT DBFONT
      LOCATE FOR ALLTRIM(UPPER(DBFONT->DEVICE))==cDevice .AND. ;
                 ALLTRIM(UPPER(DBFONT->TYPE  ))==cType

      IF DBFONT->(FOUND())
         cFont := ALLTRIM(DBFONT->FONT)
      ENDIF

      DBFONT->(DBCLOSEAREA())

   ENDIF
   DBSELECTAREA(nSel)
RETURN cFont

