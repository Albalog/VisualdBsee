/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                     Windows Printers Parameters                      |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFWINREP_CH
   #define _DFWINREP_CH

   #define DFWINREP_CODE           (CHR(27))

   #define DFWINREP_CODELENGTH     1 // Lunghezza del codice (CHR(27))
   #define DFWINREP_STRINGLENGTH   (DFWINREP_CODELENGTH + 6)
                                     // La stringa DEVE essere di  caratteri
                                     //            123456

   #define DFWINREP_SETUP          (DFWINREP_CODE+"SETUP " ) // PRINTER_SETUP
   #define DFWINREP_RESET          (DFWINREP_CODE+"RESET " ) // PRINTER_RESET
   #define DFWINREP_BOLDON         (DFWINREP_CODE+"BOLDON" ) // PRINTER_BOLDON
   #define DFWINREP_BOLDOFF        (DFWINREP_CODE+"BOLDOF" ) // PRINTER_BOLDOFF
   #define DFWINREP_ENLARGEDON     (DFWINREP_CODE+"ENLON " ) // PRINTER_ENLARGEDON
   #define DFWINREP_ENLARGEDOFF    (DFWINREP_CODE+"ENLOFF" ) // PRINTER_ENLARGEDOFF
   #define DFWINREP_UNDERLINEON    (DFWINREP_CODE+"UNDON " ) // PRINTER_UNDERLINEON
   #define DFWINREP_UNDERLINEOFF   (DFWINREP_CODE+"UNDOFF" ) // PRINTER_UNDERLINEOFF
   #define DFWINREP_SUPERSCRIPTON  (DFWINREP_CODE+"SUPON " ) // PRINTER_SUPERSCRIPTON
   #define DFWINREP_SUPERSCRIPTOFF (DFWINREP_CODE+"SUPOFF" ) // PRINTER_SUPERSCRIPTOFF
   #define DFWINREP_SUBSCRIPTON    (DFWINREP_CODE+"SUBON " ) // PRINTER_SUBSCRIPTON
   #define DFWINREP_SUBSCRIPTOFF   (DFWINREP_CODE+"SUBOFF" ) // PRINTER_SUBSCRIPTOFF
   #define DFWINREP_CONDENSEDON    (DFWINREP_CODE+"CONDON" ) // PRINTER_CONDENSEDON
   #define DFWINREP_CONDENSEDOFF   (DFWINREP_CODE+"CONDFF" ) // PRINTER_CONDENSEDOFF
   #define DFWINREP_ITALICON       (DFWINREP_CODE+"ITALON" ) // PRINTER_ITALICON
   #define DFWINREP_ITALICOFF      (DFWINREP_CODE+"ITALOF" ) // PRINTER_ITALICOFF
   #define DFWINREP_NLQON          (DFWINREP_CODE+"NLQON " ) // PRINTER_NLQON
   #define DFWINREP_NLQOFF         (DFWINREP_CODE+"NLQOFF" ) // PRINTER_NLQOFF
   #define DFWINREP_USER01ON       (DFWINREP_CODE+"US01ON" ) // PRINTER_USER01ON
   #define DFWINREP_USER01OFF      (DFWINREP_CODE+"US01OF" ) // PRINTER_USER01OFF
   #define DFWINREP_USER02ON       (DFWINREP_CODE+"US02ON" ) // PRINTER_USER02ON
   #define DFWINREP_USER02OFF      (DFWINREP_CODE+"US02OF" ) // PRINTER_USER02OFF
   #define DFWINREP_USER03ON       (DFWINREP_CODE+"US03ON" ) // PRINTER_USER03ON
   #define DFWINREP_USER03OFF      (DFWINREP_CODE+"US03OF" ) // PRINTER_USER03OFF
   #define DFWINREP_PAGELENGHT     (DFWINREP_CODE+"PAGLEN" ) // PRINTER_PAGELENGHT
   #define DFWINREP_IMAGE          (DFWINREP_CODE+"IMAGE:" ) // IMAGE
   #define DFWINREP_BOX            (DFWINREP_CODE+"BOX  :" ) // BOX
   #define DFWINREP_FONTON         (DFWINREP_CODE+"FNTON:" ) // Font utente
   #define DFWINREP_FONTOFF        (DFWINREP_CODE+"FNTOFF" ) //
   #define DFWINREP_CODEBLOCK      (DFWINREP_CODE+"CODEB:" ) // CodeBlock


   // Struttura array per dati extra di stampa
   // vedi dfWinPrE.xpp
   // ----------------------------------------
   #define DFWINREP_EX_MARGTOP      1
   #define DFWINREP_EX_MARGLEFT     2
   #define DFWINREP_EX_INTERLINE    3
   #define DFWINREP_EX_PAGEHEIGHT   4
   #define DFWINREP_EX_FONTS        5

   #define DFWINREP_EX_LEN          5

   // Struttura array per font dialog
   // vedi dfWinPrD.xpp
   // ----------------------------------------
   #define DFWINREP_FD_NORMAL       1
   #define DFWINREP_FD_BOLD         2
   #define DFWINREP_FD_CONDENSED    3
   #define DFWINREP_FD_BOLDCOND     4

   #define DFWINREP_FD_LEN          4

#endif
