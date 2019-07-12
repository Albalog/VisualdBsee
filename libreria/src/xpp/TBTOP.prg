FUNCTION tbTop(oWin); RETURN oWin:tbTop()
FUNCTION tbBottom(oWin); RETURN oWin:tbBottom()

// //*****************************************************************************
// //Progetto       : dBsee 4.0
// //Descrizione    : Funzioni di utilita' per tBrowse
// //Programmatore  : Baccan Matteo
// //*****************************************************************************
// #include "INKEY.CH"
// #include "dfwin.ch"
// #include "dfstd.ch"
// 
// * 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
// PROCEDURE tbTop( oTbr ) //
// * 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
// tbGenMove( oTbr, K_HOME )
// RETURN
// 
// * 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
// PROCEDURE tbBottom( oTbr ) //
// * 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
// tbGenMove( oTbr, K_END )
// RETURN
// 
// * 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
// STATIC PROCEDURE tbGenMove( oTbr, nMove ) //
// * 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
// LOCAL lStab
// 
// DFDISPBEGIN()
// IF oTbr:WOBJ_TYPE == W_OBJ_FRM
//    DO CASE
//       CASE nMove==K_HOME ;EVAL( oTbr:GoTopBlock )
//       CASE nMove==K_END  ;EVAL( oTbr:GoBottomBlock )
//    ENDCASE
//    tbRecCng( oTbr )
// ELSE
//    DO CASE
//       // CASE nMove==K_HOME ;IF( lStab:=oTbr:HITTOP()   ,,oTbr:GOTOP()   )
//       // CASE nMove==K_END  ;IF( lStab:=oTbr:HITBOTTOM(),,oTbr:GOBOTTOM())
// 
//       CASE nMove==K_HOME ;IF( lStab:=.F.             ,,oTbr:GOTOP()   )
//       CASE nMove==K_END  ;IF( lStab:=.F.             ,,oTbr:GOBOTTOM())
// 
//    ENDCASE
//  //  IF !oTbr:STABLE .OR. !lStab
//       IF nMove==K_HOME
//          tbTotal( oTbr )
//          tbStab( oTbr, .T. )
//       ELSE
//          tbStab( oTbr )
//       ENDIF
//       tbSysFooter( oTbr )
//  //  ENDIF
// ENDIF
// 
// // tbSayOpt( oTbr, W_MM_VSCROLLBAR )
// 
// IF nMove==K_END .AND. oTbr:W_KEY#NIL
//    oTbr:W_CURRENTKEY := EVAL( oTbr:W_KEY )
// ENDIF
// DFDISPEND()
// 
// RETURN

