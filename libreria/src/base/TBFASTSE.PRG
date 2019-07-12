// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Description : Centralised Automatic Lookup function
// *****************************************************************************

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif
#ifdef __XPP__
   #include "appevent.ch"

   #define K_UP      xbeK_UP
   #define K_DOWN    xbeK_DOWN
   #define K_ENTER   xbeK_ENTER
   #define K_ESC     xbeK_ESC
   #define K_BS      xbeK_BS

   // Sostituisce la nextkey standard
   STATIC FUNCTION NEXTKEY()
      LOCAL nEvent, mp1, mp2, oXbp
      LOCAL nKey := 0
      IF AppEvent(@mp1, @mp2, @oXbp, 1) == xbeP_Keyboard
         nKey := mp1
      ENDIF
   RETURN nKey

#else
   #include "inkey.ch"
   #xtranslate _CapsLock( [<x>]) => dfCapsLock(<x>)
#endif

#include "Common.ch"
#include "dfWin.ch"

#define TB_UPPER   1
#define TB_LOWER   2
#define TB_NORMAL  3

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbFastSeek( oTbr, oMaster, nDelay ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cType, cSeek := "", c2Add := "", uKey, nRec, cKey, lCaps, lGoto
#ifdef __XPP__
LOCAL cText
LOCAL oForm := S2FormCurr()

              //Gerr 3791 Luca 21/07/03
LOCAL lCaps1  //Inserito per gestire il malfunzionamento di _Capslock()
              //Assume tre stati:
              //1 .T. chiave con upper
              //2 .F. chiave con Lower
              //3 NIL chiave mista

#endif

DEFAULT nDelay TO dfSet(AI_FASTSEEKTIMEOUT)
DEFAULT nDelay TO 3  // In caso fosse vuoto


IF tbIsFast( oTbr )
   cKey  := (oTbr:W_ALIAS)->(ORDKEY(INDEXORD()))         // Key
   IF !EMPTY(cKey) // If not empty
      uKey  := (oTbr:W_ALIAS)->( &cKey )                 // Key
      cType := VALTYPE( uKey )
      nRec  := (oTbr:W_ALIAS)->(RECNO())

      lCaps := _CapsLock()
      //Gerr 3791 Luca 21/07/03
      #ifdef __XPP__
      lCaps := .F.
      #endif
      IF cType $ "CN"                                    // Number or Char
         IF cType=="C"
            IF oTbr:W_KEY#NIL   // Fast Key default on the KEY
               c2Add := EVAL(oTbr:W_KEY)
            ENDIF
            DO CASE
                    // Upper of expression
               CASE "UPPER"$UPPER(cKey)
                    _CapsLock( .T. )
                     //Gerr 3791 Luca 21/07/03
                    #ifdef __XPP__
                       lCaps1 := .T.
                    #endif
                    // Lower of expression
               CASE "LOWER"$UPPER(cKey)
                    _CapsLock( .F. )
                     //Gerr 3791 Luca 21/07/03
                    #ifdef __XPP__
                       lCaps1 := .F.
                    #endif

               ///////////////////////////////////////////////////////////////////////////////////
               //Luca 30/08/2007
               //Inserito settaggio per settare ricrca sempre su Upper,Lower o in base al tipo indice. 
               CASE dfSet("XbaseFastSeekMode")== "ALWAYSUPPER"
                    _CapsLock( .T. )
                    lCaps1 := .T.

               CASE dfSet("XbaseFastSeekMode")== "ALWAYSLOWER"
                    _CapsLock( .F. )
                    lCaps1 := .F.
               ///////////////////////////////////////////////////////////////////////////////////

                    // No information in the key
               OTHERWISE
                    lGoto := .F.
                    IF EMPTY( uKey ) .OR. dfIsUpper( uKey )==dfIsLower( uKey )
                       // In the bottom of file the key is't empty
                       lGoto := .T.
                       EVAL( oTbr:GOBOTTOMBLOCK )
                       uKey  := (oTbr:W_ALIAS)->( &cKey ) // Key
                    ENDIF

                    //Gerr 3791 Luca 21/07/03
                    #ifdef __XPP__
                    lCaps1:= NIL
                    #else
                    IF dfIsUpper( uKey ); _CapsLock( .T. ); ENDIF
                    IF dfIsLower( uKey ); _CapsLock( .F. ); ENDIF
                    #endif


                    IF lGoto
                       (oTbr:W_ALIAS)->(DBGOTO( nRec ))
                    ENDIF
            ENDCASE

            #ifdef __XPP__
               // simone 24/8/04 GERR 4198
               IF tbFastSIsLetter(M->A) // compresi fra "A" e "z"
                  //M->A >= 65 .AND. M->A <= 122  // compresi fra "A" e "z"

                  IF dfIsCapsLock() .OR. lCaps1== .T.
                     M->A := ASC(UPPER(CHR(M->A)))
                  ELSE
                     //Gerr 3791 Luca 21/07/03
                     M->A := ASC(CHR(M->A))
                     //M->A := ASC(LOWER(CHR(M->A)))
                  ENDIF
               ENDIF
            #else

               IF _CapsLock()
                  KEYBOARD UPPER(CHR(M->A))
               ELSE
                  KEYBOARD LOWER(CHR(M->A))
               ENDIF
               M->A := dfINKEY() //FW
            #endif

         ENDIF

         #ifdef __XPP__
         cText:=oForm:getMsg()
         oForm:setMsg(CHR(M->A))
         #else
         dbScrSav( "GetKey", MAXROW() )
         #endif

         DO WHILE .T.
            DO CASE
               CASE M->A == K_BS
                    cSeek := SUBSTR( cSeek, 1, LEN(cSeek)-1)  // Remove

               // simone 24/8/04 GERR 4198
              #ifdef __XPP__
               CASE tbFastSChkKey(M->A) //M->A >= 32 .AND. M->A <= 132 
                    cSeek += CHR(M->A)                   // Add
              #else
               CASE M->A >= 32 .AND. M->A <= 132 
                    cSeek += CHR(M->A)                   // Add
              #endif
            ENDCASE


            #ifdef __XPP__
            //Gerr 3791 Luca 21/07/03
            IF lCaps1 == .T.
               cSeek  :=UPPER( cSeek )
            ELSEIF lCaps1 == .F.
               cSeek  :=LOWER( cSeek )
            ENDIF

            oForm:setMsg(PADR(cSeek, MAXCOL()+1))
            #else
            @ MAXROW(), 0   SAY PADR(cSeek, MAXCOL()+1 ) ;
                            COLOR "W+/B"                 // Print the char
            #endif
            DO CASE                                      // Seek the value
               CASE cType == "C"; (oTbr:W_ALIAS)->(DBSEEK(c2Add+cSeek,.T.))
               CASE cType == "N"; (oTbr:W_ALIAS)->(DBSEEK(VAL(cSeek),.T.))
            ENDCASE

            WHILE !EVAL(oTbr:W_FILTER)     .AND.; // Not in filter
                  !EVAL(oTbr:W_BREAK)      .AND.; // In break
                  !(oTbr:W_ALIAS)->(EOF()) .AND.; // In EOF()
                  NEXTKEY()==0             .AND.; // No other key
                  EVAL( oTbr:SKIPBLOCK ) > 0 // Next record
            ENDDO

            IF !EVAL(oTbr:W_FILTER) .OR.; // Non in filter
                EVAL(oTbr:W_BREAK)  .OR.; // In break
                (oTbr:W_ALIAS)->(EOF())   // In EOF()
               EVAL( oTbr:GOBOTTOMBLOCK )
            ENDIF

            oTbr:ROWPOS := 1
            tbCONFIGURE(oTbr)
            oTbr:REFRESHCURRENT()                    // REFRESH current
            tbStab( oTbr, .T. )                      // Stabilize

            IF !( (M->A:=dfINKEY(nDelay)) #0  .AND.; //FW
                  LEN(cSeek)<=MAXCOL()        .AND.;
                  M->A#K_UP                   .AND.;
                  M->A#K_DOWN                 .AND.;
                  M->A#K_ENTER                .AND.;
                  M->A#K_ESC                       )
               EXIT
            ENDIF

            #ifdef __XPP__
               IF tbFastSIsLetter(M->A) // compresi fra "A" e "z"
               // M->A >= 65 .AND. M->A <= 122  // compresi fra "A" e "z"
                  IF dfIsCapsLock() .OR. lCaps== .T.
                     M->A := ASC(UPPER(CHR(M->A)))
                  ELSE
                     //Gerr 3791 Luca 21/07/03
                     M->A := ASC(CHR(M->A))
                    // M->A := ASC(LOWER(CHR(M->A)))
                  ENDIF
               ENDIF
            #endif
         ENDDO

         // Check if current record is in filre or if is in break
         IF !EVAL(oTbr:W_FILTER) .OR.; // Non in filter
             EVAL(oTbr:W_BREAK)  .OR.; // In break
             (oTbr:W_ALIAS)->(EOF())   // In EOF()
            (oTbr:W_ALIAS)->(DBGOTO(nRec)) // Return to old record
         ENDIF
         tbRecCng( oTbr )       // Remember the record
         tbReset( oTbr, .F. )   // Reset
         tbRtr( oTbr, oMaster ) // Refresh

         #ifdef __XPP__
         oForm:setMsg(cText)
         #else
         dbScrResDel( "GetKey" )
         #endif

         IF M->A==K_ENTER
            dbAct2Kbd( "ret" )
         ENDIF
      ENDIF
      _CapsLock( lCaps )
   ENDIF
ENDIF

RETURN

#ifdef __XPP__
STATIC FUNCTION _CapsLock(lSet)
   LOCAL cMode := dfSet("XbaseFastSeekMode")
   // SD 26/10/02 - GERR3400
   // Workaround che disabilita la possibilit… di cambiare
   // lo stato del capslock su win9x altrimenti ho problemi
   //IF dfOSFamily() == "WIN9X" .AND. dfSet("XbaseFastSeekMode") != NIL
   DO CASE
      CASE cMode == NIL
      CASE cMode == "NOCHANGECAPS"
         lSet := NIL
      CASE cMode == "NOCHANGECAPS_ON_WIN9X" .AND. dfOSFamily() == "WIN9X"
         lSet := NIL
      CASE cMode == "NOCHANGECAPS_ON_WINNT" .AND. dfOSFamily() == "WINNT"
         lSet := NIL
      ///////////////////////////////////////////////////////////////////////////////////
      //Luca 30/08/2007
      //Inserito settaggio per settare ricrca sempre su Upper,Lower o in base al tipo indice. 
      CASE cMode == "ALWAYSUPPER"
         lSet := .T.
      CASE cMode == "ALWAYSLOWER"
         lSet := .F.
      ///////////////////////////////////////////////////////////////////////////////////
   ENDCASE

   IF lSet != NIL
      dfCapsLock(lSet)
   ENDIF
RETURN dfIsCapsLock()

STATIC FUNCTION dfIsCapsLock()
   LOCAL lCapsLock := .F.

   // some necessary defines
   #define VK_NUMLOCK        0x90
   #define VK_SCROLL         0x91
   #define VK_CAPSLOCK       0x14
   #define APPKEY_PRESSED    2

   // find out whether CAPS_LOCK key is currently pressed
   lCapsLock := (AppKeystate(VK_CAPSLOCK, .T.) == APPKEY_PRESSED)
RETURN lCapsLock

// ritorna se il carattere pu• essere trasformato in upper o lower
// ad esempio:
//   se A oppure a -> .T.
//   se ! oppure % -> .F.
STATIC FUNCTION tbFastSIsLetter(nKey)
RETURN ASC(UPPER(CHR(nKey))) != nKey .OR. ;
       ASC(LOWER(CHR(nKey))) != nKey 

#endif

