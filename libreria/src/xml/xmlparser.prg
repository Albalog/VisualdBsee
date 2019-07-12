/*****************************
* Source : xmlparser.prg
* System : <unkown>
* Author : Phil Ide
* Created: 12/02/2004
*
* Purpose:
* ----------------------------
* History:
* ----------------------------
*    12/02/2004 13:14 PPI - Created
*****************************/

#include "Xbp.ch"
#include "error.ch"
#include "Common.ch"

#define CRLF Chr(13)+Chr(10)

#define WS_INTAG     ' '+Chr(9)+Chr(0)+CRLF
#define WS_OUTTAG    WS_INTAG
#define WS_CONTENT   ''

#define OUT_TAG      0
#define IN_TAG       1
#define IN_CONTENT   2

#ifdef _TEST_
   Function Main(cFile)
      local oXml
      local nH
      if FExists(cFile)
         oXml := dfParseXml( memoread(cFile) )
         if !oXml == NIL
            nH := FCreate('test.xml')
            FWrite(nH,oXml:asString())
            FClose(nH)
         endif
      endif
      return nil
#endif

// come dfParseXML ma non da errore di runtime e lo ritorna by reference
FUNCTION dfParseXML1(cStream, oNodeClass, oErr)
   LOCAL oRet
   LOCAL bErr
   LOCAL xRet
   LOCAL err

   oErr := NIL
   bErr := ERRORBLOCK({|e| dfErrBreak(e, CRLF, .T., .T.)})
   BEGIN SEQUENCE
      xRet := dfParseXml( cStream, oNodeClass )

   RECOVER USING err
      oErr := err
   END SEQUENCE
   ERRORBLOCK(bErr)
RETURN xRet
   

Function dfParseXml( cStream, oNodeClass )
   local oParser := XmlParser():new(cStream)
   local oXml

   oParser:setNodeClass(oNodeClass)
   oXml := oParser:parse()
   return oXml

CLASS XMLParser
   EXPORTED:
      VAR cData
      VAR iPos
      VAR inTag
      VAR nEnd
      VAR inString
      VAR stringDelim
      VAR LineNum
      VAR oTree
      VAR lastPos
      VAR oNodeClass

      METHOD init
      METHOD parse
      METHOD setNodeClass

   PROTECTED:
      METHOD XMLParse
      METHOD getNextToken
      METHOD lookAhead
      METHOD strip
      METHOD ungetToken
      METHOD xmlError
      METHOD getTag
ENDCLASS


METHOD XMLParser:init(cStream)
   ::cData       := cStream
   ::iPos        := 1
   ::inTag       := OUT_TAG
   ::nEnd        := Len(::cData)
   ::inString    := FALSE
   ::stringDelim := {}
   ::LineNum     := 1
   ::oTree       := {}
   ::oNodeClass  := XmlNode()
   return self

METHOD XMLParser:parse()
   local oDoc
   // call lexical analyser
   ::XmlParse()
   if !Empty(::oTree)
      oDoc := ::oTree[1]
   endif
   return oDoc

METHOD XMLParser:XmlParse()
   local cToken := '0'
   local oDoc
   local n
   //Mantis 2183
   // Simone 17/10/11 XL 3074
   // FIX per tag che contiene a capo
   //  es 
   //       <test1>xx</test1>
   //       <test2>&#13;&10;</test2>
   //       <test3>pippo</test3>
   // esce dopo il parse di <test2> e non fa il parse di <test3>
   // perch‚ la getNextToken() torna la stringa CRLF che Š EMPTY() 
   // e quindi esce interrompendo il parse
   //
   //While !Empty( cToken := ::getNextToken() )
   While  !((cToken := ::getNextToken()) == "")
      if cToken == '<'
         ::getTag() // call lexical parser

      elseif ::inTag == OUT_TAG .and. !Empty(::oTree)
         // reset pointer
         ::iPos = ::lastPos
         n := ::lookAhead()
         cToken := SubStr( ::cData, ::iPos, n )
         if !Empty(::Strip(cToken,WS_OUTTAG)) // is there only white-space?
            // simone 22/4/10 FIX per conversione del contenuto di un tag
            // es. <prova>ciao&apos;</prova> -> o:content deve essere "ciao'" e non "ciao&apos;"
            ATail(::oTree):content := dfXml2Str( cToken ) // keep white-space if there is data
         endif
         ::iPos += n
      else
         ::xmlError(cToken)
      endif
   Enddo
   return nil

METHOD XMLParser:getNextToken()
   local cToken := ''
   local cA

   ::lastPos := ::iPos

   While ::iPos <= ::nEnd
      cA := ::cData[::iPos]
      if ::cData[::iPos] == Chr(10)
         ::LineNum++
      endif

      do case

         case ::inString .and. !(::cData[::iPos] == ATail(::stringDelim))
            cToken += ::cData[::iPos]

         case ::cData[::iPos] == '?' .and. ::inTag == IN_TAG .and. !::inString
            if Len(cToken) > 0
               exit
            else
               cToken := '?'
               ::iPos++
               exit
            endif

         case ::cData[::iPos] == '=' .and. ::inTag == IN_TAG
            if Len(cToken) > 0
               exit
            else
               cToken := '='
               ::iPos++
               exit
            endif

         case ::inTag == OUT_TAG .and. ::cData[::iPos] == '<' .and. !::inString
            if Len(cToken) > 0
               exit
            else
               cToken := '<'
               ::inTag := IN_TAG
               ::iPos++
               exit
            endif

         case ::inTag == OUT_TAG .and. !(::cData[::iPos] $ '"'+"'") .and. !(::cData[::iPos] $ WS_OUTTAG)
            cToken += ::cData[::iPos]

         case ::cData[::iPos] == '>' .and. !::inString
            if Len(cToken) > 0
               exit
            else
               cToken := '>'
               ::inTag := OUT_TAG
               ::iPos++
               exit
            endif

         case ::cData[::iPos] == '"' .or. ::cData[::iPos] == "'"
            if !::inString
               aadd(::stringDelim, ::cData[::iPos])
               ::inString := TRUE
            elseif ::cData[::iPos] == ATail(::stringDelim)
               ASize(::stringDelim, Len(::stringDelim)-1)
               ::inString := FALSE

               cToken += ::cData[::iPos]
               ::iPos++
               exit
            endif
            cToken += ::cData[::iPos]

         case ::inTag == IN_TAG .and. ::cData[::iPos] $ WS_INTAG
            if Len(cToken) > 0
               ::iPos++
               exit
            endif

         case ::inTag == OUT_TAG .and. ::cData[::iPos] $ WS_OUTTAG
            if Len(cToken) > 0
               ::iPos++
               exit
            endif

         otherwise
            cToken += ::cData[::iPos]
      endcase
      ::iPos++
   Enddo

   // conversione &amp; -> & ecc.
   cToken := dfXml2Str(cToken)

   return cToken

METHOD XMLParser:lookAhead()
   local i := ::iPos+1
   local n := 1
   local aDelim := {}

   While i <= ::nEnd
      if ::cData[i] $ '"'+"'"
         if !Empty(aDelim) .and. ::cData[i] == ATail(aDelim)
            ASize(aDelim, Len(aDelim)-1)
         else
            aadd(aDelim, ::cData[i])
         endif
      elseif ::cData[i] $ '<'
         exit
      endif
      i++
   Enddo
   return i-::iPos

METHOD XMLParser:Strip(cToken,cStrip)
   local i
   local n := Len(cToken)
   local c := ''

   for i := 1 to n
      if !(cToken[i] $ cStrip)
         c += cToken[i]
      endif
   next
   return c


METHOD XMLParser:ungetToken()
   ::iPos := ::lastPos
   return NIL



METHOD XMLParser:XmlError(cToken)
   local o := Error():new()

   o:args := {cToken, "line: "+alltrim(str(::LineNum)), "row: "+alltrim(str(::iPos-1))}
   o:description := "XML Parsing error - Error in Input"
   o:severity := XPP_ES_FATAL
   o:subSystem := "XML"
   Eval( ErrorBlock(), o)
   return nil

METHOD XMLParser:getTag()
   local oTag := ::oNodeClass:new()
   local cAttrName
   local cAttrVal
   local cName
   local cToken
   local n

   oTag:name := ::getNextToken()
   if LEFT(oTag:name, 3) == "!--" // commento, cerca fine commento
      ::iPos--
      n := ::iPos 

      While .T.
         IF SUBSTR(::cData, n, 3) == '-->'
            // simone 22/4/10 FIX per conversione del contenuto di un tag
            // es. <prova>ciao&apos;</prova> -> o:content deve essere "ciao'" e non "ciao&apos;"
            oTag:content := dfXml2Str( SUBSTR(::cData, ::iPos, (n-::iPos)) )
            ::iPos := n+3 -1
            EXIT
         ENDIF
         IF ++n > ::nEnd
            EXIT
         ENDIF
      enddo

   else
      if oTag:name == '?' .or. oTag:name == '!' .or. oTag:name == '/'
         oTag:name += ::getNextToken() // ?xml
      endif

      While !(::cData[::iPos] == '>')
         cAttrName := ::getNextToken()
         cAttrVal := NIL
         if !(cAttrName == '?' .or. cAttrName == '/')
            cToken := ::getNextToken() // remove '='
            if cToken == '='
               cAttrVal := ::getNextToken()
               // strip out quotes
               if cAttrVal[1] $'"'+"'"
                  cAttrVal := SubStr(cAttrVal,2)
               endif
               if cAttrVal[-1] $'"'+"'"
                  cAttrVal := Left(cAttrVal,Len(cAttrVal)-1)
               endif
            else
               ::ungetToken(cToken)
            endif
            oTag:addAttribute(cAttrName, cAttrVal)
            //aadd( oTag:attribute, {cAttrName, cAttrVal} )
         elseif cAttrName == '/'
            oTag:hasEndTag := FALSE
         else
            oTag:addAttribute(cAttrName, NIL)
            //aadd( oTag:attribute, {cAttrName, NIL} )
         endif
         // ----------------------------------------------
         // simone 13/11/06 
         // mantis 0001166: problema parser XML con spazi prima del tag ">"
         // FIX per errata gestione di spazi prima di ">"
         // es. <actions> Š ok,  <actions > da problemi 
         IF ! ::inString .AND. ::inTag == IN_TAG 
            // se non sono in stringa e sono dentro un tag, salto eventuali spazi
            DO WHILE ::iPos <= ::nEnd .AND. ::cData[::iPos] $ WS_INTAG
               ::iPos++
            ENDDO
         ENDIF
         // ----------------------------------------------

      enddo
   endif

   if LEFT(oTag:name, 3) == "!--" 
      oTag:hasEndTag := FALSE
      if !Empty(::oTree)
         oTag:parent := ATail(::oTree)
         aadd( ATail(::oTree):children, oTag )
      endif
      //aadd(::oTree, oTag)

   elseif !(oTag:name[1] == '/')
      if !(cAttrName == '?' .or. cAttrName == '/')
         if !Empty(::oTree)
            oTag:parent := ATail(::oTree)
            aadd( ATail(::oTree):children, oTag )
         endif
         aadd(::oTree, oTag)
      elseif cAttrName == '?' .and. Empty(::oTree)
         oTag:hasEndTag := FALSE
         aadd(::oTree,oTag)
      elseif lower(oTag:name) == '?xml'
         aadd(::oTree,oTag)
      elseif oTag:name[1] == '!'
         oTag:hasEndTag := FALSE
      elseif cAttrName[1] == '/'
         oTag:hasEndTag := FALSE
         oTag:parent := ATail(::oTree)
         aadd( ATail(::oTree):children, oTag )
      endif

   // simone 17/10/11
   // fix per stringhe senza <?xml version="1.0" ?> iniziale es "<doc />"
   // tolgo l'elemento solo se l'array non rimane vuoto
   //else
   elseif len(::oTree) > 1 
      oTag:hasEndTag := FALSE
      ASize(::oTree, Len(::oTree)-1)
   endif

   ::getNextToken() // clear '>'
   return oTag

METHOD XMLParser:setNodeClass(o)
   IF valtype(o)=="O"
      ::oNodeClass := o
   ENDIF
   return .t.
