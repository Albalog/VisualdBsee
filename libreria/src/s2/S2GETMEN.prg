#include "Xbp.ch"
#include "dfMsg1.ch"

STATIC oMenu

// Menu di default su tasto destro su GET, quello Alaska non funziona
// con le get modificate

FUNCTION S2GetRBMenu()
RETURN oMenu

FUNCTION S2GetRBMenuInit()
   LOCAL oM := S2EditRBMenu():new() //XbpMenuBmp

   oM:create()
   oM:addItem({dfStdMsg1( MSG1_S2GETMEN01 )   ,  {|| dbAct2Kbd("C_u") }})
   oM:addItem({NIL,NIL, XBPMENUBAR_MIS_SEPARATOR, 0})
   oM:addItem({dfStdMsg1( MSG1_S2GETMEN02 )   ,  {|| dbAct2Kbd("C_x") }})
   oM:addItem({dfStdMsg1( MSG1_S2GETMEN03 )   ,  {|| dbAct2Kbd("C_c") }})
   oM:addItem({dfStdMsg1( MSG1_S2GETMEN04 )   ,  {|| dbAct2Kbd("C_v") }})
   oM:addItem({dfStdMsg1( MSG1_S2GETMEN05 )   ,  {|| dbAct2Kbd("ecr") }})

   oMenu := oM
RETURN oM


CLASS S2EditRBMenu FROM XbpMenuBmp
EXPORTED:
   INLINE METHOD popUp(obj, aPos)
       LOCAL lEnabled := .T.
       IF ! obj:isEnabled() .OR. ;
          (isMemberVar(obj, "editable") .AND. ! obj:editable)

          lEnabled := .F.
       ENDIF
       IF lEnabled
          oMenu:enableItem(3)
          oMenu:enableItem(5)
          oMenu:enableItem(6)
       ELSE
          oMenu:disableItem(3)
          oMenu:disableItem(5)
          oMenu:disableItem(6)
       ENDIF

   RETURN ::XbpMenuBmp:popUp(obj, aPos)
ENDCLASS

