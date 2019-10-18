// *****************************************************************************
// Copyright (C) 1994 ISA - Italian Software Agency
// Descrizione    : Library message
// *****************************************************************************
#include "dfMsg.ch"
#include "dfState.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStdMsg( nMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cMsg := ""
DO CASE
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_LANGUAGE       ; cMsg := "BOSNIA"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INITERROR      ; cMsg := "Datoteka Init se ne mo§e otvoriti"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_STD_YES        ; cMsg := "^Da"
   CASE nMsg == MSG_STD_NO         ; cMsg := "^Ne"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TABGET01       ; cMsg := "Nema reference u dbDD//"
   CASE nMsg == MSG_TABGET02       ; cMsg := " ne postoji "
   CASE nMsg == MSG_TABGET03       ; cMsg := "Greзka otvaranja DBDD.DBF"
   CASE nMsg == MSG_TABGET04       ; cMsg := "Greзka otvaranja DBTABD.DBF"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TABCHK01       ; cMsg := "Prozor na "
   CASE nMsg == MSG_TABCHK02       ; cMsg := " nedostupan!//"
   CASE nMsg == MSG_TABCHK03       ; cMsg := "Datoteka: "
   CASE nMsg == MSG_TABCHK04       ; cMsg := " nema podataka !"
   CASE nMsg == MSG_TABCHK05       ; cMsg := "Podatak je obavezan//("
   CASE nMsg == MSG_TABCHK06       ; cMsg := "Podatak//("
   CASE nMsg == MSG_TABCHK07       ; cMsg := ")//vrijednost://"
   CASE nMsg == MSG_TABCHK08       ; cMsg := "ne nalazi se u datoteci: "
   CASE nMsg == MSG_TABCHK09       ; cMsg := "//Umetni"
   CASE nMsg == MSG_TABCHK10       ; cMsg := "Podatak//("
   CASE nMsg == MSG_TABCHK11       ; cMsg := ")//vrijednost://"
   CASE nMsg == MSG_TABCHK12       ; cMsg := "ne nalazi se u datoteci"
   CASE nMsg == MSG_TABCHK13       ; cMsg := "Polje kljuџa"
   CASE nMsg == MSG_TABCHK14       ; cMsg := "Ne postoji"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ERRSYS01       ; cMsg := "Pogreзan broj funkcije"
   CASE nMsg == MSG_ERRSYS02       ; cMsg := "Nema datoteke"
   CASE nMsg == MSG_ERRSYS03       ; cMsg := "Nema putanje"
   CASE nMsg == MSG_ERRSYS04       ; cMsg := "Previзe otvorenih datoteka"
   CASE nMsg == MSG_ERRSYS05       ; cMsg := "Pristup zabranjen"
   CASE nMsg == MSG_ERRSYS06       ; cMsg := "Nedovoljno memorije"
   CASE nMsg == MSG_ERRSYS07       ; cMsg := "Rezervirano"
   CASE nMsg == MSG_ERRSYS08       ; cMsg := "Disk je zaзtiџen"
   CASE nMsg == MSG_ERRSYS09       ; cMsg := "Nepoznata naredba"
   CASE nMsg == MSG_ERRSYS10       ; cMsg := "Greзka pisanja"
   CASE nMsg == MSG_ERRSYS11       ; cMsg := "Greзka џitanja"
   CASE nMsg == MSG_ERRSYS12       ; cMsg := "Op†enita greзka"
// CASE nMsg == MSG_ERRSYS13       ; cMsg := "Pristup zabranjen"
   CASE nMsg == MSG_ERRSYS14       ; cMsg := "Datoteka ve† postoji"
   CASE nMsg == MSG_ERRSYS15       ; cMsg := "Ova greзka snimljena je u datoteku :"
   CASE nMsg == MSG_ERRSYS16       ; cMsg := "Pritisnite tipku..."
   CASE nMsg == MSG_ERRSYS17       ; cMsg := "Invalid handle"
   CASE nMsg == MSG_ERRSYS18       ; cMsg := "Memory control blocks destroyed"
   CASE nMsg == MSG_ERRSYS19       ; cMsg := "Invalid memory block address"
   CASE nMsg == MSG_ERRSYS20       ; cMsg := "Invalid environment"
   CASE nMsg == MSG_ERRSYS21       ; cMsg := "Invalid format"
   CASE nMsg == MSG_ERRSYS22       ; cMsg := "Invalid access code"
   CASE nMsg == MSG_ERRSYS23       ; cMsg := "Invalid data"
   CASE nMsg == MSG_ERRSYS24       ; cMsg := "Naveden je pogreзan ureРaj"
   CASE nMsg == MSG_ERRSYS25       ; cMsg := "Pokuзaj brisanja teku†eg direktorija"
   CASE nMsg == MSG_ERRSYS26       ; cMsg := "Nije isti ureРaj"
   CASE nMsg == MSG_ERRSYS27       ; cMsg := "Nema viзe datoteka"
   CASE nMsg == MSG_ERRSYS28       ; cMsg := "Nepoznati ureРaj"
   CASE nMsg == MSG_ERRSYS29       ; cMsg := "UreРaj nije spreman"
   CASE nMsg == MSG_ERRSYS30       ; cMsg := "Greзka u podacima (CRC)"
   CASE nMsg == MSG_ERRSYS31       ; cMsg := "Bad request structure length"
   CASE nMsg == MSG_ERRSYS32       ; cMsg := "Seek error"
   CASE nMsg == MSG_ERRSYS33       ; cMsg := "Unknown media type"
   CASE nMsg == MSG_ERRSYS34       ; cMsg := "Sector not found"
   CASE nMsg == MSG_ERRSYS35       ; cMsg := "Nema papira"
   CASE nMsg == MSG_ERRSYS36       ; cMsg := "Sharing violation"
   CASE nMsg == MSG_ERRSYS37       ; cMsg := "Lock violation"
   CASE nMsg == MSG_ERRSYS38       ; cMsg := "Invalid disk change"
   CASE nMsg == MSG_ERRSYS39       ; cMsg := "FCB nedostupan"
   CASE nMsg == MSG_ERRSYS40       ; cMsg := "Sharing buffer overflow"
   CASE nMsg == MSG_ERRSYS41       ; cMsg := "Network request not supported"
   CASE nMsg == MSG_ERRSYS42       ; cMsg := "Remote computer not listening"
   CASE nMsg == MSG_ERRSYS43       ; cMsg := "Dupliciran naziv na mre§i"
   CASE nMsg == MSG_ERRSYS44       ; cMsg := "Naziv mre§e nije pronaРen"
   CASE nMsg == MSG_ERRSYS45       ; cMsg := "Mre§a je zauzeta"
   CASE nMsg == MSG_ERRSYS46       ; cMsg := "Mre§ni ureРaj viзe ne postoji"
   CASE nMsg == MSG_ERRSYS47       ; cMsg := "Network BIOS command limit exceeded"
   CASE nMsg == MSG_ERRSYS48       ; cMsg := "Hardverska greзka mre§nog adaptera"
   CASE nMsg == MSG_ERRSYS49       ; cMsg := "Nekorektan odgovor sa mre§e"
   CASE nMsg == MSG_ERRSYS50       ; cMsg := "Greзka na mre§i"
   CASE nMsg == MSG_ERRSYS51       ; cMsg := "Incompatible remote adapter"
   CASE nMsg == MSG_ERRSYS52       ; cMsg := "Zahtjev za зtampu popunjen"
   CASE nMsg == MSG_ERRSYS53       ; cMsg := "Nema dovoljno mjesta za print datoteku"
   CASE nMsg == MSG_ERRSYS54       ; cMsg := "Print datoteka obrisana (nema dovoljno prostora)"
   CASE nMsg == MSG_ERRSYS55       ; cMsg := "Network name deleted"
   CASE nMsg == MSG_ERRSYS56       ; cMsg := "Network device type incorrect"
// //   CASE nMsg == MSG_ERRSYS57       ; cMsg := "Network name not found"
   CASE nMsg == MSG_ERRSYS58       ; cMsg := "Network name limit exceeded"
   CASE nMsg == MSG_ERRSYS59       ; cMsg := "Network BIOS session limit exceeded"
   CASE nMsg == MSG_ERRSYS60       ; cMsg := "Privremeno zaustavljeno"
   CASE nMsg == MSG_ERRSYS61       ; cMsg := "Network request not accepted"
   CASE nMsg == MSG_ERRSYS62       ; cMsg := "жtampa ili disk preusmjerenje pauzirano"
   CASE nMsg == MSG_ERRSYS63       ; cMsg := "Cannot make directory entry"
   CASE nMsg == MSG_ERRSYS64       ; cMsg := "Fail on INT 24H"
   CASE nMsg == MSG_ERRSYS65       ; cMsg := "Too many redirections"
   CASE nMsg == MSG_ERRSYS66       ; cMsg := "Duplicate redirection"
   CASE nMsg == MSG_ERRSYS67       ; cMsg := "Pogreзna lozinka"
   CASE nMsg == MSG_ERRSYS68       ; cMsg := "Pogreзan parametar"
   CASE nMsg == MSG_ERRSYS69       ; cMsg := "Network device fault"
   CASE nMsg == MSG_ERRSYS70       ; cMsg := "Prekid"
   CASE nMsg == MSG_ERRSYS71       ; cMsg := "Pokuзaj"
   CASE nMsg == MSG_ERRSYS72       ; cMsg := "Default"
   CASE nMsg == MSG_ERRSYS73       ; cMsg := "DOS greзka :="
   CASE nMsg == MSG_ERRSYS74       ; cMsg := "Prekid"
   CASE nMsg == MSG_ERRSYS75       ; cMsg := "Pozvana iz"
   CASE nMsg == MSG_ERRSYS76       ; cMsg := "Greзka "
   CASE nMsg == MSG_ERRSYS77       ; cMsg := "Upozorenje "
   CASE nMsg == MSG_ERRSYS78       ; cMsg := "NEPOZNAT "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBPATH01       ; cMsg := "¬itanje putanje : @"
   CASE nMsg == MSG_DBPATH02       ; cMsg := "Naziv varijable ne postoji"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDUSE01        ; cMsg := "Datoteka ne postoji:"
   CASE nMsg == MSG_DDUSE02        ; cMsg := "Otvaranje datoteke :"
   CASE nMsg == MSG_DDUSE03        ; cMsg := "Pogreзno ime varijable: "
   CASE nMsg == MSG_DDUSE04        ; cMsg := "Nepoznati naџin!"
   CASE nMsg == MSG_DDUSE05        ; cMsg := "Indeks :"
// CASE nMsg == MSG_DDUSE06        ; cMsg := "Pogreзno ime varijable: "
   CASE nMsg == MSG_DDUSE07        ; cMsg := "Greзka otvaranja"
   CASE nMsg == MSG_DDUSE08        ; cMsg := "Nemogu†e je otvoriti datoteku"
   CASE nMsg == MSG_DDUSE09        ; cMsg := "Vrijeme isteklo :"
   CASE nMsg == MSG_DDUSE10        ; cMsg := "Indeks ne postoji"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBMSGERR       ; cMsg := "OK"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DE_STATE_INK   ; cMsg := "Pregled"
   CASE nMsg == MSG_DE_STATE_ADD   ; cMsg := "Novi"
   CASE nMsg == MSG_DE_STATE_MOD   ; cMsg := "Promjena"
   CASE nMsg == MSG_DE_STATE_DEL   ; cMsg := "Brisanje"
   CASE nMsg == MSG_DE_STATE_COPY  ; cMsg := "Kopira"
   CASE nMsg == MSG_DE_STATE_QRY   ; cMsg := "Upit"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBSKIP01       ; cMsg := " nema podataka !!"
   CASE nMsg == MSG_TBSKIP02       ; cMsg := "Poџetak : "
   CASE nMsg == MSG_TBSKIP03       ; cMsg := "Kraj : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DE_DEL         ; cMsg := "Potvrdite brisanje sloga !"
   CASE nMsg == MSG_DE_NOTMOD      ; cMsg := "Nema podataka !"
   CASE nMsg == MSG_DE_NOTDEL      ; cMsg := "Nema podataka !"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_NUM2WORD01     ; cMsg := "jedan"
   CASE nMsg == MSG_NUM2WORD02     ; cMsg := "dva"
   CASE nMsg == MSG_NUM2WORD03     ; cMsg := "tri"
   CASE nMsg == MSG_NUM2WORD04     ; cMsg := "џetiri"
   CASE nMsg == MSG_NUM2WORD05     ; cMsg := "pet"
   CASE nMsg == MSG_NUM2WORD06     ; cMsg := "зest"
   CASE nMsg == MSG_NUM2WORD07     ; cMsg := "sedam"
   CASE nMsg == MSG_NUM2WORD08     ; cMsg := "osam"
   CASE nMsg == MSG_NUM2WORD09     ; cMsg := "devet"
   CASE nMsg == MSG_NUM2WORD10     ; cMsg := "deset"
   CASE nMsg == MSG_NUM2WORD11     ; cMsg := "jedanaest"
   CASE nMsg == MSG_NUM2WORD12     ; cMsg := "dvanaest"
   CASE nMsg == MSG_NUM2WORD13     ; cMsg := "trinaest"
   CASE nMsg == MSG_NUM2WORD14     ; cMsg := "џetrnaest"
   CASE nMsg == MSG_NUM2WORD15     ; cMsg := "petnaest"
   CASE nMsg == MSG_NUM2WORD16     ; cMsg := "зesnaest"
   CASE nMsg == MSG_NUM2WORD17     ; cMsg := "sedamnaest"
   CASE nMsg == MSG_NUM2WORD18     ; cMsg := "osamnaest"
   CASE nMsg == MSG_NUM2WORD19     ; cMsg := "devetnaest"
   CASE nMsg == MSG_NUM2WORD20     ; cMsg := "deset"
   CASE nMsg == MSG_NUM2WORD21     ; cMsg := "dvadeset"
   CASE nMsg == MSG_NUM2WORD22     ; cMsg := "trideset"
   CASE nMsg == MSG_NUM2WORD23     ; cMsg := "џetrdeset"
   CASE nMsg == MSG_NUM2WORD24     ; cMsg := "pedeset"
   CASE nMsg == MSG_NUM2WORD25     ; cMsg := "зezdeset"
   CASE nMsg == MSG_NUM2WORD26     ; cMsg := "sedamdeset"
   CASE nMsg == MSG_NUM2WORD27     ; cMsg := "osamdeset"
   CASE nMsg == MSG_NUM2WORD28     ; cMsg := "devedeset"
   CASE nMsg == MSG_NUM2WORD29     ; cMsg := " bilion"
   CASE nMsg == MSG_NUM2WORD30     ; cMsg := " milion"
   CASE nMsg == MSG_NUM2WORD31     ; cMsg := " hiljada"
   CASE nMsg == MSG_NUM2WORD32     ; cMsg := "nula"
   CASE nMsg == MSG_NUM2WORD33     ; cMsg := "hiljada"
   CASE nMsg == MSG_NUM2WORD34     ; cMsg := "milion"
   CASE nMsg == MSG_NUM2WORD35     ; cMsg := "milijarda"
   CASE nMsg == MSG_NUM2WORD36     ; cMsg := "stotina"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_NTXSYS01       ; cMsg := "Oporavak sistemskih indeksa"
   //   nMsg == MSG_NTXSYS02       ; cMsg := "Brisanje indeksa"
   CASE nMsg == MSG_NTXSYS03       ; cMsg := "Oporavak dbDD indeksa"
   CASE nMsg == MSG_NTXSYS04       ; cMsg := "Oporavak Help indeksa"
   CASE nMsg == MSG_NTXSYS05       ; cMsg := "Oporavak indeksa"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_PGLIST01       ; cMsg := "Popis stranica" // List of pages
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBCFGOPE01     ; cMsg := "Reindeksiranje"
   CASE nMsg == MSG_DBCFGOPE02     ; cMsg := "Ne mogu otvoriti sistemske datoteke"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_HLP01          ; cMsg := "^Sljede†i"
   CASE nMsg == MSG_HLP02          ; cMsg := "P^rethodni"
   CASE nMsg == MSG_HLP03          ; cMsg := "^Meni"
   CASE nMsg == MSG_HLP04          ; cMsg := "^Datoteka"
   CASE nMsg == MSG_HLP05          ; cMsg := "^Info"
   CASE nMsg == MSG_HLP06          ; cMsg := "^Sistem"
   CASE nMsg == MSG_HLP07          ; cMsg := "^Sa§etak"
   CASE nMsg == MSG_HLP08          ; cMsg := "^Prethodni"
   CASE nMsg == MSG_HLP09          ; cMsg := "N^aРi"
   CASE nMsg == MSG_HLP10          ; cMsg := "^Datoteka"
   CASE nMsg == MSG_HLP11          ; cMsg := "^Ispis predmeta"
   CASE nMsg == MSG_HLP12          ; cMsg := "^Izlaz"
   CASE nMsg == MSG_HLP13          ; cMsg := "^Koriзtenje vodi†a"
   CASE nMsg == MSG_HLP14          ; cMsg := "PronaРi tekst"
   CASE nMsg == MSG_HLP15          ; cMsg := "Nema teksta"
   CASE nMsg == MSG_HLP16          ; cMsg := "Upute"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBRID01        ; cMsg := "Brisanje je zabranjeno."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_USRHELP01      ; cMsg := "Nema uputa za ovo podruџje//"
   CASE nMsg == MSG_USRHELP02      ; cMsg := "u ovoj okolini !"
   CASE nMsg == MSG_USRHELP03      ; cMsg := " Dostupne tipke "
   CASE nMsg == MSG_USRHELP04      ; cMsg := "Prethodni ekran"
   CASE nMsg == MSG_USRHELP05      ; cMsg := "Kalkulator"
   CASE nMsg == MSG_USRHELP06      ; cMsg := "Izlaz u operativni sistem"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDINDEX01      ; cMsg := "Reindeksiranje"
   CASE nMsg == MSG_DDINDEX02      ; cMsg := "^Globalno"
   CASE nMsg == MSG_DDINDEX03      ; cMsg := "^Parcijalno"
   CASE nMsg == MSG_DDINDEX04      ; cMsg := "^Sistemske datoteke"
   CASE nMsg == MSG_DDINDEX05      ; cMsg := "  Index    3Slog  3Izraz     "
   CASE nMsg == MSG_DDINDEX06      ; cMsg := "Reindeksiranje"
   CASE nMsg == MSG_DDINDEX07      ; cMsg := " s pakiranjem"
   CASE nMsg == MSG_DDINDEX08      ; cMsg := "Odaberite INDEKSNU datoteku. Enter=Potvrdi ! "
   CASE nMsg == MSG_DDINDEX09      ; cMsg := "STANKA - Stisnite tipku - STANKA"
   CASE nMsg == MSG_DDINDEX10      ; cMsg := "Razmak=Stanka 3 Reindeksiranje !"
   CASE nMsg == MSG_DDINDEX11      ; cMsg := "...Pakiranje datoteke ("
   CASE nMsg == MSG_DDINDEX12      ; cMsg := ") u toku !..."
   CASE nMsg == MSG_DDINDEX13      ; cMsg := "Indeks datoteke :"
   CASE nMsg == MSG_DDINDEX14      ; cMsg := "Pogreзan naziv varijable :"
   CASE nMsg == MSG_DDINDEX15      ; cMsg := "^Provjera"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDINDEXFL01    ; cMsg := "Indeks     :"
   CASE nMsg == MSG_DDINDEXFL02    ; cMsg := "Pogreзan naziv varijable :"
   CASE nMsg == MSG_DDINDEXFL03    ; cMsg := "PACK datoteke :"
   CASE nMsg == MSG_DDINDEXFL04    ; cMsg := " u toku "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDWIN01        ; cMsg := "Prozor "
   CASE nMsg == MSG_DDWIN02        ; cMsg := "//Nedostupan !"
   CASE nMsg == MSG_DDWIN03        ; cMsg := "Nema podataka !"
   CASE nMsg == MSG_DDWIN04        ; cMsg := "Obrisati oznaџeni podatak"
   CASE nMsg == MSG_DDWIN05        ; cMsg := "Nema podataka !"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFAUTOFORM01   ; cMsg := "^Potvrdi"
   CASE nMsg == MSG_DFAUTOFORM02   ; cMsg := "^Odustani"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCOLOR01      ; cMsg := "Boja oznake"
   CASE nMsg == MSG_DFCOLOR02      ; cMsg := "Ne postoji"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFALERT01      ; cMsg := "Pritisnite tipku..."
   CASE nMsg == MSG_DFALERT02      ; cMsg := "Pritisnite neku od navedenih tipaka" // indicated
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFMEMO01       ; cMsg := "Potvrdi tipku"
   CASE nMsg == MSG_DFMEMO02       ; cMsg := "¬itanje s diska"
   CASE nMsg == MSG_DFMEMO03       ; cMsg := "Pisanje na disk"
   CASE nMsg == MSG_DFMEMO05       ; cMsg := "Isprazni total"
   CASE nMsg == MSG_DFMEMO06       ; cMsg := "Zbroji u total"
   CASE nMsg == MSG_DFMEMO07       ; cMsg := "Prika§i total"
   CASE nMsg == MSG_DFMEMO08       ; cMsg := "Prebaci total u tekst"
   CASE nMsg == MSG_DFMEMO09       ; cMsg := "Rijeзi izraz i dopiзi rezultat"
   CASE nMsg == MSG_DFMEMO10       ; cMsg := "Rijeзi izraz i umetni rezultat"
   CASE nMsg == MSG_DFMEMO11       ; cMsg := "¬itanje datoteke"
   CASE nMsg == MSG_DFMEMO12       ; cMsg := "3¬itanje Memo s diska3"
   CASE nMsg == MSG_DFMEMO13       ; cMsg := "Automatski izraџunat total. Zbrojene vrijednosti :"
   CASE nMsg == MSG_DFMEMO14       ; cMsg := "Total primljen iz kalkulatora//"
// CASE nMsg == MSG_DFMEMO15       ; cMsg := "Automatski izraџunat total. Zbrojene vrijednosti :"
   CASE nMsg == MSG_DFMEMO16       ; cMsg := "Ne mogu prona†i poџetak izraza !"
   CASE nMsg == MSG_DFMEMO17       ; cMsg := "Izlaz bez snimanja promjena"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFQRY01        ; cMsg := "Manje od"
   CASE nMsg == MSG_DFQRY02        ; cMsg := "Ve†e od"
   CASE nMsg == MSG_DFQRY03        ; cMsg := "Manje ili jednako"
   CASE nMsg == MSG_DFQRY04        ; cMsg := "Ve†e ili jednako"
   CASE nMsg == MSG_DFQRY05        ; cMsg := "Jednako"
   CASE nMsg == MSG_DFQRY06        ; cMsg := "Razliџito od"
   CASE nMsg == MSG_DFQRY07        ; cMsg := "Sadr§i"
   CASE nMsg == MSG_DFQRY08        ; cMsg := "je sadr§an u"
   CASE nMsg == MSG_DFQRY09        ; cMsg := "Upravo jednako"
   CASE nMsg == MSG_DFQRY10        ; cMsg := "istina"
   CASE nMsg == MSG_DFQRY11        ; cMsg := "neistina"
   CASE nMsg == MSG_DFQRY12        ; cMsg := " i "
   CASE nMsg == MSG_DFQRY13        ; cMsg := " ili "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_VALID01        ; cMsg := "Podatak je obavezan"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINI01        ; cMsg := "Drugaџija verzija"
   CASE nMsg == MSG_DFINI02        ; cMsg := "Regeneriranje DBSTART.INI by dBsee"
   CASE nMsg == MSG_DFINI03        ; cMsg := "Priprema funkcija ...."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFFILE2PRN01   ; cMsg := "Pisaџ nije spreman za rad!//Ponoviti pokuзaj ?"
   CASE nMsg == MSG_DFFILE2PRN02   ; cMsg := "Ispis..."
   CASE nMsg == MSG_DFFILE2PRN03   ; cMsg := "Ispisivanje zaustavljeno"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFNET01        ; cMsg := "Drugi korisnik zauzima DATOTEKU :"
   CASE nMsg == MSG_DFNET02        ; cMsg := "Drugi korisnik zauzima SLOG broj."
   CASE nMsg == MSG_DFNET03        ; cMsg := "Nije mogu†e dodati SLOG"
   //   nMsg == MSG_DFNET04        ; cMsg := "NEPOZNATA FUNKCIJA !!"
   //   nMsg == MSG_DFNET05        ; cMsg := "Trajanje pristupa: "
   CASE nMsg == MSG_DFNET06        ; cMsg := "Pristup slogu/datoteci"
   CASE nMsg == MSG_DFNET07        ; cMsg := "sekundi"
   CASE nMsg == MSG_DFNET08        ; cMsg := "ZAKLJU¬AVANJE Datoteke :"
   CASE nMsg == MSG_DFNET09        ; cMsg := "Koriзtenje semafora"
   CASE nMsg == MSG_DFNET10        ; cMsg := "Ne mo§e se na†i"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFMEMOWRI01    ; cMsg := "Datoteka za upis: "
   CASE nMsg == MSG_DFMEMOWRI02    ; cMsg := "Upiзite naziv datoteke.3F10=Potvrdi3Esc=Prekini"
   CASE nMsg == MSG_DFMEMOWRI03    ; cMsg := "Pisanje Memo na disk"
   CASE nMsg == MSG_DFMEMOWRI04    ; cMsg := "Datoteka ve† postoji. Prepisati ?"
   //   nMsg == MSG_DFMEMOWRI05    ; cMsg := "Datoteka "
   //   nMsg == MSG_DFMEMOWRI06    ; cMsg := " je upisan !"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPATH01    ; cMsg := "Priprema putanja ...."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIFONT01    ; cMsg := "Priprema fontova ...."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPRN01     ; cMsg := "Priprema pisaџa ...."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPROGIND01    ; cMsg := "Prekid"
   CASE nMsg == MSG_DFPROGIND02    ; cMsg := "     Prekid pristupa ?     "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBLOOK01       ; cMsg := "Podatak je obavezan//"
   CASE nMsg == MSG_DBLOOK02       ; cMsg := "     "
   CASE nMsg == MSG_DBLOOK03       ; cMsg := "Upozorenje: //"
   CASE nMsg == MSG_DBLOOK04       ; cMsg := "//ne postoji !!"
   CASE nMsg == MSG_DBLOOK05       ; cMsg := "Upozorenje: //"
   CASE nMsg == MSG_DBLOOK06       ; cMsg := "//ne nalazi se u datoteci"
   CASE nMsg == MSG_DBLOOK07       ; cMsg := "//Dodati ?"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABDE01      ; cMsg := "Datoteke"
   CASE nMsg == MSG_DFTABDE02      ; cMsg := "Tablice"
   CASE nMsg == MSG_DFTABDE03      ; cMsg := "Promjena"
   CASE nMsg == MSG_DFTABDE04      ; cMsg := "Nema tablica u aplikaciji"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBINK01        ; cMsg := "Ovaj slog zauzimate joз"
   CASE nMsg == MSG_DBINK02        ; cMsg := "sekundi"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
// CASE nMsg == MSG_DFINIPP01      ; cMsg := "Priprema portova pisaџa ...."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPOR01     ; cMsg := "Priprema izlaznih portova ...."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFGET01        ; cMsg := "Napusti masku"
   CASE nMsg == MSG_DFGET02        ; cMsg := "Snimi masku"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBBRWNEW01     ; cMsg := "Vrati izvornu veliџinu prozora"
   CASE nMsg == MSG_TBBRWNEW02     ; cMsg := "Promjena polo§aja prozora"
   CASE nMsg == MSG_TBBRWNEW03     ; cMsg := "Veliџina prozora"
   CASE nMsg == MSG_TBBRWNEW04     ; cMsg := "Smanji prozor na najmanju mogu†u veliџinu"
   CASE nMsg == MSG_TBBRWNEW05     ; cMsg := "Poveџaj prozor na najve†u mogu†u veliџinu"
   CASE nMsg == MSG_TBBRWNEW06     ; cMsg := "Ukloni teku†i i pripadaju†e prozore s ekrana"
   CASE nMsg == MSG_TBBRWNEW07     ; cMsg := "Poka§i popis aktivnih stranica"
   CASE nMsg == MSG_TBBRWNEW08     ; cMsg := "Sljede†i"
   CASE nMsg == MSG_TBBRWNEW09     ; cMsg := "Prethodni"
   CASE nMsg == MSG_TBBRWNEW10     ; cMsg := "Prvi"
   CASE nMsg == MSG_TBBRWNEW11     ; cMsg := "Zadnji"
   CASE nMsg == MSG_TBBRWNEW12     ; cMsg := "Lijevo"
   CASE nMsg == MSG_TBBRWNEW13     ; cMsg := "Desno"
   CASE nMsg == MSG_TBBRWNEW14     ; cMsg := "Prethodna stranica"
   CASE nMsg == MSG_TBBRWNEW15     ; cMsg := "Sljede†a stranica"
   CASE nMsg == MSG_TBBRWNEW16     ; cMsg := "Blokira/Otpuзta kolone s lijeva"
   CASE nMsg == MSG_TBBRWNEW17     ; cMsg := "Pove†ava kolonu"
   CASE nMsg == MSG_TBBRWNEW18     ; cMsg := "Smanjuje kolonu"
   CASE nMsg == MSG_TBBRWNEW19     ; cMsg := "Uklanja oznaku s elementa"
   CASE nMsg == MSG_TBBRWNEW20     ; cMsg := "Bira element"
   CASE nMsg == MSG_TBBRWNEW21     ; cMsg := "Bira sve"
   CASE nMsg == MSG_TBBRWNEW22     ; cMsg := "PrilagoРava teku†i element"
   CASE nMsg == MSG_TBBRWNEW23     ; cMsg := "Sljede†a stranica"
   CASE nMsg == MSG_TBBRWNEW24     ; cMsg := "^Otvori"
   CASE nMsg == MSG_TBBRWNEW25     ; cMsg := "^Pomakni"
   CASE nMsg == MSG_TBBRWNEW26     ; cMsg := "Odredi ^veliџinu"
   CASE nMsg == MSG_TBBRWNEW27     ; cMsg := "^Ikoniziraj"
   CASE nMsg == MSG_TBBRWNEW28     ; cMsg := "Pov^eџaj"
   CASE nMsg == MSG_TBBRWNEW29     ; cMsg := "Zatvori"
   CASE nMsg == MSG_TBBRWNEW30     ; cMsg := "^Prijelaz na..."
   CASE nMsg == MSG_TBBRWNEW31     ; cMsg := "Tipka"
   CASE nMsg == MSG_TBBRWNEW32     ; cMsg := "Prethodna stranica"
   CASE nMsg == MSG_TBBRWNEW33     ; cMsg := "Ispis podataka"
   CASE nMsg == MSG_TBBRWNEW34     ; cMsg := "Ispis labele"
   CASE nMsg == MSG_TBBRWNEW35     ; cMsg := "Statistika"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDGENDBF01     ; cMsg := "Datoteka"
   CASE nMsg == MSG_DDGENDBF02     ; cMsg := "nema niti jedno polje"
   CASE nMsg == MSG_DDGENDBF03     ; cMsg := "Kreiranje datoteke"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABPRINT01   ; cMsg := "Nema tablice"
   CASE nMsg == MSG_DFTABPRINT02   ; cMsg := "~ Tablice ~"
   CASE nMsg == MSG_DFTABPRINT03   ; cMsg := "Ispis tablica"
   //   nMsg == MSG_DFTABPRINT04   ; cMsg := "Ispis tablica"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPRNSTART01   ; cMsg := "Greзka otvaranja"
   CASE nMsg == MSG_DFPRNSTART02   ; cMsg := "Pritisni enter za ispis"
   CASE nMsg == MSG_DFPRNSTART03   ; cMsg := "Glavna datoteka"
   CASE nMsg == MSG_DFPRNSTART04   ; cMsg := "Ispis na"
   CASE nMsg == MSG_DFPRNSTART05   ; cMsg := "Teku†i pisaџ"
   CASE nMsg == MSG_DFPRNSTART06   ; cMsg := "Port pisaџa"
   CASE nMsg == MSG_DFPRNSTART07   ; cMsg := "Kvaliteta"
   CASE nMsg == MSG_DFPRNSTART08   ; cMsg := "Normalna"
   CASE nMsg == MSG_DFPRNSTART09   ; cMsg := "Visoka"
   CASE nMsg == MSG_DFPRNSTART10   ; cMsg := "Znakovi"
   CASE nMsg == MSG_DFPRNSTART11   ; cMsg := "^Normalni"
   CASE nMsg == MSG_DFPRNSTART12   ; cMsg := "^Komprimirani"
   CASE nMsg == MSG_DFPRNSTART13   ; cMsg := "P^ort"
   CASE nMsg == MSG_DFPRNSTART14   ; cMsg := "^Rubovi"
   CASE nMsg == MSG_DFPRNSTART15   ; cMsg := "^Pisaџi"
   CASE nMsg == MSG_DFPRNSTART16   ; cMsg := "Spoo^ler aktivan"
   CASE nMsg == MSG_DFPRNSTART17   ; cMsg := "Kopi^ja :"
   CASE nMsg == MSG_DFPRNSTART18   ; cMsg := "^Broj kopija"
   CASE nMsg == MSG_DFPRNSTART19   ; cMsg := "^Datoteka :"
   CASE nMsg == MSG_DFPRNSTART20   ; cMsg := "Pre^gled"
   CASE nMsg == MSG_DFPRNSTART21   ; cMsg := "^Ispis"
   CASE nMsg == MSG_DFPRNSTART22   ; cMsg := "Pr^ekid"
   CASE nMsg == MSG_DFPRNSTART23   ; cMsg := "Redova po stranici"
   CASE nMsg == MSG_DFPRNSTART24   ; cMsg := "Gornji rub"
   CASE nMsg == MSG_DFPRNSTART25   ; cMsg := "Donji rub"
   CASE nMsg == MSG_DFPRNSTART26   ; cMsg := "Lijevi rub"
   CASE nMsg == MSG_DFPRNSTART27   ; cMsg := "Rubovi"
   CASE nMsg == MSG_DFPRNSTART28   ; cMsg := "~ Portovi ~"
   CASE nMsg == MSG_DFPRNSTART29   ; cMsg := "~ Popis pisaџa ~"
   CASE nMsg == MSG_DFPRNSTART30   ; cMsg := "Izvjeзtaj bez razmaka meРu stranicama"
   CASE nMsg == MSG_DFPRNSTART31   ; cMsg := "Datoteka je prazna"
   CASE nMsg == MSG_DFPRNSTART32   ; cMsg := "Naziv izvjeзtaja"
   CASE nMsg == MSG_DFPRNSTART33   ; cMsg := "Opis filtera"
   CASE nMsg == MSG_DFPRNSTART34   ; cMsg := "Izraz filtera"
   CASE nMsg == MSG_DFPRNSTART35   ; cMsg := "In^formacija"
   CASE nMsg == MSG_DFPRNSTART36   ; cMsg := "Setup"
   CASE nMsg == MSG_DFPRNSTART37   ; cMsg := "Setup ^1"
   CASE nMsg == MSG_DFPRNSTART38   ; cMsg := "Setup ^2"
   CASE nMsg == MSG_DFPRNSTART39   ; cMsg := "Setup ^3"
   CASE nMsg == MSG_DFPRNSTART40   ; cMsg := "S^tranice"
   CASE nMsg == MSG_DFPRNSTART41   ; cMsg := "Ispis svih stranica"
   //   nMsg == MSG_DFPRNSTART42   ; cMsg := "Ispis svih stranica"
   CASE nMsg == MSG_DFPRNSTART43   ; cMsg := "Od stranice :"
   CASE nMsg == MSG_DFPRNSTART44   ; cMsg := "Ispis od stranice"
   CASE nMsg == MSG_DFPRNSTART45   ; cMsg := "Do stranice :"
   CASE nMsg == MSG_DFPRNSTART46   ; cMsg := "Ispis do stranice"
   CASE nMsg == MSG_DFPRNSTART47   ; cMsg := "Stranice"
   CASE nMsg == MSG_DFPRNSTART48   ; cMsg := "^Filter"
   CASE nMsg == MSG_DFPRNSTART49   ; cMsg := "Promjena filtera"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDDE01         ; cMsg := "Automatski prozor//"
   CASE nMsg == MSG_DDDE02         ; cMsg := "//nije definiran !"
   CASE nMsg == MSG_DDDE03         ; cMsg := "Automatski prozor//"
   CASE nMsg == MSG_DDDE04         ; cMsg := "//Primarni kljuџ nije definiran !"
   CASE nMsg == MSG_DDDE05         ; cMsg := "Prozor "
   CASE nMsg == MSG_DDDE06         ; cMsg := "PRIMARNI KLJU¬//"
   CASE nMsg == MSG_DDDE07         ; cMsg := "//Nije jedinstven !"
   CASE nMsg == MSG_DDDE08         ; cMsg := "Obavezan podatak"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBINK01        ; cMsg := "Oznaџeni slog je obrisan"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBGETKEY01     ; cMsg := "Lista vrijednosti"
   CASE nMsg == MSG_TBGETKEY02     ; cMsg := "Pretra§ivanje"
// CASE nMsg == MSG_TBGETKEY03     ; cMsg := "Lista vrijednosti"
   CASE nMsg == MSG_TBGETKEY04     ; cMsg := "Edit memo"
   CASE nMsg == MSG_TBGETKEY05     ; cMsg := "Oznaџi/Skini oznaku"
   CASE nMsg == MSG_TBGETKEY06     ; cMsg := "Odaberi vrijednost"
   CASE nMsg == MSG_TBGETKEY07     ; cMsg := "Stisni senzor"
   CASE nMsg == MSG_TBGETKEY08     ; cMsg := "Pove†ava vrijednost"
   CASE nMsg == MSG_TBGETKEY09     ; cMsg := "Smanjuje vrijednost"
   CASE nMsg == MSG_TBGETKEY10     ; cMsg := "Pove†ava vrijednost 10 puta"
   CASE nMsg == MSG_TBGETKEY11     ; cMsg := "Smanjuje vrijednost 10 puta"
   CASE nMsg == MSG_TBGETKEY14     ; cMsg := "Kopiranje"
   CASE nMsg == MSG_TBGETKEY15     ; cMsg := "Umetanje"
   CASE nMsg == MSG_TBGETKEY16     ; cMsg := "Prethodni podatak"
   CASE nMsg == MSG_TBGETKEY17     ; cMsg := "Sljede†i podatak"
   CASE nMsg == MSG_TBGETKEY18     ; cMsg := "Prvi podatak"
   CASE nMsg == MSG_TBGETKEY19     ; cMsg := "Zadnji podatak"
   CASE nMsg == MSG_TBGETKEY20     ; cMsg := "Kalendar"
   CASE nMsg == MSG_TBGETKEY21     ; cMsg := "Sljede†i datum"
   CASE nMsg == MSG_TBGETKEY22     ; cMsg := "Prethodni datum"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFSVILLEV01    ; cMsg := "Ispis zaustavljen"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFLOGIN01      ; cMsg := "Ne mo§e se otvoriti datoteka s lozinkama"
   CASE nMsg == MSG_DFLOGIN02      ; cMsg := "Unesite lozinku"
   CASE nMsg == MSG_DFLOGIN03      ; cMsg := "*  Lozinku koju ste upisali  *//"
   CASE nMsg == MSG_DFLOGIN04      ; cMsg := "    koristi drugi korisnik!   //"
   CASE nMsg == MSG_DFLOGIN05      ; cMsg := "==============================//"
   CASE nMsg == MSG_DFLOGIN06      ; cMsg := "Lozinka"
   CASE nMsg == MSG_DFLOGIN07      ; cMsg := "//nije pronaРena//"
   CASE nMsg == MSG_DFLOGIN08      ; cMsg := "Unesite ponovo lozinku"
   CASE nMsg == MSG_DFLOGIN09      ; cMsg := "* Pristup programu nije mogu†! *//"
   CASE nMsg == MSG_DFLOGIN10      ; cMsg := "     Niste autorizirani!    //"
   CASE nMsg == MSG_DFLOGIN11      ; cMsg := "=============================="
   CASE nMsg == MSG_DFLOGIN12      ; cMsg := " Greзka kod unoзenja lozinke //"
   CASE nMsg == MSG_DFLOGIN13      ; cMsg := "=============================="
   CASE nMsg == MSG_DFLOGIN14      ; cMsg := "LOZINKA"
   CASE nMsg == MSG_DFLOGIN15      ; cMsg := "Unesite novu lozinku"
   CASE nMsg == MSG_DFLOGIN16      ; cMsg := "Unesite ponovo lozinku"
   CASE nMsg == MSG_DFLOGIN17      ; cMsg := "Ime   Korisnik"
   CASE nMsg == MSG_DFLOGIN18      ; cMsg := "Unesite novu LOZINKU"
   CASE nMsg == MSG_DFLOGIN19      ; cMsg := "For the new laws on the Privacy //the Password must at least be of 8 characters!"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDWIT01        ; cMsg := "Novi element"
   CASE nMsg == MSG_DDWIT02        ; cMsg := "Promjena teku†eg elementa"
   CASE nMsg == MSG_DDWIT03        ; cMsg := "Brisanje teku†eg elementa"
   CASE nMsg == MSG_DDWIT04        ; cMsg := "Tra§enje"
   CASE nMsg == MSG_DDWIT05        ; cMsg := "жifra "
   CASE nMsg == MSG_DDWIT06        ; cMsg := " ne postoji"
   CASE nMsg == MSG_DDWIT07        ; cMsg := "Obrisati teku†i element"
   CASE nMsg == MSG_DDWIT08        ; cMsg := "Tra§i "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDKEY01        ; cMsg := "Nema kljuџa za tra§enje//-      "
   CASE nMsg == MSG_DDKEY02        ; cMsg := " Datoteka nema indeksa ! -"
   CASE nMsg == MSG_DDKEY03        ; cMsg := "Nemogu†e je prona†i kljuџ"
   CASE nMsg == MSG_DDKEY04        ; cMsg := "Sekvencijalna potraga aktivna samo na tekstu. !"
   CASE nMsg == MSG_DDKEY05        ; cMsg := "Prozor potrage"
   CASE nMsg == MSG_DDKEY06        ; cMsg := "Tra§enje odgovaraju†eg niza"
   CASE nMsg == MSG_DDKEY07        ; cMsg := "Prozor na LookUp datoteci"
   CASE nMsg == MSG_DDKEY08        ; cMsg := "Interaktivno formiranje kljuџa"
   CASE nMsg == MSG_DDKEY09        ; cMsg := "Kljuџ: "
   CASE nMsg == MSG_DDKEY10        ; cMsg := "//nije naРen!"
   CASE nMsg == MSG_DDKEY11        ; cMsg := " Pritisnite neku tipku za kraj "
   CASE nMsg == MSG_DDKEY12        ; cMsg := "//Molim priџekajte...//"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDUPDDBF01     ; cMsg := "Ispravljanje datoteke"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
*  CASE nMsg == MSG_DFTABFRM01     ; cMsg := "Promjena"
*  CASE nMsg == MSG_DFTABFRM02     ; cMsg := "Unos"
   CASE nMsg == MSG_DFTABFRM03     ; cMsg := "2. prolaz. Dvostruka зifra !//Upis zabranjen !!"
   CASE nMsg == MSG_DFTABFRM04     ; cMsg := "Greзka: dvostruka зifra u "
   CASE nMsg == MSG_DFTABFRM05     ; cMsg := "Upozorenje!"
   CASE nMsg == MSG_DFTABFRM06     ; cMsg := "^Ve† se koristi u"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPK01         ; cMsg := "primarni"
   CASE nMsg == MSG_DFPK02         ; cMsg := "jedinstveni"
   CASE nMsg == MSG_DFPK03         ; cMsg := "Kljuџ "
   CASE nMsg == MSG_DFPK04         ; cMsg := " kljuџ ve† postoji!//"
   CASE nMsg == MSG_DFPK05         ; cMsg := " kljuџ nije popunjen!//"
   CASE nMsg == MSG_DFPK06         ; cMsg := "===============================//"
   CASE nMsg == MSG_DFPK07         ; cMsg := "    Upiзite novu vrijednost !    "
*  CASE nMsg == MSG_DFPK08         ; cMsg := "Validate key "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDQRY01        ; cMsg := "i       [ .AND.["
   CASE nMsg == MSG_DDQRY02        ; cMsg := "ili     [ .OR. ["
   CASE nMsg == MSG_DDQRY17        ; cMsg := "zagrada [  )   ["
   CASE nMsg == MSG_DDQRY03        ; cMsg := "Kraj    [      ["
   CASE nMsg == MSG_DDQRY04        ; cMsg := " <   Manji od................ "
   CASE nMsg == MSG_DDQRY05        ; cMsg := " >   Ve†i od................. "
   CASE nMsg == MSG_DDQRY06        ; cMsg := " <=  Manji i jednak.......... "
   CASE nMsg == MSG_DDQRY07        ; cMsg := " >=  Ve†i i jednak........... "
   CASE nMsg == MSG_DDQRY08        ; cMsg := " =   Jednak.................. "
   CASE nMsg == MSG_DDQRY09        ; cMsg := " #   Razliџit................ "
   CASE nMsg == MSG_DDQRY10        ; cMsg := " $   Sadr§an u............... "
   CASE nMsg == MSG_DDQRY11        ; cMsg := "    Sadr§i.................. "
   CASE nMsg == MSG_DDQRY12        ; cMsg := "Polja datoteke"
   CASE nMsg == MSG_DDQRY13        ; cMsg := "Uvjeti"
   CASE nMsg == MSG_DDQRY14        ; cMsg := "Logiџke veze"
   CASE nMsg == MSG_DDQRY15        ; cMsg := "3Filter OK3"
   CASE nMsg == MSG_DDQRY16        ; cMsg := "3LO[ filter3"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBGET01        ; cMsg := "Razmak=Promjena 3 "
   CASE nMsg == MSG_TBGET02        ; cMsg := "F10=Snimanje 3 "
   CASE nMsg == MSG_TBGET03        ; cMsg := "Upisana vrijednost je pogreзna"
   CASE nMsg == MSG_TBGET04        ; cMsg := "Nemogu†e je mijenjati CONTROL"
   CASE nMsg == MSG_TBGET05        ; cMsg := "Podaci su izmijenjeni"
   CASE nMsg == MSG_TBGET06        ; cMsg := "^Snimi"
   CASE nMsg == MSG_TBGET07        ; cMsg := "^Kraj"
   CASE nMsg == MSG_TBGET08        ; cMsg := "^Nastavi"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFSTA01        ; cMsg := "Proteklo vrijeme"
   CASE nMsg == MSG_DFSTA02        ; cMsg := "Oџekivano vrijeme"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIREP01     ; cMsg := "Uџitavanje definicija izvjeзtaja"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCALC01       ; cMsg := "Zbrajanje"
   CASE nMsg == MSG_DFCALC02       ; cMsg := "Mno§enje"
   CASE nMsg == MSG_DFCALC03       ; cMsg := "Oduzimanje"
   CASE nMsg == MSG_DFCALC04       ; cMsg := "Dijeljenje"
   CASE nMsg == MSG_DFCALC06       ; cMsg := "Dodavanje"
   CASE nMsg == MSG_DFCALC07       ; cMsg := "On"
   CASE nMsg == MSG_DFCALC08       ; cMsg := "Off"
   CASE nMsg == MSG_DFCALC09       ; cMsg := "Izlaz i umetanje"
   CASE nMsg == MSG_DFCALC10       ; cMsg := "Pretvorba iz KM U EURO"
   CASE nMsg == MSG_DFCALC11       ; cMsg := "Konverzija iz EURA u KM"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INTCOL01       ; cMsg := "Crna"
   CASE nMsg == MSG_INTCOL02       ; cMsg := "Tamno siva"
   CASE nMsg == MSG_INTCOL03       ; cMsg := "Svijetlo siva"
   CASE nMsg == MSG_INTCOL04       ; cMsg := "Tamno plava"
   CASE nMsg == MSG_INTCOL05       ; cMsg := "Plava"
   CASE nMsg == MSG_INTCOL06       ; cMsg := "Svijetlo plava"
   CASE nMsg == MSG_INTCOL07       ; cMsg := "Tamno zelena"
   CASE nMsg == MSG_INTCOL08       ; cMsg := "Zelena"
   CASE nMsg == MSG_INTCOL09       ; cMsg := "Svijetlo zelena"
   CASE nMsg == MSG_INTCOL10       ; cMsg := "Tamno crvena"
   CASE nMsg == MSG_INTCOL11       ; cMsg := "Crvena"
   CASE nMsg == MSG_INTCOL12       ; cMsg := "Svijetlo crvena"
   CASE nMsg == MSG_INTCOL13       ; cMsg := "Tamno §uta"
   CASE nMsg == MSG_INTCOL14       ; cMsg := "¦uta"
   CASE nMsg == MSG_INTCOL15       ; cMsg := "Svijetlo §uta"
   CASE nMsg == MSG_INTCOL16       ; cMsg := "Bijela"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INTPRN01       ; cMsg := "Obiџni tekst (bez ESC-sekvenci)"
   //   nMsg == MSG_INTPRN02       ; cMsg := "EPSON FX-80"
   //   nMsg == MSG_INTPRN03       ; cMsg := "HP LASERJET PLUS"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ACTINT001      ; cMsg := "Home"
   CASE nMsg == MSG_ACTINT002      ; cMsg := "Ctrl-Desno"
   CASE nMsg == MSG_ACTINT003      ; cMsg := "PageDn"
   CASE nMsg == MSG_ACTINT004      ; cMsg := "Desno"
   CASE nMsg == MSG_ACTINT005      ; cMsg := "Gore"
   CASE nMsg == MSG_ACTINT006      ; cMsg := "End"
   CASE nMsg == MSG_ACTINT007      ; cMsg := "Del"
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
   CASE nMsg == MSG_ACTINT019      ; cMsg := "Ctrl-Enter"
   CASE nMsg == MSG_ACTINT020      ; cMsg := "Enter"
   CASE nMsg == MSG_ACTINT021      ; cMsg := "PageUp"
   CASE nMsg == MSG_ACTINT022      ; cMsg := "Lijevo"
   CASE nMsg == MSG_ACTINT023      ; cMsg := "Ins"
   CASE nMsg == MSG_ACTINT024      ; cMsg := "Ctrl-End"
   CASE nMsg == MSG_ACTINT025      ; cMsg := "Dolje"
   CASE nMsg == MSG_ACTINT026      ; cMsg := "Ctrl-Lijevo"
   CASE nMsg == MSG_ACTINT027      ; cMsg := "Esc"
   CASE nMsg == MSG_ACTINT028      ; cMsg := "F1"
   CASE nMsg == MSG_ACTINT029      ; cMsg := "Ctrl-Home"
   CASE nMsg == MSG_ACTINT030      ; cMsg := "Ctrl-PageUp"
   CASE nMsg == MSG_ACTINT031      ; cMsg := "Ctrl-PageDn"
   CASE nMsg == MSG_ACTINT032      ; cMsg := "Razmak"
   //   nMsg == MSG_ACTINT033      ; cMsg := "+"
   //   nMsg == MSG_ACTINT034      ; cMsg := "-"
   //   nMsg == MSG_ACTINT035      ; cMsg := "<"
   //   nMsg == MSG_ACTINT036      ; cMsg := ">"
   //   nMsg == MSG_ACTINT037      ; cMsg := "Shft-F1"
   //   nMsg == MSG_ACTINT038      ; cMsg := "Shft-F2"
   //   nMsg == MSG_ACTINT039      ; cMsg := "Shft-F3"
   //   nMsg == MSG_ACTINT040      ; cMsg := "Shft-F4"
   //   nMsg == MSG_ACTINT041      ; cMsg := "Shft-F5"
   //   nMsg == MSG_ACTINT042      ; cMsg := "Shft-F6"
   //   nMsg == MSG_ACTINT043      ; cMsg := "Shft-F7"
   //   nMsg == MSG_ACTINT044      ; cMsg := "Shft-F8"
   //   nMsg == MSG_ACTINT045      ; cMsg := "Shft-F9"
   //   nMsg == MSG_ACTINT046      ; cMsg := "Shft-F10"
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
   CASE nMsg == MSG_ACTINT081      ; cMsg := "Alt -"
   CASE nMsg == MSG_ACTINT082      ; cMsg := "Alt +"
   CASE nMsg == MSG_ACTINT083      ; cMsg := "Alt-Enter"
   CASE nMsg == MSG_ACTINT084      ; cMsg := "Alt-A"
   CASE nMsg == MSG_ACTINT085      ; cMsg := "Alt-S"
   CASE nMsg == MSG_ACTINT086      ; cMsg := "Alt-D"
   CASE nMsg == MSG_ACTINT087      ; cMsg := "Alt-F"
   CASE nMsg == MSG_ACTINT088      ; cMsg := "Alt-G"
   CASE nMsg == MSG_ACTINT089      ; cMsg := "Alt-H"
   CASE nMsg == MSG_ACTINT090      ; cMsg := "Alt-J"
   CASE nMsg == MSG_ACTINT091      ; cMsg := "Alt-K"
   CASE nMsg == MSG_ACTINT092      ; cMsg := "Alt-L"
   CASE nMsg == MSG_ACTINT093      ; cMsg := "Alt-"
   CASE nMsg == MSG_ACTINT094      ; cMsg := "Alt-"
   CASE nMsg == MSG_ACTINT095      ; cMsg := "Alt-\"
   CASE nMsg == MSG_ACTINT096      ; cMsg := "Alt-"
   CASE nMsg == MSG_ACTINT097      ; cMsg := "Alt-Z"
   CASE nMsg == MSG_ACTINT098      ; cMsg := "Alt-X"
   CASE nMsg == MSG_ACTINT099      ; cMsg := "Alt-C"
   CASE nMsg == MSG_ACTINT100      ; cMsg := "Alt-V"
   CASE nMsg == MSG_ACTINT101      ; cMsg := "Alt-B"
   CASE nMsg == MSG_ACTINT102      ; cMsg := "Alt-N"
   CASE nMsg == MSG_ACTINT103      ; cMsg := "Alt-M"
   CASE nMsg == MSG_ACTINT104      ; cMsg := "Alt-,"
   CASE nMsg == MSG_ACTINT105      ; cMsg := "Alt-."
   CASE nMsg == MSG_ACTINT106      ; cMsg := "Alt-"
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
   CASE nMsg == MSG_ACTINT118      ; cMsg := "Alt-"
   CASE nMsg == MSG_ACTINT119      ; cMsg := "F11"
   CASE nMsg == MSG_ACTINT120      ; cMsg := "F12"
   //   nMsg == MSG_ACTINT121      ; cMsg := "Shft-F11"
   //   nMsg == MSG_ACTINT122      ; cMsg := "Shft-F12"
   //   nMsg == MSG_ACTINT123      ; cMsg := "Ctrl-F11"
   //   nMsg == MSG_ACTINT124      ; cMsg := "Ctrl-F12"
   //   nMsg == MSG_ACTINT125      ; cMsg := "Alt-F11"
   //   nMsg == MSG_ACTINT126      ; cMsg := "Alt-F12"
   CASE nMsg == MSG_ACTINT127      ; cMsg := "Ctrl-Gore"
   CASE nMsg == MSG_ACTINT128      ; cMsg := "Ctrl-Dolje"
   CASE nMsg == MSG_ACTINT129      ; cMsg := "Ctrl-Ins"
   CASE nMsg == MSG_ACTINT130      ; cMsg := "Ctrl-Del"
   CASE nMsg == MSG_ACTINT131      ; cMsg := "Ctrl-Tab"
   CASE nMsg == MSG_ACTINT132      ; cMsg := "Ctrl-/"
   CASE nMsg == MSG_ACTINT133      ; cMsg := "Alt-Home"
   CASE nMsg == MSG_ACTINT134      ; cMsg := "Alt-Gore"
   CASE nMsg == MSG_ACTINT135      ; cMsg := "Alt-PageUp"
   CASE nMsg == MSG_ACTINT136      ; cMsg := "Alt-Lijevo"
   CASE nMsg == MSG_ACTINT137      ; cMsg := "Alt-Desno"
   CASE nMsg == MSG_ACTINT138      ; cMsg := "Alt-End"
   CASE nMsg == MSG_ACTINT139      ; cMsg := "Alt-Dolje"
   CASE nMsg == MSG_ACTINT140      ; cMsg := "Alt-PageDn"
   CASE nMsg == MSG_ACTINT141      ; cMsg := "Alt-Ins"
   CASE nMsg == MSG_ACTINT142      ; cMsg := "Alt-Del"
   CASE nMsg == MSG_ACTINT143      ; cMsg := "Alt-Tab"
   //   nMsg == MSG_ACTINT144      ; cMsg := "Ctrl-F"
   CASE nMsg == MSG_ACTINT145      ; cMsg := "Ctrl-\"
   CASE nMsg == MSG_ACTINT146      ; cMsg := "Ctrl-Razmak"
   CASE nMsg == MSG_ACTINT147      ; cMsg := "Alt-Razmak"
   CASE nMsg == MSG_ACTINT148      ; cMsg := "Shft-Del"
   CASE nMsg == MSG_ACTINT149      ; cMsg := "Shft-Ins"
   CASE nMsg == MSG_ACTINT150      ; cMsg := "Alt-?"
   CASE nMsg == MSG_ACTINT151      ; cMsg := "Alt-Shift-Tab"
   //   nMsg == MSG_ACTINT152      ; cMsg := "Ctrl-P"
   CASE nMsg == MSG_ACTINT153      ; cMsg := "Ctrl"
   CASE nMsg == MSG_ACTINT154      ; cMsg := "Alt"
   CASE nMsg == MSG_ACTINT155      ; cMsg := "Shft"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ADDMENUUND     ; cMsg := "Nedefiniran dogaРaj !"
   CASE nMsg == MSG_ATTBUTUND      ; cMsg := "Nedefinirana funkcija !"
   CASE nMsg == MSG_FORMESC        ; cMsg := "Izlaz"
   CASE nMsg == MSG_FORMWRI        ; cMsg := "Snimi"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INFO01         ; cMsg := "Sintaksa:"
   CASE nMsg == MSG_INFO02         ; cMsg := "[opcije] [Inifile.ext]"
   CASE nMsg == MSG_INFO03         ; cMsg := "Opcije :   /?|/h = Ovaj info"
   CASE nMsg == MSG_INFO04         ; cMsg := "           /UPD  = Kontrola datoteka aplikacije"
   CASE nMsg == MSG_INFO05         ; cMsg := "Inifile.ext:   Naziv INI datoteke"
   CASE nMsg == MSG_INFO06         ; cMsg := "               Default naziv je DBSTART.INI"
   CASE nMsg == MSG_INFO07         ; cMsg := "           /FAST = Brzo aktiviranje miзa"
   CASE nMsg == MSG_INFO08         ; cMsg := "Program Generiran s dBsee %VER% the STANDARD CASE for CA-CLIPPER"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFISPIRATE01   ; cMsg := "Program trenutno nezaзtiжen!//Obavite zaзtitu!"
   CASE nMsg == MSG_DFISPIRATE02   ; cMsg := "Problemi u toku zaзti†ivanja"
   CASE nMsg == MSG_DFISPIRATE03   ; cMsg := "Program trenutno nezaзti†en!//Morate zaзititi program!"
   CASE nMsg == MSG_DFISPIRATE04   ; cMsg := "Nelegalna kopija programa!//pozovite tehniџku podrзku"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCFGPAL01     ; cMsg := "Boje su izmijenjene//§elite li ih snimiti?"
   CASE nMsg == MSG_DFCFGPAL02     ; cMsg := "Priџekajte ..."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_AS40001        ; cMsg := "Naziv servera : "
   CASE nMsg == MSG_AS40002        ; cMsg := "AS/400 Connection"
   CASE nMsg == MSG_AS40003        ; cMsg := "Greзka u vezi//Provjerite W400ENV environment setting"
   CASE nMsg == MSG_AS40004        ; cMsg := "Provjeri datoteku (%FILE%)"
   CASE nMsg == MSG_AS40005        ; cMsg := "Naziv konfiguracijske biblioteke : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFDATEFT01     ; cMsg := "Od datuma :"
   CASE nMsg == MSG_DFDATEFT02     ; cMsg := "Do datuma :"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPRNLAB01     ; cMsg := "Labela u redu"
   CASE nMsg == MSG_DFPRNLAB02     ; cMsg := "Prostor labele"
   CASE nMsg == MSG_DFPRNLAB03     ; cMsg := "Du§ina labele"
   CASE nMsg == MSG_DFPRNLAB04     ; cMsg := "Labela"
   CASE nMsg == MSG_DFPRNLAB05     ; cMsg := "Izvrзiti funkciju"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCOL2PRN01    ; cMsg := "Ispisati kolone"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCHKDBF01     ; cMsg := "Zaglavlje datoteke//"
   CASE nMsg == MSG_DFCHKDBF02     ; cMsg := "//ima neispravan broj slogova"
   CASE nMsg == MSG_DFCHKDBF03     ; cMsg := "//Header setting   : "
   CASE nMsg == MSG_DFCHKDBF04     ; cMsg := "//Real setting     : "
   CASE nMsg == MSG_DFCHKDBF05     ; cMsg := "//Ispraviti pogreзku ?"
   CASE nMsg == MSG_DFCHKDBF06     ; cMsg := "////Ako ne izvrзite indeksiranje "
   CASE nMsg == MSG_DFCHKDBF07     ; cMsg := "//mogli biste izgubiti dijelove podataka"
   CASE nMsg == MSG_DFCHKDBF08     ; cMsg := "//UPAMTITE : Napravite kopiju prije izmjena u bazi"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDFILEST01     ; cMsg := "Izaberite polja statistike"
   CASE nMsg == MSG_DDFILEST02     ; cMsg := "Ostalo"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
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
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
ENDCASE

#ifdef __XPP__
cMsg := STRTRAN( cMsg, "і", "" )
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
