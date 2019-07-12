#include "Common.ch"
#include "dfPdf.ch"
#include "dfMsg1.ch"
#include "xbp.ch"


// Classe per gestire i font e il colore nella stampa Pdf

CLASS dfPdfFont
   PROTECTED
      VAR status

   EXPORTED
      VAR oPdf
      VAR FamilyName
      VAR Height //in 1/72 di pollice
      VAR CompoundName
      VAR underScore
      VAR Reverse
      VAR Type
      VAR Width
      VAR Italic
      VAR Bold
      VAR Color
      VAR nLPI


      METHOD Init
      METHOD Destroy
      METHOD Create
      METHOD List
      METHOD Configure
      METHOD SetPdfFont
      METHOD Str2Color


      INLINE METHOD status()       ; RETURN ::status
      INLINE METHOD GetFontName()  ; RETURN ::FamilyName
      INLINE METHOD GetHeight()    ; RETURN ::Height
      INLINE METHOD GetFontType()  ; RETURN ::Type
      INLINE METHOD GetunderScore(); RETURN ::underScore
      INLINE METHOD GetReverse()   ; RETURN ::Reverse
      INLINE METHOD GetWidth()     ; RETURN ::Width
ENDCLASS

METHOD dfPdfFont:Destroy()
   ::status       := XBP_STAT_INIT
RETURN Self

METHOD dfPdfFont:Init(oPdf)
   //IF Empty(oPdf)
   //   dbmsgerr(dfStdMsg1(MSG1_DFPDF03))
   //   RETURN Self
   //ENDIF

   //DEFAULT oPDF TO dfPdf():new()

   ::oPdf         := oPdf
   ::FamilyName   := "Courier"
   ::Height       := 11
   ::CompoundName := "11.Courier"
   ::underScore   := .F.
   ::Reverse      := .F.
   ::Type         := PDF_NORMAL
   ::Bold         := .F.
   ::Italic       := .F.
   ::nLPI         := 6

   //::oPdf:setFont(::FamilyName, ::Type, ::Height )
   ::Width        := 0 //::oPdf:Length("W")
   ::Color        := PDF_BLACK

   ::status       := XBP_STAT_INIT

RETURN Self

METHOD dfPdfFont:Create(cCompoundName)
   Local cNum,cfontComp ,nNum,nN,cTip,cFont
   LOCAL lBold   := .F.
   LOCAL lItalic := .F.

   ::status       := XBP_STAT_FAILURE

   IF EMPTY(::oPdf)
      RETURN self
   ENDIF

   DEFAULT cCompoundName TO "11.Courier"
   cCompoundName := ALLTRIM(cCompoundName)

   IF AT(".",cCompoundName)>0
      cNum      := SubStr(cCompoundName,1,AT(".",cCompoundName)-1)
      cFontComp := SubStr(cCompoundName,AT(".",cCompoundName)+1,LEN(cCompoundName))
      IF AT(" ",cFontComp)>0 //Siamo in presenza di un font composto : Courier Bold;
         cFont     := SubStr(cFontComp,1,AT(" ",cFontComp)-1)
         cTip      := SubStr(cFontComp,AT(" ",cFontComp)+1,Len(cFontComp))
         IF "BOLD" $ UPPER(cTip) .OR.  "GRAS" $ UPPER(cTip)
            lBold := .T.
         ENDIF
         IF "ITAL" $ UPPER(cTip) .OR.  "CORS" $ UPPER(cTip)
            lItalic := .T.
         ENDIF
      ELSE
         cfont := cFontComp
      ENDIF
   ELSE
     cfont := cCompoundName
   ENDIF
   //per sicurezza
   IF AT(";",cFont)>0
      cFont := LEFT(cFont,AT(";",cFont) -1)
   ENDIF


   IF ! dfIsDigit(cNum)
      RETURN self
   ENDIF

   //FOR nN := 1 TO Len(cNum)
   //   IF !cNum[nN] $ "0123456789"
   //      dbMsgErr(dfStdMsg1(MSG1_DFPDF04))
   //      RETURN Self
   //   ENDIF
   //NEXT

   ::FamilyName   := cFont
   ::Height       := VAL(cNum,Len(cNum),0)
   ::CompoundName := cCompoundName
   ::underScore   := .F.
   ::Reverse      := .F.
   ::Bold         := lBold
   ::Italic       := lItalic
   ::nLPI         :=  6
   IF lBold .AND. lItalic
      ::Type        := PDF_BOLDITALIC
   ELSEIF !lBold .AND. lItalic
      ::Type        := PDF_ITALIC
   ELSEIF lBold .AND. !lItalic
      ::Type        := PDF_BOLD
   ELSE
      ::Type        := PDF_NORMAL
   ENDIF
   ::Color := PDF_BLACK

   ::oPdf:setFont(::FamilyName, ::Type, ::Height )
   ::Width := ::oPdf:Length("W")

   ::status       := XBP_STAT_CREATE

RETURN Self

METHOD dfPdfFont:List()
   Local aList := {}
   aList := ACLONE( ::oPdf:aReport[ PDF_FONTS ])
   //aList := ACLONE( ::oPdf:aReport[ PDF_TYPE1 ])
RETURN aList

METHOD dfPdfFont:Configure(FamilyName,Height,lBold,lItalic,lUnderScore,lReverse,cColor)
   DEFAULT lBold   TO .F.
   DEFAULT lItalic TO .F.
   DEFAULT cColor  TO PDF_BLACK

   IF EMPTY(::CompoundName)
      ::CompoundName := STR(::oPdf:aReport[PDF_FONTSIZE])+"."+ ::oPdf:aReport[PDF_FONTNAME]
   ENDIF
   IF EMPTY(Height) .AND. EMPTY(::Height)
      ::Height := ::oPdf:aReport[PDF_FONTSIZE]
   ELSE
      ::Height := Height
   ENDIF
   IF EMPTY(FamilyName) .AND. EMPTY(::FamilyName)
      ::FamilyName := ::oPdf:aReport[PDF_FONTNAME]
   ELSE
      ::FamilyName := FamilyName
   ENDIF
   IF Empty(lunderScore)
      ::underScore   := .F.
   ELSE
      ::underScore   := lunderScore
   ENDIF
   IF Empty(lReverse)
      ::Reverse   := .F.
   ELSE
      ::Reverse   := lReverse
   ENDIF
   IF lBold .AND. lItalic
      ::Type        := PDF_BOLDITALIC
      ::Bold         := .T.
      ::Italic       := .T.
   ELSEIF !lBold .AND. lItalic
      ::Type        := PDF_ITALIC
      ::Bold         := .F.
      ::Italic       := .T.
   ELSEIF lBold .AND. !lItalic
      ::Type        := PDF_BOLD
      ::Bold         := .T.
      ::Italic       := .F.
   ELSE
      ::Type        := PDF_NORMAL
      ::Bold         := .F.
      ::Italic       := .F.
   ENDIF
   ::Color := cColor
   ::Width := ::oPdf:Length("W")

RETURN Self

METHOD dfPdfFont:SetPdfFont(cString,cColor)
  DEFAULT cString TO ""
  DEFAULT cColor  TO PDF_BLACK

  IF ::bold .AND. ::Italic
     ::Type := PDF_BOLDITALIC
  ELSEIF !::Bold .AND. ::Italic
     ::Type := PDF_ITALIC
  ELSEIF ::Bold .AND. !::Italic
     ::Type := PDF_BOLD
  ELSE
     ::Type := PDF_NORMAL
  ENDIF

  ::oPdf:setFont(::FamilyName, ::Type, ::Height )
  ::Width := ::oPdf:Length("W")
  IF ::underScore
     cString := ::oPdf:UnderLine(cString)
  ENDIF
  IF ::Reverse
    cString := ::oPdf:Reverse( cString )
  ENDIF
  cString := ::Str2Color(cColor) + cString
RETURN cString

METHOD dfPdfFont:Str2Color(cCod)
  Local cStr
  IF Empty(cCod)
    cCod:= ::Color
  ENDIF
  cStr:= chr(253)                               +;
         chr( cTon( substr( cCod, 1, 2 ), 16) ) +;
         chr( cTon( substr( cCod, 3, 2 ), 16) ) +;
         chr( cTon( substr( cCod, 5, 2 ), 16) )

RETURN cStr

//컴컴컴컴컴컴컴컴컴컴컴컴�\\
//
// This function called only used in tstPdf.prg
//
static function cTon( cString, nBase )
   local cTemp, nI, cChar := "", n := 0, nLen

   nLen := len( cString )
   cTemp := ""
   for nI := nLen to 1 step -1
       cTemp += substr( cString, nI, 1 )
   next
   cTemp = upper( cTemp )

   for nI = 1 to nLen
      cChar = substr( cTemp, nI, 1 )
      if .not. IsDigit( cChar )
         n = n + ((Asc( cChar ) - 65) + 10) * ( nBase ^ ( nI - 1 ) )
		else
         n = n + (( nBase ^ ( nI - 1 )) * val( cChar ))
      endif
	next

return n

//컴컴컴컴컴컴컴컴컴컴컴컴�\\

