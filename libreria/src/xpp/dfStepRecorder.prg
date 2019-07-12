#include "appevent.ch"
#include "common.ch"
#include "xbp.ch"
#include "gra.ch"
#include "dfStd.ch"

// simone 13/11/09
// mantis 0002109: abilitare step recorder tipo Windows 7 
//
// Gestione di un registratore simile a quello presente in Windows 7
// Esempio
// dfStepRecorderSetup(20, -1) // abilita memorizzazione 20 eventi
// dfStepRecorderSetup(20, "A_w") // abilita memorizzazione 20 eventi, ALT_W salva ora
// 




/*
#define xbeM_LbClick                   (013 + xbeB_Event)
#define xbeM_MbClick                   (014 + xbeB_Event)
#define xbeM_RbClick                   (015 + xbeB_Event)
#define xbeM_LbDblClick                (016 + xbeB_Event)
#define xbeM_MbDblClick                (017 + xbeB_Event)
#define xbeM_RbDblClick                (018 + xbeB_Event)
#define xbeM_Wheel                     (023 + xbeB_Event)
#define xbeP_Keyboard                  (004 + xbeB_Event)
*/

// opzioni
#define OPT_SEP           "-"

#define OPT_SAVE_AREAS    "-save_areas-"
#define OPT_SAVE_IMG_DISK "-save_img_disk-"
#define OPT_SAVE_IMG_MEM  "-save_img_mem-"

#define OPT_DEFAULT       (OPT_SAVE_AREAS + OPT_SAVE_IMG_MEM)


// array eventi da gestire
STATIC a2Log:=NIL
STATIC aEvents2Log:=NIL

// ultimo evento ricevuto
STATIC oLastXbp := NIL
STATIC nLastSec := 0
STATIC nLastThreadID := -1
STATIC nLastEvent:=-1

// logs attuali
STATIC aLogs:={}
STATIC nCurr:=0

STATIC nMax:=0 // n. max eventi da loggare

//STATIC nWriteKey:= xbeK_ALT_W // abilita il tasto ALT-W per salvare lo stato
STATIC nWriteKey:=  -1  // -1 = nessun tasto 
STATIC cOptions := OPT_DEFAULT  // opzioni

STATIC oAction

//INIT PROCEDURE dfEvent2LogInitProc()
//   dfEvent2LogInit()
//RETURN 

// Funzione di abilitazione/disabilitazione step recorder
// nSteps = numero step da salvare (0=disabilita)
// xWrKey = codice tasto per salvare immediatamente (-1=non salva)  
//          può essere stringa dell'azione 
//          (es. "wri" oppure numero azione da appevent.ch) 
// cOpt   = opzioni (da sommare) es "-save_img_disk-save_areas-"
//          "save_img_mem" = salva immagine in memoria
//          "save_img_disk"= salva immagine immediatamente su disco
//          "save_areas"   = salva areas
//
// by reference torna i dati esempio
// nSteps:= NIL 
// xWrKey:= NIL
// cOpt  := NIL
// dfStepRecorderSetup(@nSteps, @xWrKey, @cOpt)

FUNCTION dfStepRecorderSetup(nSteps, xWrKey, cOpt)
   
   DEFAULT nSteps TO nMax
   DEFAULT xWrKey TO nWriteKey
   DEFAULT cOpt   TO cOptions

   IF VALTYPE(xWrKey) $ "CM"
      xWrKey := dbAct2Ksc(xWrKey)
   ENDIF

   nWriteKey := xWrKey
   cOpt      := LOWER(ALLTRIM(cOpt))

   // aggiungo "-" iniziale e finale
   IF ! LEFT(cOpt, 1) == OPT_SEP
      cOpt := OPT_SEP+cOpt
   ENDIF

   IF ! RIGHT(cOpt, 1) == OPT_SEP
      cOpt += OPT_SEP
   ENDIF

   cOptions  := cOpt

   IF nSteps == nMax
      RETURN .T.
   ENDIF

   nCurr:=0

   nMax:=nSteps

   dfStepRecorderClear()

   // inizializzo array degli ultimi "nMax" eventi
   IF nMax > 0
      aLogs:=ARRAY(nMax)
         
      // eventi da "loggare"
      aEvents2Log:={}

      AADD(aEvents2Log, Event2Log_Keyboard())
      AADD(aEvents2Log, Event2Log_LbClick())
      AADD(aEvents2Log, Event2Log_LbDblClick())
      AADD(aEvents2Log, Event2Log_LbDown())
      AADD(aEvents2Log, Event2Log_RbClick())
      AADD(aEvents2Log, Event2Log_RbDblClick())
      AADD(aEvents2Log, Event2Log_RbDown())
      AADD(aEvents2Log, Event2Log_MbClick())
      AADD(aEvents2Log, Event2Log_MbDblClick())

      // calcolo gli ID eventi da loggare 
      a2Log:={}
      AEVAL(aEvents2Log, {|o| AADD(a2Log, o:nEventID)} )

      // azione per cancellare eventuali files su disco
      // alla chiusura applicazione
      IF oAction == NIL
         oAction := dfExecuteAction():new({||EraseScreenImage()})
         dfXbaseExitProcAdd(oAction)
      ENDIF

   ELSE
      aLogs:={}
      aEvents2Log:=NIL
      a2Log:=NIL
   ENDIF
RETURN .T.

// disattivo salvataggio immagini e cancello files
STATIC FUNCTION EraseScreenImage()
   dfStepRecorderSetup(0) 
RETURN .T.

FUNCTION dfStepRecorderEnabled()
RETURN nMax > 0

// salva un evento nella lista ultimi eventi
FUNCTION dfStepRecorderLog(nEvent, mp1, mp2, oXbp)
   LOCAL nPos
   LOCAL oLog
   LOCAL cFile

   IF nMax <=0 .OR. a2Log==NIL .OR. EMPTY(nEvent) .OR. nEvent==xbe_None
      RETURN .F.
   ENDIF

   // Š un evento da loggare?
   nPos:= ASCAN(a2Log, nEvent)
   IF nPos == 0
      RETURN .F.
   ENDIF


   // gestione tasto nWriteKey per creare il file
   IF nEvent == xbeP_Keyboard .AND. mp1==nWriteKey 
      cFile:=dfExePath()
      FCLOSE(dfFileTemp(@cFile, "step", NIL, ".zip"))
      FERASE(cFile)
      dfWaitOn("Creazione file step recorder in corso...")
      dfStepRecorderSave(cFile)
      dfWaitOff()
      dfAlert("Creato file "+cFile)
      RETURN .F.
   ENDIF

   oLog := NIL
   // se Š un evento di tastiera guardo se devo aggiornare
   // in modo se ad esempio l'utente scrive una stringa da salvare 
   // tutto in un solo evento
   IF nLastThreadID == ThreadID()   .AND. ;
      oXbp == oLastXbp        

      IF nEvent == xbeP_Keyboard .AND. ;
         SECONDS() -nLastSec < 3 //.AND. ; // entro 3 secondi 
         //mp1 >=32 .AND. mp1 <= 128

         oLog := aLogs[nCurr]

      ELSEIF nEvent == xbeM_LbClick .AND. nLastEvent==xbeM_LbDown
         oLog := aLogs[nCurr]

      ELSEIF nEvent == xbeM_RbClick .AND. nLastEvent==xbeM_RbDown
         oLog := aLogs[nCurr]
      ENDIF
   ENDIF

   IF oLog == NIL
      // aggiungo un evento
      oLog := aEvents2Log[nPos]:new(mp1, mp2, oXbp)
      IF ++nCurr > nMax
         nCurr := 1
      ENDIF
      IF ! EMPTY(aLogs[nCurr])
         aLogs[nCurr]:destroy()
      ENDIF
      aLogs[nCurr] := oLog
   ELSE
      oLog:update(mp1, mp2, oXbp)
   ENDIF

   nLastThreadID:=ThreadID()
   nLastSec:=SECONDS()
   nLastEvent := nEvent
   oLastXbp:=oXbp
   
RETURN .T.

// azzera la coda
FUNCTION dfStepRecorderClear()

   AEVAL(aLogs, {|x| IIF(EMPTY(x), NIL, x:destroy())})
   aLogs:=ARRAY(nMax)
   nCurr:=0

   oLastXbp := NIL
   nLastSec := 0
   nLastThreadID := -1
   nLastEvent:=-1
RETURN .T.

// creo un file ZIP contenente HTML e immagini
// nella coda
FUNCTION dfStepRecorderSave(cFile)
   LOCAL nH, cTxt
   LOCAL nInd
   LOCAL nStep
   LOCAL cImg, xImg
   LOCAL cPath
   LOCAL nPrevSec
   LOCAL nRet:=0
   LOCAL aFiles:={}
   LOCAL cTmp
   LOCAL lOk

   IF nCurr==0
      RETURN -2
   ENDIF

   cPath := dfPathTemp()
   IF EMPTY(cPath)
      RETURN -1
   ENDIF
   //cPath:=dfFnameSplit(cFile, 1+2)

   nH:=FCREATE(cPath+"step_recorder.html")


   AADD(aFiles, "step_recorder.html")

   TEXT INTO cTxt WRAP
        <head>
           <script type="text/javascript">
            //ora in base al browser utilizzo le propriet… corrette di visibilit…
            function shoh(id) {

                if (document.getElementById) { // DOM3 = IE5+, NS6+, FF
                    if (document.getElementById(id).style.display == "none"){
                        document.getElementById(id).style.display = 'block';
                    } else {
                        document.getElementById(id).style.display = 'none';
                    }
                } else {
                    if (document.layers) { // NS4.7
                        if (document.id.display == "none"){
                            document.id.display = 'block';
                        } else {
                            document.id.display = 'none';
                        }
                    } else { //IE 4
                        if (document.all.id.style.visibility == "none"){
                            document.all.id.style.display = 'block';
                        } else {
                            document.all.id.style.display = 'none';
                        }
                    }
                }
            }
           </script>
        </head>
   ENDTEXT
   cTxt:="<html>"+cTxt+"<body><table><ol>"

   FWRITE(nH, cTxt)

   nInd:=nCurr
   nStep:=0
   nPrevSec:=NIL
   DO WHILE .T.
      IF ++nInd>nMax
         nInd := 1
      ENDIF

      IF ! EMPTY(aLogs[nInd])
         cTxt:=""
         IF ! EMPTY(nPrevSec)
            IF nPrevSec > aLogs[nInd]:nSeconds
               nPrevSec -= 86400
            ENDIF
            cTxt := ALLTRIM(STR(aLogs[nInd]:nSeconds - nPrevSec))
            cTxt := "(+"+cTxt+" sec.) "
         ENDIF
         nPrevSec := aLogs[nInd]:nSeconds
         cTxt:="<li><b>"+cTxt+ConvToAnsiCP(aLogs[nInd]:log())+"</b></li>"
         FWRITE(nH, cTxt)

         nStep++

         IF ! EMPTY(aLogs[nInd]:cAreas)

           cTmp:=aLogs[nInd]:cAreas
           cTmp:=dfStr2Ascii(cTmp)
           cTmp:=ConvToAnsiCP( dfStr2Xml(cTmp, 0) )
           //cTmp:=STRTRAN(cTmp, CRLF, "<br />"+CRLF) non importa c'è il <pre>

           TEXT INTO cTxt WRAP
             <a href="#" onclick="shoh('%id%');">Mostra/Nascondi Areas</a><br></li>
             <div style="display: none;" id="%id%"><pre>
             %areas%
             </pre></div>
           ENDTEXT

           cTxt:=STRTRAN(cTxt, "%id%", "step_"+ALLTRIM(STR(nStep)))
           cTxt:=STRTRAN(cTxt, "%areas%", cTmp)

/*
           cTxt := [<a href="#" onclick="shoh('step_%n%');">Mostra/Nascondi Areas</a>]
           cTxt:=STRTRAN(cTxt, "%n%", ALLTRIM(STR(nStep)))
           FWRITE(nH, cTxt)

           cTxt:='<div style="display: none;" id="step_%n%"><pre>'
           cTxt:=STRTRAN(cTxt, "%n%", ALLTRIM(STR(nStep)))
           FWRITE(nH, cTxt)

           cTxt:=aLogs[nInd]:cAreas
           cTxt:=dfStr2Ascii(cTxt)
           cTxt:=ConvToAnsiCP( dfStr2Xml(cTxt) )
           cTxt:=STRTRAN(cTxt, CRLF, "<br />"+CRLF)
           FWRITE(nH, cTxt)

           cTxt:= '</pre></div>'
           FWRITE(nH, cTxt)
*/
           
           FWRITE(nH, cTxt)
         ENDIF
         xImg:= aLogs[nInd]:xImg
         IF ! EMPTY(xImg) //.AND. ! EMPTY(xImg[1])
            cImg := "step_"+ALLTRIM(STR(nStep))+".jpg"
            IF VALTYPE(xImg) $ "CM"
               lOk := dfFileCopy(xImg, cPath+cImg, .F., .T.)
            ELSE
               lOk := xImg:saveFile(cPath+cImg, XBPBMP_FORMAT_JPG, 60)
            ENDIF
            IF lOk
               AADD(aFiles, cImg)

               cTxt:='<br /><a href="%img%"><img src="%img%" alt="step %n%" width=420/></a><p />'
               cTxt:= STRTRAN(cTxt, "%img%", cImg)
               cTxt:= STRTRAN(cTxt, "%n%", ALLTRIM(STR(nStep)))
               FWRITE(nH, cTxt)
            ENDIF
         ENDIF
      ENDIF

      IF nInd==nCurr
         EXIT
      ENDIF
   ENDDO
   cTxt:="</ol></body></html>"
   FWRITE(nH, cTxt)
   FCLOSE(nH)
   nRet:=dfZipFile(cFile, cPath, NIL, "*.*", NIL, NIL, .T., 0)
   AEVAL(aFiles, {|x|FERASE(cPath+x)})
   dfRd(cPath)
RETURN nRet


// classe base contenente i dati di UN log
*****************************************************************
STATIC CLASS Event2Log
*****************************************************************
PROTECTED:
    DEFERRED METHOD saveXbpRef
    METHOD logStd
    METHOD getScreenImage
    METHOD saveScreenImage

EXPORTED:
    CLASS VAR nEventID
    CLASS METHOD getXbpRef
    VAR threadID
    VAR dDate
    VAR cTime
    VAR nSeconds
    VAR xImg
    VAR aDBstatus
    VAR cLog
    VAR cAreas

    VAR mp1
    VAR mp2
    VAR Xbp_ref // non memorizzo riferimento a oXbp solo ma una stringa o array di stringhe,
                // per non avere troppi dati e riferimenti a oggetti in memoria

    CLASS METHOD InitClass
    METHOD Init
    METHOD save
    METHOD update
    METHOD destroy
    METHOD destroyImage

    METHOD Log
ENDCLASS

CLASS METHOD Event2Log:initclass()
  ::nEventID := NIL // da definire in sottoclassi
RETURN self

METHOD Event2Log:init(mp1, mp2, oXbp)
   ::save(mp1, mp2, oXbp)
RETURN self

METHOD Event2Log:save(mp1, mp2, oXbp)
   LOCAL xImg, cImg

   ::threadID := ThreadID()
   ::dDate := DATE()
   ::cTime := dfTimeStd()
   ::nSeconds := SECONDS()

   IF OPT_SAVE_AREAS $ cOptions
      ::cAreas := dfAreasInspect()
   ENDIF

   ::saveXbpRef(mp1, mp2, oXbp)

   // elimino immagine precedente
   ::destroyImage()

   IF OPT_SAVE_IMG_MEM $ cOptions .OR. OPT_SAVE_IMG_DISK $ cOptions
      xImg := ::getScreenImage(oXbp)
      IF OPT_SAVE_IMG_DISK $ cOptions
         cImg := ::saveScreenImage(xImg)
         IF ! EMPTY(cImg)
            // se creato il file JPG, libero la memoria
            xImg:destroy()
            xImg := cImg
         ENDIF
      ENDIF
      ::xImg := xImg
   ENDIF
RETURN self

METHOD Event2Log:update(mp1, mp2, oXbp)
RETURN self

METHOD Event2Log:saveScreenImage(xImg)
   LOCAL cFile

   IF ! VALTYPE(xImg)=="O"
      RETURN xImg
   ENDIF

   cFile:=NIL
   FCLOSE(dfFileTemp(@cFile, "step", NIL, ".jpg"))
   FERASE(cFile)

   IF ! EMPTY(cFile) .AND. ;
      xImg:saveFile(cFile, XBPBMP_FORMAT_JPG, 60)

   ELSE
      cFile := NIL
   ENDIF
RETURN cFile


METHOD Event2Log:getScreenImage(oXbp)
   LOCAL aPos
   LOCAL aEnd
   LOCAL aBmp
   LOCAL oPS
   LOCAL aAttr
   LOCAL xImg

   aBmp := dfXbp2Bitmap(Appdesktop()) //dfScreenCapture()

   // disegna un quadrato intorno all'oggetto selezionato
   IF ! EMPTY(oXbp)
      aPos := oXbp:currentPos()
      aPos := dfCalcAbsolutePosition(aPos,oXbp:setParent())
      aEnd := oXbp:currentsize()
      aEnd[1]+=aPos[1]+8
      aEnd[2]+=aPos[2]+8
      oPS:=aBmp[1]:presSpace()
      //GraFocusRect(oPS, aPos, aEnd)

      aAttr := Array( GRA_AL_COUNT )      // determine fill attributes 
      aAttr [ GRA_AL_COLOR] := GRA_CLR_YELLOW
      aAttr [ GRA_AL_WIDTH] := 4
      GraSetAttrLine( oPS, aAttr ) 
      GraBox( oPS, aPos, aEnd, GRA_OUTLINE) 
   ENDIF

   IF VALTYPE(aBmp)=="A"
      xImg := aBmp[1] //:setFormat()
   ENDIF
RETURN xImg

METHOD Event2Log:destroy()
   ::destroyImage()
RETURN self

METHOD Event2Log:destroyImage()
   IF ! EMPTY(::xImg)
      IF VALTYPE(::xImg)=="O"
//      ::xImg[2]:unlockPS()
         ::xImg:destroy()
      ELSE
         FERASE(::xImg)
      ENDIF
      ::xImg:=NIL
   ENDIF
RETURN self

CLASS METHOD Event2Log:getXbpRef(oXbp)
   LOCAL cVar := ""
   IF IsMethod( oXbp, "getTitle" ) .AND. ! EMPTY(oXbp:getTitle())
      cVar += " "+VAR2CHAR(oXbp:getTitle())
   ENDIF
   IF isMembervar(oXbp, "caption") .AND. ! EMPTY(oXbp:caption)
      cVar += " "+VAR2CHAR(oXbp:caption)
   ENDIF
   IF isMembervar(oXbp, "varname") .AND. ! EMPTY(oXbp:varname)
      cVar += " "+VAR2CHAR(oXbp:varname)
   ENDIF
RETURN SUBSTR(cVar, 2)

METHOD Event2Log:logStd()
   LOCAL cRet:= PAD(ALLTRIM(STR(::threadID)), 3)+" "+DTOC(::dDate)+" "+::cTime+"> "
RETURN cRet

METHOD Event2Log:log()
   LOCAL cRet:= ::logStd()+VAR2CHAR(::Xbp_ref)+"-"+VAR2CHAR(::mp1)+","+VAR2CHAR(::mp2)
RETURN cRet


// gestisce un LOG per evento di tastiera
*****************************************************************
STATIC CLASS Event2Log_Keyboard FROM Event2Log
*****************************************************************
PROTECTED:
    METHOD saveXbpRef

    VAR lWriteMode
EXPORTED:
//    METHOD init
    CLASS METHOD initClass
    METHOD update
    METHOD log
ENDCLASS

CLASS METHOD Event2Log_Keyboard:initclass()
   ::nEventID := xbeP_Keyboard
RETURN self

//METHOD Event2Log_keyboard:init(mp1, mp2, oXbp)
//  ::event2Log:init(mp1, mp2, oXbp)
// RETURN self

METHOD Event2Log_Keyboard:update(mp1, mp2, oXbp)
   LOCAL aKeyTable, nPos

::lWriteMode:=.T.

   IF VALTYPE(mp1)=="N"
       IF mp1 >=32 .AND. mp1 <= 128

          DEFAULT ::lWriteMode TO .T.

          mp1:=CHR(mp1)
       ELSE
          DEFAULT ::lWriteMode TO .F.

          aKeyTable := dbGetKeyTable()
          nPos := ASCAN(aKeyTable, mp1)
          IF nPos > 0 .AND. ! EMPTY(aKeyTable[nPos][3])
             mp1:= "{"+aKeyTable[nPos][3]+"}"
          ELSE
             mp1:= "{"+ALLTRIM(STR(mp1))+"}"
          ENDIF
       ENDIF
   ELSE
      mp1 := VAR2CHAR(mp1)
   ENDIF
//   IF ! VALTYPE(mp2)=="N"
//      mp2 := VAR2CHAR(mp2)
//   ENDIF
   AADD(::mp1, mp1)
   //AADD(::mp2, mp2)
RETURN .T.

METHOD Event2Log_Keyboard:saveXbpRef(mp1, mp2, oXbp)
    LOCAL cLog, cVar
    ::mp1:={}
    //::mp2:={}

    cVar:=""
    IF EMPTY(oXbp)
       cVar := "(unknown xbp)"
       ::Xbp_Ref := {cVar, cVar, {0, 0}, {0, 0}}
    ELSE
       cVar:=::getXbpRef(oXbp)
       ::Xbp_Ref := {oXbp:className(), cVar, oXbp:currentPos(), oXbp:currentSize()}
    ENDIF

    ::Xbp_Ref := {oXbp:className(), cVar, oXbp:currentPos(), oXbp:currentSize()}
    ::update(mp1, mp2, oXbp)
RETURN self

METHOD Event2Log_Keyboard:log()
   LOCAL cRet:= ::logStd()
   IF EMPTY(::lWriteMode) .OR. LEN(::mp1) == 1
      cRet+="press key "+::mp1[1]
   ELSE
      cRet+="write text ["
      AEVAL(::mp1, {|x|cRet+=x})
      cRet+="]"
   ENDIF
   cRet += " on "+::Xbp_Ref[2]
RETURN cRet


// BASE per gestione LOG per evento CLICK del mouse
*****************************************************************
STATIC CLASS Event2Log_MouseClick FROM Event2Log
*****************************************************************
PROTECTED:
    METHOD saveXbpRef

EXPORTED:
//    METHOD init
    METHOD getScreenImage
    METHOD update
ENDCLASS

METHOD Event2Log_MouseClick:update(mp1, mp2, oXbp)
   ::save(mp1, mp2, oXbp)
RETURN self

METHOD Event2Log_MouseClick:saveXbpRef(mp1, mp2, oXbp)
    LOCAL cLog, cVar
    ::mp1:=mp1
    //::mp2:=mp2
    cVar:=""
    IF EMPTY(oXbp)
       cVar := "(unknown xbp)"
       ::Xbp_Ref := {cVar, cVar, {0, 0}, {0, 0}}
    ELSE
       cVar:=::getXbpRef(oXbp)
       ::Xbp_Ref := {oXbp:className(), cVar, oXbp:currentPos(), oXbp:currentSize()}
    ENDIF

    ::mp1:=mp1 
RETURN self

METHOD Event2Log_MouseClick:getScreenImage(oXbp, nMode, nClr)
   LOCAL aBmp
   LOCAL aAttr
   LOCAL aPos
   LOCAL oPS
   LOCAL xImg

   DEFAULT nClr TO GRA_CLR_BLACK

   xImg := ::Event2Log:getScreenImage(oXbp)

   IF ! EMPTY(xImg)
      // aggiungo "crocina" dove c'è il puntatore
      aPos:=dfGetMousePos( AppDesktop(), .T.)

      oPS:=xImg:presSpace()
      //GraFocusRect(oPS, aPos, aEnd)

      aAttr := Array( GRA_AM_COUNT )      // determine fill attributes 
      aAttr [ GRA_AM_COLOR] := nClr
      aAttr [ GRA_AM_SYMBOL] := GRA_MARKSYM_SIXPOINTSTAR
      GraSetAttrMarker( oPS, aAttr ) 
      GraMarker( oPS, aPos) 
      IF ! EMPTY(nMode) // doppio click
         aPos[1]+=3
         aPos[2]-=3
         GraMarker( oPS, aPos) 
      ENDIF
   ENDIF
RETURN xImg


// gestisce un LOG per evento CLICK sinistro del mouse
*****************************************************************
STATIC CLASS Event2Log_LbClick FROM Event2Log_MouseClick
*****************************************************************
EXPORTED:
   CLASS METHOD initClass
   METHOD log
ENDCLASS

CLASS METHOD Event2Log_LbClick:initclass()
   ::nEventID := xbeM_LbClick
RETURN self

METHOD Event2Log_LbClick:log()
   LOCAL cRet:= ::logStd()
   cRet+="click left on "+::Xbp_Ref[2]
RETURN cRet



// gestisce un LOG per evento DOPPIO CLICK sinistro del mouse
*****************************************************************
STATIC CLASS Event2Log_LbDblClick FROM Event2Log_MouseClick
*****************************************************************
EXPORTED:
    CLASS METHOD initClass
    METHOD log
    METHOD getScreenImage
ENDCLASS

CLASS METHOD Event2Log_LbDblClick:initclass()
   ::nEventID := xbeM_LbDblClick
RETURN self

METHOD Event2Log_LbDblClick:log()
   LOCAL cRet:= ::logStd()
   cRet+="double click left on "+::Xbp_Ref[2]
RETURN cRet

METHOD Event2Log_LbDblClick:getScreenImage(oXbp, nMode)
RETURN ::Event2Log_MouseClick:getScreenImage(oXbp, 2)


// gestisce un LOG per evento mouse down sinistro del mouse
*****************************************************************
STATIC CLASS Event2Log_LbDown FROM Event2Log_MouseClick
*****************************************************************
EXPORTED:
    CLASS METHOD initClass
    METHOD log
ENDCLASS

CLASS METHOD Event2Log_LbDown:initclass()
   ::nEventID := xbeM_LbDown
RETURN self

METHOD Event2Log_LbDown:log()
   LOCAL cRet:= ::logStd()
   cRet+="left mouse down on "+::Xbp_Ref[2]
RETURN cRet



// gestisce un LOG per evento CLICK destro del mouse
*****************************************************************
STATIC CLASS Event2Log_RbClick FROM Event2Log_MouseClick
*****************************************************************
EXPORTED:
    CLASS METHOD initClass
    METHOD log
    METHOD getScreenImage
ENDCLASS

CLASS METHOD Event2Log_RbClick:initclass()
   ::nEventID := xbeM_RbClick
RETURN self

METHOD Event2Log_RbClick:log()
   LOCAL cRet:= ::logStd()
   cRet+="click right on "+::Xbp_Ref[2]
RETURN cRet

METHOD Event2Log_RbClick:getScreenImage(oXbp)
RETURN ::Event2Log_MouseClick:getScreenImage(oXbp, 0, GRA_CLR_RED)

// gestisce un LOG per evento DOPPIO CLICK destro del mouse
*****************************************************************
STATIC CLASS Event2Log_RbDblClick FROM Event2Log_MouseClick
*****************************************************************
EXPORTED:
    CLASS METHOD initClass
    METHOD log
    METHOD getScreenImage
ENDCLASS

CLASS METHOD Event2Log_RbDblClick:initclass()
   ::nEventID := xbeM_RbDblClick
RETURN self

METHOD Event2Log_RbDblClick:log()
   LOCAL cRet:= ::logStd()
   cRet+="double click right on "+::Xbp_Ref[2]
RETURN cRet

METHOD Event2Log_RbDblClick:getScreenImage(oXbp, nMode)
RETURN ::Event2Log_MouseClick:getScreenImage(oXbp, 2, GRA_CLR_RED)

// gestisce un LOG per evento mouse down sinistro del mouse
*****************************************************************
STATIC CLASS Event2Log_RbDown FROM Event2Log_RbClick
*****************************************************************
EXPORTED:
    CLASS METHOD initClass
    METHOD log
ENDCLASS

CLASS METHOD Event2Log_RbDown:initclass()
   ::nEventID := xbeM_RbDown
RETURN self

METHOD Event2Log_RbDown:log()
   LOCAL cRet:= ::logStd()
   cRet+="right mouse down on "+::Xbp_Ref[2]
RETURN cRet



// gestisce un LOG per evento CLICK medio del mouse
*****************************************************************
STATIC CLASS Event2Log_MbClick FROM Event2Log_MouseClick
*****************************************************************
EXPORTED:
    CLASS METHOD initClass
    METHOD log
    METHOD getScreenImage
ENDCLASS

CLASS METHOD Event2Log_MbClick:initclass()
   ::nEventID := xbeM_MbClick
RETURN self

METHOD Event2Log_MbClick:log()
   LOCAL cRet:= ::logStd()
   cRet+="click middle on "+::Xbp_Ref[2]
RETURN cRet

METHOD Event2Log_MbClick:getScreenImage(oXbp)
RETURN ::Event2Log_MouseClick:getScreenImage(oXbp, 0, GRA_CLR_BLUE)

// gestisce un LOG per evento DOPPIO CLICK medio del mouse
*****************************************************************
STATIC CLASS Event2Log_MbDblClick FROM Event2Log_MouseClick
*****************************************************************
EXPORTED:
    CLASS METHOD initClass
    METHOD log
    METHOD getScreenImage
ENDCLASS

CLASS METHOD Event2Log_MbDblClick:initclass()
   ::nEventID := xbeM_MbDblClick
RETURN self

METHOD Event2Log_MbDblClick:log()
   LOCAL cRet:= ::logStd()
   cRet+="double click middle on "+::Xbp_Ref[2]
RETURN cRet

METHOD Event2Log_MbDblClick:getScreenImage(oXbp, nMode)
RETURN ::Event2Log_MouseClick:getScreenImage(oXbp, 2, GRA_CLR_BLUE)
