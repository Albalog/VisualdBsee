// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Descrizione    : Funzione contenente i messaggi di libreria
// *****************************************************************************
#include "dfMsg.ch"
#include "dfState.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStdMsg( nMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cMsg := ""
DO CASE
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_LANGUAGE       ; cMsg := "ITALIANO"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INITERROR      ; cMsg := "Non riesco ad aprire il file di INI"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_STD_YES        ; cMsg := "^Si"
   CASE nMsg == MSG_STD_NO         ; cMsg := "^No"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TABGET01       ; cMsg := "Manca riferimento in dbDD//Campo "
   CASE nMsg == MSG_TABGET02       ; cMsg := " non trovato "
   CASE nMsg == MSG_TABGET03       ; cMsg := "Errore in apertura DBDD.DBF"
   CASE nMsg == MSG_TABGET04       ; cMsg := "Errore in apertura DBTABD.DBF"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TABCHK01       ; cMsg := "Finestra su "
   CASE nMsg == MSG_TABCHK02       ; cMsg := " non disponibile !//"
   CASE nMsg == MSG_TABCHK03       ; cMsg := "Il file "
   CASE nMsg == MSG_TABCHK04       ; cMsg := " Љ vuoto !"
   CASE nMsg == MSG_TABCHK05       ; cMsg := "Impossibile lasciare vuoto il campo//("
   CASE nMsg == MSG_TABCHK06       ; cMsg := "Campo//("
   CASE nMsg == MSG_TABCHK07       ; cMsg := ")//il valore://"
   CASE nMsg == MSG_TABCHK08       ; cMsg := "non esiste in archivio: "
   CASE nMsg == MSG_TABCHK09       ; cMsg := "//inserire"
   CASE nMsg == MSG_TABCHK10       ; cMsg := "Campo//("
   CASE nMsg == MSG_TABCHK11       ; cMsg := ")//il valore://"
   CASE nMsg == MSG_TABCHK12       ; cMsg := "non esiste in tabella"
   CASE nMsg == MSG_TABCHK13       ; cMsg := "Campo chiave della tabella"
   CASE nMsg == MSG_TABCHK14       ; cMsg := "non trovato"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ERRSYS01       ; cMsg := "Numero non valido di funzione"
   CASE nMsg == MSG_ERRSYS02       ; cMsg := "Archivio non trovato"
   CASE nMsg == MSG_ERRSYS03       ; cMsg := "Percorso non trovato"
   CASE nMsg == MSG_ERRSYS04       ; cMsg := "Troppi files aperti"
   CASE nMsg == MSG_ERRSYS05       ; cMsg := "Accesso negato"
   CASE nMsg == MSG_ERRSYS06       ; cMsg := "Memoria Insufficiente"
   CASE nMsg == MSG_ERRSYS07       ; cMsg := "Riservato"
   CASE nMsg == MSG_ERRSYS08       ; cMsg := "Tentativo di scrittura su disco protetto"
   CASE nMsg == MSG_ERRSYS09       ; cMsg := "Comando Sconosciuto"
   CASE nMsg == MSG_ERRSYS10       ; cMsg := "Errore di scrittura"
   CASE nMsg == MSG_ERRSYS11       ; cMsg := "Errore di lettura"
   CASE nMsg == MSG_ERRSYS12       ; cMsg := "Fallimento generale"
   //   nMsg == MSG_ERRSYS13       ; cMsg := "Accesso Negato"
   CASE nMsg == MSG_ERRSYS14       ; cMsg := "File gia esistente"
   CASE nMsg == MSG_ERRSYS15       ; cMsg := "Questo errore e' stato memorizzato nel file :"
   CASE nMsg == MSG_ERRSYS16       ; cMsg := "Premi un tasto per continuare ..."
   CASE nMsg == MSG_ERRSYS17       ; cMsg := "Invalid handle"
   CASE nMsg == MSG_ERRSYS18       ; cMsg := "Memory control blocks destroyed"
   CASE nMsg == MSG_ERRSYS19       ; cMsg := "Invalid memory block address"
   CASE nMsg == MSG_ERRSYS20       ; cMsg := "Invalid environment"
   CASE nMsg == MSG_ERRSYS21       ; cMsg := "Invalid format"
   CASE nMsg == MSG_ERRSYS22       ; cMsg := "Invalid access code"
   CASE nMsg == MSG_ERRSYS23       ; cMsg := "Invalid data"
   CASE nMsg == MSG_ERRSYS24       ; cMsg := "Invalid drive was specified"
   CASE nMsg == MSG_ERRSYS25       ; cMsg := "Attempt to remove the current directory"
   CASE nMsg == MSG_ERRSYS26       ; cMsg := "Not same device"
   CASE nMsg == MSG_ERRSYS27       ; cMsg := "No more files"
   CASE nMsg == MSG_ERRSYS28       ; cMsg := "Unknown unit"
   CASE nMsg == MSG_ERRSYS29       ; cMsg := "Drive non pronto"
   CASE nMsg == MSG_ERRSYS30       ; cMsg := "Data error (CRC)"
   CASE nMsg == MSG_ERRSYS31       ; cMsg := "Bad request structure length"
   CASE nMsg == MSG_ERRSYS32       ; cMsg := "Seek error"
   CASE nMsg == MSG_ERRSYS33       ; cMsg := "Unknown media type"
   CASE nMsg == MSG_ERRSYS34       ; cMsg := "Settore non trovato"
   CASE nMsg == MSG_ERRSYS35       ; cMsg := "Printer out of paper"
   CASE nMsg == MSG_ERRSYS36       ; cMsg := "Sharing violation"
   CASE nMsg == MSG_ERRSYS37       ; cMsg := "Lock violation"
   CASE nMsg == MSG_ERRSYS38       ; cMsg := "Invalid disk change"
   CASE nMsg == MSG_ERRSYS39       ; cMsg := "FCB unavailable"
   CASE nMsg == MSG_ERRSYS40       ; cMsg := "Sharing buffer overflow"
   CASE nMsg == MSG_ERRSYS41       ; cMsg := "Network request not supported"
   CASE nMsg == MSG_ERRSYS42       ; cMsg := "Remote computer not listening"
   CASE nMsg == MSG_ERRSYS43       ; cMsg := "Duplicate name on network"
   CASE nMsg == MSG_ERRSYS44       ; cMsg := "Network name not found"
   CASE nMsg == MSG_ERRSYS45       ; cMsg := "Network busy"
   CASE nMsg == MSG_ERRSYS46       ; cMsg := "Network device no longer exists"
   CASE nMsg == MSG_ERRSYS47       ; cMsg := "Network BIOS command limit exceeded"
   CASE nMsg == MSG_ERRSYS48       ; cMsg := "Network adapter hardware error"
   CASE nMsg == MSG_ERRSYS49       ; cMsg := "Incorrect response from network"
   CASE nMsg == MSG_ERRSYS50       ; cMsg := "Unexpected network error"
   CASE nMsg == MSG_ERRSYS51       ; cMsg := "Incompatible remote adapter"
   CASE nMsg == MSG_ERRSYS52       ; cMsg := "Print queue full"
   CASE nMsg == MSG_ERRSYS53       ; cMsg := "Not enough space for print file"
   CASE nMsg == MSG_ERRSYS54       ; cMsg := "Print file deleted (not enough space)"
   CASE nMsg == MSG_ERRSYS55       ; cMsg := "Network name deleted"
   CASE nMsg == MSG_ERRSYS56       ; cMsg := "Network device type incorrect"
   //   nMsg == MSG_ERRSYS57       ; cMsg := "Network name not found"
   CASE nMsg == MSG_ERRSYS58       ; cMsg := "Network name limit exceeded"
   CASE nMsg == MSG_ERRSYS59       ; cMsg := "Network BIOS session limit exceeded"
   CASE nMsg == MSG_ERRSYS60       ; cMsg := "Temporarily paused"
   CASE nMsg == MSG_ERRSYS61       ; cMsg := "Network request not accepted"
   CASE nMsg == MSG_ERRSYS62       ; cMsg := "Print or disk redirection paused"
   CASE nMsg == MSG_ERRSYS63       ; cMsg := "Cannot make directory entry"
   CASE nMsg == MSG_ERRSYS64       ; cMsg := "Fail on INT 24H"
   CASE nMsg == MSG_ERRSYS65       ; cMsg := "Too many redirections"
   CASE nMsg == MSG_ERRSYS66       ; cMsg := "Duplicate redirection"
   CASE nMsg == MSG_ERRSYS67       ; cMsg := "Invalid password"
   CASE nMsg == MSG_ERRSYS68       ; cMsg := "Invalid parameter"
   CASE nMsg == MSG_ERRSYS69       ; cMsg := "Network device fault"
   CASE nMsg == MSG_ERRSYS70       ; cMsg := "^Quit"
   CASE nMsg == MSG_ERRSYS71       ; cMsg := "^Retry"
   CASE nMsg == MSG_ERRSYS72       ; cMsg := "^Default"
   CASE nMsg == MSG_ERRSYS73       ; cMsg := "DOS Error :="
   CASE nMsg == MSG_ERRSYS74       ; cMsg := "^Break"
   CASE nMsg == MSG_ERRSYS75       ; cMsg := "Chiamato da"
   CASE nMsg == MSG_ERRSYS76       ; cMsg := "Error "
   CASE nMsg == MSG_ERRSYS77       ; cMsg := "Warning "
   CASE nMsg == MSG_ERRSYS78       ; cMsg := "Errore di tipo sconosciuto"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBPATH01       ; cMsg := "Elaborazione path : @"
   CASE nMsg == MSG_DBPATH02       ; cMsg := "Nome variabile inesistente"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDUSE01        ; cMsg := "Non esiste file :"
   CASE nMsg == MSG_DDUSE02        ; cMsg := "Apertura file :"
   CASE nMsg == MSG_DDUSE03        ; cMsg := "Errore in nome variabile :"
   CASE nMsg == MSG_DDUSE04        ; cMsg := "Modalit… sconosciuta!"
   CASE nMsg == MSG_DDUSE05        ; cMsg := "Indice file :"
   //   nMsg == MSG_DDUSE06        ; cMsg := "Errore in nome variabile :"
   CASE nMsg == MSG_DDUSE07        ; cMsg := "Errore apertura file"
   CASE nMsg == MSG_DDUSE08        ; cMsg := "Non riesco ad aprire il FILE"
   CASE nMsg == MSG_DDUSE09        ; cMsg := "TimeOut :"
   CASE nMsg == MSG_DDUSE10        ; cMsg := "Indice non trovato"
   CASE nMsg == MSG_DDUSE11        ; cMsg := "Impossibile aprire la tabella %file% perchЉ in uso da altri utenti.//Riprovare l'operazione in un secondo momento."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBMSGERR       ; cMsg := "OK"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DE_STATE_INK   ; cMsg := "іConsultazioneі"
   CASE nMsg == MSG_DE_STATE_ADD   ; cMsg := "іInserimentoі"
   CASE nMsg == MSG_DE_STATE_MOD   ; cMsg := "іModificaі"
   CASE nMsg == MSG_DE_STATE_DEL   ; cMsg := "іCancellazioneі"
   CASE nMsg == MSG_DE_STATE_COPY  ; cMsg := "іCopiaі"
   CASE nMsg == MSG_DE_STATE_QRY   ; cMsg := "іQueryі"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBSKIP01       ; cMsg := " e' vuoto !!"
   CASE nMsg == MSG_TBSKIP02       ; cMsg := "Raggiunto l'inizio di : "
   CASE nMsg == MSG_TBSKIP03       ; cMsg := "Raggiunta la fine di : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DE_DEL         ; cMsg := "Conferma eliminazione RECORD !"
   CASE nMsg == MSG_DE_NOTMOD      ; cMsg := "Non ci sono righe da modificare !"
   CASE nMsg == MSG_DE_NOTDEL      ; cMsg := "Non ci sono righe da cancellare !"
   CASE nMsg == MSG_DE_NOTADD      ; cMsg := "Non Љ possibile aggiungere un Record con la Tabella base vuota: "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_NUM2WORD01     ; cMsg := "uno"
   CASE nMsg == MSG_NUM2WORD02     ; cMsg := "due"
   CASE nMsg == MSG_NUM2WORD03     ; cMsg := "tre"
   CASE nMsg == MSG_NUM2WORD04     ; cMsg := "quattro"
   CASE nMsg == MSG_NUM2WORD05     ; cMsg := "cinque"
   CASE nMsg == MSG_NUM2WORD06     ; cMsg := "sei"
   CASE nMsg == MSG_NUM2WORD07     ; cMsg := "sette"
   CASE nMsg == MSG_NUM2WORD08     ; cMsg := "otto"
   CASE nMsg == MSG_NUM2WORD09     ; cMsg := "nove"
   CASE nMsg == MSG_NUM2WORD10     ; cMsg := "dieci"
   CASE nMsg == MSG_NUM2WORD11     ; cMsg := "undici"
   CASE nMsg == MSG_NUM2WORD12     ; cMsg := "dodici"
   CASE nMsg == MSG_NUM2WORD13     ; cMsg := "tredici"
   CASE nMsg == MSG_NUM2WORD14     ; cMsg := "quattordici"
   CASE nMsg == MSG_NUM2WORD15     ; cMsg := "quindici"
   CASE nMsg == MSG_NUM2WORD16     ; cMsg := "sedici"
   CASE nMsg == MSG_NUM2WORD17     ; cMsg := "diciassette"
   CASE nMsg == MSG_NUM2WORD18     ; cMsg := "diciotto"
   CASE nMsg == MSG_NUM2WORD19     ; cMsg := "diciannove"
   CASE nMsg == MSG_NUM2WORD20     ; cMsg := "dieci"
   CASE nMsg == MSG_NUM2WORD21     ; cMsg := "venti"
   CASE nMsg == MSG_NUM2WORD22     ; cMsg := "trenta"
   CASE nMsg == MSG_NUM2WORD23     ; cMsg := "quaranta"
   CASE nMsg == MSG_NUM2WORD24     ; cMsg := "cinquanta"
   CASE nMsg == MSG_NUM2WORD25     ; cMsg := "sessanta"
   CASE nMsg == MSG_NUM2WORD26     ; cMsg := "settanta"
   CASE nMsg == MSG_NUM2WORD27     ; cMsg := "ottanta"
   CASE nMsg == MSG_NUM2WORD28     ; cMsg := "novanta"
   CASE nMsg == MSG_NUM2WORD29     ; cMsg := " miliardi"
   CASE nMsg == MSG_NUM2WORD30     ; cMsg := " milioni"
   CASE nMsg == MSG_NUM2WORD31     ; cMsg := " mila"
   CASE nMsg == MSG_NUM2WORD32     ; cMsg := "zero"
   CASE nMsg == MSG_NUM2WORD33     ; cMsg := "mille"
   CASE nMsg == MSG_NUM2WORD34     ; cMsg := "un milione"
   CASE nMsg == MSG_NUM2WORD35     ; cMsg := "un miliardo"
   CASE nMsg == MSG_NUM2WORD36     ; cMsg := "cento"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_NTXSYS01       ; cMsg := "Ricostruzione indici di sistema"
   //   nMsg == MSG_NTXSYS02       ; cMsg := "Cancellazione indici su disco"
   CASE nMsg == MSG_NTXSYS03       ; cMsg := "Ricostruzione indici dbDD"
   CASE nMsg == MSG_NTXSYS04       ; cMsg := "Ricostruzione indici Help"
   CASE nMsg == MSG_NTXSYS05       ; cMsg := "Ricostruzione indici Tabelle"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_PGLIST01       ; cMsg := "Lista delle pagine"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBCFGOPE01     ; cMsg := "Reindicizzazione"
   CASE nMsg == MSG_DBCFGOPE02     ; cMsg := "Non riesco ad aprire il file di sistema"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_HLP01          ; cMsg := "^Prossimo"
   CASE nMsg == MSG_HLP02          ; cMsg := "P^recedente"
   CASE nMsg == MSG_HLP03          ; cMsg := "^Menu"
   CASE nMsg == MSG_HLP04          ; cMsg := "^File"
   CASE nMsg == MSG_HLP05          ; cMsg := "^Info"
   CASE nMsg == MSG_HLP06          ; cMsg := "^Sistema"
   CASE nMsg == MSG_HLP07          ; cMsg := "S^ommario"
   CASE nMsg == MSG_HLP08          ; cMsg := "^Precedente"
   CASE nMsg == MSG_HLP09          ; cMsg := "C^erca"
   CASE nMsg == MSG_HLP10          ; cMsg := "^File"
   CASE nMsg == MSG_HLP11          ; cMsg := "^Stampa Argomento"
   CASE nMsg == MSG_HLP12          ; cMsg := "^Esci"
   CASE nMsg == MSG_HLP13          ; cMsg := "^Uso della guida"
   CASE nMsg == MSG_HLP14          ; cMsg := "Stringa da cercare"
   CASE nMsg == MSG_HLP15          ; cMsg := "Stringa non trovata"
   CASE nMsg == MSG_HLP16          ; cMsg := "Aiuto"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBRID01        ; cMsg := "Integrita' tipo RESTRICT impossibile cancellare il RECORD"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_USRHELP01      ; cMsg := "Help contestuale non disponibile//"
   CASE nMsg == MSG_USRHELP02      ; cMsg := "in questo ambiente!"
   CASE nMsg == MSG_USRHELP03      ; cMsg := " Tasti disponibili "
   CASE nMsg == MSG_USRHELP04      ; cMsg := "Ritorno alla maschera precedente"
   CASE nMsg == MSG_USRHELP05      ; cMsg := "Calcolatrice"
   CASE nMsg == MSG_USRHELP06      ; cMsg := "Fine della sessione di lavoro"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDINDEX01      ; cMsg := "Ricostruzione Indici"
   CASE nMsg == MSG_DDINDEX02      ; cMsg := "^Globale"
   CASE nMsg == MSG_DDINDEX03      ; cMsg := "^Parziale"
   CASE nMsg == MSG_DDINDEX04      ; cMsg := "^File di Sistema"
   CASE nMsg == MSG_DDINDEX05      ; cMsg := "  Indice   іRecordіEspressione"
   CASE nMsg == MSG_DDINDEX06      ; cMsg := "Ricostruzione indici"
   CASE nMsg == MSG_DDINDEX07      ; cMsg := " con COMPATTAMENTO archivi"
   CASE nMsg == MSG_DDINDEX08      ; cMsg := "Selezionare i file INDICE da ricostruire. RETURN conferma ! "
   CASE nMsg == MSG_DDINDEX09      ; cMsg := "PAUSA - Un tasto per continuare - PAUSA"
   CASE nMsg == MSG_DDINDEX10      ; cMsg := "Barra=Pausa і Ricostruzione INDICI in corso !"
   CASE nMsg == MSG_DDINDEX11      ; cMsg := "...Pack del file ("
   CASE nMsg == MSG_DDINDEX12      ; cMsg := ") in corso !..."
   CASE nMsg == MSG_DDINDEX13      ; cMsg := "Indice file :"
   CASE nMsg == MSG_DDINDEX14      ; cMsg := "Errore in nome variabile :"
   CASE nMsg == MSG_DDINDEX15      ; cMsg := "^Check"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDINDEXFL01    ; cMsg := "Indice file :"
   CASE nMsg == MSG_DDINDEXFL02    ; cMsg := "Errore in nome variabile :"
   CASE nMsg == MSG_DDINDEXFL03    ; cMsg := "PACK del file :"
   CASE nMsg == MSG_DDINDEXFL04    ; cMsg := " in corso "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDWIN01        ; cMsg := "Finestra "
   CASE nMsg == MSG_DDWIN02        ; cMsg := "//Non disponibile !"
   CASE nMsg == MSG_DDWIN03        ; cMsg := "Nulla da cancellare !"
   CASE nMsg == MSG_DDWIN04        ; cMsg := "CANCELLA ELEMENTO CORRENTE"
   CASE nMsg == MSG_DDWIN05        ; cMsg := "Nulla da modificare !"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFAUTOFORM01   ; cMsg := "C^onferma"
   CASE nMsg == MSG_DFAUTOFORM02   ; cMsg := "^Abbandona"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCOLOR01      ; cMsg := "Label Colore"
   CASE nMsg == MSG_DFCOLOR02      ; cMsg := "Non Trovata"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFALERT01      ; cMsg := "Premere un tasto per continuare ..."
   CASE nMsg == MSG_DFALERT02      ; cMsg := "Premere uno dei Tasti indicati"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFMEMO01       ; cMsg := "Conferma testo"
   CASE nMsg == MSG_DFMEMO02       ; cMsg := "Legge da disco"
   CASE nMsg == MSG_DFMEMO03       ; cMsg := "Scrive su disco"
   CASE nMsg == MSG_DFMEMO05       ; cMsg := "Azzera totale"
   CASE nMsg == MSG_DFMEMO06       ; cMsg := "Somma  totale"
   CASE nMsg == MSG_DFMEMO07       ; cMsg := "Visualizza totale"
   CASE nMsg == MSG_DFMEMO08       ; cMsg := "Riporta totale nel testo"
   CASE nMsg == MSG_DFMEMO09       ; cMsg := "Risolve espressione postponendo risultato"
   CASE nMsg == MSG_DFMEMO10       ; cMsg := "Risolve espressione sostituendo risultato"
   CASE nMsg == MSG_DFMEMO11       ; cMsg := "File da Leggere"
   CASE nMsg == MSG_DFMEMO12       ; cMsg := "Lettura Memo da Disco"
   CASE nMsg == MSG_DFMEMO13       ; cMsg := "Sistema automatico di totalizzazione, importi sommati :"
   CASE nMsg == MSG_DFMEMO14       ; cMsg := "Totale ottenuto con calcolatrice//"
   //   nMsg == MSG_DFMEMO15       ; cMsg := "Sistema automatico di totalizzazione, importi sommati :"
   CASE nMsg == MSG_DFMEMO16       ; cMsg := "Manca carattere identificatore inizio !"
   CASE nMsg == MSG_DFMEMO17       ; cMsg := "Sei Sicuro di voler abbandonare le modifiche"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFQRY01        ; cMsg := "Minore di"
   CASE nMsg == MSG_DFQRY02        ; cMsg := "Maggiore di"
   CASE nMsg == MSG_DFQRY03        ; cMsg := "Minore o Uguale a"
   CASE nMsg == MSG_DFQRY04        ; cMsg := "Maggiore o Uguale a"
   CASE nMsg == MSG_DFQRY05        ; cMsg := "Uguale a"
   CASE nMsg == MSG_DFQRY06        ; cMsg := "Diverso da"
   CASE nMsg == MSG_DFQRY07        ; cMsg := "Contiene"
   CASE nMsg == MSG_DFQRY08        ; cMsg := "e' Contenuto in"
   CASE nMsg == MSG_DFQRY09        ; cMsg := "Esattamente Uguale"
   CASE nMsg == MSG_DFQRY10        ; cMsg := "vero"
   CASE nMsg == MSG_DFQRY11        ; cMsg := "falso"
   CASE nMsg == MSG_DFQRY12        ; cMsg := " e "
   CASE nMsg == MSG_DFQRY13        ; cMsg := " o "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_VALID01        ; cMsg := "Impossibile lasciare il campo vuoto"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINI01        ; cMsg := "Riporta una versione non corretta"
   CASE nMsg == MSG_DFINI02        ; cMsg := "Rigenerare dbStart.ini da Visual dBsee"
   CASE nMsg == MSG_DFINI03        ; cMsg := "Caricamento Azioni"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFFILE2PRN01   ; cMsg := "Stampante non pronta//Nuovo tentativo"
   CASE nMsg == MSG_DFFILE2PRN02   ; cMsg := "Stampa in corso"
   CASE nMsg == MSG_DFFILE2PRN03   ; cMsg := "Interruzione Stampa"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFNET01        ; cMsg := "Impossibile bloccare il FILE :"
   CASE nMsg == MSG_DFNET02        ; cMsg := "Impossibile bloccare  RECORD n§. %2%"
   CASE nMsg == MSG_DFNET03        ; cMsg := "Impossibile appendere il RECORD"
   //   nMsg == MSG_DFNET04        ; cMsg := "FUNZIONE SCONOSCIUTA !!"
   //   nMsg == MSG_DFNET05        ; cMsg := "Time Out: "
   CASE nMsg == MSG_DFNET06        ; cMsg := "Tentativo di LOCK"
   CASE nMsg == MSG_DFNET07        ; cMsg := "Secondi"
   CASE nMsg == MSG_DFNET08        ; cMsg := "LOCK File :"
   CASE nMsg == MSG_DFNET09        ; cMsg := "Tramite semaforo"
   CASE nMsg == MSG_DFNET10        ; cMsg := "Non riesco a trovare il file"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFMEMOWRI01    ; cMsg := "File da scrivere: "
   CASE nMsg == MSG_DFMEMOWRI02    ; cMsg := "Digitare nome file da scrivere.іF10=confermaіEsc=rinuncia"
   CASE nMsg == MSG_DFMEMOWRI03    ; cMsg := "Scrittura memo su disco"
   CASE nMsg == MSG_DFMEMOWRI04    ; cMsg := "File esistente, ricoprire ?"
   //   nMsg == MSG_DFMEMOWRI05    ; cMsg := "Scrittura file "
   //   nMsg == MSG_DFMEMOWRI06    ; cMsg := " ultimata !"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPATH01    ; cMsg := "Caricamento Path dell'Applicazione"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIFONT01    ; cMsg := "Caricamento FONT"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPRN01     ; cMsg := "Caricamento STAMPANTI"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPROGIND01    ; cMsg := "Annulla"
   CASE nMsg == MSG_DFPROGIND02    ; cMsg := "Sei sicuro di voler interrompere"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBLOOK01       ; cMsg := "Non e' possibile lasciare il campo//"
   CASE nMsg == MSG_DBLOOK02       ; cMsg := "vuoto"
   CASE nMsg == MSG_DBLOOK03       ; cMsg := "Attenzione: //"
   CASE nMsg == MSG_DBLOOK04       ; cMsg := "//inesistente !!"
   CASE nMsg == MSG_DBLOOK05       ; cMsg := "Attenzione : il codice//"
   CASE nMsg == MSG_DBLOOK06       ; cMsg := "//non esiste nel file"
   CASE nMsg == MSG_DBLOOK07       ; cMsg := "//volete inserirlo?"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABDE01      ; cMsg := "Elenco file tabellari"
   CASE nMsg == MSG_DFTABDE02      ; cMsg := "Tabelle"
   CASE nMsg == MSG_DFTABDE03      ; cMsg := "Modifica"
   CASE nMsg == MSG_DFTABDE04      ; cMsg := "Non ci sono tabelle nell'applicazione"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBINK01        ; cMsg := "Time out di tastiera"
   CASE nMsg == MSG_DBINK02        ; cMsg := "Secondi"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   //   nMsg == MSG_DFINIPP01      ; cMsg := "Caricamento Porte di STAMPA"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPOR01     ; cMsg := "Caricamento Porte"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFGET01        ; cMsg := "Uscita dalla Maschera"
   CASE nMsg == MSG_DFGET02        ; cMsg := "Salvataggio della Maschera"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBBRWNEW01     ; cMsg := "Ripristina le dimensioni originali della finestra"
   CASE nMsg == MSG_TBBRWNEW02     ; cMsg := "Riposiziona la finestra sullo schermo"
   CASE nMsg == MSG_TBBRWNEW03     ; cMsg := "Cambia le dimensioni della finestra"
   CASE nMsg == MSG_TBBRWNEW04     ; cMsg := "Riduce alle minime dimensioni consentite la finestra"
   CASE nMsg == MSG_TBBRWNEW05     ; cMsg := "Ingrandisce alle massime dimensioni consentite dalla finestra"
   CASE nMsg == MSG_TBBRWNEW06     ; cMsg := "Rimuove la finestra corrente e tutte quelle associate dallo schermo"
   CASE nMsg == MSG_TBBRWNEW07     ; cMsg := "Presenta una lista delle pagine attive"
   CASE nMsg == MSG_TBBRWNEW08     ; cMsg := "Successivo"
   CASE nMsg == MSG_TBBRWNEW09     ; cMsg := "Precedente"
   CASE nMsg == MSG_TBBRWNEW10     ; cMsg := "Primo"
   CASE nMsg == MSG_TBBRWNEW11     ; cMsg := "Ultimo"
   CASE nMsg == MSG_TBBRWNEW12     ; cMsg := "Destra"
   CASE nMsg == MSG_TBBRWNEW13     ; cMsg := "Sinistra"
   CASE nMsg == MSG_TBBRWNEW14     ; cMsg := "Pagina su"
   CASE nMsg == MSG_TBBRWNEW15     ; cMsg := "Pagina giu"
   CASE nMsg == MSG_TBBRWNEW16     ; cMsg := "Fissa/Libera colonne a Sinistra"
   CASE nMsg == MSG_TBBRWNEW17     ; cMsg := "Allarga Colonna"
   CASE nMsg == MSG_TBBRWNEW18     ; cMsg := "Stringi Colonna"
   CASE nMsg == MSG_TBBRWNEW19     ; cMsg := "Deselezione di tutti gli Elementi"
   CASE nMsg == MSG_TBBRWNEW20     ; cMsg := "Selezione Elemento"
   CASE nMsg == MSG_TBBRWNEW21     ; cMsg := "Selezione di tutti gli Elementi"
   CASE nMsg == MSG_TBBRWNEW22     ; cMsg := "Modifica Elemento Corrente"
   CASE nMsg == MSG_TBBRWNEW23     ; cMsg := "Pagina successiva"
   CASE nMsg == MSG_TBBRWNEW24     ; cMsg := "^Ripristina"
   CASE nMsg == MSG_TBBRWNEW25     ; cMsg := "^Sposta"
   CASE nMsg == MSG_TBBRWNEW26     ; cMsg := "Ri^dimensiona"
   CASE nMsg == MSG_TBBRWNEW27     ; cMsg := "Riduci a ^icona"
   CASE nMsg == MSG_TBBRWNEW28     ; cMsg := "I^ngrandisci"
   CASE nMsg == MSG_TBBRWNEW29     ; cMsg := "C^hiudi"
   CASE nMsg == MSG_TBBRWNEW30     ; cMsg := "^Passa a ..."
   CASE nMsg == MSG_TBBRWNEW31     ; cMsg := "Tasti"
   CASE nMsg == MSG_TBBRWNEW32     ; cMsg := "Pagina precedente"
   CASE nMsg == MSG_TBBRWNEW33     ; cMsg := "Stampa database"
   CASE nMsg == MSG_TBBRWNEW34     ; cMsg := "Stampa Etichette"
   CASE nMsg == MSG_TBBRWNEW35     ; cMsg := "Statistica"
   CASE nMsg == MSG_TBBRWNEW36     ; cMsg := "Seleziona/Deseleziona riga"
   CASE nMsg == MSG_TBBRWNEW37     ; cMsg := "Deseleziona tutto"
   CASE nMsg == MSG_TBBRWNEW38     ; cMsg := "Seleziona tutto"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDGENDBF01     ; cMsg := "File"
   CASE nMsg == MSG_DDGENDBF02     ; cMsg := "senza campi"
   CASE nMsg == MSG_DDGENDBF03     ; cMsg := "Creazione File"
   CASE nMsg == MSG_DDGENDBF04     ; cMsg := "Attenzione!!! Directory non esistente della Tabella:// "
   CASE nMsg == MSG_DDGENDBF05     ; cMsg := "//Creare la Directory adesso?"
   CASE nMsg == MSG_DDGENDBF06     ; cMsg := "Errore in creazione Directory://"
   CASE nMsg == MSG_DDGENDBF07     ; cMsg := "Errore Grave in creazione Tabella!!!//Operazione annullata...//Tabella: "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABPRINT01   ; cMsg := "Nessuna tabella da stampare"
   CASE nMsg == MSG_DFTABPRINT02   ; cMsg := "Tabelle"
   CASE nMsg == MSG_DFTABPRINT03   ; cMsg := "Stampa Tabelle"
   //   nMsg == MSG_DFTABPRINT04   ; cMsg := "Stampa Tabelle"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPRNSTART01   ; cMsg := "Errore in apertura file"
   CASE nMsg == MSG_DFPRNSTART02   ; cMsg := "Premere Invio per stampare//"
   CASE nMsg == MSG_DFPRNSTART03   ; cMsg := "File Principale"
   CASE nMsg == MSG_DFPRNSTART04   ; cMsg := "Stampa Su"
   CASE nMsg == MSG_DFPRNSTART05   ; cMsg := "Stampante attuale"
   CASE nMsg == MSG_DFPRNSTART06   ; cMsg := "Porta di stampa"
   CASE nMsg == MSG_DFPRNSTART07   ; cMsg := "Qualita'"
   CASE nMsg == MSG_DFPRNSTART08   ; cMsg := "No^rmale"
   CASE nMsg == MSG_DFPRNSTART09   ; cMsg := "A^lta"
   CASE nMsg == MSG_DFPRNSTART10   ; cMsg := "Carattere"
   CASE nMsg == MSG_DFPRNSTART11   ; cMsg := "Normal^e"
   CASE nMsg == MSG_DFPRNSTART12   ; cMsg := "C^ompresso"
   CASE nMsg == MSG_DFPRNSTART13   ; cMsg := "Cambio ^porta"
   CASE nMsg == MSG_DFPRNSTART14   ; cMsg := "^Margini"
   CASE nMsg == MSG_DFPRNSTART15   ; cMsg := "S^tampanti"
   CASE nMsg == MSG_DFPRNSTART16   ; cMsg := "Spooler Atti^vo"
   CASE nMsg == MSG_DFPRNSTART17   ; cMsg := "Cop^ie :"
   CASE nMsg == MSG_DFPRNSTART18   ; cMsg := "^Numero di Copie"
   CASE nMsg == MSG_DFPRNSTART19   ; cMsg := "^File :"
   CASE nMsg == MSG_DFPRNSTART20   ; cMsg := "^Anteprima"
   CASE nMsg == MSG_DFPRNSTART21   ; cMsg := "^Stampa"
   CASE nMsg == MSG_DFPRNSTART22   ; cMsg := "A^bbandona"
   CASE nMsg == MSG_DFPRNSTART23   ; cMsg := "Righe per pagina"
   CASE nMsg == MSG_DFPRNSTART24   ; cMsg := "Margine superiore"
   CASE nMsg == MSG_DFPRNSTART25   ; cMsg := "Margine inferiore"
   CASE nMsg == MSG_DFPRNSTART26   ; cMsg := "Margine sinistro"
   CASE nMsg == MSG_DFPRNSTART27   ; cMsg := "Margini"
   CASE nMsg == MSG_DFPRNSTART28   ; cMsg := "ю Porte Fisiche ю"
   CASE nMsg == MSG_DFPRNSTART29   ; cMsg := "ю Porte di Stampa ю"
   CASE nMsg == MSG_DFPRNSTART30   ; cMsg := "Stampa senza salti pagina"
   CASE nMsg == MSG_DFPRNSTART31   ; cMsg := "Nulla da stampare"
   CASE nMsg == MSG_DFPRNSTART32   ; cMsg := "Nome Report"
   CASE nMsg == MSG_DFPRNSTART33   ; cMsg := "Descrizione filtro"
   CASE nMsg == MSG_DFPRNSTART34   ; cMsg := "Espressione filtro"
   CASE nMsg == MSG_DFPRNSTART35   ; cMsg := "I^nformazioni"
   CASE nMsg == MSG_DFPRNSTART36   ; cMsg := "Setup"
   CASE nMsg == MSG_DFPRNSTART37   ; cMsg := "Usa Setup ^1"
   CASE nMsg == MSG_DFPRNSTART38   ; cMsg := "Usa Setup ^2"
   CASE nMsg == MSG_DFPRNSTART39   ; cMsg := "Usa Setup ^3"
   CASE nMsg == MSG_DFPRNSTART40   ; cMsg := "Pa^gine"
   CASE nMsg == MSG_DFPRNSTART41   ; cMsg := "Stampa tutte le pagine"
   //   nMsg == MSG_DFPRNSTART42   ; cMsg := "Stampa tutte le pagine"
   CASE nMsg == MSG_DFPRNSTART43   ; cMsg := "Da Pagina :"
   CASE nMsg == MSG_DFPRNSTART44   ; cMsg := "Stampa da Pagina"
   CASE nMsg == MSG_DFPRNSTART45   ; cMsg := "A Pagina  :"
   CASE nMsg == MSG_DFPRNSTART46   ; cMsg := "Stampa fino a Pagina"
   CASE nMsg == MSG_DFPRNSTART47   ; cMsg := "Pagine"
   CASE nMsg == MSG_DFPRNSTART48   ; cMsg := "^Filtro"
   CASE nMsg == MSG_DFPRNSTART49   ; cMsg := "Sostituisco il filtro attuale"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDDE01         ; cMsg := "Quadro automatico//"
   CASE nMsg == MSG_DDDE02         ; cMsg := "//non definito !"
   CASE nMsg == MSG_DDDE03         ; cMsg := "Quadro automatico//"
   CASE nMsg == MSG_DDDE04         ; cMsg := "//Chiave primaria non definita !"
   CASE nMsg == MSG_DDDE05         ; cMsg := "Quadro "
   CASE nMsg == MSG_DDDE06         ; cMsg := "CHIAVE PRIMARIA//"
   CASE nMsg == MSG_DDDE07         ; cMsg := "//Duplicata !"
   CASE nMsg == MSG_DDDE08         ; cMsg := "Campo obbligatorio"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBINK01        ; cMsg := "Il Record corrente e' stato cancellato"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBGETKEY01     ; cMsg := "Chiama la finestra di ricerca"
   CASE nMsg == MSG_TBGETKEY02     ; cMsg := "Chiama le chiavi di ricerca"
   //   nMsg == MSG_TBGETKEY03     ; cMsg := "Chiama la finestra di ricerca"
   CASE nMsg == MSG_TBGETKEY04     ; cMsg := "Entra in edit sul memo"
   CASE nMsg == MSG_TBGETKEY05     ; cMsg := "Seleziona/Deseleziona il valore"
   CASE nMsg == MSG_TBGETKEY06     ; cMsg := "Seleziona il valore"
   CASE nMsg == MSG_TBGETKEY07     ; cMsg := "Conferma il pulsante"
   CASE nMsg == MSG_TBGETKEY08     ; cMsg := "Incrementa il valore"
   CASE nMsg == MSG_TBGETKEY09     ; cMsg := "Decrementa il valore"
   CASE nMsg == MSG_TBGETKEY10     ; cMsg := "Incrementa 10 volte il valore"
   CASE nMsg == MSG_TBGETKEY11     ; cMsg := "Decrementa 10 volte il valore"
   CASE nMsg == MSG_TBGETKEY14     ; cMsg := "Copia nel buffer"
   CASE nMsg == MSG_TBGETKEY15     ; cMsg := "Importa dal buffer"
   CASE nMsg == MSG_TBGETKEY16     ; cMsg := "Record precedente"
   CASE nMsg == MSG_TBGETKEY17     ; cMsg := "Record successivo"
   CASE nMsg == MSG_TBGETKEY18     ; cMsg := "Primo record"
   CASE nMsg == MSG_TBGETKEY19     ; cMsg := "Ultimo record"
   CASE nMsg == MSG_TBGETKEY20     ; cMsg := "Richiama il Calendario"
   CASE nMsg == MSG_TBGETKEY21     ; cMsg := "Prossima Data"
   CASE nMsg == MSG_TBGETKEY22     ; cMsg := "Data Precedente"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFSVILLEV01    ; cMsg := "Interruzione Stampa"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFLOGIN01      ; cMsg := "Non riesco ad aprire il file delle Password"
   CASE nMsg == MSG_DFLOGIN02      ; cMsg := "Digitare la password"
   CASE nMsg == MSG_DFLOGIN03      ; cMsg := "*      CODICE D'ACCESSO      *//"
   CASE nMsg == MSG_DFLOGIN04      ; cMsg := " Gia' utilizzato  nel Sistema //"
   CASE nMsg == MSG_DFLOGIN05      ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД//"
   CASE nMsg == MSG_DFLOGIN06      ; cMsg := "La Password"
   CASE nMsg == MSG_DFLOGIN07      ; cMsg := "//non e' stata trovata//"
   CASE nMsg == MSG_DFLOGIN08      ; cMsg := "Digitare nuovamente la Password"
   CASE nMsg == MSG_DFLOGIN09      ; cMsg := "*      ACCESSO  NEGATO    *//"
   CASE nMsg == MSG_DFLOGIN10      ; cMsg := "  Utente non autorizzato ! //"
   CASE nMsg == MSG_DFLOGIN11      ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДД"
   CASE nMsg == MSG_DFLOGIN12      ; cMsg := "Errore di digitazione Password//"
   CASE nMsg == MSG_DFLOGIN13      ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
   CASE nMsg == MSG_DFLOGIN14      ; cMsg := "PASSWORD"
   CASE nMsg == MSG_DFLOGIN15      ; cMsg := "Digitare la Nuova Password"
   CASE nMsg == MSG_DFLOGIN16      ; cMsg := "Ridigitare la Password"
   CASE nMsg == MSG_DFLOGIN17      ; cMsg := "Nome  Utente"
   CASE nMsg == MSG_DFLOGIN18      ; cMsg := "Vuoi digitare una nuova PASSWORD"
   CASE nMsg == MSG_DFLOGIN19      ; cMsg := "Per le nuove leggi sulla Privacy //la Password deve essere almeno di 8 caratteri!"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDWIT01        ; cMsg := "Aggiunge un elemento"
   CASE nMsg == MSG_DDWIT02        ; cMsg := "Modifica l'elemento corrente"
   CASE nMsg == MSG_DDWIT03        ; cMsg := "Cancella l'elemento corrente"
   CASE nMsg == MSG_DDWIT04        ; cMsg := "Ricerca"
   CASE nMsg == MSG_DDWIT05        ; cMsg := "Codice "
   CASE nMsg == MSG_DDWIT06        ; cMsg := " inesistente ! "
   CASE nMsg == MSG_DDWIT07        ; cMsg := "CANCELLA ELEMENTO CORRENTE"
   CASE nMsg == MSG_DDWIT08        ; cMsg := "Ricerca "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDKEY01        ; cMsg := "Chiavi non disponibili//- File "
   CASE nMsg == MSG_DDKEY02        ; cMsg := " senza indici ! -"
   CASE nMsg == MSG_DDKEY03        ; cMsg := "Impossibile valutare la chiave di ricerca//"
   CASE nMsg == MSG_DDKEY04        ; cMsg := "Ricerca sequenziale attiva solo su campi carattere !"
   CASE nMsg == MSG_DDKEY05        ; cMsg := "Finestra di ricerca"
   CASE nMsg == MSG_DDKEY06        ; cMsg := "Ricerca per contenuto"
   CASE nMsg == MSG_DDKEY07        ; cMsg := "Finestra su file di LOOKUP"
   CASE nMsg == MSG_DDKEY08        ; cMsg := "Costruzione interattiva della chiave di ricerca"
   CASE nMsg == MSG_DDKEY09        ; cMsg := "Chiave: "
   CASE nMsg == MSG_DDKEY10        ; cMsg := "//non trovata!"
   CASE nMsg == MSG_DDKEY11        ; cMsg := " Premere un tasto per l'interruzione della scansione "
   CASE nMsg == MSG_DDKEY12        ; cMsg := "//Attivazione filtro////Attendere prego...//"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDUPDDBF01     ; cMsg := "Aggiornamento"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABFRM03     ; cMsg := "2ш controllo codice duplicato !//Inserimento sospeso !!"
   CASE nMsg == MSG_DFTABFRM04     ; cMsg := "Errore: codice duplicato in "
   CASE nMsg == MSG_DFTABFRM05     ; cMsg := "Attenzione!"
   CASE nMsg == MSG_DFTABFRM06     ; cMsg := "^Gia' utilizzato in"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPK01         ; cMsg := "primaria"
   CASE nMsg == MSG_DFPK02         ; cMsg := "univoca"
   CASE nMsg == MSG_DFPK03         ; cMsg := "Chiave "
   CASE nMsg == MSG_DFPK04         ; cMsg := " duplicata !//"
   CASE nMsg == MSG_DFPK05         ; cMsg := " vuota !//"
   CASE nMsg == MSG_DFPK06         ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД//"
   CASE nMsg == MSG_DFPK07         ; cMsg := "     digitare nuova chiave !   "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDQRY01        ; cMsg := "e         Ы .AND.Ы"
   CASE nMsg == MSG_DDQRY02        ; cMsg := "oppure    Ы .OR. Ы"
   CASE nMsg == MSG_DDQRY17        ; cMsg := "parentesi Ы  )   Ы"
   CASE nMsg == MSG_DDQRY03        ; cMsg := "Fine      Ы      Ы"
   CASE nMsg == MSG_DDQRY04        ; cMsg := " <   Minore di............. "
   CASE nMsg == MSG_DDQRY05        ; cMsg := " >   Maggiore di........... "
   CASE nMsg == MSG_DDQRY06        ; cMsg := " <=  Minore di o uguale a.. "
   CASE nMsg == MSG_DDQRY07        ; cMsg := " >=  Maggiore di o uguale a "
   CASE nMsg == MSG_DDQRY08        ; cMsg := " =   Uguale a.............. "
   CASE nMsg == MSG_DDQRY09        ; cMsg := " #   Diverso da............ "
   CASE nMsg == MSG_DDQRY10        ; cMsg := " $   E' Contenuto.......... "
   CASE nMsg == MSG_DDQRY11        ; cMsg := " њ   Contiene.............. "
   CASE nMsg == MSG_DDQRY12        ; cMsg := "Campi del File"
   CASE nMsg == MSG_DDQRY13        ; cMsg := "Condizioni"
   CASE nMsg == MSG_DDQRY14        ; cMsg := "Legami logici"
   CASE nMsg == MSG_DDQRY15        ; cMsg := "іFILTRO CORRETTOі"
   CASE nMsg == MSG_DDQRY16        ; cMsg := "іFILTRO ERRATOі"
   //   nMsg == MSG_DDQRY17        usato sopra
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBGET01        ; cMsg := "Barra Modifica і "
   CASE nMsg == MSG_TBGET02        ; cMsg := "F10 per registrare і "
   CASE nMsg == MSG_TBGET03        ; cMsg := "Il valore digitato e' errato"
   CASE nMsg == MSG_TBGET04        ; cMsg := "NON posso editare il CONTROL"
   CASE nMsg == MSG_TBGET05        ; cMsg := "Sono state effettuate delle modifiche//sui dati presenti nella maschera"
   CASE nMsg == MSG_TBGET06        ; cMsg := "^Salva"
   CASE nMsg == MSG_TBGET07        ; cMsg := "^Abbandona"
   CASE nMsg == MSG_TBGET08        ; cMsg := "^Continua"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFSTA01        ; cMsg := "Tempo trascorso"
   CASE nMsg == MSG_DFSTA02        ; cMsg := "Tempo stimato"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIREP01     ; cMsg := "Caricamento profili di stampa"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCALC01       ; cMsg := "Somma"
   CASE nMsg == MSG_DFCALC02       ; cMsg := "Moltiplicazione"
   CASE nMsg == MSG_DFCALC03       ; cMsg := "Sottrazione"
   CASE nMsg == MSG_DFCALC04       ; cMsg := "Divisione"
   CASE nMsg == MSG_DFCALC06       ; cMsg := "Totalizzazione"
   CASE nMsg == MSG_DFCALC07       ; cMsg := "Accensione"
   CASE nMsg == MSG_DFCALC08       ; cMsg := "Spegnimento"
   CASE nMsg == MSG_DFCALC09       ; cMsg := "Uscita con caricamento nel buffer di tastiera"
   CASE nMsg == MSG_DFCALC10       ; cMsg := "Conversione da LIRE a EURO"
   CASE nMsg == MSG_DFCALC11       ; cMsg := "Conversione da EURO a LIRE"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INTCOL01       ; cMsg := "NERO"
   CASE nMsg == MSG_INTCOL02       ; cMsg := "GRIGIO SCURO"
   CASE nMsg == MSG_INTCOL03       ; cMsg := "GRIGIO CHIARO"
   CASE nMsg == MSG_INTCOL04       ; cMsg := "BLU SCURO"
   CASE nMsg == MSG_INTCOL05       ; cMsg := "BLU"
   CASE nMsg == MSG_INTCOL06       ; cMsg := "BLU CHIARO"
   CASE nMsg == MSG_INTCOL07       ; cMsg := "VERDE SCURO"
   CASE nMsg == MSG_INTCOL08       ; cMsg := "VERDE"
   CASE nMsg == MSG_INTCOL09       ; cMsg := "VERDE CHIARO"
   CASE nMsg == MSG_INTCOL10       ; cMsg := "ROSSO SCURO"
   CASE nMsg == MSG_INTCOL11       ; cMsg := "ROSSO"
   CASE nMsg == MSG_INTCOL12       ; cMsg := "ROSSO CHIARO"
   CASE nMsg == MSG_INTCOL13       ; cMsg := "GIALLO SCURO"
   CASE nMsg == MSG_INTCOL14       ; cMsg := "GIALLO"
   CASE nMsg == MSG_INTCOL15       ; cMsg := "GIALLO CHIARO"
   CASE nMsg == MSG_INTCOL16       ; cMsg := "BIANCO"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INTPRN01       ; cMsg := "STAMPANTE SENZA CARATTERI D'ESCAPE"
   //   nMsg == MSG_INTPRN02       ; cMsg := "EPSON FX-80"
   //   nMsg == MSG_INTPRN03       ; cMsg := "HP LASERJET PLUS"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ACTINT001      ; cMsg := "Home"
   CASE nMsg == MSG_ACTINT002      ; cMsg := "Ctrl-Fr.Destra"
   CASE nMsg == MSG_ACTINT003      ; cMsg := "Pag.gi—"
   CASE nMsg == MSG_ACTINT004      ; cMsg := "Fr.Destra"
   CASE nMsg == MSG_ACTINT005      ; cMsg := "Fr.s—"
   CASE nMsg == MSG_ACTINT006      ; cMsg := "Fine"
   CASE nMsg == MSG_ACTINT007      ; cMsg := "Canc"
   CASE nMsg == MSG_ACTINT008      ; cMsg := "BackSpace"
   CASE nMsg == MSG_ACTINT009      ; cMsg := "Tab"
   //   nMsg == MSG_ACTINT010      ; cMsg := "F2"
   //   nMsg == MSG_ACTINT011      ; cMsg := "F3"
   //   nMsg == MSG_ACTINT012      ; cMsg := "F4"
   //   nMsg == MSG_ACTINT013      ; cMsg := "F5"
   //   nMsg == MSG_ACTINT014      ; cMsg := "F6"
   //   nMsg == MSG_ACTINT015      ; cMsg := "F7"
   //   nMsg == MSG_ACTINT016      ; cMsg := "F8"
   //   nMsg == MSG_ACTINT017      ; cMsg := "F9"
   //   nMsg == MSG_ACTINT018      ; cMsg := "F10"
   CASE nMsg == MSG_ACTINT019      ; cMsg := "Ctrl-Invio"
   CASE nMsg == MSG_ACTINT020      ; cMsg := "Invio"
   CASE nMsg == MSG_ACTINT021      ; cMsg := "Pag.s—"
   CASE nMsg == MSG_ACTINT022      ; cMsg := "Fr.sin."
   CASE nMsg == MSG_ACTINT023      ; cMsg := "Ins"
   CASE nMsg == MSG_ACTINT024      ; cMsg := "Ctrl-Fine"
   CASE nMsg == MSG_ACTINT025      ; cMsg := "Fr.gi—"
   CASE nMsg == MSG_ACTINT026      ; cMsg := "Ctrl-Fr.sin."
   CASE nMsg == MSG_ACTINT027      ; cMsg := "Esc"
   CASE nMsg == MSG_ACTINT028      ; cMsg := "F1"
   CASE nMsg == MSG_ACTINT029      ; cMsg := "Ctrl-Home"
   CASE nMsg == MSG_ACTINT030      ; cMsg := "Ctrl-Pag.gi—"
   CASE nMsg == MSG_ACTINT031      ; cMsg := "Ctrl-Pag.s—"
   CASE nMsg == MSG_ACTINT032      ; cMsg := "Barra"
   //   nMsg == MSG_ACTINT033      ; cMsg := "+"
   //   nMsg == MSG_ACTINT034      ; cMsg := "-"
   //   nMsg == MSG_ACTINT035      ; cMsg := "<"
   //   nMsg == MSG_ACTINT036      ; cMsg := ">"
   //   nMsg == MSG_ACTINT037      ; cMsg := "Shift-F1"
   //   nMsg == MSG_ACTINT038      ; cMsg := "Shift-F2"
   //   nMsg == MSG_ACTINT039      ; cMsg := "Shift-F3"
   //   nMsg == MSG_ACTINT040      ; cMsg := "Shift-F4"
   //   nMsg == MSG_ACTINT041      ; cMsg := "Shift-F5"
   //   nMsg == MSG_ACTINT042      ; cMsg := "Shift-F6"
   //   nMsg == MSG_ACTINT043      ; cMsg := "Shift-F7"
   //   nMsg == MSG_ACTINT044      ; cMsg := "Shift-F8"
   //   nMsg == MSG_ACTINT045      ; cMsg := "Shift-F9"
   //   nMsg == MSG_ACTINT046      ; cMsg := "Shift-F10"
   //   nMsg == MSG_ACTINT047      ; cMsg := "Ctrl-F1"
   //   nMsg == MSG_ACTINT048      ; cMsg := "Ctrl-F2"
   //   nMsg == MSG_ACTINT049      ; cMsg := "Ctrl-F3"
   //   nMsg == MSG_ACTINT050      ; cMsg := "Ctrl-F4"
   //   nMsg == MSG_ACTINT051      ; cMsg := "Ctrl-F5"
   //   nMsg == MSG_ACTINT052      ; cMsg := "Ctrl-F6"
   //   nMsg == MSG_ACTINT053      ; cMsg := "Ctrl-F7"
   //   nMsg == MSG_ACTINT054      ; cMsg := "Ctrl-F8"
   //   nMsg == MSG_ACTINT055      ; cMsg := "Ctrl-F9"
   //   nMsg == MSG_ACTINT056      ; cMsg := "Ctrl-F10"
   //   nMsg == MSG_ACTINT057      ; cMsg := "Alt-F1"
   //   nMsg == MSG_ACTINT058      ; cMsg := "Alt-F2"
   //   nMsg == MSG_ACTINT059      ; cMsg := "Alt-F3"
   //   nMsg == MSG_ACTINT060      ; cMsg := "Alt-F4"
   //   nMsg == MSG_ACTINT061      ; cMsg := "Alt-F5"
   //   nMsg == MSG_ACTINT062      ; cMsg := "Alt-F6"
   //   nMsg == MSG_ACTINT063      ; cMsg := "Alt-F7"
   //   nMsg == MSG_ACTINT064      ; cMsg := "Alt-F8"
   //   nMsg == MSG_ACTINT065      ; cMsg := "Alt-F9"
   //   nMsg == MSG_ACTINT066      ; cMsg := "Alt-F10"
   CASE nMsg == MSG_ACTINT067      ; cMsg := "Ctrl-BackSpace"
   CASE nMsg == MSG_ACTINT068      ; cMsg := "Alt-Esc"
   CASE nMsg == MSG_ACTINT069      ; cMsg := "Alt-BackSpace"
   CASE nMsg == MSG_ACTINT070      ; cMsg := "Shift-Tab"
   CASE nMsg == MSG_ACTINT071      ; cMsg := "Alt-Q"
   CASE nMsg == MSG_ACTINT072      ; cMsg := "Alt-W"
   CASE nMsg == MSG_ACTINT073      ; cMsg := "Alt-E"
   CASE nMsg == MSG_ACTINT074      ; cMsg := "Alt-R"
   CASE nMsg == MSG_ACTINT075      ; cMsg := "Alt-T"
   CASE nMsg == MSG_ACTINT076      ; cMsg := "Alt-Y"
   CASE nMsg == MSG_ACTINT077      ; cMsg := "Alt-U"
   CASE nMsg == MSG_ACTINT078      ; cMsg := "Alt-I"
   CASE nMsg == MSG_ACTINT079      ; cMsg := "Alt-O"
   CASE nMsg == MSG_ACTINT080      ; cMsg := "Alt-P"
   CASE nMsg == MSG_ACTINT081      ; cMsg := "Alt-Љ"
   CASE nMsg == MSG_ACTINT082      ; cMsg := "Alt-+"
   CASE nMsg == MSG_ACTINT083      ; cMsg := "Alt-Invio"
   CASE nMsg == MSG_ACTINT084      ; cMsg := "Alt-A"
   CASE nMsg == MSG_ACTINT085      ; cMsg := "Alt-S"
   CASE nMsg == MSG_ACTINT086      ; cMsg := "Alt-D"
   CASE nMsg == MSG_ACTINT087      ; cMsg := "Alt-F"
   CASE nMsg == MSG_ACTINT088      ; cMsg := "Alt-G"
   CASE nMsg == MSG_ACTINT089      ; cMsg := "Alt-H"
   CASE nMsg == MSG_ACTINT090      ; cMsg := "Alt-J"
   CASE nMsg == MSG_ACTINT091      ; cMsg := "Alt-K"
   CASE nMsg == MSG_ACTINT092      ; cMsg := "Alt-L"
   CASE nMsg == MSG_ACTINT093      ; cMsg := "Alt-•"
   CASE nMsg == MSG_ACTINT094      ; cMsg := "Alt-…"
   CASE nMsg == MSG_ACTINT095      ; cMsg := "Alt-Backslash"
   CASE nMsg == MSG_ACTINT096      ; cMsg := "Alt-—"
   CASE nMsg == MSG_ACTINT097      ; cMsg := "Alt-Z"
   CASE nMsg == MSG_ACTINT098      ; cMsg := "Alt-X"
   CASE nMsg == MSG_ACTINT099      ; cMsg := "Alt-C"
   CASE nMsg == MSG_ACTINT100      ; cMsg := "Alt-V"
   CASE nMsg == MSG_ACTINT101      ; cMsg := "Alt-B"
   CASE nMsg == MSG_ACTINT102      ; cMsg := "Alt-N"
   CASE nMsg == MSG_ACTINT103      ; cMsg := "Alt-M"
   CASE nMsg == MSG_ACTINT104      ; cMsg := "Alt-,"
   CASE nMsg == MSG_ACTINT105      ; cMsg := "Alt-."
   CASE nMsg == MSG_ACTINT106      ; cMsg := "Alt--"
   CASE nMsg == MSG_ACTINT107      ; cMsg := "Alt-1"
   CASE nMsg == MSG_ACTINT108      ; cMsg := "Alt-2"
   CASE nMsg == MSG_ACTINT109      ; cMsg := "Alt-3"
   CASE nMsg == MSG_ACTINT110      ; cMsg := "Alt-4"
   CASE nMsg == MSG_ACTINT111      ; cMsg := "Alt-5"
   CASE nMsg == MSG_ACTINT112      ; cMsg := "Alt-6"
   CASE nMsg == MSG_ACTINT113      ; cMsg := "Alt-7"
   CASE nMsg == MSG_ACTINT114      ; cMsg := "Alt-8"
   CASE nMsg == MSG_ACTINT115      ; cMsg := "Alt-9"
   CASE nMsg == MSG_ACTINT116      ; cMsg := "Alt-0"
   CASE nMsg == MSG_ACTINT117      ; cMsg := "Alt-'"
   CASE nMsg == MSG_ACTINT118      ; cMsg := "Alt-Ќ"
   CASE nMsg == MSG_ACTINT119      ; cMsg := "F11"
   CASE nMsg == MSG_ACTINT120      ; cMsg := "F12"
   //   nMsg == MSG_ACTINT121      ; cMsg := "Shift-F11"
   //   nMsg == MSG_ACTINT122      ; cMsg := "Shift-F12"
   //   nMsg == MSG_ACTINT123      ; cMsg := "Ctrl-F11"
   //   nMsg == MSG_ACTINT124      ; cMsg := "Ctrl-F12"
   //   nMsg == MSG_ACTINT125      ; cMsg := "Alt-F11"
   //   nMsg == MSG_ACTINT126      ; cMsg := "Alt-F12"
   CASE nMsg == MSG_ACTINT127      ; cMsg := "Ctrl-Fr.s—"
   CASE nMsg == MSG_ACTINT128      ; cMsg := "Ctrl-Fr.gi—"
   CASE nMsg == MSG_ACTINT129      ; cMsg := "Ctrl-Ins"
   CASE nMsg == MSG_ACTINT130      ; cMsg := "Ctrl-Canc"
   CASE nMsg == MSG_ACTINT131      ; cMsg := "Ctrl-Tab"
   CASE nMsg == MSG_ACTINT132      ; cMsg := "Ctrl-Slash"
   CASE nMsg == MSG_ACTINT133      ; cMsg := "Alt-Home"
   CASE nMsg == MSG_ACTINT134      ; cMsg := "Alt-Fr.s—"
   CASE nMsg == MSG_ACTINT135      ; cMsg := "Alt-Pag.s—"
   CASE nMsg == MSG_ACTINT136      ; cMsg := "Alt Fr.sin."
   CASE nMsg == MSG_ACTINT137      ; cMsg := "Alt-Fr.Destra"
   CASE nMsg == MSG_ACTINT138      ; cMsg := "Alt-Fine"
   CASE nMsg == MSG_ACTINT139      ; cMsg := "Alt-Fr.gi—"
   CASE nMsg == MSG_ACTINT140      ; cMsg := "Alt-Pag.gi—"
   CASE nMsg == MSG_ACTINT141      ; cMsg := "Alt-Ins"
   CASE nMsg == MSG_ACTINT142      ; cMsg := "Alt-Canc"
   CASE nMsg == MSG_ACTINT143      ; cMsg := "Alt-Tab"
   //   nMsg == MSG_ACTINT144      ; cMsg := "Ctrl-F"
   CASE nMsg == MSG_ACTINT145      ; cMsg := "Ctrl-Backslash"
   CASE nMsg == MSG_ACTINT146      ; cMsg := "Ctrl-Barra"
   CASE nMsg == MSG_ACTINT147      ; cMsg := "Alt-Barra"
   CASE nMsg == MSG_ACTINT148      ; cMsg := "Shift-Canc"
   CASE nMsg == MSG_ACTINT149      ; cMsg := "Shift-Ins"
   CASE nMsg == MSG_ACTINT150      ; cMsg := "Alt-?"
   CASE nMsg == MSG_ACTINT151      ; cMsg := "Alt-Shift-Tab"
   //   nMsg == MSG_ACTINT152      ; cMsg := "Ctrl-P"
   CASE nMsg == MSG_ACTINT153      ; cMsg := "Ctrl"
   CASE nMsg == MSG_ACTINT154      ; cMsg := "Alt"
   CASE nMsg == MSG_ACTINT155      ; cMsg := "Shift"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД


   CASE nMsg == MSG_ADDMENUUND     ; cMsg := "Azione non attivabile."
   CASE nMsg == MSG_ATTBUTUND      ; cMsg := "Funzione non attivabile."
   CASE nMsg == MSG_FORMESC        ; cMsg := "Fine operazioni"
   CASE nMsg == MSG_FORMWRI        ; cMsg := "Conferma i dati"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INFO01         ; cMsg := "Sintassi:"
   CASE nMsg == MSG_INFO02         ; cMsg := "[opzioni] [Inifile.ext]"
   CASE nMsg == MSG_INFO03         ; cMsg := "Opzioni:   /?|/h = Questo help"
   CASE nMsg == MSG_INFO04         ; cMsg := "           /UPD  = Controlla la BASE DATI dell'applicazione"
   CASE nMsg == MSG_INFO05         ; cMsg := "Inifile.ext:   Nome del file INI di configurazione"
   CASE nMsg == MSG_INFO06         ; cMsg := "               Il nome di default e' DBSTART.INI"
   CASE nMsg == MSG_INFO07         ; cMsg := "           /FAST = Inizializzazione veloce del mouse"
   CASE nMsg == MSG_INFO08         ; cMsg := "Programma Generato con Visual dBsee %VER% il CASE STANDARD per Xbase++"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFISPIRATE01   ; cMsg := "Programma non protetto//Procedere con la protezione"
   CASE nMsg == MSG_DFISPIRATE02   ; cMsg := "La protezione del programma non e' andata a buon fine"
   CASE nMsg == MSG_DFISPIRATE03   ; cMsg := "Per un corretto funzionamento del programma//procedere con la protezione"
   CASE nMsg == MSG_DFISPIRATE04   ; cMsg := "Copia illegale del programma//contattare il servizio di assistenza tecnica"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCFGPAL01     ; cMsg := "I colori sono cambiati//si desidera salvare i cambiamenti in modo permanente"
   CASE nMsg == MSG_DFCFGPAL02     ; cMsg := "Modifica in corso"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_AS40001        ; cMsg := "Nome del Server : "
   CASE nMsg == MSG_AS40002        ; cMsg := "Connessione AS/400"
   CASE nMsg == MSG_AS40003        ; cMsg := "Errore di Connessione//Controllare la variabile di environment W400ENV"
   CASE nMsg == MSG_AS40004        ; cMsg := "Controllo del file (%FILE%)"
   CASE nMsg == MSG_AS40005        ; cMsg := "Nome della libreria di configurazione : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFDATEFT01     ; cMsg := "Data iniziale :"
   CASE nMsg == MSG_DFDATEFT02     ; cMsg := "Data finale :"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPRNLAB01     ; cMsg := "Etichette per riga"
   CASE nMsg == MSG_DFPRNLAB02     ; cMsg := "Interlinea tra etichette"
   CASE nMsg == MSG_DFPRNLAB03     ; cMsg := "Larghezza etichette"
   CASE nMsg == MSG_DFPRNLAB04     ; cMsg := "Etichetta"
   CASE nMsg == MSG_DFPRNLAB05     ; cMsg := "Funzione da applicare"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCOL2PRN01    ; cMsg := "Colonne da stampare"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCHKDBF01     ; cMsg := "L'header del file//"
   CASE nMsg == MSG_DFCHKDBF02     ; cMsg := "//riporta un numero di record diversi da quelli reali"
   CASE nMsg == MSG_DFCHKDBF03     ; cMsg := "//Valore riportato : "
   CASE nMsg == MSG_DFCHKDBF04     ; cMsg := "//Valore reale     : "
   CASE nMsg == MSG_DFCHKDBF05     ; cMsg := "//Correggo l'errore ?"
   CASE nMsg == MSG_DFCHKDBF06     ; cMsg := "////Una mancata correzione potrebbe portare ad una"
   CASE nMsg == MSG_DFCHKDBF07     ; cMsg := "//perdita di dati, alla prima ricostruzione indici"
   CASE nMsg == MSG_DFCHKDBF08     ; cMsg := "//Effettuate SEMPRE un BACKUP prima di questa operazione"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDFILEST01     ; cMsg := "Scelta campo per statistica"
   CASE nMsg == MSG_DDFILEST02     ; cMsg := "Altri"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFFILEDLG01    ; cMsg := "^Path"
   CASE nMsg == MSG_DFFILEDLG02    ; cMsg := "^Tree"
   CASE nMsg == MSG_DFFILEDLG03    ; cMsg := "^Unit…"
   CASE nMsg == MSG_DFFILEDLG04    ; cMsg := "^WildCard"
   CASE nMsg == MSG_DFFILEDLG05    ; cMsg := "^Files"
   CASE nMsg == MSG_DFFILEDLG06    ; cMsg := "Name"
   CASE nMsg == MSG_DFFILEDLG07    ; cMsg := "Dim"
   CASE nMsg == MSG_DFFILEDLG08    ; cMsg := "Date"
   CASE nMsg == MSG_DFFILEDLG09    ; cMsg := "Time"
   CASE nMsg == MSG_DFFILEDLG10    ; cMsg := "File Dialog"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
ENDCASE

cMsg := STRTRAN( cMsg, "і", "" )

RETURN cMsg

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbDeState( nDeState )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := ""

DO CASE
   CASE nDeState == DE_STATE_INK  ; cRet := dfStdMsg( MSG_DE_STATE_INK  )
   CASE nDeState == DE_STATE_ADD  ; cRet := dfStdMsg( MSG_DE_STATE_ADD  )
   CASE nDeState == DE_STATE_MOD  ; cRet := dfStdMsg( MSG_DE_STATE_MOD  )
   CASE nDeState == DE_STATE_DEL  ; cRet := dfStdMsg( MSG_DE_STATE_DEL  )
   CASE nDeState == DE_STATE_COPY ; cRet := dfStdMsg( MSG_DE_STATE_COPY )
   CASE nDeState == DE_STATE_QRY  ; cRet := dfStdMsg( MSG_DE_STATE_QRY  )
ENDCASE

//#ifdef __XPP__
   //IF LEN(cRet)>2
      //cRet := SUBSTR( cRet, 2, LEN(cRet)-2 )
   //ENDIF
//#endif

RETURN cRet
