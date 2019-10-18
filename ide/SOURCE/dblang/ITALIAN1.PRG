// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Descrizione    : Funzione contenente i messaggi di libreria
// *****************************************************************************
#include "dfMsg1.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStdMsg1( nMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cMsg := ""
DO CASE
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_LANGUAGE       ; cMsg := "ITALIANO"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_INITAPPS01     ; cMsg := "Ho trovato il file dbupdate.log !!"
   CASE nMsg == MSG1_INITAPPS02     ; cMsg := "L'applicazione e' in fase di aggiornamento"
   CASE nMsg == MSG1_INITAPPS03     ; cMsg := "Riprova piu' tardi"
   CASE nMsg == MSG1_INITAPPS04     ; cMsg := "Tempo d'avvio : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DBINK01        ; cMsg := "Tu hai "
   CASE nMsg == MSG1_DBINK02        ; cMsg := " secondi per uscire"
   CASE nMsg == MSG1_DBINK03        ; cMsg := "Secondi : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_TBBRWNEW36     ; cMsg := "Stampa schermo"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFDBFNTX01     ; cMsg := "Database engine DBFDBE not loaded"
   CASE nMsg == MSG1_DFDBFNTX02     ; cMsg := "Database engine NTXDBE not loaded"
   CASE nMsg == MSG1_DFDBFNTX03     ; cMsg := "DBFNTX database engine could not be created"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFDBFCDX01     ; cMsg := "Database engine FOXDBE not loaded"
   CASE nMsg == MSG1_DFDBFCDX02     ; cMsg := "Database engine CDXDBE not loaded"
   CASE nMsg == MSG1_DFDBFCDX03     ; cMsg := "DBFCDX database engine could not be created"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2GETMEN01     ; cMsg := "&Annulla"
   CASE nMsg == MSG1_S2GETMEN02     ; cMsg := "&Taglia"
   CASE nMsg == MSG1_S2GETMEN03     ; cMsg := "&Copia"
   CASE nMsg == MSG1_S2GETMEN04     ; cMsg := "&Incolla"
   CASE nMsg == MSG1_S2GETMEN05     ; cMsg := "&Elimina"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFPRNMENU01    ; cMsg := "Fon^t"
   CASE nMsg == MSG1_DFPRNMENU02    ; cMsg := "Stampante non valida"
   CASE nMsg == MSG1_DFPRNMENU03    ; cMsg := "Pag."
   CASE nMsg == MSG1_DFPRNMENU04    ; cMsg := "Anteprima Pagina "
   CASE nMsg == MSG1_DFPRNMENU05    ; cMsg := "Stampante non Definita!"
   CASE nMsg == MSG1_DFPRNMENU06    ; cMsg := "Stampa Pagina "
   CASE nMsg == MSG1_DFPRNMENU07    ; cMsg := "Attesa..."
   CASE nMsg == MSG1_DFPRNMENU08    ; cMsg := "Nessuna stampante installata.//E' necessario installare una stampante nel sistema."
   CASE nMsg == MSG1_DFPRNMENU09    ; cMsg := "Nessuna proprieta' da impostare"

   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFMAILCO01     ; cMsg := "^A:"
   CASE nMsg == MSG1_DFMAILCO02     ; cMsg := "Indicare i destinatari"
   CASE nMsg == MSG1_DFMAILCO03     ; cMsg := "^CC:"
   CASE nMsg == MSG1_DFMAILCO04     ; cMsg := "Indicare i destinatari CC"
   CASE nMsg == MSG1_DFMAILCO05     ; cMsg := "^BCC:"
   CASE nMsg == MSG1_DFMAILCO06     ; cMsg := "Indicare i destinatari BCC"
   CASE nMsg == MSG1_DFMAILCO07     ; cMsg := "^Oggetto:"
   CASE nMsg == MSG1_DFMAILCO08     ; cMsg := "Indicare l'oggetto del messaggio"
   CASE nMsg == MSG1_DFMAILCO09     ; cMsg := "^Testo del messaggio"
   CASE nMsg == MSG1_DFMAILCO10     ; cMsg := "Indicare il testo del messaggio"
   CASE nMsg == MSG1_DFMAILCO11     ; cMsg := "^Invia"
   CASE nMsg == MSG1_DFMAILCO12     ; cMsg := "^Files allegati"
   CASE nMsg == MSG1_DFMAILCO13     ; cMsg := "Inserisci allegato"
   CASE nMsg == MSG1_DFMAILCO14     ; cMsg := "Togli allegato"
   CASE nMsg == MSG1_DFMAILCO15     ; cMsg := "Composizione Messaggio"
   CASE nMsg == MSG1_DFMAILCO16     ; cMsg := "Allega Files"
   CASE nMsg == MSG1_DFMAILCO17     ; cMsg := "Non Љ stato specificato l'oggetto del messaggio//Inviare ugualmente l'email ?"
   CASE nMsg == MSG1_DFMAILCO18     ; cMsg := "Non Љ stato specificato nessun destinatario.//Impossibile inviare l'email."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFGETW01       ; cMsg := "Richiesta Dati"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PI01         ; cMsg := "Interrompere ?"
   CASE nMsg == MSG1_S2PI02         ; cMsg := "Annulla"
   CASE nMsg == MSG1_S2PI03         ; cMsg := "Attendere"
   CASE nMsg == MSG1_S2PI04         ; cMsg := "Attendere prego..."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2CALENDAR01   ; cMsg := "Calendario"
   CASE nMsg == MSG1_S2CALENDAR02   ; cMsg := "Oggi"
   CASE nMsg == MSG1_S2CALENDAR03   ; cMsg := "Esci"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PRNMNU01     ; cMsg := "Menu di stampa"
   CASE nMsg == MSG1_S2PRNMNU02     ; cMsg := "&Filtro"
   CASE nMsg == MSG1_S2PRNMNU03     ; cMsg := "&Anteprima"
   CASE nMsg == MSG1_S2PRNMNU04     ; cMsg := "&Stampa"
   CASE nMsg == MSG1_S2PRNMNU05     ; cMsg := "A&nnulla"
   CASE nMsg == MSG1_S2PRNMNU06     ; cMsg := "Opzioni di stampa"
   CASE nMsg == MSG1_S2PRNMNU07     ; cMsg :=  "&Dispositivi"
   CASE nMsg == MSG1_S2PRNMNU08     ; cMsg := "Carattere"
   CASE nMsg == MSG1_S2PRNMNU09     ; cMsg := "Normale"
   CASE nMsg == MSG1_S2PRNMNU10     ; cMsg := "Compresso"
   CASE nMsg == MSG1_S2PRNMNU11     ; cMsg := "Pa&gine"
   CASE nMsg == MSG1_S2PRNMNU12     ; cMsg := "&Margini"
   CASE nMsg == MSG1_S2PRNMNU13     ; cMsg := "Dispositivo di stampa n. "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISWP01     ; cMsg := "Stampante Windows"
   CASE nMsg == MSG1_S2PDISWP02     ; cMsg := "Stampa s&u"
   CASE nMsg == MSG1_S2PDISWP03     ; cMsg := "&Propriet…"
   CASE nMsg == MSG1_S2PDISWP04     ; cMsg := "&Imposta font"
   CASE nMsg == MSG1_S2PDISWP05     ; cMsg := "Formato &carta"
   CASE nMsg == MSG1_S2PDISWP06     ; cMsg := "A&limentazione"
   CASE nMsg == MSG1_S2PDISWP07     ; cMsg := "Copi&e"
   CASE nMsg == MSG1_S2PDISWP08     ; cMsg := "Nessuna stampante Windows installata"
   CASE nMsg == MSG1_S2PDISWP09     ; cMsg := "(sconosciuta)"
   CASE nMsg == MSG1_S2PDISWP10     ; cMsg := "Impossibile utilizzare la stampante//"
   CASE nMsg == MSG1_S2PDISWP11     ; cMsg := "//Errore durante la lettura delle caratteristiche//del driver di stampa."
   CASE nMsg == MSG1_S2PDISWP12     ; cMsg := "%printer% su %name%"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDIS01       ; cMsg := "Dispositivo di stampa generico"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISCL01     ; cMsg := "Stampa su Appunti (Clipboard)"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISPR01     ; cMsg := "Anteprima di stampa"
   CASE nMsg == MSG1_S2PDISPR02     ; cMsg := "Impossibile utilizzare la stampante//"
   CASE nMsg == MSG1_S2PDISPR03     ; cMsg := "//Errore durante la lettura delle caratteristiche//del driver di stampa."
   CASE nMsg == MSG1_S2PDISPR04     ; cMsg := "(sconosciuta)"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISFI01     ; cMsg := "Stampa su FILE"
   CASE nMsg == MSG1_S2PDISFI02     ; cMsg := "Nome &del file"
   CASE nMsg == MSG1_S2PDISFI03     ; cMsg := "Sfog&lia"
   CASE nMsg == MSG1_S2PDISFI04     ; cMsg := "Crea file"
   CASE nMsg == MSG1_S2PDISFI05     ; cMsg := "Tip&o File"
   CASE nMsg == MSG1_S2PDISFI06     ; cMsg := "A&prire File"
   CASE nMsg == MSG1_S2PDISFI07     ; cMsg := "Ori&entamento Stampa"
   CASE nMsg == MSG1_S2PDISFI08     ; cMsg := "Errore Creazione File Pdf"
   CASE nMsg == MSG1_S2PDISFI09     ; cMsg := "Verticale"
   CASE nMsg == MSG1_S2PDISFI10     ; cMsg := "Orizzontale"
   CASE nMsg == MSG1_S2PDISFI11     ; cMsg := "Stampa Pdf Terminata"
   CASE nMsg == MSG1_S2PDISFI12     ; cMsg := "Nome file Obbligatorio"
   CASE nMsg == MSG1_S2PDISFI13     ; cMsg := "Fascicola"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISMF01     ; cMsg := "Stampa su FAX (MAPI)"
   CASE nMsg == MSG1_S2PDISMF02     ; cMsg := "Numeri di &Telefono:"
   CASE nMsg == MSG1_S2PDISMF03     ; cMsg := "Indicare almeno un numero di Fax"
   CASE nMsg == MSG1_S2PDISMF04     ; cMsg := "Invio Fax in corso...//"
   CASE nMsg == MSG1_S2PDISMF05     ; cMsg := "Stampa"
   CASE nMsg == MSG1_S2PDISMF06     ; cMsg := "In allegato file di testo della stampa in oggetto"
   CASE nMsg == MSG1_S2PDISMF07     ; cMsg := "Errore durante invio Fax:"
   CASE nMsg == MSG1_S2PDISMF08     ; cMsg := "Errore Creazione File Pdf-Fax:"
   CASE nMsg == MSG1_S2PDISMF09     ; cMsg := "Messaggio Fax..."
   CASE nMsg == MSG1_S2PDISMF10     ; cMsg := "Ori&entamento Stampa:"
   CASE nMsg == MSG1_S2PDISMF11     ; cMsg := "Formato &carta:"
   CASE nMsg == MSG1_S2PDISMF12     ; cMsg := "Mantenere Formato &Immagini, Grassetto e Bordi"
   CASE nMsg == MSG1_S2PDISMF13     ; cMsg := "&Oggetto Fax:"
   CASE nMsg == MSG1_S2PDISMF14     ; cMsg := "Co&rpo Fax:"
   CASE nMsg == MSG1_S2PDISMF15     ; cMsg := "Spedizione Fax Terminata"
   CASE nMsg == MSG1_S2PDISMF16     ; cMsg := "I seguenti campi sono vuoti. Inviare Fax?"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISMM01     ; cMsg := "Stampa su posta elettronica (MAPI)"
   CASE nMsg == MSG1_S2PDISMM02     ; cMsg := "&Indirizzi di posta:"
   CASE nMsg == MSG1_S2PDISMM03     ; cMsg := "Indicare almeno un indirizzo email"
   CASE nMsg == MSG1_S2PDISMM04     ; cMsg := "Invio messaggio in corso...//"
   CASE nMsg == MSG1_S2PDISMM05     ; cMsg := "Stampa"
   CASE nMsg == MSG1_S2PDISMM06     ; cMsg := "In allegato file della stampa in oggetto"
   CASE nMsg == MSG1_S2PDISMM07     ; cMsg := "Errore durante invio email:"
   CASE nMsg == MSG1_S2PDISMM08     ; cMsg := "Spedizione Email Terminata"
   CASE nMsg == MSG1_S2PDISMM09     ; cMsg := "&ZIP file"
   CASE nMsg == MSG1_S2PDISMM10     ; cMsg := "Compressione file %file% in corso..."

   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISSM01     ; cMsg := "Stampa su E-Mail (SMTP)"
   CASE nMsg == MSG1_S2PDISSM02     ; cMsg := "I&ndirizzi E-Mail:"
   CASE nMsg == MSG1_S2PDISSM03     ; cMsg := "Indicare almeno un indirizzo email"
   CASE nMsg == MSG1_S2PDISSM04     ; cMsg := "Impostare il server di posta in uscita (XBaseSMTPServer)"
   CASE nMsg == MSG1_S2PDISSM05     ; cMsg := "Impostare l'email dell'invio utente (XBaseSMTPFrom)"
   CASE nMsg == MSG1_S2PDISSM06     ; cMsg := "Invio messaggio in corso...//"
   CASE nMsg == MSG1_S2PDISSM07     ; cMsg := "Stampa"
   CASE nMsg == MSG1_S2PDISSM08     ; cMsg := "In allegato file della stampa in oggetto"
   CASE nMsg == MSG1_S2PDISSM09     ; cMsg := "Errore durante invio email:"
   CASE nMsg == MSG1_S2PDISSM10     ; cMsg := "Ogge&tto:"
   CASE nMsg == MSG1_S2PDISSM11     ; cMsg := "Corpo &Email:"
   CASE nMsg == MSG1_S2PDISSM12     ; cMsg := "Spedizione Email Terminata"
   CASE nMsg == MSG1_S2PDISSM13     ; cMsg := "I seguenti campi sono vuoti. Inviare E-Mail?"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISDP01     ; cMsg := "Stampante DOS"
   CASE nMsg == MSG1_S2PDISDP02     ; cMsg := "Stampa s&u"
   CASE nMsg == MSG1_S2PDISDP03     ; cMsg := "&Porta di stampa"
   CASE nMsg == MSG1_S2PDISDP04     ; cMsg := "Qualita"
   CASE nMsg == MSG1_S2PDISDP05     ; cMsg := "N&ormale"
   CASE nMsg == MSG1_S2PDISDP06     ; cMsg := "A&lta"
   CASE nMsg == MSG1_S2PDISDP07     ; cMsg := "Setup"
   CASE nMsg == MSG1_S2PDISDP08     ; cMsg := "Usa Setup &1"
   CASE nMsg == MSG1_S2PDISDP09     ; cMsg := "Usa Setup &2"
   CASE nMsg == MSG1_S2PDISDP10     ; cMsg := "Usa Setup &3"
   CASE nMsg == MSG1_S2PDISDP11     ; cMsg := "Copi&e"
   CASE nMsg == MSG1_S2PDISDP12     ; cMsg := "Nessuna stampante DOS installata"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFWINPRN01     ; cMsg := "Imposta font "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFWINPRD01     ; cMsg := "Normale"
   CASE nMsg == MSG1_DFWINPRD02     ; cMsg := "Imposta"
   CASE nMsg == MSG1_DFWINPRD03     ; cMsg := "Font normale"
   CASE nMsg == MSG1_DFWINPRD04     ; cMsg := "Font grassetto"
   CASE nMsg == MSG1_DFWINPRD05     ; cMsg := "Font compresso"
   CASE nMsg == MSG1_DFWINPRD06     ; cMsg := "Font compresso grassetto"
   CASE nMsg == MSG1_DFWINPRD07     ; cMsg := "&Ok"
   CASE nMsg == MSG1_DFWINPRD08     ; cMsg := "&Annulla"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DBMSGERR01     ; cMsg := "Errore"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFALERT01      ; cMsg := "Attenzione"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFYESNO01      ; cMsg := "Richiesta"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISCP01     ; cMsg := "Stampante Windows"
   CASE nMsg == MSG1_S2PDISCP02     ; cMsg := "File non trovato: "
   CASE nMsg == MSG1_S2PDISCP03     ; cMsg := "File creato: "
   CASE nMsg == MSG1_S2PDISCP04     ; cMsg := "Errore in caricamento Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCP05     ; cMsg := "Errore in stampa: "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISCV01     ; cMsg := "Anteprima"
   CASE nMsg == MSG1_S2PDISCV02     ; cMsg := "File non trovato: "
   CASE nMsg == MSG1_S2PDISCV03     ; cMsg := "File creato: "
   CASE nMsg == MSG1_S2PDISCV04     ; cMsg := "Errore in caricamento Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCV05     ; cMsg := "Errore in anteprima: "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISCF01     ; cMsg := "Stampa su FILE"
   CASE nMsg == MSG1_S2PDISCF02     ; cMsg := "File non trovato: "
   CASE nMsg == MSG1_S2PDISCF03     ; cMsg := "File creato: "
   CASE nMsg == MSG1_S2PDISCF04     ; cMsg := "Errore in caricamento Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCF05     ; cMsg := "Errore in esportazione: "
   CASE nMsg == MSG1_S2PDISCF06     ; cMsg := "Esportazione non disponibile"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   //CASE nMsg == MSG1_DFPDF01        ; cMsg := "Inizializzazione Pdf non Corretta"
   CASE nMsg == MSG1_DFPDF02        ; cMsg := "Creazione file PDF pag."
   //CASE nMsg == MSG1_DFPDF03        ; cMsg := "Errore in Inizializzazione Classe PdfFont"
   //CASE nMsg == MSG1_DFPDF04        ; cMsg := "Errore in Formato Compound Name"
   CASE nMsg == MSG1_DFPDF05        ; cMsg := "ACROBAT READER non e' correttamente Installato"
   CASE nMsg == MSG1_DFPDF06        ; cMsg := "Attendere prego...//...Elaborazione Immagine in corso"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFTIFF01       ; cMsg := "Errore in Caricamento Dll dbImage.dll!"
   CASE nMsg == MSG1_DFTIFF02       ; cMsg := "Errore in conversione Bmp -> Tiff"
   CASE nMsg == MSG1_DFTIFF03       ; cMsg := "TIFF Resolution Tag non trovato!"
   CASE nMsg == MSG1_DFTIFF04       ; cMsg := "Errore in Settaggio Risoluzione"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFJPG01        ; cMsg := "JPEG Resolution Tag non trovato!"
   CASE nMsg == MSG1_DFJPG02        ; cMsg := "Errore in conversione Bmp -> JPEG"
   CASE nMsg == MSG1_DFJPG03        ; cMsg := "Errore in Settaggio Risoluzione"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFBMP01        ; cMsg := "BMP Resolution Tag non trovato!"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_CRW01          ; cMsg := "Errore: La Banda del Report con Alias <%band%>//"+;
                                              "Non contiene tutti campi della chiave nш %nrel%//"+;
                                              "E' necessario aggiungere nella banda di stampa dell'archivio %band%//"+;
                                              "i campi: %fields%//"+;
                                              "Non sar… possibile costruire le Relazioni in Crystal Report!"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFREPTYP01; cMsg := "Report Manager print engine (reportman.ocx) non trovato//Impossibile stampare."
   CASE nMsg == MSG1_DFREPTYP02; cMsg := "Report File non trovato//%file%"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFWAIT01      ; cMsg := "Attendere prego..."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_TOOLCLASS01   ; cMsg := "Configura Toolbar..."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_TOOLTIPMINCHARS; cMsg := "Caratteri rimanenti: %nchars%"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

   CASE nMsg == MSG1_DDKEYWIN0000  ; cMsg := "Ricerca Informazioni"
   CASE nMsg == MSG1_DDKEYWIN0010  ; cMsg := "Cerca"
   CASE nMsg == MSG1_DDKEYWIN0020  ; cMsg := "Filtro generico"
   CASE nMsg == MSG1_DDKEYWIN0030  ; cMsg := "Stampa"
   CASE nMsg == MSG1_DDKEYWIN0040  ; cMsg := "Stampa elenco records"
   CASE nMsg == MSG1_DDKEYWIN0050  ; cMsg := "Conferma i dati (F10)"
   CASE nMsg == MSG1_DDKEYWIN0060  ; cMsg := "Fine operazioni (Esc)"
   CASE nMsg == MSG1_DDKEYWIN0070  ; cMsg := "Aiuto (F1)"
   CASE nMsg == MSG1_DDKEYWIN0080  ; cMsg := "Aiuto (Shift-F1)"
   CASE nMsg == MSG1_DDKEYWIN0090  ; cMsg := "Criteri di selezione"
   CASE nMsg == MSG1_DDKEYWIN0100  ; cMsg := "Records"
   CASE nMsg == MSG1_DDKEYWIN0110  ; cMsg := "Seleziona record"
   CASE nMsg == MSG1_DDKEYWIN0120  ; cMsg := "Pagina Successiva"
   CASE nMsg == MSG1_DDKEYWIN0130  ; cMsg := "Pagina Precedente"
   CASE nMsg == MSG1_DDKEYWIN0140  ; cMsg := "C~erca:"
   CASE nMsg == MSG1_DDKEYWIN0150  ; cMsg := "~Ordinamento:"
   CASE nMsg == MSG1_DDKEYWIN0160  ; cMsg := "Togli ^Filtro"
   CASE nMsg == MSG1_DDKEYWIN0170  ; cMsg := "Imposta ^Filtro"
   CASE nMsg == MSG1_DDKEYWIN0180  ; cMsg := "Nessun record corrisponde alla selezione impostata"
   CASE nMsg == MSG1_DDKEYWIN0190  ; cMsg := "(filtro generico impostato, premi 'Togli Filtro' per abilitare la ricerca)"
   CASE nMsg == MSG1_DDKEYWIN0200  ; cMsg := "Espressione di edit non valida//"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFUSEREVENTWAIT1; cMsg := "Attenzione!//Entro %count% Sec. verr… terminata la corrente procedura!//Premere un tasto sulla Tastiera per continuare." 

   CASE nMsg == MSG1_DFMAKEIND000  ; cMsg := "Errore in creazione indice %file%//Verificare i diritti di accesso alla cartella."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DDFILESTA000  ; cMsg := "Errore in creazione file temporanei//Verificare i diritti di accesso alla cartella %file%."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFGRAPH30000  ; cMsg := "Stampa"
   CASE nMsg == MSG1_DFGRAPH30010  ; cMsg := "Stampa il grafico"
   CASE nMsg == MSG1_DFGRAPH30020  ; cMsg := "E' possibile stampare il grafico solo su stampanti Windows"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

ENDCASE
RETURN cMsg
