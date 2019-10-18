// *****************************************************************************
// Copyright (C) 1994 ISA - Italian Software Agency
// Descrizione    : Library message
// *****************************************************************************
#include "dfMsg1.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStdMsg1( nMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cMsg := ""
DO CASE
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_LANGUAGE       ; cMsg := "BOSNIA"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_INITAPPS01     ; cMsg := "Naзao dbupdate.log !!"
   CASE nMsg == MSG1_INITAPPS02     ; cMsg := "Aplikacija u toku nadogradnje"
   CASE nMsg == MSG1_INITAPPS03     ; cMsg := "Molim pokuзajte ponovo"
   CASE nMsg == MSG1_INITAPPS04     ; cMsg := "Bootstrap sekundi : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DBINK01        ; cMsg := "Imate "
   CASE nMsg == MSG1_DBINK02        ; cMsg := " Sekundi za prekid"
   CASE nMsg == MSG1_DBINK03        ; cMsg := "Sekunde : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_TBBRWNEW36     ; cMsg := "жtampanje"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFDBFNTX01     ; cMsg := "Database engine DBFDBE nije uџitan"
   CASE nMsg == MSG1_DFDBFNTX02     ; cMsg := "Database engine NTXDBE nije uџitan"
   CASE nMsg == MSG1_DFDBFNTX03     ; cMsg := "DBFNTX database engine nemo§e biti kreiran"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFDBFCDX01     ; cMsg := "Database engine FOXDBE nije uџitan"
   CASE nMsg == MSG1_DFDBFCDX02     ; cMsg := "Database engine CDXDBE nije uџitan"
   CASE nMsg == MSG1_DFDBFCDX03     ; cMsg := "DBFCDX database engine nemo§e biti kreiran"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2GETMEN01     ; cMsg := "&Odustajem"
   CASE nMsg == MSG1_S2GETMEN02     ; cMsg := "&Vrati"
   CASE nMsg == MSG1_S2GETMEN03     ; cMsg := "&Kopiraj"
   CASE nMsg == MSG1_S2GETMEN04     ; cMsg := "&Zalijepi"
   CASE nMsg == MSG1_S2GETMEN05     ; cMsg := "&Briзi"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFPRNMENU01    ; cMsg := "Fon^t"
   CASE nMsg == MSG1_DFPRNMENU02    ; cMsg := "Printer nije validan"
   CASE nMsg == MSG1_DFPRNMENU03    ; cMsg := "Strana"
   CASE nMsg == MSG1_DFPRNMENU04    ; cMsg := "Pogled na ekran"
   CASE nMsg == MSG1_DFPRNMENU05    ; cMsg := "Printer nije definiran!"
   CASE nMsg == MSG1_DFPRNMENU06    ; cMsg := "жtampam list "
   CASE nMsg == MSG1_DFPRNMENU07    ; cMsg := "Saџekajte..."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFMAILCO01     ; cMsg := "^Za:"
   CASE nMsg == MSG1_DFMAILCO02     ; cMsg := "жalji na"
   CASE nMsg == MSG1_DFMAILCO03     ; cMsg := "^CC:"
   CASE nMsg == MSG1_DFMAILCO04     ; cMsg := "жalji CC"
   CASE nMsg == MSG1_DFMAILCO05     ; cMsg := "^BCC:"
   CASE nMsg == MSG1_DFMAILCO06     ; cMsg := "жalji BCC"
   CASE nMsg == MSG1_DFMAILCO07     ; cMsg := "S^ubjekt:"
   CASE nMsg == MSG1_DFMAILCO08     ; cMsg := "Subjekt poruke"
   CASE nMsg == MSG1_DFMAILCO09     ; cMsg := "^Tekst"
   CASE nMsg == MSG1_DFMAILCO10     ; cMsg := "Tekst poruke"
   CASE nMsg == MSG1_DFMAILCO11     ; cMsg := "^жalji"
   CASE nMsg == MSG1_DFMAILCO12     ; cMsg := "^Ukljuџi datoteke"
   CASE nMsg == MSG1_DFMAILCO13     ; cMsg := "Ubaci datoteku u poruku"
   CASE nMsg == MSG1_DFMAILCO14     ; cMsg := "Obriзi ubaџenu datoteku"
   CASE nMsg == MSG1_DFMAILCO15     ; cMsg := "Poruka"
   CASE nMsg == MSG1_DFMAILCO16     ; cMsg := "Ukljuџene datoteke"
   CASE nMsg == MSG1_DFMAILCO17     ; cMsg := "Subjekat nije odreРen//жalji poruku?"
   CASE nMsg == MSG1_DFMAILCO18     ; cMsg := "Upiзite ispravnu email adresu."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFGETW01       ; cMsg := "Zahtjev"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PI01         ; cMsg := "Stani ?"
   CASE nMsg == MSG1_S2PI02         ; cMsg := "Prekid"
   CASE nMsg == MSG1_S2PI03         ; cMsg := "жaџekaj"
   CASE nMsg == MSG1_S2PI04         ; cMsg := "Molim saџekaj..."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2CALENDAR01   ; cMsg := "Kalendar"
   CASE nMsg == MSG1_S2CALENDAR02   ; cMsg := "Danas"
   CASE nMsg == MSG1_S2CALENDAR03   ; cMsg := "Kraj"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PRNMNU01     ; cMsg := "Meni зtampe"
   CASE nMsg == MSG1_S2PRNMNU02     ; cMsg := "&Filter"
   CASE nMsg == MSG1_S2PRNMNU03     ; cMsg := "Po&gled"
   CASE nMsg == MSG1_S2PRNMNU04     ; cMsg := "&Print"
   CASE nMsg == MSG1_S2PRNMNU05     ; cMsg := "&Odustani"
   CASE nMsg == MSG1_S2PRNMNU06     ; cMsg := "Opcije зtampe"
   CASE nMsg == MSG1_S2PRNMNU07     ; cMsg := "&UreРaji"
   CASE nMsg == MSG1_S2PRNMNU08     ; cMsg := "Font"
   CASE nMsg == MSG1_S2PRNMNU09     ; cMsg := "Normalno"
   CASE nMsg == MSG1_S2PRNMNU10     ; cMsg := "Kompresovano"
   CASE nMsg == MSG1_S2PRNMNU11     ; cMsg := "&Stranice"
   CASE nMsg == MSG1_S2PRNMNU12     ; cMsg := "&Margine"
   CASE nMsg == MSG1_S2PRNMNU13     ; cMsg := "Koristi ureРaj broj. "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISWP01     ; cMsg := "Windows Printer"
   CASE nMsg == MSG1_S2PDISWP02     ; cMsg := "жtampaj &na"
   CASE nMsg == MSG1_S2PDISWP03     ; cMsg := "&Postavke"
   CASE nMsg == MSG1_S2PDISWP04     ; cMsg := "&Ukljuџi font"
   CASE nMsg == MSG1_S2PDISWP05     ; cMsg := "&Format papira"
   CASE nMsg == MSG1_S2PDISWP06     ; cMsg := "P&oravnanje"
   CASE nMsg == MSG1_S2PDISWP07     ; cMsg := "&Kopije"
   CASE nMsg == MSG1_S2PDISWP08     ; cMsg := "Nema Windows printera instaliranog"
   CASE nMsg == MSG1_S2PDISWP09     ; cMsg := "(nepoznat)"
   CASE nMsg == MSG1_S2PDISWP10     ; cMsg := "Nemogu зtampati na//"
   CASE nMsg == MSG1_S2PDISWP11     ; cMsg := "//Greзka pristupa printer drajveru"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDIS01       ; cMsg := "Neformatirana зtampa"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISCL01     ; cMsg := "жtampaj u memoriju"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISPR01     ; cMsg := "Pogled na ekranu"
   CASE nMsg == MSG1_S2PDISPR02     ; cMsg := "Nemogu koristiti printer//"
   CASE nMsg == MSG1_S2PDISPR03     ; cMsg := "//Greзka pristupa printer drajveru"
   CASE nMsg == MSG1_S2PDISPR04     ; cMsg := "(nepoznat)"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISFI01     ; cMsg := "жtampanje u datoteku"
   CASE nMsg == MSG1_S2PDISFI02     ; cMsg := "&Naziv datoteke"
   CASE nMsg == MSG1_S2PDISFI03     ; cMsg := "&Pogledaj"
   CASE nMsg == MSG1_S2PDISFI04     ; cMsg := "Kreiraj datoeku"
   CASE nMsg == MSG1_S2PDISFI05     ; cMsg := "Odaberite &tip datoteke"
   CASE nMsg == MSG1_S2PDISFI06     ; cMsg := "Ot&vori datoteku"
   CASE nMsg == MSG1_S2PDISFI07     ; cMsg := "O&rjentacija papira"
   CASE nMsg == MSG1_S2PDISFI08     ; cMsg := "Greзka generisanja Pdf datoteke"
   CASE nMsg == MSG1_S2PDISFI09     ; cMsg := "Vertikalno"
   CASE nMsg == MSG1_S2PDISFI10     ; cMsg := "Horizontalno"
   CASE nMsg == MSG1_S2PDISFI11     ; cMsg := "Prekinuta Pdf зtampa"
   CASE nMsg == MSG1_S2PDISFI12     ; cMsg := "Naziv datoteke obavezan"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISMF01     ; cMsg := "жtampaj na FAX (MAPI)"
   CASE nMsg == MSG1_S2PDISMF02     ; cMsg := "&Telefonski brojevi"
   CASE nMsg == MSG1_S2PDISMF03     ; cMsg := "Broj Fax-a nije odreРen"
   CASE nMsg == MSG1_S2PDISMF04     ; cMsg := "Slanje FAX-a...//"
   CASE nMsg == MSG1_S2PDISMF05     ; cMsg := "жtampaj"
   CASE nMsg == MSG1_S2PDISMF06     ; cMsg := "Vidi ukljuџenu datoteku"
   CASE nMsg == MSG1_S2PDISMF07     ; cMsg := "Greзka slanja Fax-a:"
   CASE nMsg == MSG1_S2PDISMF08     ; cMsg := "Greзka generisanja Pdf-Fax datoteke"
   CASE nMsg == MSG1_S2PDISMF09     ; cMsg := "Faks poruka..."
   CASE nMsg == MSG1_S2PDISMF10     ; cMsg := "O&rjentacija papira:"
   CASE nMsg == MSG1_S2PDISMF11     ; cMsg := "F&ormat papira:"
   CASE nMsg == MSG1_S2PDISMF12     ; cMsg := "Saџuvati Sliku, Okvir and Izgled"
   CASE nMsg == MSG1_S2PDISMF13     ; cMsg := "Faks Ob&jekt:"
   CASE nMsg == MSG1_S2PDISMF14     ; cMsg := "Faks Sad&r§aj:"
   CASE nMsg == MSG1_S2PDISMF15     ; cMsg := "Prekinuto Mapi Fax Slanje"
   CASE nMsg == MSG1_S2PDISMF16     ; cMsg := "Following polje je prazno. жalji Faks?"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISMM01     ; cMsg := "жtampaj u E-Mail (MAPI)"
   CASE nMsg == MSG1_S2PDISMM02     ; cMsg := "&E-Mail adresa"
   CASE nMsg == MSG1_S2PDISMM03     ; cMsg := "E-Mail adresa nije odreРena"
   CASE nMsg == MSG1_S2PDISMM04     ; cMsg := "Slanje poruke...//"
   CASE nMsg == MSG1_S2PDISMM05     ; cMsg := "жtampaj"
   CASE nMsg == MSG1_S2PDISMM06     ; cMsg := "Vidi ukljuџenu datoteku"
   CASE nMsg == MSG1_S2PDISMM07     ; cMsg := "Greзka slanja E-Mail:"
   CASE nMsg == MSG1_S2PDISMM08     ; cMsg := "Prekinuto Mapi E-mail Slanje"
   CASE nMsg == MSG1_S2PDISMM09     ; cMsg := "&ZIP datoteka"
   CASE nMsg == MSG1_S2PDISMM10     ; cMsg := "Zip datoteka: %file%"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISSM01     ; cMsg := "жtampaj u E-Mail (SMTP)"
   CASE nMsg == MSG1_S2PDISSM02     ; cMsg := "&E-Mail adresa"
   CASE nMsg == MSG1_S2PDISSM03     ; cMsg := "E-Mail adresa nije odreРena"
   CASE nMsg == MSG1_S2PDISSM04     ; cMsg := "SMTP Server nije odreРen (XBaseSMTPServer)"
   CASE nMsg == MSG1_S2PDISSM05     ; cMsg := "E-Mail poзiljalac nije odreРen (XBaseSMTPFrom)"
   CASE nMsg == MSG1_S2PDISSM06     ; cMsg := "Slanje poruke...//"
   CASE nMsg == MSG1_S2PDISSM07     ; cMsg := "жtampaj"
   CASE nMsg == MSG1_S2PDISSM08     ; cMsg := "Vidi ukljuџenu datoteku"
   CASE nMsg == MSG1_S2PDISSM09     ; cMsg := "Greзka slanja E-Mail:"
   CASE nMsg == MSG1_S2PDISSM10     ; cMsg := "Ob&jekt:"
   CASE nMsg == MSG1_S2PDISSM11     ; cMsg := "Email &Sadr§aj:"
   CASE nMsg == MSG1_S2PDISSM12     ; cMsg := "Prekinuto Smtp E-mail Slanje"
   CASE nMsg == MSG1_S2PDISSM13     ; cMsg := "Following polje je prazno. жalji E-Mail?"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISDP01     ; cMsg := "DOS Printer"
   CASE nMsg == MSG1_S2PDISDP02     ; cMsg := "жtampaj &na"
   CASE nMsg == MSG1_S2PDISDP03     ; cMsg := "&Printer port"
   CASE nMsg == MSG1_S2PDISDP04     ; cMsg := "Kvalitet"
   CASE nMsg == MSG1_S2PDISDP05     ; cMsg := "&Normalno"
   CASE nMsg == MSG1_S2PDISDP06     ; cMsg := "&Masnije"
   CASE nMsg == MSG1_S2PDISDP07     ; cMsg := "Podesi"
   CASE nMsg == MSG1_S2PDISDP08     ; cMsg := "Uzmi Setup &1"
   CASE nMsg == MSG1_S2PDISDP09     ; cMsg := "Uzmi Setup &2"
   CASE nMsg == MSG1_S2PDISDP10     ; cMsg := "Uzmi Setup &3"
   CASE nMsg == MSG1_S2PDISDP11     ; cMsg := "Kopi&je"
   CASE nMsg == MSG1_S2PDISDP12     ; cMsg := "Nema DOS Printera instaliranog"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFWINPRN01     ; cMsg := "Postavi Font "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFWINPRD01     ; cMsg := "Normal"
   CASE nMsg == MSG1_DFWINPRD02     ; cMsg := "Postavi"
   CASE nMsg == MSG1_DFWINPRD03     ; cMsg := "Normal Font"
   CASE nMsg == MSG1_DFWINPRD04     ; cMsg := "Masniji Font"
   CASE nMsg == MSG1_DFWINPRD05     ; cMsg := "Kopresovani Font"
   CASE nMsg == MSG1_DFWINPRD06     ; cMsg := "Masniji kompresovani Font"
   CASE nMsg == MSG1_DFWINPRD07     ; cMsg := "&Nastavi"
   CASE nMsg == MSG1_DFWINPRD08     ; cMsg := "&Odustani"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DBMSGERR01     ; cMsg := "Greзka"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFALERT01      ; cMsg := "Upozorenje"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFYESNO01      ; cMsg := "Zahtjev"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISCP01     ; cMsg := "Printer - CRW"
   CASE nMsg == MSG1_S2PDISCP02     ; cMsg := "Datoteka nije naРena: "
   CASE nMsg == MSG1_S2PDISCP03     ; cMsg := "Datoteka kreirana: "
   CASE nMsg == MSG1_S2PDISCP04     ; cMsg := "Greзka uџitavanja Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCP05     ; cMsg := "Greзka u зtampi: "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISCV01     ; cMsg := "Pogled - CRW"
   CASE nMsg == MSG1_S2PDISCV02     ; cMsg := "Datoteka nije naРena: "
   CASE nMsg == MSG1_S2PDISCV03     ; cMsg := "Datoteka kreirana: "
   CASE nMsg == MSG1_S2PDISCV04     ; cMsg := "Greзka uџitavanja Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCV05     ; cMsg := "Greзka u pogledu: "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_S2PDISCF01     ; cMsg := "жtampaj u datoteku"
   CASE nMsg == MSG1_S2PDISCF02     ; cMsg := "Datoteka nije naРena: "
   CASE nMsg == MSG1_S2PDISCF03     ; cMsg := "Datoteka kreirana: "
   CASE nMsg == MSG1_S2PDISCF04     ; cMsg := "Greзka uџitavanja Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCF05     ; cMsg := "Greзka u izvozu: "
   CASE nMsg == MSG1_S2PDISCF06     ; cMsg := "Izvoz nije dostupan"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   //CASE nMsg == MSG1_DFPDF01        ; cMsg := "Greзka Pdf Inicijalizacije"
   CASE nMsg == MSG1_DFPDF02        ; cMsg := "Kreiram list PDF datoteke "
   //CASE nMsg == MSG1_DFPDF03        ; cMsg := "Greзka uџitavanja Klase PdfFont"
   //CASE nMsg == MSG1_DFPDF04        ; cMsg := "Pogreзan slo§eni format naziva"
   CASE nMsg == MSG1_DFPDF05        ; cMsg := "ACROBAT READER nije ispravno instaliran"
   CASE nMsg == MSG1_DFPDF06        ; cMsg := "RazraРivanje Slike u toku..."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFTIFF01       ; cMsg := "Greзka uџitavanja Dll dbImage.dll!"
   CASE nMsg == MSG1_DFTIFF02       ; cMsg := "Greзka u konverziji Bmp -> Tiff"
   CASE nMsg == MSG1_DFTIFF03       ; cMsg := "TIFF Rezolucijski Tag nije naРen!"
   CASE nMsg == MSG1_DFTIFF04       ; cMsg := "Greзka postavljanja rezolucije"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFJPG01        ; cMsg := "JPEG Rezolucijski Tag nije naРen!"
   CASE nMsg == MSG1_DFJPG02        ; cMsg := "Greзka u konverziji Bmp -> JPEG"
   CASE nMsg == MSG1_DFJPG03        ; cMsg := "Greзka postavljanja rezolucije"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_DFBMP01        ; cMsg := "BMP Rezolucijski Tag nije naРen!"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG1_CRW01          ; cMsg := "Greзka: Report Body Alias <%band%> ne sadr§i//"+;
                                              "sve primarne kljuџeve Baze podataka. Kljuџ n. %nrel%//"+;
                                              "Slijede†a polja su neophodna: %fields%//"+;
                                              "Biti †e nemogu†e kreirati relaciju u Crystal Report-u!"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
ENDCASE
RETURN cMsg
