#include "common.ch"

// come XmlNode
// ma gestisce attributi come variabili

class XmlNode2 from XmlNode
   exported:
     method init
     method getNoIvar
     method setNoIvar

     method getName
     method setName

     method getContent
     method setContent

     method findAllChildrenFromName
endclass

method XmlNode2:init(x)
  ::XmlNode:init()
  if ! empty(x)
     ::setName( x )
  endif
return self

method XmlNode2:getName()
return ::XmlNode:name

method XmlNode2:setName(c)
   ::XmlNode:name := c
return self

method XmlNode2:getContent()
return ::XmlNode:content

method XmlNode2:setContent(c)
   ::XmlNode:content := c
return self

method XmlNode2:getNoIvar(x)
return ::findAttribute(x) 

method XmlNode2:setNoIvar(x, y)
//if valtype(y)$"CM"
//   y:=dfStr2Xml(y)
//endif
// avvertimento su attributo gi… specificato
//if ::findAttribute(x) != NIL
//   msgbox(x)
//endif
return ::setAttribute(x, y)

// come il metodo padre, per• scandisce anche i children dei nodi che si trovano
// ad esempio
//    <category id="a">
//       <category id="b">
//       </category>
//    </category>
//    <category id="c">
//       <category id="d">
//       </category>
//    </category>
// il metodo XmlNode:findAllChildrenFromName
// trova solo i nodi "a" e "c"
// questo trova "a", "b", "c" e "d"
// se nScanMode=0 lavora come il padre
// 
// Esempio
// - elenco nodi <category>
//   ::findAllchildrenFromName("category") 
// - elenco nodi <category> con attributo id="d"
//   ::findAllchildrenFromName({|o| o:getName()=="category" .AND. o:id="d"})
// - elenco nodi <category> con attributo id="d" (altra sintassi)
//   ::findAllchildrenFromName("view", NIL, {|o| o:id="pippo"})

method XmlNode2:findAllChildrenFromName(cName, nScanMode, bFind2)
   local aRet := {}
   local i
   local n
   local aTmp
   local lFound
   local bFind
   
   default nScanMode to 1

   if valtype(cName) $ "CM"
      bFind := {|oNode| lower(oNode:name) == lower(cName)}
   else
      bFind := cName
   endif

   if ! valtype(bFind) == "B"
      return aRet
   endif

   for i := 1 to len(::children)
      lFound := .F.
      if eval(bFind, ::children[i]) .and. ;
         (bFind2==NIL .OR. eval(bFind2, ::children[i]))

         lFound := .T.
         aadd( aRet, ::children[i] )
      endif
      if ! lFound .or. nScanMode == 1
         aTmp := ::children[i]:findAllChildrenFromName(cName, NIL, bFind2)
         for n := 1 to len(aTmp)
            aadd( aRet, aTmp[n] )
         next
      endif
   next
   return aRet
   
