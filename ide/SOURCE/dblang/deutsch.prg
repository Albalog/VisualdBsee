// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Visual dBsee 
// Subset der System-Library Meldungen Deutsch
// šbersetzung: Helmut Knappe, dc soft
// *****************************************************************************
//------------------------------------------------------------
//
//Funktion:
//
//     dfStdMsg()
//
//Zweck:
//
//     Gibt die Meldungen der Anwendung zurck
//
//Syntax:
//
//     dfStdMsg( <nMsg> ) --> cMsg
//
//Parameter:
//
//     <nMsg>     Nummer der Meldung, die in String umgewandelt werden soll
//
//Rckgabe:
//
//     <cMsg>     Zugeh”riger Meldungstext
//
//Beschreibung:
//
//     Auf Angabe der Meldungsnummer gibt diese Funktion den zugeh”rigen String
//     zurck. Sie k”nnen auch die in Visual dBsee  definierten Konstanten verwenden.
//     Die Definitionen stehen in der Header-Datei DFMSG.CH.
//
//     Die meisten Visual dBsee -Library-Module rufen diese Funktion auf um die passende
//     Meldung zu bekommen. Die Funktion liegt in den Visual dBsee  Libraries schon
//     vorkompiliert vor. Wenn die Standard-Library-Meldungen ge„ndert werden
//     sollen, bersetzen Sie diese Datei und kompilieren sie.
//
//     Dies haben wir fr Sie bereits gemacht. Aber falls Sie noch nderungen
//     anbringen m”chten mssen Sie so verfahren (dc soft GmbH).
//
//     Sie sollten eine Backup-Kopie der Datei anlegen, bevor Sie nderungen
//     durchfhren. Beachten Sie, daá ein Upgrade oder Update diese Datei wieder
//     berschreiben kann.
//
//     Kompilieren Sie das Programm mit: XPP deutsch -n [-l -m -w]
//
//     Damit das System die neuen Meldungen erkennt, fgen Sie diese Datei zur
//     Liste der Externals in Ihrem Projekt hinzu, damit das Objekt mit
//     eingebunden wird. Falls sie die nderungen festschreiben wollen,
//     k”nnen sie das Modul ENGLISH aus der Library entfernen und durch das
//     neu kompilierte DEUTSCH ersetzen.
//
//Beispiel:
//
//     #include "dfMsg.ch"
//     ? dfStdMsg( MSG_DE_STATE_ADD ) // "Einfgen"
//     // Zugeh”rige Meldung zurckgeben
//     // code MSG_DE_STATE_ADD (siehe dfmsg.ch)
//
//------------------------------------------------------------
#include "dfmsg.ch"
#include "dfState.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStdMsg( nMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cMsg := ""
DO CASE
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_LANGUAGE       ; cMsg := "DEUTSCH"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_INITERROR      ; cMsg := "Kann Init-Datei nicht ”ffnen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_STD_YES        ; cMsg := "^Ja"
   CASE nMsg == MSG_STD_NO         ; cMsg := "^Nein"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_TABGET01       ; cMsg := "Keine Referenz in dbDD//Feld "
   CASE nMsg == MSG_TABGET02       ; cMsg := " nicht gefunden "
   CASE nMsg == MSG_TABGET03       ; cMsg := "Fehler beim ™ffnen von DBDD.DBF"
   CASE nMsg == MSG_TABGET04       ; cMsg := "Fehler beim ™ffnen von DBTABD.DBF"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_TABCHK01       ; cMsg := "Fenster auf "
   CASE nMsg == MSG_TABCHK02       ; cMsg := " nicht verfgbar!//"
   CASE nMsg == MSG_TABCHK03       ; cMsg := "Datei: "
   CASE nMsg == MSG_TABCHK04       ; cMsg := " ist leer !"
   CASE nMsg == MSG_TABCHK05       ; cMsg := "Kann Feld nicht leer lassen//("
   CASE nMsg == MSG_TABCHK06       ; cMsg := "Feld//("
   CASE nMsg == MSG_TABCHK07       ; cMsg := ")//Wert://"
   CASE nMsg == MSG_TABCHK08       ; cMsg := "nicht in Datei: "
   CASE nMsg == MSG_TABCHK09       ; cMsg := "//einfgen"
   CASE nMsg == MSG_TABCHK10       ; cMsg := "Feld//("
   CASE nMsg == MSG_TABCHK11       ; cMsg := ")//Wert://"
   CASE nMsg == MSG_TABCHK12       ; cMsg := "nicht in Tabelle"
   CASE nMsg == MSG_TABCHK13       ; cMsg := "Tabellen-Schlsselfeld"
   CASE nMsg == MSG_TABCHK14       ; cMsg := "Nicht gefunden"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_ERRSYS01       ; cMsg := "Ungltige Funktionsnummer"
   CASE nMsg == MSG_ERRSYS02       ; cMsg := "Datei nicht gefunden"
   CASE nMsg == MSG_ERRSYS03       ; cMsg := "Pfad nicht gefunden"
   CASE nMsg == MSG_ERRSYS04       ; cMsg := "Zu viele offene Dateien"
   CASE nMsg == MSG_ERRSYS05       ; cMsg := "Zugriff verweigert"
   CASE nMsg == MSG_ERRSYS06       ; cMsg := "Nicht gengend Speicher"
   CASE nMsg == MSG_ERRSYS07       ; cMsg := "Reserviert"
   CASE nMsg == MSG_ERRSYS08       ; cMsg := "Diskette ist schreibgeschtzt"
   CASE nMsg == MSG_ERRSYS09       ; cMsg := "Unbekannter Befehl"
   CASE nMsg == MSG_ERRSYS10       ; cMsg := "Schreibfehler"
   CASE nMsg == MSG_ERRSYS11       ; cMsg := "Lesefehler"
   CASE nMsg == MSG_ERRSYS12       ; cMsg := "Allgemeiner Fehler"
   //   nMsg == MSG_ERRSYS13       ; cMsg := "Zugriff verweigert"
   CASE nMsg == MSG_ERRSYS14       ; cMsg := "Datei existiert bereits"
   CASE nMsg == MSG_ERRSYS15       ; cMsg := "Dieser Fehler wurde gespeichert in Datei :"
   CASE nMsg == MSG_ERRSYS16       ; cMsg := "Beliebige Taste drcken um fortzufahren..."
   CASE nMsg == MSG_ERRSYS17       ; cMsg := "Ungltiger Handle"
   CASE nMsg == MSG_ERRSYS18       ; cMsg := "RAM-Speicher"
   CASE nMsg == MSG_ERRSYS19       ; cMsg := "RAM-Speicher"
   CASE nMsg == MSG_ERRSYS20       ; cMsg := "Ungltiges Environment"
   CASE nMsg == MSG_ERRSYS21       ; cMsg := "ungltiges Format"
   CASE nMsg == MSG_ERRSYS22       ; cMsg := "ungltiger Zugriffscode"
   CASE nMsg == MSG_ERRSYS23       ; cMsg := "Ungltige Daten"
   CASE nMsg == MSG_ERRSYS24       ; cMsg := "Ungltiges Laufwerk"
   CASE nMsg == MSG_ERRSYS25       ; cMsg := "Verzeichnis konnte nicht entfernt werden"
   CASE nMsg == MSG_ERRSYS26       ; cMsg := "Nicht selbe Einheit"
   CASE nMsg == MSG_ERRSYS27       ; cMsg := "Keine weiteren Dateien"
   CASE nMsg == MSG_ERRSYS28       ; cMsg := "Unbekannte Einheit"
   CASE nMsg == MSG_ERRSYS29       ; cMsg := "Laufwerk nicht bereit"
   CASE nMsg == MSG_ERRSYS30       ; cMsg := "Daten Fehler (CRC)"
   CASE nMsg == MSG_ERRSYS31       ; cMsg := "Falsche Anfrage"
   CASE nMsg == MSG_ERRSYS32       ; cMsg := "Seek Fehler"
   CASE nMsg == MSG_ERRSYS33       ; cMsg := "In unbekanntem Format formatiert"
   CASE nMsg == MSG_ERRSYS34       ; cMsg := "Sektor nicht gefunden"
   CASE nMsg == MSG_ERRSYS35       ; cMsg := "Drucker hat kein Papier"
   CASE nMsg == MSG_ERRSYS36       ; cMsg := "Sharing violation"
   CASE nMsg == MSG_ERRSYS37       ; cMsg := "Lock violation"
   CASE nMsg == MSG_ERRSYS38       ; cMsg := "Ungltiger Diskwechsel"
   CASE nMsg == MSG_ERRSYS39       ; cMsg := "FCB nicht verfgbar"
   CASE nMsg == MSG_ERRSYS40       ; cMsg := "Sharing buffer overflow"
   CASE nMsg == MSG_ERRSYS41       ; cMsg := "Netzwerkanfrage nicht untersttzt"
   CASE nMsg == MSG_ERRSYS42       ; cMsg := "Gegenstelle antwortet nicht"
   CASE nMsg == MSG_ERRSYS43       ; cMsg := "Doppelter Name im Netzwerk"
   CASE nMsg == MSG_ERRSYS44       ; cMsg := "Netzwerkname nicht gefunden"
   CASE nMsg == MSG_ERRSYS45       ; cMsg := "Netzwerk belegt"
   CASE nMsg == MSG_ERRSYS46       ; cMsg := "Netzwerk Einheit existiert nicht mehr"
   CASE nMsg == MSG_ERRSYS47       ; cMsg := "Network BIOS command limit exceeded"
   CASE nMsg == MSG_ERRSYS48       ; cMsg := "Netzwerk-Adapter hat Hardware Fehler"
   CASE nMsg == MSG_ERRSYS49       ; cMsg := "Ungltige Antwort vom Netzwerk"
   CASE nMsg == MSG_ERRSYS50       ; cMsg := "Unerwarteter Netzwerkfehler"
   CASE nMsg == MSG_ERRSYS51       ; cMsg := "Inkompatibler Gegenstellen-Adapter"
   CASE nMsg == MSG_ERRSYS52       ; cMsg := "Druckerschlange voll"
   CASE nMsg == MSG_ERRSYS53       ; cMsg := "Nicht gengend Platz fr Spooldatei"
   CASE nMsg == MSG_ERRSYS54       ; cMsg := "Spooldatei gel”scht (nicht genug Platz)"
   CASE nMsg == MSG_ERRSYS55       ; cMsg := "Netzwerkname gel”scht"
   CASE nMsg == MSG_ERRSYS56       ; cMsg := "ungltiger Netzwerkeinheit-Typ"
   //   nMsg == MSG_ERRSYS57       ; cMsg := "Netzwerkname nicht gefunden"
   CASE nMsg == MSG_ERRSYS58       ; cMsg := "Network name limit exceeded"
   CASE nMsg == MSG_ERRSYS59       ; cMsg := "Network BIOS session limit exceeded"
   CASE nMsg == MSG_ERRSYS60       ; cMsg := "zeitweise gestoppt"
   CASE nMsg == MSG_ERRSYS61       ; cMsg := "Netzwerk-Anfrage nicht akzeptiert"
   CASE nMsg == MSG_ERRSYS62       ; cMsg := "Druck oder Diskumleitung zeitweise gestoppt"
   CASE nMsg == MSG_ERRSYS63       ; cMsg := "Konnte keinen Verzeichniseintrag anlegen"
   CASE nMsg == MSG_ERRSYS64       ; cMsg := "Fehler beim INT 24H"
   CASE nMsg == MSG_ERRSYS65       ; cMsg := "Zu viele Umleitunegn im Netz"
   CASE nMsg == MSG_ERRSYS66       ; cMsg := "Doppelte Umleitung"
   CASE nMsg == MSG_ERRSYS67       ; cMsg := "ungltiges Passwort"
   CASE nMsg == MSG_ERRSYS68       ; cMsg := "ungltiger Parameter"
   CASE nMsg == MSG_ERRSYS69       ; cMsg := "Fehler in Netzwerkeinheit"
   CASE nMsg == MSG_ERRSYS70       ; cMsg := "Beenden"
   CASE nMsg == MSG_ERRSYS71       ; cMsg := "Wiederholen"
   CASE nMsg == MSG_ERRSYS72       ; cMsg := "šbergehen"
   CASE nMsg == MSG_ERRSYS73       ; cMsg := "DOS Fehler :="
   CASE nMsg == MSG_ERRSYS74       ; cMsg := "Abbruch"
   CASE nMsg == MSG_ERRSYS75       ; cMsg := "Aufgerufen von"
   CASE nMsg == MSG_ERRSYS76       ; cMsg := "Fehler "
   CASE nMsg == MSG_ERRSYS77       ; cMsg := "Warnung "
   CASE nMsg == MSG_ERRSYS78       ; cMsg := "Undefinerter oder reservierter Fehlercode!"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DBPATH01       ; cMsg := "Lese Pfad : @"
   CASE nMsg == MSG_DBPATH02       ; cMsg := "Variablenname existiert nicht"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDUSE01        ; cMsg := "Datei existiert nicht:"
   CASE nMsg == MSG_DDUSE02        ; cMsg := "™ffne Datei :"
   CASE nMsg == MSG_DDUSE03        ; cMsg := "Fehler in Variablenname: "
   CASE nMsg == MSG_DDUSE04        ; cMsg := "Unbekannter Modus!"
   CASE nMsg == MSG_DDUSE05        ; cMsg := "Datei-Index :"
   //   nMsg == MSG_DDUSE06        ; cMsg := "Fehler in Variablenname: "
   CASE nMsg == MSG_DDUSE07        ; cMsg := "Fehler beim ™ffnen der Datei"
   CASE nMsg == MSG_DDUSE08        ; cMsg := "Kann Datei nicht ”ffnen"
   CASE nMsg == MSG_DDUSE09        ; cMsg := "Zeitberschreitung :"
   CASE nMsg == MSG_DDUSE10        ; cMsg := "Index nicht gefunden"
   CASE nMsg == MSG_DDUSE11        ; cMsg := "Unable to open file %file%. The file is used by other users.//Please try again later."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DBMSGERR       ; cMsg := "OK"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DE_STATE_INK   ; cMsg := "³Ansicht³"
   CASE nMsg == MSG_DE_STATE_ADD   ; cMsg := "³Einfgen³"
   CASE nMsg == MSG_DE_STATE_MOD   ; cMsg := "³ndern³"
   CASE nMsg == MSG_DE_STATE_DEL   ; cMsg := "³L”schen³"
   CASE nMsg == MSG_DE_STATE_COPY  ; cMsg := "³Kopieren³"
   CASE nMsg == MSG_DE_STATE_QRY   ; cMsg := "³Abfrage³"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_TBSKIP01       ; cMsg := " ist leer !!"
   CASE nMsg == MSG_TBSKIP02       ; cMsg := "Dateianfang erreicht bei: "
   CASE nMsg == MSG_TBSKIP03       ; cMsg := "Dateiende erreicht bei: "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DE_DEL         ; cMsg := "Best„tigung fr Satz l”schen !"
   CASE nMsg == MSG_DE_NOTMOD      ; cMsg := "Keine S„tze zu „ndern !"
   CASE nMsg == MSG_DE_NOTDEL      ; cMsg := "Keine S„tze zu l”schen !"
   CASE nMsg == MSG_DE_NOTADD      ; cMsg := "It is not possible to add Record if the head table is empty: "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_NUM2WORD01     ; cMsg := "ein"
   CASE nMsg == MSG_NUM2WORD02     ; cMsg := "zwei"
   CASE nMsg == MSG_NUM2WORD03     ; cMsg := "drei"
   CASE nMsg == MSG_NUM2WORD04     ; cMsg := "vier"
   CASE nMsg == MSG_NUM2WORD05     ; cMsg := "fnf"
   CASE nMsg == MSG_NUM2WORD06     ; cMsg := "sechs"
   CASE nMsg == MSG_NUM2WORD07     ; cMsg := "sieben"
   CASE nMsg == MSG_NUM2WORD08     ; cMsg := "acht"
   CASE nMsg == MSG_NUM2WORD09     ; cMsg := "neun"
   CASE nMsg == MSG_NUM2WORD10     ; cMsg := "zehn"
   CASE nMsg == MSG_NUM2WORD11     ; cMsg := "elf"
   CASE nMsg == MSG_NUM2WORD12     ; cMsg := "zw”lf"
   CASE nMsg == MSG_NUM2WORD13     ; cMsg := "dreizehn"
   CASE nMsg == MSG_NUM2WORD14     ; cMsg := "vierzehn"
   CASE nMsg == MSG_NUM2WORD15     ; cMsg := "fnfzehn"
   CASE nMsg == MSG_NUM2WORD16     ; cMsg := "sechzehn"
   CASE nMsg == MSG_NUM2WORD17     ; cMsg := "siebzehn"
   CASE nMsg == MSG_NUM2WORD18     ; cMsg := "achtzehn"
   CASE nMsg == MSG_NUM2WORD19     ; cMsg := "neunzehn"
   CASE nMsg == MSG_NUM2WORD20     ; cMsg := "zehn"
   CASE nMsg == MSG_NUM2WORD21     ; cMsg := "zwanzig"
   CASE nMsg == MSG_NUM2WORD22     ; cMsg := "dreiáig"
   CASE nMsg == MSG_NUM2WORD23     ; cMsg := "vierzig"
   CASE nMsg == MSG_NUM2WORD24     ; cMsg := "fnfzig"
   CASE nMsg == MSG_NUM2WORD25     ; cMsg := "sechzig"
   CASE nMsg == MSG_NUM2WORD26     ; cMsg := "siebzig"
   CASE nMsg == MSG_NUM2WORD27     ; cMsg := "achtzig"
   CASE nMsg == MSG_NUM2WORD28     ; cMsg := "neunzig"
   CASE nMsg == MSG_NUM2WORD29     ; cMsg := " Milliarde"
   CASE nMsg == MSG_NUM2WORD30     ; cMsg := " Million"
   CASE nMsg == MSG_NUM2WORD31     ; cMsg := " Tausend"
   CASE nMsg == MSG_NUM2WORD32     ; cMsg := "Null"
   CASE nMsg == MSG_NUM2WORD33     ; cMsg := "ein Tausend"
   CASE nMsg == MSG_NUM2WORD34     ; cMsg := "eine Million"
   CASE nMsg == MSG_NUM2WORD35     ; cMsg := "eine Milliarde"
   CASE nMsg == MSG_NUM2WORD36     ; cMsg := "Hundert"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_NTXSYS01       ; cMsg := "Baue System-Indexdateien neu auf"
   //   nMsg == MSG_NTXSYS02       ; cMsg := "L”sche Indexdateien von Platte"
   CASE nMsg == MSG_NTXSYS03       ; cMsg := "Baue dbDD-Indexdateien neu auf"
   CASE nMsg == MSG_NTXSYS04       ; cMsg := "Baue Hilfe-Indexdateien neu auf"
   CASE nMsg == MSG_NTXSYS05       ; cMsg := "Baue Tabellen-Indexdateien neu auf"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_PGLIST01       ; cMsg := "Seitenliste"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DBCFGOPE01     ; cMsg := "Reindizierung"
   CASE nMsg == MSG_DBCFGOPE02     ; cMsg := "Kann System-Dateien nicht ”ffnen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_HLP01          ; cMsg := "^N„chster"
   CASE nMsg == MSG_HLP02          ; cMsg := "Vo^rheriger"
   CASE nMsg == MSG_HLP03          ; cMsg := "^Men"
   CASE nMsg == MSG_HLP04          ; cMsg := "^Datei"
   CASE nMsg == MSG_HLP05          ; cMsg := "^Info"
   CASE nMsg == MSG_HLP06          ; cMsg := "^System"
   CASE nMsg == MSG_HLP07          ; cMsg := "š^bersicht"
   CASE nMsg == MSG_HLP08          ; cMsg := "^Zurck"
   CASE nMsg == MSG_HLP09          ; cMsg := "^Finde"
   CASE nMsg == MSG_HLP10          ; cMsg := "^Datei"
   CASE nMsg == MSG_HLP11          ; cMsg := "Drucke ^Eintrag"
   CASE nMsg == MSG_HLP12          ; cMsg := "^Beenden"
   CASE nMsg == MSG_HLP13          ; cMsg := "^Hilfe benutzen"
   CASE nMsg == MSG_HLP14          ; cMsg := "String fr Suche"
   CASE nMsg == MSG_HLP15          ; cMsg := "String nicht gefunden"
   CASE nMsg == MSG_HLP16          ; cMsg := "Hilfe"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DBRID01        ; cMsg := "Integrit„ts-SCHRANKE. Kann SATZ nicht l”schen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_USRHELP01      ; cMsg := "Kontext-Hilfe nicht verfgbar//"
   CASE nMsg == MSG_USRHELP02      ; cMsg := "in dieser Umgebung !"
   CASE nMsg == MSG_USRHELP03      ; cMsg := " Verfgbare Tasten "
   CASE nMsg == MSG_USRHELP04      ; cMsg := "Zurck zu voriger Maske"
   CASE nMsg == MSG_USRHELP05      ; cMsg := "Rechner"
   CASE nMsg == MSG_USRHELP06      ; cMsg := "Zurck zu DOS"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDINDEX01      ; cMsg := "Dateien reindizieren"
   CASE nMsg == MSG_DDINDEX02      ; cMsg := "^Global"
   CASE nMsg == MSG_DDINDEX03      ; cMsg := "^Partiell"
   CASE nMsg == MSG_DDINDEX04      ; cMsg := "^System-Dateien"
   CASE nMsg == MSG_DDINDEX05      ; cMsg := "  Index    ³ Satz ³ Ausdruck"
   CASE nMsg == MSG_DDINDEX06      ; cMsg := "Dateien reindizieren "
   CASE nMsg == MSG_DDINDEX07      ; cMsg := " mit PACK"
   CASE nMsg == MSG_DDINDEX08      ; cMsg := "W„hle INDEX-Datei fr Neuaufbau. Enter=Wahl OK !"
   CASE nMsg == MSG_DDINDEX09      ; cMsg := "PAUSE - Taste drcken um fortzufahren - PAUSE"
   CASE nMsg == MSG_DDINDEX10      ; cMsg := "Leertaste=Pause ³ Reindiziere Dateien !"
   CASE nMsg == MSG_DDINDEX11      ; cMsg := "...Packe Datei ("
   CASE nMsg == MSG_DDINDEX12      ; cMsg := ") in Arbeit !..."
   CASE nMsg == MSG_DDINDEX13      ; cMsg := "Index von Datei :"
   CASE nMsg == MSG_DDINDEX14      ; cMsg := "Fehler in Variable :"
   CASE nMsg == MSG_DDINDEX15      ; cMsg := "^Check"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDINDEXFL01    ; cMsg := "Indexdatei :"
   CASE nMsg == MSG_DDINDEXFL02    ; cMsg := "Fehler in Variable :"
   CASE nMsg == MSG_DDINDEXFL03    ; cMsg := "PACKE Datei :"
   CASE nMsg == MSG_DDINDEXFL04    ; cMsg := " in Arbeit "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDWIN01        ; cMsg := "Fenster "
   CASE nMsg == MSG_DDWIN02        ; cMsg := "//Nicht verfgbar !"
   CASE nMsg == MSG_DDWIN03        ; cMsg := "Nichts zu l”schen !"
   CASE nMsg == MSG_DDWIN04        ; cMsg := "L™SCHE AKTUELLES ELEMENT"
   CASE nMsg == MSG_DDWIN05        ; cMsg := "Nichts zu „ndern !"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFAUTOFORM01   ; cMsg := "  ^OK   "
   CASE nMsg == MSG_DFAUTOFORM02   ; cMsg := "^Abbruch"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFCOLOR01      ; cMsg := "Text-Farbe"
   CASE nMsg == MSG_DFCOLOR02      ; cMsg := "Nicht gefunden"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFALERT01      ; cMsg := "Taste drcken um fortzufahren..."
   CASE nMsg == MSG_DFALERT02      ; cMsg := "Eine der angezeigten Tasten drcken"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFMEMO01       ; cMsg := "Best„tige Text"
   CASE nMsg == MSG_DFMEMO02       ; cMsg := "Von Platte lesen"
   CASE nMsg == MSG_DFMEMO03       ; cMsg := "Auf Platte schreiben"
   CASE nMsg == MSG_DFMEMO05       ; cMsg := "Summe zurcksetzen"
   CASE nMsg == MSG_DFMEMO06       ; cMsg := "Aufsummieren"
   CASE nMsg == MSG_DFMEMO07       ; cMsg := "Summe anzeigen"
   CASE nMsg == MSG_DFMEMO08       ; cMsg := "Summe in Text einfgen"
   CASE nMsg == MSG_DFMEMO09       ; cMsg := "Ausdruck auswerten und Ergebnis dahinter schreiben"
   CASE nMsg == MSG_DFMEMO10       ; cMsg := "Ausdruck auswerten und mit Ergebnis berschreiben"
   CASE nMsg == MSG_DFMEMO11       ; cMsg := "Datei zum Lesen"
   CASE nMsg == MSG_DFMEMO12       ; cMsg := "Lese Memo von Platte"
   CASE nMsg == MSG_DFMEMO13       ; cMsg := "Automatisch berechnete Summe. Summierte Werte :"
   CASE nMsg == MSG_DFMEMO14       ; cMsg := "Summe aus Rechner//"
   //   nMsg == MSG_DFMEMO15       ; cMsg := "Automatisch berechnete Summe. Summierte Werte :"
   CASE nMsg == MSG_DFMEMO16       ; cMsg := "Kann Anfang des Ausdrucks nicht finden !"
   CASE nMsg == MSG_DFMEMO17       ; cMsg := "Ende ohne Abspeichern"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFQRY01        ; cMsg := "Kleiner als"
   CASE nMsg == MSG_DFQRY02        ; cMsg := "Gr”áer als"
   CASE nMsg == MSG_DFQRY03        ; cMsg := "Kleiner oder gleich mit"
   CASE nMsg == MSG_DFQRY04        ; cMsg := "Gr”áer oder gleich mit"
   CASE nMsg == MSG_DFQRY05        ; cMsg := "Gleich mit"
   CASE nMsg == MSG_DFQRY06        ; cMsg := "Nicht gleich mit"
   CASE nMsg == MSG_DFQRY07        ; cMsg := "Enh„lt"
   CASE nMsg == MSG_DFQRY08        ; cMsg := "ist enthalten in"
   CASE nMsg == MSG_DFQRY09        ; cMsg := "Exakt gleich mit"
   CASE nMsg == MSG_DFQRY10        ; cMsg := "wahr"
   CASE nMsg == MSG_DFQRY11        ; cMsg := "falsch"
   CASE nMsg == MSG_DFQRY12        ; cMsg := " und "
   CASE nMsg == MSG_DFQRY13        ; cMsg := " oder "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_VALID01        ; cMsg := "Kann Feld nicht leer lassen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFINI01        ; cMsg := "Meldet andere Version"
   CASE nMsg == MSG_DFINI02        ; cMsg := "Regeneriere DBSTART.INI mit Visual dBsee"
   CASE nMsg == MSG_DFINI03        ; cMsg := "Lade Aktionen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFFILE2PRN01   ; cMsg := "Drucker nicht bereit//Wiederhole"
   CASE nMsg == MSG_DFFILE2PRN02   ; cMsg := "Drucke..."
   CASE nMsg == MSG_DFFILE2PRN03   ; cMsg := "Druck angehalten"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFNET01        ; cMsg := "Kann Datei nicht sperren :"
   CASE nMsg == MSG_DFNET02        ; cMsg := "Kann Satz nicht sperren Nr. %2%"
   CASE nMsg == MSG_DFNET03        ; cMsg := "Kann keinen Satz anh„ngen"
   //   nMsg == MSG_DFNET04        ; cMsg := "UNBEKANNTE FUNKTION !!"
   //   nMsg == MSG_DFNET05        ; cMsg := "Zeitberscheitung: "
   CASE nMsg == MSG_DFNET06        ; cMsg := "Sperrversuch"
   CASE nMsg == MSG_DFNET07        ; cMsg := "Sekunden"
   CASE nMsg == MSG_DFNET08        ; cMsg := "SPERRE Datei :"
   CASE nMsg == MSG_DFNET09        ; cMsg := "Verwende Semaphore"
   CASE nMsg == MSG_DFNET10        ; cMsg := "Kann nicht finden"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFMEMOWRI01    ; cMsg := "Schreibe zu: "
   CASE nMsg == MSG_DFMEMOWRI02    ; cMsg := "Dateiname eingeben.³F10=Wahl OK³Esc=Abruch"
   CASE nMsg == MSG_DFMEMOWRI03    ; cMsg := "Schreibe Memo auf Platte"
   CASE nMsg == MSG_DFMEMOWRI04    ; cMsg := "Datei existiert bereits. šberschreiben ?"
   //   nMsg == MSG_DFMEMOWRI05    ; cMsg := "Datei "
   //   nMsg == MSG_DFMEMOWRI06    ; cMsg := " wurde geschrieben !"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFINIPATH01    ; cMsg := "Lade Anwendungspfade"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFINIFONT01    ; cMsg := "Lade Fonts"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFINIPRN01     ; cMsg := "Lade Drucker"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFPROGIND01    ; cMsg := "Abbruch"
   CASE nMsg == MSG_DFPROGIND02    ; cMsg := "Wollen Sie wirklich unterbrechen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DBLOOK01       ; cMsg := "Kann Feld nicht verlassen//"
   CASE nMsg == MSG_DBLOOK02       ; cMsg := "leer"
   CASE nMsg == MSG_DBLOOK03       ; cMsg := "Warnung: //"
   CASE nMsg == MSG_DBLOOK04       ; cMsg := "//existiert nicht !!"
   CASE nMsg == MSG_DBLOOK05       ; cMsg := "Warnung: Code//"
   CASE nMsg == MSG_DBLOOK06       ; cMsg := "//nicht in Datei"
   CASE nMsg == MSG_DBLOOK07       ; cMsg := "//jetzt einfgen?"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFTABDE01      ; cMsg := "Tabellen-Dateien"
   CASE nMsg == MSG_DFTABDE02      ; cMsg := "Tabellen"
   CASE nMsg == MSG_DFTABDE03      ; cMsg := "ndern"
   CASE nMsg == MSG_DFTABDE04      ; cMsg := "Keine Tabellen-Dateien in Anwendung"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DBINK01        ; cMsg := "Tastatur-Zeitberschreitung"
   CASE nMsg == MSG_DBINK02        ; cMsg := "Sekunden"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //   nMsg == MSG_DFINIPP01      ; cMsg := "Lade Druckerschnittstellen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFINIPOR01     ; cMsg := "Lade Schnittstellen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFGET01        ; cMsg := "Maske verlassen"
   CASE nMsg == MSG_DFGET02        ; cMsg := "Maske speichern"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_TBBRWNEW01     ; cMsg := "Ursprngliche Fenstergr”áe wiederherstellen"
   CASE nMsg == MSG_TBBRWNEW02     ; cMsg := "Fensterposition „ndern"
   CASE nMsg == MSG_TBBRWNEW03     ; cMsg := "Fenstergr”áe „ndern"
   CASE nMsg == MSG_TBBRWNEW04     ; cMsg := "Fenster auf minimale Gr”áe verkleinern"
   CASE nMsg == MSG_TBBRWNEW05     ; cMsg := "Fenster auf maximale Gr”áe vergr”áern"
   CASE nMsg == MSG_TBBRWNEW06     ; cMsg := "Aktuelles und zugeh”rige Fenster vom Bildschirm l”schen"
   CASE nMsg == MSG_TBBRWNEW07     ; cMsg := "Liste der aktiven Seiten anzeigen"
   CASE nMsg == MSG_TBBRWNEW08     ; cMsg := "N„chste"
   CASE nMsg == MSG_TBBRWNEW09     ; cMsg := "Vorherige"
   CASE nMsg == MSG_TBBRWNEW10     ; cMsg := "Erste"
   CASE nMsg == MSG_TBBRWNEW11     ; cMsg := "Letzte"
   CASE nMsg == MSG_TBBRWNEW12     ; cMsg := "Links"
   CASE nMsg == MSG_TBBRWNEW13     ; cMsg := "Rechts"
   CASE nMsg == MSG_TBBRWNEW14     ; cMsg := "Seite auf"
   CASE nMsg == MSG_TBBRWNEW15     ; cMsg := "Seite ab"
   CASE nMsg == MSG_TBBRWNEW16     ; cMsg := "Linke Spalten einfrieren/freigeben"
   CASE nMsg == MSG_TBBRWNEW17     ; cMsg := "Spalte vergr”áern"
   CASE nMsg == MSG_TBBRWNEW18     ; cMsg := "Spalte verkleinern"
   CASE nMsg == MSG_TBBRWNEW19     ; cMsg := "Element aus Auswahl entfernen"
   CASE nMsg == MSG_TBBRWNEW20     ; cMsg := "Element ausw„hlen"
   CASE nMsg == MSG_TBBRWNEW21     ; cMsg := "Alle ausw„hlen"
   CASE nMsg == MSG_TBBRWNEW22     ; cMsg := "Aktuelles Element „ndern"
   CASE nMsg == MSG_TBBRWNEW23     ; cMsg := "N„chste Seite"
   CASE nMsg == MSG_TBBRWNEW24     ; cMsg := "^Wiederherstellen"
   CASE nMsg == MSG_TBBRWNEW25     ; cMsg := "^Bewegen"
   CASE nMsg == MSG_TBBRWNEW26     ; cMsg := "^Gr”áe „ndern"
   CASE nMsg == MSG_TBBRWNEW27     ; cMsg := "^Minimieren"
   CASE nMsg == MSG_TBBRWNEW28     ; cMsg := "M^aximieren"
   CASE nMsg == MSG_TBBRWNEW29     ; cMsg := "^Schlieáen"
   CASE nMsg == MSG_TBBRWNEW30     ; cMsg := "^Umschalten auf..."
   CASE nMsg == MSG_TBBRWNEW31     ; cMsg := "Schlssel"
   CASE nMsg == MSG_TBBRWNEW32     ; cMsg := "Vorige Seite"
   CASE nMsg == MSG_TBBRWNEW33     ; cMsg := "Drucke"
   CASE nMsg == MSG_TBBRWNEW34     ; cMsg := "Etikett Ausdruck"
   CASE nMsg == MSG_TBBRWNEW35     ; cMsg := "Statistic"
   CASE nMsg == MSG_TBBRWNEW36     ; cMsg := "Select/Unselect row"
   CASE nMsg == MSG_TBBRWNEW37     ; cMsg := "Unselect all"
   CASE nMsg == MSG_TBBRWNEW38     ; cMsg := "Select all"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDGENDBF01     ; cMsg := "Datei"
   CASE nMsg == MSG_DDGENDBF02     ; cMsg := "ohne Felder"
   CASE nMsg == MSG_DDGENDBF03     ; cMsg := "Generiere Datei"
   CASE nMsg == MSG_DDGENDBF04     ; cMsg := "Attention!!! The Directory not exist:// "
   CASE nMsg == MSG_DDGENDBF05     ; cMsg := "//Create the Directory now?"
   CASE nMsg == MSG_DDGENDBF06     ; cMsg := "Unable to Create the Directory://"
   CASE nMsg == MSG_DDGENDBF07     ; cMsg := "Serious error in Table creation!!!// Operation aborted ...//Table: "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFTABPRINT01   ; cMsg := "Keine Tabellen-Datei zum Drucken"
   CASE nMsg == MSG_DFTABPRINT02   ; cMsg := "ş Tabellen ş"
   CASE nMsg == MSG_DFTABPRINT03   ; cMsg := "Drucke Tabellen"
   //   nMsg == MSG_DFTABPRINT04   ; cMsg := "Drucke Tabellen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFPRNSTART01   ; cMsg := "Fehler beim ™ffnen der Datei"
   CASE nMsg == MSG_DFPRNSTART02   ; cMsg := "Enter drcken fr Druck"
   CASE nMsg == MSG_DFPRNSTART03   ; cMsg := "Hauptdatei"
   CASE nMsg == MSG_DFPRNSTART04   ; cMsg := "Drucke auf"
   CASE nMsg == MSG_DFPRNSTART05   ; cMsg := "Aktueller Drucker"
   CASE nMsg == MSG_DFPRNSTART06   ; cMsg := "Druckerport"
   CASE nMsg == MSG_DFPRNSTART07   ; cMsg := "Qualit„t"
   CASE nMsg == MSG_DFPRNSTART08   ; cMsg := "Normal"
   CASE nMsg == MSG_DFPRNSTART09   ; cMsg := "Hoch"
   CASE nMsg == MSG_DFPRNSTART10   ; cMsg := "Zeichen"
   CASE nMsg == MSG_DFPRNSTART11   ; cMsg := "Normal"
   CASE nMsg == MSG_DFPRNSTART12   ; cMsg := "Komprimiert"
   CASE nMsg == MSG_DFPRNSTART13   ; cMsg := "^Port"
   CASE nMsg == MSG_DFPRNSTART14   ; cMsg := "^R„nder"
   CASE nMsg == MSG_DFPRNSTART15   ; cMsg := "^Drucker"
   CASE nMsg == MSG_DFPRNSTART16   ; cMsg := "^Spooler aktiv"
   CASE nMsg == MSG_DFPRNSTART17   ; cMsg := "^Kopien :"
   CASE nMsg == MSG_DFPRNSTART18   ; cMsg := "Anzahl der auszudruckenden Kopien"
   CASE nMsg == MSG_DFPRNSTART19   ; cMsg := "Da^tei :"
   CASE nMsg == MSG_DFPRNSTART20   ; cMsg := "^Voransicht"
   CASE nMsg == MSG_DFPRNSTART21   ; cMsg := "Dr^uck"
   CASE nMsg == MSG_DFPRNSTART22   ; cMsg := "^Ende"
   CASE nMsg == MSG_DFPRNSTART23   ; cMsg := "^Zeilen pro Seite"
   CASE nMsg == MSG_DFPRNSTART24   ; cMsg := "^Oberer Rand"
   CASE nMsg == MSG_DFPRNSTART25   ; cMsg := "^Unterer Rand"
   CASE nMsg == MSG_DFPRNSTART26   ; cMsg := "^Linker Rand"
   CASE nMsg == MSG_DFPRNSTART27   ; cMsg := "R„nder"
   CASE nMsg == MSG_DFPRNSTART28   ; cMsg := "ş Schnittstellen ş"
   CASE nMsg == MSG_DFPRNSTART29   ; cMsg := "ş Druckertreiber ş"
   CASE nMsg == MSG_DFPRNSTART30   ; cMsg := "Drucke ohne Seiten^vorschbe"
   CASE nMsg == MSG_DFPRNSTART31   ; cMsg := "Nichts zu drucken"
   CASE nMsg == MSG_DFPRNSTART32   ; cMsg := "Reportname"
   CASE nMsg == MSG_DFPRNSTART33   ; cMsg := "Filterbeschreibung"
   CASE nMsg == MSG_DFPRNSTART34   ; cMsg := "Filterausdruck"
   CASE nMsg == MSG_DFPRNSTART35   ; cMsg := "I^nformation"
   CASE nMsg == MSG_DFPRNSTART36   ; cMsg := "Setup"
   CASE nMsg == MSG_DFPRNSTART37   ; cMsg := "Setup ^1"
   CASE nMsg == MSG_DFPRNSTART38   ; cMsg := "Setup ^2"
   CASE nMsg == MSG_DFPRNSTART39   ; cMsg := "Setup ^3"
   CASE nMsg == MSG_DFPRNSTART40   ; cMsg := "Sei^ten"
   CASE nMsg == MSG_DFPRNSTART41   ; cMsg := "^Drucke alle Seiten"
   //   nMsg == MSG_DFPRNSTART42   ; cMsg := "Angekreuzt=Ja, sonst=Von-Bis, Wechseln mit Leertaste"
   CASE nMsg == MSG_DFPRNSTART43   ; cMsg := "^von Seite"
   CASE nMsg == MSG_DFPRNSTART44   ; cMsg := "Erste auszudruckende Seite"
   CASE nMsg == MSG_DFPRNSTART45   ; cMsg := "^bis Seite"
   CASE nMsg == MSG_DFPRNSTART46   ; cMsg := "Letzte auszudruckende Seite"
   CASE nMsg == MSG_DFPRNSTART47   ; cMsg := "Seiten"
   CASE nMsg == MSG_DFPRNSTART48   ; cMsg := "^Filter"
   CASE nMsg == MSG_DFPRNSTART49   ; cMsg := "Aktuellen Filter wechseln"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDDE01         ; cMsg := "Automatische Maske//"
   CASE nMsg == MSG_DDDE02         ; cMsg := "//nicht definiert !"
   CASE nMsg == MSG_DDDE03         ; cMsg := "Automatische Maske//"
   CASE nMsg == MSG_DDDE04         ; cMsg := "//Prim„rschlssel nicht definiert !"
   CASE nMsg == MSG_DDDE05         ; cMsg := "Maske "
   CASE nMsg == MSG_DDDE06         ; cMsg := "Prim„r-Schlssel//"
   CASE nMsg == MSG_DDDE07         ; cMsg := "//Doppelt !"
   CASE nMsg == MSG_DDDE08         ; cMsg := "Pflichtfeld"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_TBINK01        ; cMsg := "Aktueller Satz wurde gel”scht"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_TBGETKEY01     ; cMsg := "Rufe Suchfenster auf"
   CASE nMsg == MSG_TBGETKEY02     ; cMsg := "Rufe Suchtasten auf"
   //   nMsg == MSG_TBGETKEY03     ; cMsg := "Rufe Suchfenster auf"
   CASE nMsg == MSG_TBGETKEY04     ; cMsg := "Editiere Memo"
   CASE nMsg == MSG_TBGETKEY05     ; cMsg := "W„hle/Entferne Wert"
   CASE nMsg == MSG_TBGETKEY06     ; cMsg := "W„hle Wert"
   CASE nMsg == MSG_TBGETKEY07     ; cMsg := "Drcke Knopf"
   CASE nMsg == MSG_TBGETKEY08     ; cMsg := "Erh”he Wert"
   CASE nMsg == MSG_TBGETKEY09     ; cMsg := "Vermindere Wert"
   CASE nMsg == MSG_TBGETKEY10     ; cMsg := "Erh”he Wert 10-fach"
   CASE nMsg == MSG_TBGETKEY11     ; cMsg := "Vermindere Wert 10-fach"
   CASE nMsg == MSG_TBGETKEY14     ; cMsg := "Kopieren"
   CASE nMsg == MSG_TBGETKEY15     ; cMsg := "Einfgen"
   CASE nMsg == MSG_TBGETKEY16     ; cMsg := "Voriger Satz"
   CASE nMsg == MSG_TBGETKEY17     ; cMsg := "N„chster Satz"
   CASE nMsg == MSG_TBGETKEY18     ; cMsg := "Erster Satz"
   CASE nMsg == MSG_TBGETKEY19     ; cMsg := "Letzter Satz"
   CASE nMsg == MSG_TBGETKEY20     ; cMsg := "Kalender aufrufen"
   CASE nMsg == MSG_TBGETKEY21     ; cMsg := "N„chster Tag"
   CASE nMsg == MSG_TBGETKEY22     ; cMsg := "Vorheriger Tag"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFSVILLEV01    ; cMsg := "Druck angehalten"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFLOGIN01      ; cMsg := "Kann Paáwort-Datei nicht ”ffnen"
   CASE nMsg == MSG_DFLOGIN02      ; cMsg := "Paáwort-Eingabe"
   CASE nMsg == MSG_DFLOGIN03      ; cMsg := "*        ZUGANGS-CODE        *//"
   CASE nMsg == MSG_DFLOGIN04      ; cMsg := "   Bereits im System bentzt  //"
   CASE nMsg == MSG_DFLOGIN05      ; cMsg := "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//"
   CASE nMsg == MSG_DFLOGIN06      ; cMsg := "Paáwort"
   CASE nMsg == MSG_DFLOGIN07      ; cMsg := "nicht gefunden"
   CASE nMsg == MSG_DFLOGIN08      ; cMsg := "Paáwort erneut eingeben"
   CASE nMsg == MSG_DFLOGIN09      ; cMsg := "*    ZUGANG VERWEIGERT    *//"
   CASE nMsg == MSG_DFLOGIN10      ; cMsg := " Unberechtigter Benutzer ! //"
   CASE nMsg == MSG_DFLOGIN11      ; cMsg := "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   CASE nMsg == MSG_DFLOGIN12      ; cMsg := "   Fehler bei Paáworteingabe  //"
   CASE nMsg == MSG_DFLOGIN13      ; cMsg := "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   CASE nMsg == MSG_DFLOGIN14      ; cMsg := "PASSWORT"
   CASE nMsg == MSG_DFLOGIN15      ; cMsg := "Neues Passwort eingeben"
   CASE nMsg == MSG_DFLOGIN16      ; cMsg := "Passwort erneut eingeben"
   CASE nMsg == MSG_DFLOGIN17      ; cMsg := "Name  Benutzer"
   CASE nMsg == MSG_DFLOGIN18      ; cMsg := "Eingabe neues PASSWORT"
   CASE nMsg == MSG_DFLOGIN19      ; cMsg := "For the new laws on the Privacy //the Password must at least be of 8 characters!"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDWIT01        ; cMsg := "Element hinzufgen"
   CASE nMsg == MSG_DDWIT02        ; cMsg := "Aktuelles Element „ndern"
   CASE nMsg == MSG_DDWIT03        ; cMsg := "Aktuelles Element l”schen"
   CASE nMsg == MSG_DDWIT04        ; cMsg := "Suche"
   CASE nMsg == MSG_DDWIT05        ; cMsg := "Code "
   CASE nMsg == MSG_DDWIT06        ; cMsg := " existiert nicht"
   CASE nMsg == MSG_DDWIT07        ; cMsg := "L”sche aktuelles Objekt"
   CASE nMsg == MSG_DDWIT08        ; cMsg := "Suche "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDKEY01        ; cMsg := "Keine Suchschlssel vorhanden//- Datei "
   CASE nMsg == MSG_DDKEY02        ; cMsg := " hat keine Indizes ! -"
   CASE nMsg == MSG_DDKEY03        ; cMsg := "Kann Suchschlssel nicht auswerten//"
   CASE nMsg == MSG_DDKEY04        ; cMsg := "Sequentielle Suche nur aktiv auf Zeichenfeldern !"
   CASE nMsg == MSG_DDKEY05        ; cMsg := "Suchfenster"
   CASE nMsg == MSG_DDKEY06        ; cMsg := "Suche nach passendem String"
   CASE nMsg == MSG_DDKEY07        ; cMsg := "Fenster fr LookUp-Datei"
   CASE nMsg == MSG_DDKEY08        ; cMsg := "Interaktive Erzeugung des Suchschlssels"
   CASE nMsg == MSG_DDKEY09        ; cMsg := "Schlssel: "
   CASE nMsg == MSG_DDKEY10        ; cMsg := "//nicht gefunden!"
   CASE nMsg == MSG_DDKEY11        ; cMsg := " Unterbrechen mit beliebiger Taste "
   CASE nMsg == MSG_DDKEY12        ; cMsg := "//Warten...//"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDUPDDBF01     ; cMsg := "Update"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFTABFRM03     ; cMsg := "2. Kontrolle. Doppelter Code !//Einfgen abgebrochen !!"
   CASE nMsg == MSG_DFTABFRM04     ; cMsg := "Fehler: Code dupliziert in "
   CASE nMsg == MSG_DFTABFRM05     ; cMsg := "Warnung!"
   CASE nMsg == MSG_DFTABFRM06     ; cMsg := "^Bereits verwendet in"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFPK01         ; cMsg := "prim„r"
   CASE nMsg == MSG_DFPK02         ; cMsg := "unique"
   CASE nMsg == MSG_DFPK03         ; cMsg := "Schlssel "
   CASE nMsg == MSG_DFPK04         ; cMsg := " dupliziert !//"
   CASE nMsg == MSG_DFPK05         ; cMsg := " leer !//"
   CASE nMsg == MSG_DFPK06         ; cMsg := "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//"
   CASE nMsg == MSG_DFPK07         ; cMsg := "   Neuen Schlssel eingeben !    "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDQRY01        ; cMsg := "und     Û .AND.Û"
   CASE nMsg == MSG_DDQRY02        ; cMsg := "oder    Û .OR. Û"
   CASE nMsg == MSG_DDQRY17        ; cMsg := "Klammer Û  )   Û"
   CASE nMsg == MSG_DDQRY03        ; cMsg := "Fertig  Û      Û"
   CASE nMsg == MSG_DDQRY04        ; cMsg := " <   Kleiner als............. "
   CASE nMsg == MSG_DDQRY05        ; cMsg := " >   Gr”áer als.............. "
   CASE nMsg == MSG_DDQRY06        ; cMsg := " <=  Kleiner oder gleich wie. "
   CASE nMsg == MSG_DDQRY07        ; cMsg := " >=  Gr”áer oder gleich wie.. "
   CASE nMsg == MSG_DDQRY08        ; cMsg := " =   Gleich wie.............. "
   CASE nMsg == MSG_DDQRY09        ; cMsg := " #   Nicht gleich wie........ "
   CASE nMsg == MSG_DDQRY10        ; cMsg := " $   Ist enthalten in........ "
   CASE nMsg == MSG_DDQRY11        ; cMsg := " œ   Enh„lt.................. "
   CASE nMsg == MSG_DDQRY12        ; cMsg := "Felder von Datei"
   CASE nMsg == MSG_DDQRY13        ; cMsg := "Bedingungen"
   CASE nMsg == MSG_DDQRY14        ; cMsg := "Logisch links"
   CASE nMsg == MSG_DDQRY15        ; cMsg := "³Filter OK³"
   CASE nMsg == MSG_DDQRY16        ; cMsg := "³Filter FEHLER³"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_TBGET01        ; cMsg := "Leertaste=ndern³ "
   CASE nMsg == MSG_TBGET02        ; cMsg := "F10=Sichern ³ "
   CASE nMsg == MSG_TBGET03        ; cMsg := "Die Eingabe ist fehlerhaft"
   CASE nMsg == MSG_TBGET04        ; cMsg := "Control kann nicht ge„ndert werden"
   CASE nMsg == MSG_TBGET05        ; cMsg := "Die Gets sind ge„ndert"
   CASE nMsg == MSG_TBGET06        ; cMsg := "^Speichem"
   CASE nMsg == MSG_TBGET07        ; cMsg := "^Abbruch"
   CASE nMsg == MSG_TBGET08        ; cMsg := "^Weiter"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFSTA01        ; cMsg := "Verstrichene Zeit"
   CASE nMsg == MSG_DFSTA02        ; cMsg := "Gesch„tzte Zeit"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFINIREP01     ; cMsg := "Lade Report-Definition"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFCALC01       ; cMsg := "Addition"
   CASE nMsg == MSG_DFCALC02       ; cMsg := "Multiplikation"
   CASE nMsg == MSG_DFCALC03       ; cMsg := "Subtraktion"
   CASE nMsg == MSG_DFCALC04       ; cMsg := "Division"
   CASE nMsg == MSG_DFCALC06       ; cMsg := "Summe"
   CASE nMsg == MSG_DFCALC07       ; cMsg := "Ein"
   CASE nMsg == MSG_DFCALC08       ; cMsg := "Aus"
   CASE nMsg == MSG_DFCALC09       ; cMsg := "Ende mit šbername ins Tastaturpuffers"
   CASE nMsg == MSG_DFCALC10       ; cMsg := "Conversion from LIRE to EURO"
   CASE nMsg == MSG_DFCALC11       ; cMsg := "Conversion from EURO to LIRE"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_INTCOL01       ; cMsg := "Schwarz"
   CASE nMsg == MSG_INTCOL02       ; cMsg := "Dunkelgrau"
   CASE nMsg == MSG_INTCOL03       ; cMsg := "Hellgrau"
   CASE nMsg == MSG_INTCOL04       ; cMsg := "Dunkelblau"
   CASE nMsg == MSG_INTCOL05       ; cMsg := "Blau"
   CASE nMsg == MSG_INTCOL06       ; cMsg := "Hellblau"
   CASE nMsg == MSG_INTCOL07       ; cMsg := "Dunkelgrn"
   CASE nMsg == MSG_INTCOL08       ; cMsg := "Grn"
   CASE nMsg == MSG_INTCOL09       ; cMsg := "Hellgrn"
   CASE nMsg == MSG_INTCOL10       ; cMsg := "Dunkelrot"
   CASE nMsg == MSG_INTCOL11       ; cMsg := "Rot"
   CASE nMsg == MSG_INTCOL12       ; cMsg := "Hellrot"
   CASE nMsg == MSG_INTCOL13       ; cMsg := "Dunkelgelb"
   CASE nMsg == MSG_INTCOL14       ; cMsg := "Gelb"
   CASE nMsg == MSG_INTCOL15       ; cMsg := "Hellgelb"
   CASE nMsg == MSG_INTCOL16       ; cMsg := "Weiss"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_INTPRN01       ; cMsg := "ASCII-Text (ohne ESCape-Sequenzen)"
   //   nMsg == MSG_INTPRN02       ; cMsg := "EPSON FX-80"
   //   nMsg == MSG_INTPRN03       ; cMsg := "HP LASERJET PLUS"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_ACTINT001      ; cMsg := "Pos1"
   CASE nMsg == MSG_ACTINT002      ; cMsg := "Strg+->"
   CASE nMsg == MSG_ACTINT003      ; cMsg := "Bild"
   CASE nMsg == MSG_ACTINT004      ; cMsg := "<-"
   CASE nMsg == MSG_ACTINT005      ; cMsg := ""
   CASE nMsg == MSG_ACTINT006      ; cMsg := "Ende"
   CASE nMsg == MSG_ACTINT007      ; cMsg := "Entf"
   CASE nMsg == MSG_ACTINT008      ; cMsg := "Rcktaste"
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
   CASE nMsg == MSG_ACTINT019      ; cMsg := "Strg+Eingabe"
   CASE nMsg == MSG_ACTINT020      ; cMsg := "Eingabe"
   CASE nMsg == MSG_ACTINT021      ; cMsg := "Bild"
   CASE nMsg == MSG_ACTINT022      ; cMsg := "<-"
   CASE nMsg == MSG_ACTINT023      ; cMsg := "Einfg"
   CASE nMsg == MSG_ACTINT024      ; cMsg := "Strg+Ende"
   CASE nMsg == MSG_ACTINT025      ; cMsg := ""
   CASE nMsg == MSG_ACTINT026      ; cMsg := "Strg+<-"
   CASE nMsg == MSG_ACTINT027      ; cMsg := "Esc"
   CASE nMsg == MSG_ACTINT028      ; cMsg := "F1"
   CASE nMsg == MSG_ACTINT029      ; cMsg := "Strg+Pos1"
   CASE nMsg == MSG_ACTINT030      ; cMsg := "Strg+Bild"
   CASE nMsg == MSG_ACTINT031      ; cMsg := "Strg+Bild"
   CASE nMsg == MSG_ACTINT032      ; cMsg := "Leertaste"
   //   nMsg == MSG_ACTINT033      ; cMsg := "+"
   //   nMsg == MSG_ACTINT034      ; cMsg := "-"
   //   nMsg == MSG_ACTINT035      ; cMsg := "<"
   //   nMsg == MSG_ACTINT036      ; cMsg := ">"
   //   nMsg == MSG_ACTINT037      ; cMsg := "Umsch+F1"
   //   nMsg == MSG_ACTINT038      ; cMsg := "Umsch+F2"
   //   nMsg == MSG_ACTINT039      ; cMsg := "Umsch+F3"
   //   nMsg == MSG_ACTINT040      ; cMsg := "Umsch+F4"
   //   nMsg == MSG_ACTINT041      ; cMsg := "Umsch+F5"
   //   nMsg == MSG_ACTINT042      ; cMsg := "Umsch+F6"
   //   nMsg == MSG_ACTINT043      ; cMsg := "Umsch+F7"
   //   nMsg == MSG_ACTINT044      ; cMsg := "Umsch+F8"
   //   nMsg == MSG_ACTINT045      ; cMsg := "Umsch+F9"
   //   nMsg == MSG_ACTINT046      ; cMsg := "Umsch+F10"
   //   nMsg == MSG_ACTINT047      ; cMsg := "Strg+F1"
   //   nMsg == MSG_ACTINT048      ; cMsg := "Strg+F2"
   //   nMsg == MSG_ACTINT049      ; cMsg := "Strg+F3"
   //   nMsg == MSG_ACTINT050      ; cMsg := "Strg+F4"
   //   nMsg == MSG_ACTINT051      ; cMsg := "Strg+F5"
   //   nMsg == MSG_ACTINT052      ; cMsg := "Strg+F6"
   //   nMsg == MSG_ACTINT053      ; cMsg := "Strg+F7"
   //   nMsg == MSG_ACTINT054      ; cMsg := "Strg+F8"
   //   nMsg == MSG_ACTINT055      ; cMsg := "Strg+F9"
   //   nMsg == MSG_ACTINT056      ; cMsg := "Strg+F10"
   //   nMsg == MSG_ACTINT057      ; cMsg := "Alt+F1"
   //   nMsg == MSG_ACTINT058      ; cMsg := "Alt+F2"
   //   nMsg == MSG_ACTINT059      ; cMsg := "Alt+F3"
   //   nMsg == MSG_ACTINT060      ; cMsg := "Alt+F4"
   //   nMsg == MSG_ACTINT061      ; cMsg := "Alt+F5"
   //   nMsg == MSG_ACTINT062      ; cMsg := "Alt+F6"
   //   nMsg == MSG_ACTINT063      ; cMsg := "Alt+F7"
   //   nMsg == MSG_ACTINT064      ; cMsg := "Alt+F8"
   //   nMsg == MSG_ACTINT065      ; cMsg := "Alt+F9"
   //   nMsg == MSG_ACTINT066      ; cMsg := "Alt+F10"
   CASE nMsg == MSG_ACTINT067      ; cMsg := "Strg+Rcktaste"
   CASE nMsg == MSG_ACTINT068      ; cMsg := "Alt+Esc"
   CASE nMsg == MSG_ACTINT069      ; cMsg := "Alt+Rcktaste"
   CASE nMsg == MSG_ACTINT070      ; cMsg := "Umsch+Tab"
   CASE nMsg == MSG_ACTINT071      ; cMsg := "Alt+Q"
   CASE nMsg == MSG_ACTINT072      ; cMsg := "Alt+W"
   CASE nMsg == MSG_ACTINT073      ; cMsg := "Alt+E"
   CASE nMsg == MSG_ACTINT074      ; cMsg := "Alt+R"
   CASE nMsg == MSG_ACTINT075      ; cMsg := "Alt+T"
   CASE nMsg == MSG_ACTINT076      ; cMsg := "Alt+Z"
   CASE nMsg == MSG_ACTINT077      ; cMsg := "Alt+U"
   CASE nMsg == MSG_ACTINT078      ; cMsg := "Alt+I"
   CASE nMsg == MSG_ACTINT079      ; cMsg := "Alt+O"
   CASE nMsg == MSG_ACTINT080      ; cMsg := "Alt+P"
   CASE nMsg == MSG_ACTINT081      ; cMsg := "Alt+š"
   CASE nMsg == MSG_ACTINT082      ; cMsg := "Alt +"
   CASE nMsg == MSG_ACTINT083      ; cMsg := "Alt+Eingabe"
   CASE nMsg == MSG_ACTINT084      ; cMsg := "Alt+A"
   CASE nMsg == MSG_ACTINT085      ; cMsg := "Alt+S"
   CASE nMsg == MSG_ACTINT086      ; cMsg := "Alt+D"
   CASE nMsg == MSG_ACTINT087      ; cMsg := "Alt+F"
   CASE nMsg == MSG_ACTINT088      ; cMsg := "Alt+G"
   CASE nMsg == MSG_ACTINT089      ; cMsg := "Alt+H"
   CASE nMsg == MSG_ACTINT090      ; cMsg := "Alt+J"
   CASE nMsg == MSG_ACTINT091      ; cMsg := "Alt+K"
   CASE nMsg == MSG_ACTINT092      ; cMsg := "Alt+L"
   CASE nMsg == MSG_ACTINT093      ; cMsg := "Alt+™"
   CASE nMsg == MSG_ACTINT094      ; cMsg := "Alt+"
   CASE nMsg == MSG_ACTINT095      ; cMsg := "Alt+#"
   CASE nMsg == MSG_ACTINT096      ; cMsg := "Alt+^"
   CASE nMsg == MSG_ACTINT097      ; cMsg := "Alt+Y"
   CASE nMsg == MSG_ACTINT098      ; cMsg := "Alt+X"
   CASE nMsg == MSG_ACTINT099      ; cMsg := "Alt+C"
   CASE nMsg == MSG_ACTINT100      ; cMsg := "Alt+V"
   CASE nMsg == MSG_ACTINT101      ; cMsg := "Alt+B"
   CASE nMsg == MSG_ACTINT102      ; cMsg := "Alt+N"
   CASE nMsg == MSG_ACTINT103      ; cMsg := "Alt+M"
   CASE nMsg == MSG_ACTINT104      ; cMsg := "Alt+,"
   CASE nMsg == MSG_ACTINT105      ; cMsg := "Alt+."
   CASE nMsg == MSG_ACTINT106      ; cMsg := "Alt-"
   CASE nMsg == MSG_ACTINT107      ; cMsg := "Alt+1"
   CASE nMsg == MSG_ACTINT108      ; cMsg := "Alt+2"
   CASE nMsg == MSG_ACTINT109      ; cMsg := "Alt+3"
   CASE nMsg == MSG_ACTINT110      ; cMsg := "Alt+4"
   CASE nMsg == MSG_ACTINT111      ; cMsg := "Alt+5"
   CASE nMsg == MSG_ACTINT112      ; cMsg := "Alt+6"
   CASE nMsg == MSG_ACTINT113      ; cMsg := "Alt+7"
   CASE nMsg == MSG_ACTINT114      ; cMsg := "Alt+8"
   CASE nMsg == MSG_ACTINT115      ; cMsg := "Alt+9"
   CASE nMsg == MSG_ACTINT116      ; cMsg := "Alt+0"
   CASE nMsg == MSG_ACTINT117      ; cMsg := "Alt+?"
   CASE nMsg == MSG_ACTINT118      ; cMsg := "Alt+'"
   CASE nMsg == MSG_ACTINT119      ; cMsg := "F11"
   CASE nMsg == MSG_ACTINT120      ; cMsg := "F12"
   //   nMsg == MSG_ACTINT121      ; cMsg := "Umsch+F11"
   //   nMsg == MSG_ACTINT122      ; cMsg := "Umsch+F12"
   //   nMsg == MSG_ACTINT123      ; cMsg := "Strg+F11"
   //   nMsg == MSG_ACTINT124      ; cMsg := "Strg+F12"
   //   nMsg == MSG_ACTINT125      ; cMsg := "Alt+F11"
   //   nMsg == MSG_ACTINT126      ; cMsg := "Alt+F12"
   CASE nMsg == MSG_ACTINT127      ; cMsg := "Strg+"
   CASE nMsg == MSG_ACTINT128      ; cMsg := "Strg+"
   CASE nMsg == MSG_ACTINT129      ; cMsg := "Strg+Einfg"
   CASE nMsg == MSG_ACTINT130      ; cMsg := "Strg+Entf"
   CASE nMsg == MSG_ACTINT131      ; cMsg := "Strg+Tab"
   CASE nMsg == MSG_ACTINT132      ; cMsg := "Strg+Slash"
   CASE nMsg == MSG_ACTINT133      ; cMsg := "Alt+Pos1"
   CASE nMsg == MSG_ACTINT134      ; cMsg := "Alt+"
   CASE nMsg == MSG_ACTINT135      ; cMsg := "Alt+Bild"
   CASE nMsg == MSG_ACTINT136      ; cMsg := "Alt+<-"
   CASE nMsg == MSG_ACTINT137      ; cMsg := "Alt+->"
   CASE nMsg == MSG_ACTINT138      ; cMsg := "Alt+Ende"
   CASE nMsg == MSG_ACTINT139      ; cMsg := "Alt+"
   CASE nMsg == MSG_ACTINT140      ; cMsg := "Alt+Bild"
   CASE nMsg == MSG_ACTINT141      ; cMsg := "Alt+Einfg"
   CASE nMsg == MSG_ACTINT142      ; cMsg := "Alt+Entf"
   CASE nMsg == MSG_ACTINT143      ; cMsg := "Alt+Tab"
   //   nMsg == MSG_ACTINT144      ; cMsg := "Strg+F"
   CASE nMsg == MSG_ACTINT145      ; cMsg := "Strg+Backslash"
   CASE nMsg == MSG_ACTINT146      ; cMsg := "Strg+Leertaste"
   CASE nMsg == MSG_ACTINT147      ; cMsg := "Alt+Leertaste"
   CASE nMsg == MSG_ACTINT148      ; cMsg := "Umsch+Entf"
   CASE nMsg == MSG_ACTINT149      ; cMsg := "Umsch+Einfg"
   CASE nMsg == MSG_ACTINT150      ; cMsg := "Alt+?"
   CASE nMsg == MSG_ACTINT151      ; cMsg := "Alt-Shift-Tab"
   //   nMsg == MSG_ACTINT152      ; cMsg := "Strg+P"
   CASE nMsg == MSG_ACTINT153      ; cMsg := "Strg"
   CASE nMsg == MSG_ACTINT154      ; cMsg := "Alt"
   CASE nMsg == MSG_ACTINT155      ; cMsg := "Umsch"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_ADDMENUUND     ; cMsg := "Nicht definierte Aktion !"
   CASE nMsg == MSG_ATTBUTUND      ; cMsg := "Nicht definierte Funktion !"
   CASE nMsg == MSG_FORMESC        ; cMsg := "Verlassen"
   CASE nMsg == MSG_FORMWRI        ; cMsg := "Sichern"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_INFO01         ; cMsg := "Syntax:"
   CASE nMsg == MSG_INFO02         ; cMsg := "[optionen] [IniDatei.ext]"
   CASE nMsg == MSG_INFO03         ; cMsg := "Optionen:   /?|/h = Diese Info"
   CASE nMsg == MSG_INFO04         ; cMsg := "            /UPD  = Datenbank der Applikation berprfen"
   CASE nMsg == MSG_INFO05         ; cMsg := "IniDatei.ext:   Name der INI-Datei"
   CASE nMsg == MSG_INFO06         ; cMsg := "                Der Vorgabewert ist DBSTART.INI"
   CASE nMsg == MSG_INFO07         ; cMsg := "            /FAST =  Schneller Mousereset"
   CASE nMsg == MSG_INFO08         ; cMsg := "Programm erzeugt mit Visual dBsee %VER% dem STANDARD CASE fšr Xbase++"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFISPIRATE01   ; cMsg := "Programm z.Zt. ungsch_tzt//Sch_tzen Sie das Pogramm"
   CASE nMsg == MSG_DFISPIRATE02   ; cMsg := "Probleme beim Sch_tzen"
   CASE nMsg == MSG_DFISPIRATE03   ; cMsg := "Programm z.Zt. ungsch_tzt//Sch_tzen Sie das Pogramm"
   CASE nMsg == MSG_DFISPIRATE04   ; cMsg := "Illegale Kopie des Programmes//Wenden Sie sich an den technischen Support"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFCFGPAL01     ; cMsg := "Die Farben sind ge„ndert//Wollen Sie sichern ?"
   CASE nMsg == MSG_DFCFGPAL02     ; cMsg := "Warte ..."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_AS40001        ; cMsg := "Servername : "
   CASE nMsg == MSG_AS40002        ; cMsg := "AS/400-Verbindung"
   CASE nMsg == MSG_AS40003        ; cMsg := "Verbindungs-Fehler//Umgebungseinstellung W400ENV pršfen"
   CASE nMsg == MSG_AS40004        ; cMsg := "Datei pršfen (%FILE%)"
   CASE nMsg == MSG_AS40005        ; cMsg := "Name der Konfigurationsbibliothek : "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFDATEFT01     ; cMsg := "von Datum :"
   CASE nMsg == MSG_DFDATEFT02     ; cMsg := "bis Datum :"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFPRNLAB01     ; cMsg := "Etikett fšr Reihe"
   CASE nMsg == MSG_DFPRNLAB02     ; cMsg := "Platz Etikett"
   CASE nMsg == MSG_DFPRNLAB03     ; cMsg := "L„nge Etikett"
   CASE nMsg == MSG_DFPRNLAB04     ; cMsg := "Etikett"
   CASE nMsg == MSG_DFPRNLAB05     ; cMsg := "Anwendbare Funktionen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFCOL2PRN01    ; cMsg := "Spalte zum Ausdruck"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFCHKDBF01     ; cMsg := "Der Header von Datei//"
   CASE nMsg == MSG_DFCHKDBF02     ; cMsg := "//enth„lt falsche Anzahl S„tze"
   CASE nMsg == MSG_DFCHKDBF03     ; cMsg := "//Header-Einstellung    : "
   CASE nMsg == MSG_DFCHKDBF04     ; cMsg := "//Wirkliche Einstellung : "
   CASE nMsg == MSG_DFCHKDBF05     ; cMsg := "//Fehler korrigieren ?"
   CASE nMsg == MSG_DFCHKDBF06     ; cMsg := "////Wenn Sie den Index nicht updaten "
   CASE nMsg == MSG_DFCHKDBF07     ; cMsg := "//beim Neu-Indexieren k”nnen Dtaen zerst”rt werden"
   CASE nMsg == MSG_DFCHKDBF08     ; cMsg := "//ACHTUNG: Machen Sie eine Datensicherung vor dem Datenbank-Update"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DDFILEST01     ; cMsg := "Choise the statistic field"
   CASE nMsg == MSG_DDFILEST02     ; cMsg := "Other"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG_DFFILEDLG01    ; cMsg := "^Path"
   CASE nMsg == MSG_DFFILEDLG02    ; cMsg := "^Tree"
   CASE nMsg == MSG_DFFILEDLG03    ; cMsg := "^Unit"
   CASE nMsg == MSG_DFFILEDLG04    ; cMsg := "^WildCard"
   CASE nMsg == MSG_DFFILEDLG05    ; cMsg := "^Files"
   CASE nMsg == MSG_DFFILEDLG06    ; cMsg := "Name"
   CASE nMsg == MSG_DFFILEDLG07    ; cMsg := "Dim"
   CASE nMsg == MSG_DFFILEDLG08    ; cMsg := "Date"
   CASE nMsg == MSG_DFFILEDLG09    ; cMsg := "Time"
   CASE nMsg == MSG_DFFILEDLG10    ; cMsg := "File Dialog"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ENDCASE

#ifdef __XPP__
cMsg := STRTRAN( cMsg, "³", "" )
#endif

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
