#include "Common.ch"

#define PIXML_SCAN_SHALLOW   0
#define PIXML_SCAN_DEEPSCAN  1

#define CRLF Chr(13)+Chr(10)

// TAG_PAD provides indentation on output
#define TAG_PAD 2

CLASS XMLNode
   EXPORTED:
      VAR parent
      VAR name
      VAR attribute
      VAR content
      VAR children
      VAR hasEndTag
      VAR childID

      METHOD init
      METHOD asString

      METHOD compose IS asString
      METHOD parent
      METHOD children
      METHOD getChild
      METHOD allSiblings
      METHOD siblings
      METHOD getSibling
      METHOD getPreviousSibling
      METHOD getNextSibling
      METHOD isOrphan
      METHOD getAttribute
      METHOD setAttribute
      METHOD findAttribute
      METHOD checkAttribute
      METHOD findChildFromName
      METHOD findChildFromAttribute
      METHOD findAllChildrenFromName
      METHOD findSiblingFromName
      METHOD findSiblingFromAttribute

      METHOD addChild // aggiunto simone d. 9/11/06
      METHOD addAttribute // simone 19/3/08 aggiunto per poter essere modificato in sottoclassi

      // simone 20/03/08
      // metodo aggiunto per supporto scrittura su .xmlbin
      // per controllo versione dei dati scritti
      // aggiornare se ci sono variabili nuove che devono essere inizializzate
      // o se cambia il valore contenuto in una variabile
      INLINE CLASS METHOD getXmlInternalVersion(); RETURN "0"

ENDCLASS

METHOD XmlNode:init()
   ::name      := ''
   ::attribute := {}
   ::children  := {}
   ::hasEndTag := TRUE
   return self

METHOD XmlNode:parent()
   return ::parent

METHOD XmlNode:children()
   return ::children

METHOD XmlNode:getChild(n)
   local oRet

   if valType(n) == 'N' .and. n > 0 .and. n <= len(::Children)
      oRet := ::Children[n]
   endif
   return oRet   

METHOD XmlNode:allSiblings()
   return ::parent:children

METHOD XmlNode:siblings()
   local oParent := ::parent
   local i
   local aRet := {}

   for i := 1 to len(oParent:children)
      if !(oParent:children[i] == self)
         aadd( aRet, oParent:children[i] )
      endif
   next
   return aRet

METHOD XmlNode:getSibling(n)
   local oRet

   if ValType(n) == 'N' .and. n > 0 .and. n <= len(::parent:children)
      oRet := ::parent:children[n]
   endif
   return oRet

METHOD XmlNode:getPreviousSibling(nId)
   local i
   local oRet

   default nId to ::id

   i := AScan(::parent:children, {|o| o == self })
   if i > 1
      oRet := ::parent:children[i-1]
   endif
   return (oRet)

METHOD XmlNode:getNextSibling(nId)
   local i
   local oRet

   default nId to ::id

   i := AScan(::parent:children, {|o| o == self })
   if i < len(::parent:children)
      oRet := ::parent:children[i+1]
   endif
   return (oRet)

METHOD XmlNode:isOrphan()
   return ::parent == NIL


METHOD XmlNode:getAttribute(x)
   local cRet

   cRet := ::attribute[x]
   return cRet

METHOD XmlNode:setAttribute(x, xValue)
   local aRet
   local i

   do case
      case ValType(x) == 'N'
         if x > 0 .and. x <= len(::attribute)
            ::attribute[x][2] := Var2Char(xValue)
            aRet := ::attribute[x]
         endif

      case ValType(x) == 'C'
         i := Ascan( ::attribute, {|e| lower(e[1]) == lower(x) } )
         if i == 0
            aadd(::attribute,{x,Var2Char(xValue)})
            i := len(::attribute)
         else
            ::attribute[i][2] := Var2Char(xValue)
         endif
         aRet := ::attribute[i]
   endcase
   return aRet

METHOD XmlNode:findAttribute(c)
   local i := Ascan( ::attribute, {|e| lower(e[1]) == lower(c) } )
   local cRet

   if i > 0
      cRet := ::attribute[i][2]
   endif
   return cRet

METHOD XmlNode:addAttribute(c, x)
   AADD(::attribute, {c, x})
   return self

METHOD XmlNode:findChildFromName( cName, nScanLevel )
   local nDepth := 0
   local oRet
   local i

   for i := 1 to len(::children)
      if lower(::children[i]:name) == lower(cName)
         oRet := ::children[i]
      elseif nScanLevel == PIXML_SCAN_DEEPSCAN
         oRet := ::children[i]:findChildFromName( cName, nScanLevel )
      endif
      if !(oRet == NIL)
         exit
      endif
   next
   return oRet

METHOD XmlNode:findChildFromAttribute( cAttr, nScanLevel )
   local nDepth := 0
   local oRet
   local aRet
   local i

   for i := 1 to len(::children)
      aRet := ::children[i]:findAttribute(cAttr)
      if aRet == NIL .and. nScanLevel == PIXML_SCAN_DEEPSCAN
         oRet := ::children[i]:findChildFromAttribute( cAttr, nScanLevel )
      else
         oRet := ::children[i]
      endif
      if !(oRet == NIL)
         exit
      endif
   next
   return oRet

METHOD XmlNode:findSiblingFromName(cName)
   local aSiblings := ::siblings()
   local i
   local oRet

   for i := 1 to len(aSiblings)
      if lower(aSiblings[i]:name) == lower(cName)
         oRet := aSiblings[i]
         exit
      endif
   next
   return oRet

METHOD XmlNode:findSiblingFromAttribute(cAttr)
   local aSiblings := ::siblings()
   local i
   local c
   local oRet

   for i := 1 to len(aSiblings)
      c := aSiblings[i]:findAttribute(cAttr)
      if !(c == NIL)
         oRet := aSiblings[i]
         exit
      endif
   next
   return oRet

METHOD XmlNode:findAllChildrenFromName(cName)
   local aRet := {}
   local i
   local n
   local aTmp

   for i := 1 to len(::children)
      if lower(::children[i]:name) == lower(cName)
         aadd( aRet, ::children[i] )
      else
         aTmp := ::children[i]:findAllChildrenFromName(cName)
         for n := 1 to len(aTmp)
            aadd( aRet, aTmp[n] )
         next
      endif
   next
   return aRet
   

METHOD XmlNode:asString(nDepth)
   local cRet
   local i
   local v
   local n
//   local nLen :=0 

   default nDepth to 0

   cRet := Space(TAG_PAD*nDepth)+'<'

   cRet += dfStr2Xml(::name)
//   nLen :=0
   v := Len(::attribute)
   for i := 1 to v
      // simone modifica per migliore layout
      IF v > 3 .and. i > 1
        cRet += CRLF+Space(TAG_PAD*(nDepth) + len(::name)+2)+dfStr2Xml(::attribute[i][1])
      ELSE
        cRet += ' '+dfStr2Xml(::attribute[i][1])
      ENDIF
//      IF len(cRet)-nLen > 50
//        cRet += CRLF+Space(TAG_PAD*(1+nDepth))+::attribute[i][1]
//        nLen+=50
//      ELSE
//        cRet += ' '+::attribute[i][1]
//      ENDIF
//      cRet += ' '+::attribute[i][1]
      if !(::attribute[i][2] == NIL)
         cRet += '="'+dfStr2Xml(::attribute[i][2])+'"'
      endif
   next
   if ::hasEndTag .or. ::name[1] == '?'
      // simone FIX per tag ?xml
      if ::name[1]=="?" .and. Ascan( ::attribute, {|e| LEN(e)>=1 .AND. e[1] == '?' } )==0
         cRet+="?"
      endif

      cRet += '>'
   endif

   if !Empty(::content)
      cRet += dfStr2Xml(::content)
   endif

   if ::name == "!--"
      cRet += "-->"+CRLF
   endif

   if !Empty(::children)
      cRet += CRLF
   endif

   for i := 1 to Len(::children)
      n := iif( lower(::name) == '?xml', 0, nDepth+1 )
      cRet += ::children[i]:asString(n)
   next
   if !(::name[1] $ '?!')
      if ::hasEndTag
         if !Empty(::children)
            cRet += Space(TAG_PAD*nDepth)+'</'
         else
            cRet += '</'
         endif

         cRet += dfStr2Xml(::name)+'>'+CRLF
      else
         cRet += ' />'+CRLF
      endif
   endif
   return cRet


// metodo aggiunto simone d. 9/11/06
method XmlNode:addChild(xTag, cContent)
   LOCAL oTag

   oTag := XmlNode2():new()

   IF VALTYPE(xTag) == "O"
      oTag := xTag // uso oggetto passato

   ELSEIF VALTYPE(xTag) $ "CM" .AND. ! EMPTY(xTag)
      oTag:name := xTag

   ENDIF

   oTag:parent := self
   aadd( ::children, oTag )

   IF VALTYPE(cContent) $ "CM"
      oTag:content := cContent
   ENDIF
return oTag

// aggiunto simone 17/2/10
// per confronto case-insensitive
method XmlNode:checkAttribute(cAttr, cVal)
   LOCAL c := ::findAttribute(cAttr)
   IF c == NIL 
      RETURN (cVal == NIL) // torno .T. se cercavo NIL
   ENDIF
return lower(alltrim(c)) == lower(alltrim(cVal))
