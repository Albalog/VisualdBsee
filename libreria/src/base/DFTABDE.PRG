//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni per tabelle
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfCTRL.ch"
#include "dftab.ch"
#include "dfmsg.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfTabDe( ) // Data entry generale tabelle
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*  EnvId = "suttab"
LOCAL bKey    := {||"DBF"}
LOCAL bFilter := {||dbdd->file_typ=="1"}
LOCAL bBreak  := {||UPPER(dbdd->RecTyp)#"DBF"}
LOCAL aMtd    := {}

IF !dbCfgOpen("dbdd")        // Apro come altri file di configurazione
   RETURN
ENDIF

dbdd->(DBSEEK("DBF"))
WHILE !dbdd->(EOF()) .AND. !EVAL(bBreak)
   IF EVAL(bFilter)
      EXIT
   ELSE
      dbdd->(DBSKIP())
   ENDIF
ENDDO
IF !dbdd->(EOF()) .AND.; // NON SONO a EOF
   EVAL(bFilter)  .AND.; // SONO in filtro
   !EVAL(bBreak)         // NON SONO in break
   dfUsrInfo( "" )
   ADDKEY "ret" TO aMtd BLOCK {|oWin|dbTabDEMtr( oWin )} MESSAGE dfStdMsg(MSG_DFTABDE03)

   dbdd->(dfWin( INT(24/2-6), 20, INT(25/2+4), 60,; // Coordinate
                 bKey                    ,;
                 bFilter                 ,;
                 bBreak                  ,; // Chiave Filtro Break
                 dfStdMsg(MSG_DFTABDE01) ,; // titolo
                 { ;
                   { dfStdMsg(MSG_DFTABDE02), {||dbdd->file_name+" "+dbdd->field_des}} ;
                 }, aMtd ))
ELSE
   dbMsgErr( dfStdMsg(MSG_DFTABDE04) )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dbTabDeMtr( oWin ) // Modifica Tabella
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dbdd->(dfPushArea())
ddWit( dbdd->file_name, TAB_PRK, "", .T. )
dbdd->(dfPopArea())
RETURN
