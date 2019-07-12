#include "dfwin.ch"
#include "dfctrl.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbMainCtrl( oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual := ASCAN( oTbr:W_CONTROL,;
               {|aCtrl| aCTRL[FORM_CTRL_PAGE]==oTbr:W_CURRENTPAGE .AND.;
                        aCTRL[FORM_CTRL_TYP ]!=CTRL_SAY           .AND.;
                        aCTRL[FORM_CTRL_TYP ]!=CTRL_BOX           .AND.;
                        aCTRL[FORM_CTRL_TYP ]!=CTRL_FUNCTION })

RETURN MAX( nActual-1, 0)
