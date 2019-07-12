#include "dfCtrl.ch"
//Nuove define utilizzate
//FORM_TXT_COORDINATE_MODE 
//FORM_SAY_COORDINATE_MODE 
//FORM_BOX_COORDINATE_MODE 
//FORM_GET_COORDINATE_MODE 
//FORM_FUN_COORDINATE_MODE 
//FORM_CMB_COORDINATE_MODE 
//FORM_CHK_COORDINATE_MODE 
//FORM_BUT_COORDINATE_MODE 
//FORM_SPN_COORDINATE_MODE 
//FORM_RAD_COORDINATE_MODE 
//FORM_LIST_COORDINATE_MODE 


FUNCTION S2CoordModeDefault()
RETURN IIF( dfSet("VdBseeCoordinateMode") == "PIXEL", ;
            W_COORDINATE_PIXEL, ;
            W_COORDINATE_ROW_COLUMN)

FUNCTION S2CtrlCoordMode(aCtrl)
  LOCAL cRet := S2CoordModeDefault()
  LOCAL nPos 
  IF !EMPTY(aCtrl)

     DO CASE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_SAY      
           nPos := FORM_SAY_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_BOX           
           nPos := FORM_BOX_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_FUNCTION      
           nPos := FORM_FUN_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_GET           
           nPos := FORM_GET_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_CMB           
           nPos := FORM_CMB_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_TEXT          
           nPos := FORM_TXT_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_CHECK         
           nPos := FORM_CHK_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_RADIO         
           nPos := FORM_RAD_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_BUTTON        
           nPos := FORM_BUT_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_LISTBOX       
           nPos := FORM_LIST_COORDINATE_MODE 
        CASE aCtrl[FORM_CTRL_TYP] ==  CTRL_SPIN    
           nPos := FORM_SPN_COORDINATE_MODE 
     ENDCASE

     //Tipo di Coordinate Gestite
     //W_COORDINATE_PIXEL
     //W_COORDINATE_ROW_COLUMN
     IF !EMPTY(nPos) .AND. LEN(aCTRL) >= nPos  
        cRet := aCTRL[nPos]
     ENDIF   
  ENDIF   
RETURN cRet

FUNCTION S2UsePixelCoordinateDefault() 
RETURN S2CoordModeDefault() == W_COORDINATE_PIXEL

FUNCTION S2UseRowColumCoordinateDefault()
RETURN S2CoordModeDefault() == W_COORDINATE_ROW_COLUMN


FUNCTION S2PixelCoordinate(aCtrl)
RETURN S2CtrlCoordMode(aCtrl) == W_COORDINATE_PIXEL
