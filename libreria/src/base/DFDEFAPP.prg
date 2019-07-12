//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per APP
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfSet.ch"
#INCLUDE "dfCtrl.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDefApp() // Inizializzazione Applicazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aApp

aApp := ARRAY( AI_LEN )         // Inizializzo Array
aApp[AI_USERLEVEL]              := 99
aApp[AI_USERNAME]               := ""
aApp[AI_ZOOMBOX]                := 50
aApp[AI_ZOOMSOUND]              :=  0
aApp[AI_INDEXPACK]              := .F.
aApp[AI_NET]                    := .F.
aApp[AI_LOCKREPEATTIME]         := 60
aApp[AI_MOUSE]                  := .T.
aApp[AI_TABNAME]                := "dbTabD"
aApp[AI_TABINDEX1]              := aApp[AI_TABNAME] +"1"
aApp[AI_TABMODIFY]              := .T.
aApp[AI_GETTIMEOUT]             := 60
aApp[AI_GETWARNING]             := 20
aApp[AI_USEGETTIMEOUT]          := .F.
aApp[AI_CONSOLELINES]           := 0
aApp[AI_SHADOWCOLOR]            := "N+/N"
aApp[AI_DEFAULTPRINTER]         := "107"
aApp[AI_DEFAULTPORT]            := "lpt1"
aApp[AI_OBJECTOFFCOLOR]         := "W/B"
aApp[AI_INIVERSION]             := "4.0"       // Forza l'errore su ini vecchi
aApp[AI_CLEARSCREEN]            := .T.
aApp[AI_FONTREDEFINITION]       := .T.
aApp[AI_SCREENCOLOR]            := "G/B"
aApp[AI_INIMESSAGE]             := .T.
aApp[AI_ALTF4ISACTIVE]          := .T.
aApp[AI_SCRSAVERACTIVE]         := .T.
aApp[AI_SCRSAVERTIME]           := 300
aApp[AI_FASTMENUALT]            := .T.

// Non gestiti da INI
aApp[AI_FILEMODIFY]             := .T.
aApp[AI_USRICON]                := .T.
aApp[AI_USRSTATE]               := .T.
aApp[AI_FASTMENUEXIT]           := .F.
aApp[AI_FASTDISPLAY]            := .T.
aApp[AI_ERRORINWINDOW]          := .T.
aApp[AI_GETCHECKUAR]            := .F.
aApp[AI_IFNOKEYREPEATGET]       := .F.
aApp[AI_GOTOWINAFTERRETURN]     := .F.
aApp[AI_MENUSCREENFILL]         := NIL
aApp[AI_MENUSCREENCOLOR]        := NIL
aApp[AI_DISABLEKEYINDEX]        := .F.
aApp[AI_FILTEROPTIMIZER]        := .T.
aApp[AI_DDKEYMESSAGE]           := ""
aApp[AI_AS400INIT]              := .T.
aApp[AI_FILEINSERTCB]           := {||.T.}
aApp[AI_TABLEINSERTCB]          := {||.T.}
aApp[AI_CALCULATORGET]          := .F.
aApp[AI_LOGFILE]                := dfExePath()+"dbStart.log"

aApp[AI_NULLIFY_CHAR   ]        := ""//"±"
aApp[AI_NULLIFY_DATE   ]        := CTOD("01/01/80")
aApp[AI_NULLIFY_LOGICAL]        := .F.
aApp[AI_NULLIFY_NUMERIC]        := 0

aApp[AI_FORMCHECKESC]           := .T.

#ifdef __XPP__
aApp[AI_MAXMEM]                 := .T.
#else
aApp[AI_MAXMEM]                 := .F.
#endif

aApp[AI_ENABLESEARCHKEY]        := .F.

aApp[AI_DISABLEUSEMESSAGE]      := .F.

aApp[AI_AUTOMATICCOMPOUND]      := .F.

aApp[AI_FORTRESSINIT]           := .T.

aApp[AI_AS400DISABLECLOSE]      := .F.

aApp[AI_BUTDISABLEDPROMPT]      := "W+/N"
aApp[AI_BUTDISABLEDHOTKET]      := "W+/N"

aApp[AI_ENABLEUSERTRACE]        := .F.

aApp[AI_WINDOWINFO]             := dfIsDebug() // Allow info in debug mode

aApp[AI_INDEXPROGRESSBAR]       := .F.

aApp[AI_DISABLENOTHINGTOPRINT]  := .F.

aApp[AI_WIN95INTERFACE]         := .F.

aApp[AI_DATEMESSAGE]            := .F.

aApp[AI_DISABLELABELPRINT]      := .F.

aApp[AI_DISABLEALLCLOSE]        := .F.

aApp[AI_DISABLEPRINTERSAVE]     := .F.

aApp[AI_LOGMESSAGE]             := NIL

aApp[AI_DISABLEMGNOPT]          := .F.

aApp[AI_IDLETIME]               := 0

aApp[AI_HIDEMENUITEM]           := .F.

aApp[AI_DISABLEKEYOPT]          := .F.

aApp[AI_TABLECHECKCB]           := {||.T.}

aApp[AI_DISABLEREPORTFILTER]    := .F.

aApp[AI_EDITCELLCB]             := {||.T.}

aApp[AI_50ROWFORM]              := .F.

aApp[AI_UPDCREATEBAK]           := .T.

aApp[AI_MULTILINEBUTTON]        := .T.

aApp[AI_DISABLESTATISTIC]       := .F.

aApp[AI_PROGRAMMINGHELP]        := .F.

aApp[AI_TABLEFILTER]            := {||.T.}

aApp[AI_EXACTKEYFOUND]          := .F.

aApp[AI_CRIPTKEY]               := "ISA2000"

aApp[AI_EXITAPPS]               := .F.

aApp[AI_EXITAPPSTIME]           := 60

aApp[AI_BUTPRESSED]             := .F.

aApp[AI_EUROENABLED]            := .T.
aApp[AI_EUROCHANGE]             := 1936.27
#ifdef __XPP__
aApp[AI_EUROCHAR]               := 213   // se usa ANSI invece di OEM 
                                         // allora e' il 128
#else
aApp[AI_EUROCHAR]               := 128
#endif

// Il primo elemento Š il carattere per attivare la conversione
// il secondo Š la stringa da mettere sul pulsante
aApp[AI_CALCULATORBTN2EURO]     := {"e", "L->"+dfHot()+CHR(aApp[AI_EUROCHAR])}
aApp[AI_CALCULATORBTN2BASE]     := {"l", CHR(aApp[AI_EUROCHAR])+"->"+dfHot()+"L"}

// Solo per ALASKA
aApp[AI_XBASEMESSAGECENTERED]   := .T.

aApp[AI_PACKCODEBLOCK]          := {||.T.}

aApp[AI_XBASEREFRESH]           := .F.

aApp[AI_XBASEFRAMESCROLL]       := .F.

aApp[AI_REPUSEPAGELENGHT]       := .F.

aApp[AI_LOGUSEDFORM]            := .F.

aApp[AI_XBASEDOSCOMPATIBLE]     := .T.

aApp[AI_OPENFILECB]             := NIL

aApp[AI_CLOSEFILECB]            := NIL

aApp[AI_ERRORCB]                := NIL

aApp[AI_LOOKAUTOWIN]            := .F.

// Controllo sul size del DBT, se il size Š superati, vi Š un blocco
// all'apertura del file.

#ifdef __XPP__
aApp[AI_DBTMAXSIZE]             := 0 // Disabilito
#else
aApp[AI_DBTMAXSIZE]             := 30 * 1024 * 1024 // 30MB
#endif

aApp[AI_XBASEPRNMENUNEW]        := .F.

aApp[AI_CHECKMODE]              := NIL

aApp[AI_DOSPRINTDIRECT]         := .F.

aApp[AI_NEWLABEL]               := .F.

aApp[AI_FASTSEEKTIMEOUT]        := 3         // Tempo di timeout su tbFastseek

aApp[AI_XBASEPRINTFONT]         := AI_PRINTFONT_PRINTER

aApp[AI_XBASECOLORMODE]         := AI_COLORMODE_STD

aApp[AI_XBASEDDKEYMODE]         := AI_DDKEYMODE_STD

aApp[AI_XBASEDISABLEPDFPRINT]   := .F.

aApp[AI_SAVEFILTERONUSE     ]   := .F.

aApp[AI_SAVEFILTERONPUSHAREA]   := .F.

aApp[AI_DISABLEFASTSEEK]        := .F.  // fast seek disabilitata

aApp[AI_FASTSEEKVALIDKEY]       := NIL  // codeblock o stringa per validazione tasto

aApp[AI_XBASETOOLBARADDTOP]     := .F.  // abilita aggiunta azioni top/bottom nella toolbar
//Mantis 650
aApp[AI_XBASEREPORTMANTMPFILE]  :=  AI_REPORTMANAGER_TEMPFILE_DBF

//simone 7/7/05
// Mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
aApp[AI_XBASEFORMSCROLL]        :=  AI_FORMSCROLL_DISABLED

// Simone 8/7/05
// mantis 0000807: aggiungere possibilit… di avere sempre attivo il menu principale delle app. generate
aApp[AI_XBASEMAINMENUMDI]       :=  AI_MENUMDI_DISABLED

// Simone 7/7/05
// mantis 0000760: abilitare nuovi stili per i controls
aApp[AI_XBASEWAITSTYLE]         :=  AI_WAITSTYLE_STD         
aApp[AI_XBASEMSGSTYLE]          :=  AI_MSGSTYLE_STD
aApp[AI_XBASEALERTSTYLE]        :=  AI_ALERTSTYLE_STD
aApp[AI_XBASEALERTICONS]        :=  AI_ALERTICONS_STD
aApp[AI_XBASETOOLBARSTYLE]      :=  AI_TOOLBARSTYLE_STD
aApp[AI_XBASETOOLBAROPTIONS]    :=  {} // array di opzioni, tipo Presentation Parameters di Xbase++
                                       // dfSet(AI_XBASETOOLBAROPTIONS, {{AI_XBASETBRIGHT_WIDTH, 60}})
aApp[AI_XBASESTATUSLINESTYLE]   :=  AI_STATUSLINESTYLE_STD
aApp[AI_XBASEMULTIPAGESTYLE]    :=  AI_MULTIPAGESTYLE_STD

aApp[AI_XBASEGETSTYLE]          :=  GET_PS_STD
aApp[AI_XBASEBUTSTYLE]          :=  BUT_PS_STD
aApp[AI_XBASEGRPBOXSTYLE]       :=  BOX_PS_STD
aApp[AI_XBASELSBBOXSTYLE]       :=  BOX_PS_STD
aApp[AI_XBASETXTBOXSTYLE]       :=  BOX_PS_STD
aApp[AI_XBASECHKSTYLE]          :=  CHK_PS_STD
aApp[AI_XBASERADSTYLE]          :=  RAD_PS_STD

aApp[AI_XBASESTDFUNCTIONS]      :=  {} // array di funzioni standard usate in visual dbsee
                                       // dfSet(AI_XBASESTDFUNCTIONS, {{AI_STDFUNC_DDKEY,  {|a, b, c, d| myDDKey(a, b, c, d)) }}})

// Simone 14/6/06 mantis 0001082: abilitare impostazione generale per disabilitare inserimento da lookup
aApp[AI_LOOKINSERTCB]           := {|| .T. }
aApp[AI_TBSETKEYTOP]            := .T. 

// Simone 25/7/06
// mantis 0001094: Se in un una form multipagina sull prima p non ho nessun campo in Get 
aApp[AI_MULTIPAGE_FIND_CTRL]    := .F.

// Simone 29/3/07
// mantis 0001215: se la struttura di un indice Š troppo lunga in creazione indice si possono avere errori runtime o indici errati
aApp[AI_INDEXSTRUCTDYN]         := .T.

aApp[AI_XBASEPROGRESSSTYLE]     := AI_PROGRESSSTYLE_STD

aApp[AI_XBASEPRINTPROGRESSSTYLE]:= AI_PRINTPROGRESSSTYLE_STD

aApp[AI_XBASEINDEXWAITSTYLE]    := AI_INDEXWAITSTYLE_STD
//aApp[AI_NETWORKCB]              := NIL

// Simone 28/5/08
// mantis 0001865: Ingrandendo Browser o Form con listbxo le colonne non si adattano allo spazio disponibile. Effetto grafico sgradevole.
// gestire il resize delle colonne dei browse
aApp[AI_XBASEBRWAUTOFITCOLUMNS] := AI_BRWAUTOFITCOLUMNS_NO

// simone 28/5/08
// mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
aApp[AI_XBASEDISABLEDGETCOPY]   := AI_DISABLEDGETCOPY_NO

aApp[AI_ERRORSAVESCREEN]        := .F.

// simone 13/12/10 XL 2319
// poter mettere controllo accessi per utente su stampa tabella/stampa etichette
aApp[AI_TBPRNLAB_CB]            := NIL
aApp[AI_TBPRNWIN_CB]            := NIL
aApp[AI_TBFILESTAT_CB]          := NIL

// Simone 2/2/11 per invio email
aApp[AI_EMAILFAX_CB]            := NIL
RETURN aApp
