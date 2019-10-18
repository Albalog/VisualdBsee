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
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_LANGUAGE       ; cMsg := "CROATIA"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_INITAPPS01     ; cMsg := "Found dbupdate.log !!"
   CASE nMsg == MSG1_INITAPPS02     ; cMsg := "Application under update"
   CASE nMsg == MSG1_INITAPPS03     ; cMsg := "Please try later"
   CASE nMsg == MSG1_INITAPPS04     ; cMsg := "Bootstrap seconds : "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DBINK01        ; cMsg := "You have "
   CASE nMsg == MSG1_DBINK02        ; cMsg := " secont to quit"
   CASE nMsg == MSG1_DBINK03        ; cMsg := "Seconds : "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_TBBRWNEW36     ; cMsg := "Print screen"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFDBFNTX01     ; cMsg := "Database engine DBFDBE not loaded"
   CASE nMsg == MSG1_DFDBFNTX02     ; cMsg := "Database engine NTXDBE not loaded"
   CASE nMsg == MSG1_DFDBFNTX03     ; cMsg := "DBFNTX database engine could not be created"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFDBFCDX01     ; cMsg := "Database engine FOXDBE not loaded"
   CASE nMsg == MSG1_DFDBFCDX02     ; cMsg := "Database engine CDXDBE not loaded"
   CASE nMsg == MSG1_DFDBFCDX03     ; cMsg := "DBFCDX database engine could not be created"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2GETMEN01     ; cMsg := "&Cancel"
   CASE nMsg == MSG1_S2GETMEN02     ; cMsg := "&Cut"
   CASE nMsg == MSG1_S2GETMEN03     ; cMsg := "&Copy"
   CASE nMsg == MSG1_S2GETMEN04     ; cMsg := "&Past"
   CASE nMsg == MSG1_S2GETMEN05     ; cMsg := "&Delete"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFPRNMENU01    ; cMsg := "Fon^t"
   CASE nMsg == MSG1_DFPRNMENU02    ; cMsg := "Printer not valid"
   CASE nMsg == MSG1_DFPRNMENU03    ; cMsg := "Page"
   CASE nMsg == MSG1_DFPRNMENU04    ; cMsg := "Page Preview "
   CASE nMsg == MSG1_DFPRNMENU05    ; cMsg := "Printer not Defined!"
   CASE nMsg == MSG1_DFPRNMENU06    ; cMsg := "Print Page "
   CASE nMsg == MSG1_DFPRNMENU07    ; cMsg := "Wait..."
   CASE nMsg == MSG1_DFPRNMENU08    ; cMsg := "It is necessary to install a printer in the system"
   CASE nMsg == MSG1_DFPRNMENU09    ; cMsg := "No property to set"

   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFMAILCO01     ; cMsg := "^To:"
   CASE nMsg == MSG1_DFMAILCO02     ; cMsg := "Send to"
   CASE nMsg == MSG1_DFMAILCO03     ; cMsg := "^CC:"
   CASE nMsg == MSG1_DFMAILCO04     ; cMsg := "Send CC"
   CASE nMsg == MSG1_DFMAILCO05     ; cMsg := "^BCC:"
   CASE nMsg == MSG1_DFMAILCO06     ; cMsg := "Send BCC"
   CASE nMsg == MSG1_DFMAILCO07     ; cMsg := "S^ubject:"
   CASE nMsg == MSG1_DFMAILCO08     ; cMsg := "Subject of message"
   CASE nMsg == MSG1_DFMAILCO09     ; cMsg := "Te^xt"
   CASE nMsg == MSG1_DFMAILCO10     ; cMsg := "Text of message"
   CASE nMsg == MSG1_DFMAILCO11     ; cMsg := "^Send"
   CASE nMsg == MSG1_DFMAILCO12     ; cMsg := "^Attach files"
   CASE nMsg == MSG1_DFMAILCO13     ; cMsg := "Insert file in attach"
   CASE nMsg == MSG1_DFMAILCO14     ; cMsg := "Delete attach file"
   CASE nMsg == MSG1_DFMAILCO15     ; cMsg := "Message"
   CASE nMsg == MSG1_DFMAILCO16     ; cMsg := "Attach Files"
   CASE nMsg == MSG1_DFMAILCO17     ; cMsg := "The subject has not been specified//Send the message?"
   CASE nMsg == MSG1_DFMAILCO18     ; cMsg := "Please specify valid email address."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFGETW01       ; cMsg := "Request"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PI01         ; cMsg := "Stop ?"
   CASE nMsg == MSG1_S2PI02         ; cMsg := "Cancel"
   CASE nMsg == MSG1_S2PI03         ; cMsg := "Wait"
   CASE nMsg == MSG1_S2PI04         ; cMsg := "Please wait..."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2CALENDAR01   ; cMsg := "Calendar"
   CASE nMsg == MSG1_S2CALENDAR02   ; cMsg := "Today"
   CASE nMsg == MSG1_S2CALENDAR03   ; cMsg := "Exit"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PRNMNU01     ; cMsg := "Print Menu"
   CASE nMsg == MSG1_S2PRNMNU02     ; cMsg := "&Filter"
   CASE nMsg == MSG1_S2PRNMNU03     ; cMsg := "Previe&w"
   CASE nMsg == MSG1_S2PRNMNU04     ; cMsg := "&Print"
   CASE nMsg == MSG1_S2PRNMNU05     ; cMsg := "&Cancel"
   CASE nMsg == MSG1_S2PRNMNU06     ; cMsg := "Print options"
   CASE nMsg == MSG1_S2PRNMNU07     ; cMsg := "&Devices"
   CASE nMsg == MSG1_S2PRNMNU08     ; cMsg := "Font"
   CASE nMsg == MSG1_S2PRNMNU09     ; cMsg := "Normal"
   CASE nMsg == MSG1_S2PRNMNU10     ; cMsg := "Compressed"
   CASE nMsg == MSG1_S2PRNMNU11     ; cMsg := "Pa&ges"
   CASE nMsg == MSG1_S2PRNMNU12     ; cMsg := "&Margins"
   CASE nMsg == MSG1_S2PRNMNU13     ; cMsg := "Print device n. "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISWP01     ; cMsg := "Windows Printer"
   CASE nMsg == MSG1_S2PDISWP02     ; cMsg := "Print &on"
   CASE nMsg == MSG1_S2PDISWP03     ; cMsg := "&Properties"
   CASE nMsg == MSG1_S2PDISWP04     ; cMsg := "&Set font"
   CASE nMsg == MSG1_S2PDISWP05     ; cMsg := "Paper F&ormat"
   CASE nMsg == MSG1_S2PDISWP06     ; cMsg := "A&limentation"
   CASE nMsg == MSG1_S2PDISWP07     ; cMsg := "&Copies"
   CASE nMsg == MSG1_S2PDISWP08     ; cMsg := "No Windows printer installed"
   CASE nMsg == MSG1_S2PDISWP09     ; cMsg := "(unknown)"
   CASE nMsg == MSG1_S2PDISWP10     ; cMsg := "Unable to print on//"
   CASE nMsg == MSG1_S2PDISWP11     ; cMsg := "//Error accessing printer driver"
   CASE nMsg == MSG1_S2PDISWP12     ; cMsg := "%printer% on %name%"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDIS01       ; cMsg := "Generic print device"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISCL01     ; cMsg := "Print on Clipboard"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISPR01     ; cMsg := "Print preview"
   CASE nMsg == MSG1_S2PDISPR02     ; cMsg := "Unable to use the printer//"
   CASE nMsg == MSG1_S2PDISPR03     ; cMsg := "//Error accessing printer driver"
   CASE nMsg == MSG1_S2PDISPR04     ; cMsg := "(unknown)"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISFI01     ; cMsg := "Print on File"
   CASE nMsg == MSG1_S2PDISFI02     ; cMsg := "F&ile name"
   CASE nMsg == MSG1_S2PDISFI03     ; cMsg := "&Browse"
   CASE nMsg == MSG1_S2PDISFI04     ; cMsg := "Create file"
   CASE nMsg == MSG1_S2PDISFI05     ; cMsg := "Select File &Type"
   CASE nMsg == MSG1_S2PDISFI06     ; cMsg := "Ope&n File"
   CASE nMsg == MSG1_S2PDISFI07     ; cMsg := "Print O&rientation"
   CASE nMsg == MSG1_S2PDISFI08     ; cMsg := "Error File Pdf Generation"
   CASE nMsg == MSG1_S2PDISFI09     ; cMsg := "Vertical"
   CASE nMsg == MSG1_S2PDISFI10     ; cMsg := "Horizontal"
   CASE nMsg == MSG1_S2PDISFI11     ; cMsg := "Terminated Pdf Print"
   CASE nMsg == MSG1_S2PDISFI12     ; cMsg := "File Name Obligatory"
   CASE nMsg == MSG1_S2PDISFI13     ; cMsg := "Collate"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISMF01     ; cMsg := "Print on FAX (MAPI)"
   CASE nMsg == MSG1_S2PDISMF02     ; cMsg := "Telep&hone number"
   CASE nMsg == MSG1_S2PDISMF03     ; cMsg := "Fax number not specified"
   CASE nMsg == MSG1_S2PDISMF04     ; cMsg := "Sending FAX...//"
   CASE nMsg == MSG1_S2PDISMF05     ; cMsg := "Print"
   CASE nMsg == MSG1_S2PDISMF06     ; cMsg := "See attached file"
   CASE nMsg == MSG1_S2PDISMF07     ; cMsg := "Error sending Fax:"
   CASE nMsg == MSG1_S2PDISMF08     ; cMsg := "Error File Pdf-Fax Generation"
   CASE nMsg == MSG1_S2PDISMF09     ; cMsg := "Fax message..."
   CASE nMsg == MSG1_S2PDISMF10     ; cMsg := "Page O&rientation:"
   CASE nMsg == MSG1_S2PDISMF11     ; cMsg := "Page F&ormat:"
   CASE nMsg == MSG1_S2PDISMF12     ; cMsg := "Mainta&in Image, Border and Boldface"
   CASE nMsg == MSG1_S2PDISMF13     ; cMsg := "Fax Ob&ject:"
   CASE nMsg == MSG1_S2PDISMF14     ; cMsg := "Fax Bod&y:"
   CASE nMsg == MSG1_S2PDISMF15     ; cMsg := "Terminated Mapi Fax Sending"
   CASE nMsg == MSG1_S2PDISMF16     ; cMsg := "The following field is empty. Send Fax?"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISMM01     ; cMsg := "Print on E-Mail (MAPI)"
   CASE nMsg == MSG1_S2PDISMM02     ; cMsg := "&E-Mail address:"
   CASE nMsg == MSG1_S2PDISMM03     ; cMsg := "E-Mail address not specified"
   CASE nMsg == MSG1_S2PDISMM04     ; cMsg := "Sending message...//"
   CASE nMsg == MSG1_S2PDISMM05     ; cMsg := "Print"
   CASE nMsg == MSG1_S2PDISMM06     ; cMsg := "See attached file"
   CASE nMsg == MSG1_S2PDISMM07     ; cMsg := "Errore sending E-Mail:"
   CASE nMsg == MSG1_S2PDISMM08     ; cMsg := "Terminated Mapi E-mail Sending"
   CASE nMsg == MSG1_S2PDISMM09     ; cMsg := "&ZIP file"
   CASE nMsg == MSG1_S2PDISMM10     ; cMsg := "Zip file: %file%"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISSM01     ; cMsg := "Print on E-Mail (SMTP)"
   CASE nMsg == MSG1_S2PDISSM02     ; cMsg := "&E-Mail address:"
   CASE nMsg == MSG1_S2PDISSM03     ; cMsg := "E-Mail address not specified"
   CASE nMsg == MSG1_S2PDISSM04     ; cMsg := "SMTP Server not specified (XBaseSMTPServer)"
   CASE nMsg == MSG1_S2PDISSM05     ; cMsg := "E-Mail sender not specified (XBaseSMTPFrom)"
   CASE nMsg == MSG1_S2PDISSM06     ; cMsg := "Sending message...//"
   CASE nMsg == MSG1_S2PDISSM07     ; cMsg := "Print"
   CASE nMsg == MSG1_S2PDISSM08     ; cMsg := "See attached file"
   CASE nMsg == MSG1_S2PDISSM09     ; cMsg := "Errore sending E-Mail:"
   CASE nMsg == MSG1_S2PDISSM10     ; cMsg := "Ob&ject:"
   CASE nMsg == MSG1_S2PDISSM11     ; cMsg := "Email &Body:"
   CASE nMsg == MSG1_S2PDISSM12     ; cMsg := "Terminated Smtp E-mail Sending"
   CASE nMsg == MSG1_S2PDISSM13     ; cMsg := "The following field is empty. Send E-Mail?"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISDP01     ; cMsg := "DOS Printer"
   CASE nMsg == MSG1_S2PDISDP02     ; cMsg := "Print &on"
   CASE nMsg == MSG1_S2PDISDP03     ; cMsg := "&Printer port"
   CASE nMsg == MSG1_S2PDISDP04     ; cMsg := "Quality"
   CASE nMsg == MSG1_S2PDISDP05     ; cMsg := "N&ormal"
   CASE nMsg == MSG1_S2PDISDP06     ; cMsg := "&High"
   CASE nMsg == MSG1_S2PDISDP07     ; cMsg := "Setup"
   CASE nMsg == MSG1_S2PDISDP08     ; cMsg := "Use Setup &1"
   CASE nMsg == MSG1_S2PDISDP09     ; cMsg := "Use Setup &2"
   CASE nMsg == MSG1_S2PDISDP10     ; cMsg := "Use Setup &3"
   CASE nMsg == MSG1_S2PDISDP11     ; cMsg := "&Copies"
   CASE nMsg == MSG1_S2PDISDP12     ; cMsg := "No DOS Printer installed"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFWINPRN01     ; cMsg := "Set Font "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFWINPRD01     ; cMsg := "Normal"
   CASE nMsg == MSG1_DFWINPRD02     ; cMsg := "Set"
   CASE nMsg == MSG1_DFWINPRD03     ; cMsg := "Normal Font"
   CASE nMsg == MSG1_DFWINPRD04     ; cMsg := "Bold Font"
   CASE nMsg == MSG1_DFWINPRD05     ; cMsg := "Compressed Font"
   CASE nMsg == MSG1_DFWINPRD06     ; cMsg := "Bold Compressed Font"
   CASE nMsg == MSG1_DFWINPRD07     ; cMsg := "&Ok"
   CASE nMsg == MSG1_DFWINPRD08     ; cMsg := "&Cancel"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DBMSGERR01     ; cMsg := "Error"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFALERT01      ; cMsg := "Warning"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFYESNO01      ; cMsg := "Request"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISCP01     ; cMsg := "Windows Printer"
   CASE nMsg == MSG1_S2PDISCP02     ; cMsg := "File not found: "
   CASE nMsg == MSG1_S2PDISCP03     ; cMsg := "File created: "
   CASE nMsg == MSG1_S2PDISCP04     ; cMsg := "Error loading Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCP05     ; cMsg := "Error in print: "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISCV01     ; cMsg := "Preview"
   CASE nMsg == MSG1_S2PDISCV02     ; cMsg := "File not found: "
   CASE nMsg == MSG1_S2PDISCV03     ; cMsg := "File created: "
   CASE nMsg == MSG1_S2PDISCV04     ; cMsg := "Error loading Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCV05     ; cMsg := "Error in preview: "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISCF01     ; cMsg := "Print on File"
   CASE nMsg == MSG1_S2PDISCF02     ; cMsg := "File not found: "
   CASE nMsg == MSG1_S2PDISCF03     ; cMsg := "File created: "
   CASE nMsg == MSG1_S2PDISCF04     ; cMsg := "Error loading Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCF05     ; cMsg := "Error exporting: "
   CASE nMsg == MSG1_S2PDISCF06     ; cMsg := "Export not available"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //CASE nMsg == MSG1_DFPDF01        ; cMsg := "Pdf Initialization Error"
   CASE nMsg == MSG1_DFPDF02        ; cMsg := "Creating PDF File page "
   //CASE nMsg == MSG1_DFPDF03        ; cMsg := "Error loading Class PdfFont"
   //CASE nMsg == MSG1_DFPDF04        ; cMsg := "Wrong Compound Name Format"
   CASE nMsg == MSG1_DFPDF05        ; cMsg := "ACROBAT READER is not correct Installed"
   CASE nMsg == MSG1_DFPDF06        ; cMsg := "Image elaboration in progress..."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFTIFF01       ; cMsg := "Error loading Dll dbImage.dll!"
   CASE nMsg == MSG1_DFTIFF02       ; cMsg := "Conversion Error Bmp -> Tiff"
   CASE nMsg == MSG1_DFTIFF03       ; cMsg := "TIFF Resolution Tag Not Found!"
   CASE nMsg == MSG1_DFTIFF04       ; cMsg := "Error Setting Resolution"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFJPG01        ; cMsg := "JPEG Resolution Tag Not Found!"
   CASE nMsg == MSG1_DFJPG02        ; cMsg := "Conversion Error Bmp -> JPEG"
   CASE nMsg == MSG1_DFJPG03        ; cMsg := "Error Setting Resolution"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFBMP01        ; cMsg := "BMP Resolution Tag Not Found!"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_CRW01          ; cMsg := "Error: Report Body Alias <%band%> does not contain//"+;
                                              "all Database primary Key field. Key n. %nrel%//"+;
                                              "The following fields are needed: %fields%//"+;
                                              "It will be impossible to create the relation in Crystal Report!"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFREPTYP01; cMsg := "Report Manager print engine (reportman.ocx) not found//Unable to print"
   CASE nMsg == MSG1_DFREPTYP02; cMsg := "Report File not found//%file%"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFWAIT01       ; cMsg := "Please wait..."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_TOOLCLASS01    ; cMsg := "Configure Toolbar..."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_TOOLTIPMINCHARS; cMsg := "Remaining characters: %nchars%"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DDKEYWIN0000  ; cMsg := "Search"
   CASE nMsg == MSG1_DDKEYWIN0010  ; cMsg := "Search"
   CASE nMsg == MSG1_DDKEYWIN0020  ; cMsg := "Generic filter"
   CASE nMsg == MSG1_DDKEYWIN0030  ; cMsg := "Print"
   CASE nMsg == MSG1_DDKEYWIN0040  ; cMsg := "Print listed records"
   CASE nMsg == MSG1_DDKEYWIN0050  ; cMsg := "Confirm (F10)"
   CASE nMsg == MSG1_DDKEYWIN0060  ; cMsg := "Cancel (Esc)"
   CASE nMsg == MSG1_DDKEYWIN0070  ; cMsg := "Help (F1)"
   CASE nMsg == MSG1_DDKEYWIN0080  ; cMsg := "Help (Shift-F1)"
   CASE nMsg == MSG1_DDKEYWIN0090  ; cMsg := "Selection criteria"
   CASE nMsg == MSG1_DDKEYWIN0100  ; cMsg := "Records"
   CASE nMsg == MSG1_DDKEYWIN0110  ; cMsg := "Select record"
   CASE nMsg == MSG1_DDKEYWIN0120  ; cMsg := "Previous Page"
   CASE nMsg == MSG1_DDKEYWIN0130  ; cMsg := "Next Page"
   CASE nMsg == MSG1_DDKEYWIN0140  ; cMsg := "S~earch:"
   CASE nMsg == MSG1_DDKEYWIN0150  ; cMsg := "~Order:"
   CASE nMsg == MSG1_DDKEYWIN0160  ; cMsg := "Remove ^Filter"
   CASE nMsg == MSG1_DDKEYWIN0170  ; cMsg := "Set ^Filter"
   CASE nMsg == MSG1_DDKEYWIN0180  ; cMsg := "No record corresponds to the selection"
   CASE nMsg == MSG1_DDKEYWIN0190  ; cMsg := "(generic filter set, press 'Remove Filter' to enable the search)"
   CASE nMsg == MSG1_DDKEYWIN0200  ; cMsg := "Edit expression is not valid//"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFUSEREVENTWAIT1; cMsg := "Warning//In %count% seconds the current procedure will stop//Press any key to continue" 
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFMAKEIND000  ; cMsg := "Error creating index %file%//Please check access rights to the folder."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DDFILESTA000  ; cMsg := "Error creating temporary file//Please check access rights to the folder %file%."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFGRAPH30000  ; cMsg := "Print"
   CASE nMsg == MSG1_DFGRAPH30010  ; cMsg := "Print chart"
   CASE nMsg == MSG1_DFGRAPH30020  ; cMsg := "It is possible to print the chart only on Windows printers"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ENDCASE
RETURN cMsg
