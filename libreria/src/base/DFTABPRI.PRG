//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni per tabelle
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dftab.ch"
#include "dfReport.ch"
#include "dfMsg.ch"

STATIC aTabStru := NIL, aTabLst:={}, aTabRec:={}
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
PROCEDURE dfTabPrint( lReload )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL aTag := {}, cTab

IF !dbCfgOpen( "dbdd" )
   RETURN
ENDIF

DEFAULT lReload TO .F.

IF aTabStru==NIL .OR. lReload
   aTabStru := {}
   aTabLst  := {}
   aTabRec  := {}
   dbdd->(DBSEEK( "DBF" ))
   WHILE UPPER(dbdd->RecTyp) = "DBF" .AND. !(dbdd->(EOF()))
      IF ddFileIsTab()
         AADD( aTabLst, dbdd->field_des ) // Descrizioni
         AADD( aTabRec, dbdd->(RECNO()) ) // Record della tabella
         dfPushArea()
         cTab:=dbdd->file_name
         dbdd->(DBSEEK( "FIE"+UPPER(cTab) ))
         WHILE UPPER(dbdd->RecTyp+dbdd->file_name)=="FIE"+UPPER(cTab) .AND. ;
               !dbdd->(eof())
               AADD( aTabStru, {;
                               UPPER(ALLTRIM(dbdd->File_Name)) ,; // Nome File
                               dbdd->Field_name         ,; // Nome Campo
                               ALLTRIM(dbdd->Field_Des) ,; // Descrizione Campo
                               dbdd->field_type         ,; // Type
                               dbdd->field_len          ,; // Len
                               dbdd->field_dec          ,; // Dec
                               ALLTRIM(dbdd->field_pic) ,; // Picture
                               dbdd->TabFieSod           ; // Pisizione
                               })
               dbdd->(DBSKIP())
         ENDDO
         dfPopArea()
      ENDIF
      dbdd->(DBSKIP())
   ENDDO
ENDIF

IF EMPTY(aTabLst)
   dbMsgErr( dfStdMsg(MSG_DFTABPRINT01) )
ELSE
   dfArrWin( NIL,NIL,NIL,NIL, aTabLst, dfStdMsg(MSG_DFTABPRINT03), dfStdMsg(MSG_DFTABPRINT02), aTag)
ENDIF
IF M->Act=="ret" .AND. !EMPTY(aTag)
   AEVAL( aTag, {|aSub,nInd|aTag[nInd]:=aTabRec[aTag[nInd]]} )
   dfTabArrPrn( aTag )
ENDIF

RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC PROCEDURE dfTabArrPrn( aRecno ) // Stampa tabelle
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL aVirRec := {}
LOCAL VRloc, aFather, aBuffer

dbCfgOpen( "dbtabd" )

VRLoc := dfVRCreate( )
VRLoc[VR_NAME  ]     := "dbdd"           // Nome del file

VRLoc[VR_KEY   ]     := {||"DBF"}
VRLoc[VR_FILTER]     := {||ASCAN(aRecno,dbdd->(RECNO()))#0}
VRLoc[VR_BREAK ]     := {||UPPER(dbdd->RecTyp)#"DBF"}
VRLoc[VR_EOF_MODE]   := VR_IGNORE
VRLoc[VR_EJECT ]     := .F.

dfVrAddFle( aVirRec, {}, VRLoc )

VRLoc := dfVRCreate( )
VRLoc[VR_NAME  ]   := "dbTabD"                      // Nome del file

VRLoc[VR_KEY   ]     := {||UPPER(dbdd->File_name)}         // chiave
VRLoc[VR_FILTER]     := {||UPPER(dbdd->File_name)==UPPER(dbtabd->TabId)} // filtro
VRLoc[VR_BREAK ]     := {||UPPER(dbdd->File_name)!=UPPER(dbtabd->TabId)} // break
VRLoc[VR_EOF_MODE]   := VR_IGNORE
VRLoc[VR_EJECT ]     := .F.

VRLoc[VR_HEADER]     := {||dbtabdHeader()}
VRLoc[VR_ROWHEADER]  := 4
VRLoc[VR_BRKHEADER]  := .T.

VRLoc[VR_BODY  ]     := {||dbtabdBody()}
VRLoc[VR_ROWBODY  ]  := 1
VRLoc[VR_BRKBODY  ]  := .T.
VRLoc[VR_EJECTBODY]  := .F.
VRLoc[VR_BODY2HEAD]  := .T.
VRLoc[VR_BODY2FOOT]  := .T.

VRLoc[VR_FOOTER]     := {||dbtabdFooter()}
VRLoc[VR_ROWFOOTER]  := 1
VRLoc[VR_BRKFOOTER]  := .T.

aFather := {}
aAdd( aFather , "dbdd" )
dfVrAddFle( aVirRec, aFather, VRLoc )

aBuffer := dfPrnCfg()                              // Inizializzazione

aBuffer[ REP_NAME ]  := dfStdMsg(MSG_DFTABPRINT03) //  Intestazione report
aBuffer[ REP_PH ]    := {|| PageHeader()   }       //  Header di pagina
//aBuffer[ REP_PF ]    := {|| PageFooter()   }       //  Footer di pagina

IF dfPrnMenu( aBuffer )  //  Configurazione con parametri di layout
   dfPrnStart( aVirRec )
ENDIF
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC PROCEDURE dbtabdHeader()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL cHead, cHead1, cHead2, nCampi, nLen
cHead  := "�"
cHead1 := "�"
cHead2 := "�"
FOR nCampi := 1 TO LEN(aTabStru)
   IF aTabStru[nCampi][1]==UPPER(ALLTRIM(dbdd->File_Name))
      nLen := MAX( LEN(aTabStru[nCampi][3]), aTabStru[nCampi][5])
      cHead  += "�" +REPLICATE("�",nLen )          +"穆"
      cHead1 += " " +PAD(aTabStru[nCampi][3],nLen) +" �"
      cHead2 += "�" +REPLICATE("�",nLen )          +"呐"
   ENDIF
NEXT
cHead  := LEFT(cHead ,LEN(cHead )-1) +"�"
cHead1 := LEFT(cHead1,LEN(cHead1)-1) +"�"
cHead2 := LEFT(cHead2,LEN(cHead2)-1) +"�"
dfPrint( 0, 0, dbdd->Field_Des )
dfPrint( 1, 0, cHead  )
dfPrint( 2, 0, cHead1 )
dfPrint( 3, 0, cHead2 )
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC PROCEDURE dbtabdBody()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL cRow, nCampi, nLen
cRow := "�"
FOR nCampi := 1 TO LEN(aTabStru)
   IF aTabStru[nCampi][1]==UPPER(ALLTRIM(dbdd->File_Name))
      nLen := MAX( LEN(aTabStru[nCampi][3]), aTabStru[nCampi][5])
      IF aTabStru[nCampi][8]==-1
         cRow += " " +PAD( SUBSTR(dbtabd->TabCode,1,aTabStru[nCampi][5]), nLen ) +" �"
      ELSE
         cRow += " " +PAD( SUBSTR( dbtabd->TabData,aTabStru[nCampi][8],aTabStru[nCampi][5]), nLen) +" �"
      ENDIF
   ENDIF
NEXT
dfPrint( 0, 0, cRow )
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC PROCEDURE dbtabdFooter()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL cFoot, nCampi, nLen
cFoot := "�"
FOR nCampi := 1 TO LEN(aTabStru)
   IF aTabStru[nCampi][1]==UPPER(ALLTRIM(dbdd->File_Name))
      nLen := MAX( LEN(aTabStru[nCampi][3]), aTabStru[nCampi][5])
      cFoot += "�" +REPLICATE("�",nLen) +"牧"
   ENDIF
NEXT
cFoot := LEFT(cFoot,LEN(cFoot)-1) +"�"
dfPrint( 0, 0, cFoot )
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC PROCEDURE PageHeader()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
dfPrint( 1, 0, dfStdMsg(MSG_DFTABPRINT03) )
dfPrint( 2, 0, REPLICATE("�", LEN(dfStdMsg(MSG_DFTABPRINT03)) ) )
RETURN

//* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
//STATIC PROCEDURE PageFooter()
//* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
//dfPrint( 1, 0, REPLICATE("�", LEN(dfStdMsg(MSG_DFTABPRINT03)) ) )
//RETURN
