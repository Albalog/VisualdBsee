//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfwin.ch"
#include "dfctrl.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbInh( oTbr, aInh, nMode )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, nSeek, aCTRL := oTbr:W_CONTROL, aActCTRL, nPos2, aUserData
DO CASE
   CASE nMode == INH_DEF       // DEFAULT ai campi in get
        FOR nPos := 1 TO LEN( aCTRL )
            aActCTRL := aCTRL[nPos]
            DO CASE
               CASE aActCTRL[FORM_CTRL_TYP] == CTRL_CHECK
                    nSeek := ASCAN( aInh, ;
                          {|aSub|UPPER(aActCTRL[FORM_CHK_CVAR])==UPPER(aSub[1])})
                    IF nSeek # 0
                       EVAL( aActCTRL[FORM_CHK_VAR], EVAL(aInh[nSeek][2]) )
                    ENDIF

               CASE aActCTRL[FORM_CTRL_TYP] == CTRL_RADIO
                    nSeek := ASCAN( aInh, ;
                          {|aSub|UPPER(aActCTRL[FORM_RAD_CVAR])==UPPER(aSub[1])})
                    IF nSeek # 0
                       EVAL( aActCTRL[FORM_RAD_VAR], EVAL(aInh[nSeek][2]) )
                    ENDIF

               CASE aActCTRL[FORM_CTRL_TYP] == CTRL_GET
                    nSeek := ASCAN( aInh, ;
                          {|aSub|UPPER(aActCTRL[FORM_GET_CVAR])==UPPER(aSub[1])})
                    IF nSeek # 0
                       EVAL( aActCTRL[FORM_GET_VAR], EVAL(aInh[nSeek][2]) )
                    ENDIF

               CASE aActCTRL[FORM_CTRL_TYP] == CTRL_TEXT
                    nSeek := ASCAN( aInh, ;
                          {|aSub|UPPER(aActCTRL[FORM_TXT_CVAR])==UPPER(aSub[1])})
                    IF nSeek # 0
                       EVAL( aActCTRL[FORM_TXT_VAR], EVAL(aInh[nSeek][2]) )
                    ENDIF

               CASE aActCTRL[FORM_CTRL_TYP] == CTRL_CMB
                    nSeek := ASCAN( aInh, ;
                          {|aSub|UPPER(aActCTRL[FORM_CMB_CVAR])==UPPER(aSub[1])})
                    IF nSeek # 0
                       EVAL( aActCTRL[FORM_CMB_VAR], EVAL(aInh[nSeek][2]) )
                    ENDIF

               CASE aActCTRL[FORM_CTRL_TYP] == CTRL_SPIN
                    nSeek := ASCAN( aInh, ;
                          {|aSub|UPPER(aActCTRL[FORM_SPN_CVAR])==UPPER(aSub[1])})
                    IF nSeek # 0
                       EVAL( aActCTRL[FORM_SPN_VAR], EVAL(aInh[nSeek][2]) )
                    ENDIF
               //////////////////////////////////////////////////////////////////
               //Mantis  821
               CASE aActCTRL[FORM_CTRL_TYP] == CTRL_FUNCTION
                    nSeek := ASCAN( aInh, ;
                          {|aSub|UPPER(aActCTRL[FORM_CTRL_ID])==UPPER(aSub[1])})
                    IF nSeek # 0
                       EVAL( aActCTRL[FORM_FUN_VAR], EVAL(aInh[nSeek][2]) )
                    ENDIF
               //////////////////////////////////////////////////////////////////

//Maudp-Simone 02/01/2012 Aggiunta possibilit… di gestire anche i ComboBox (fatto per XL 3189)
*************************************************************************************************
               CASE aActCTRL[FORM_CTRL_TYP] == CTRL_USERCB

                   aUserData := aActCTRL[FORM_UCB_USERDATA]
                   //Cerco il campo sulla form
                   nPos2 := ASCAN(aUserData, {|x|UPPER(ALLTRIM(x[1]))=="VARNAME"})
                   IF nPos2 > 0 .AND. VALTYPE(aUserData[nPos2][2]) $ "CM"

                      //Se ha il DATALINK procedo con la prevalorizzazione
                      nSeek := ASCAN( aInh, {|aSub| UPPER(aUserData[nPos2][2]) == UPPER(aSub[1])})
                      IF nSeek # 0
                         nPos2 := ASCAN(aUserData, {|x|UPPER(ALLTRIM(x[1]))=="DATALINK"})
                         IF nPos2 > 0 .AND. VALTYPE(aUserData[nPos2][2]) == "B"
                            EVAL(aUserData[nPos2][2], EVAL(aInh[nSeek][2]))
                         ENDIF
                      ENDIF
                   ENDIF
*************************************************************************************************
            ENDCASE
        NEXT
        FOR nPos := 2 TO LEN( oTbr:W_PRIMARYKEY ) // eredito la chiave
            nSeek := ASCAN( aInh, {|aSub|UPPER(oTbr:W_PRIMARYKEY[nPos][1])==UPPER(aSub[1])})
            IF nSeek # 0
               EVAL( oTbr:W_PRIMARYKEY[nPos][3], EVAL(aInh[nSeek][2]) )
            ENDIF
        NEXT

   CASE nMode == INH_WRI       // REPLACE sui campi da disco
        IF !EMPTY( oTbr:W_ALIAS )
           FOR nPos := 1 TO LEN( aInh )
              (oTbr:W_ALIAS)->;
                    (FIELDPUT( FIELDPOS(aInh[nPos][1]), EVAL(aInh[nPos][2]) ))
           NEXT
        ENDIF
ENDCASE
RETURN
