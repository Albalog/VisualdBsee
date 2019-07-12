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
   CASE nMsg == MSG1_LANGUAGE       ; cMsg := "ESPANOL"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_INITAPPS01     ; cMsg := "Buscar dbupdate.log !!"
   CASE nMsg == MSG1_INITAPPS02     ; cMsg := "Application en posta al dia"
   CASE nMsg == MSG1_INITAPPS03     ; cMsg := "Por favor intentar mas tarde"
   CASE nMsg == MSG1_INITAPPS04     ; cMsg := "Bootstrap seconds : "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DBINK01        ; cMsg := "usted habe "
   CASE nMsg == MSG1_DBINK02        ; cMsg := " second a terminar"
   CASE nMsg == MSG1_DBINK03        ; cMsg := "Secundos : "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_TBBRWNEW36     ; cMsg := "Imprimir pantalla"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFDBFNTX01     ; cMsg := "Database engine DBFDBE no cargado"
   CASE nMsg == MSG1_DFDBFNTX02     ; cMsg := "Database engine NTXDBE no cargado"
   CASE nMsg == MSG1_DFDBFNTX03     ; cMsg := "DBFNTX database engine no puede esser creado"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFDBFCDX01     ; cMsg := "Database engine FOXDBE no cargado"
   CASE nMsg == MSG1_DFDBFCDX02     ; cMsg := "Database engine CDXDBE no cargado"
   CASE nMsg == MSG1_DFDBFCDX03     ; cMsg := "DBFCDX database engine no puede esser creado"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2GETMEN01     ; cMsg := "&Anular"
   CASE nMsg == MSG1_S2GETMEN02     ; cMsg := "&Cortar"
   CASE nMsg == MSG1_S2GETMEN03     ; cMsg := "&Copiar"
   CASE nMsg == MSG1_S2GETMEN04     ; cMsg := "&A¤adir"
   CASE nMsg == MSG1_S2GETMEN05     ; cMsg := "&Eliminar"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFPRNMENU01    ; cMsg := "Fon^tes"
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
   CASE nMsg == MSG1_DFMAILCO01     ; cMsg := "^A:"
   CASE nMsg == MSG1_DFMAILCO02     ; cMsg := "Enviar a"
   CASE nMsg == MSG1_DFMAILCO03     ; cMsg := "CC:"
   CASE nMsg == MSG1_DFMAILCO04     ; cMsg := "Enviar CC"
   CASE nMsg == MSG1_DFMAILCO05     ; cMsg := "^BCC:"
   CASE nMsg == MSG1_DFMAILCO06     ; cMsg := "Enviar BCC"
   CASE nMsg == MSG1_DFMAILCO07     ; cMsg := "O^bjecto:"
   CASE nMsg == MSG1_DFMAILCO08     ; cMsg := "Objecto de mensaje"
   CASE nMsg == MSG1_DFMAILCO09     ; cMsg := "^Texto"
   CASE nMsg == MSG1_DFMAILCO10     ; cMsg := "Texto de mensaje"
   CASE nMsg == MSG1_DFMAILCO11     ; cMsg := "^Enviar"
   CASE nMsg == MSG1_DFMAILCO12     ; cMsg := "^Insertar archivo"
   CASE nMsg == MSG1_DFMAILCO13     ; cMsg := "Insertar archivo en conexion"
   CASE nMsg == MSG1_DFMAILCO14     ; cMsg := "Cancelar archivo en conexion"
   CASE nMsg == MSG1_DFMAILCO15     ; cMsg := "Mensaje"
   CASE nMsg == MSG1_DFMAILCO16     ; cMsg := "Conectar archivos"
   CASE nMsg == MSG1_DFMAILCO17     ; cMsg := "no se ha especificado l'objecto//Enviar el mensaje?"
   CASE nMsg == MSG1_DFMAILCO18     ; cMsg := "por favor especificar una direcion email valida."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFGETW01       ; cMsg := "Pedir"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PI01         ; cMsg := "Stop ?"
   CASE nMsg == MSG1_S2PI02         ; cMsg := "Cancelar"
   CASE nMsg == MSG1_S2PI03         ; cMsg := "Atender"
   CASE nMsg == MSG1_S2PI04         ; cMsg := "Por favor atender..."
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2CALENDAR01   ; cMsg := "Dietario"
   CASE nMsg == MSG1_S2CALENDAR02   ; cMsg := "Hoy"
   CASE nMsg == MSG1_S2CALENDAR03   ; cMsg := "Salida"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PRNMNU01     ; cMsg := "Menu de impresion"
   CASE nMsg == MSG1_S2PRNMNU02     ; cMsg := "&Filtro"
   CASE nMsg == MSG1_S2PRNMNU03     ; cMsg := "Visualiza&r"
   CASE nMsg == MSG1_S2PRNMNU04     ; cMsg := "&Imprimir"
   CASE nMsg == MSG1_S2PRNMNU05     ; cMsg := "&Cancelar"
   CASE nMsg == MSG1_S2PRNMNU06     ; cMsg := "Opciones de Impresora"
   CASE nMsg == MSG1_S2PRNMNU07     ; cMsg := "Ma&quina"
   CASE nMsg == MSG1_S2PRNMNU08     ; cMsg := "Silueta"
   CASE nMsg == MSG1_S2PRNMNU09     ; cMsg := "Normal"
   CASE nMsg == MSG1_S2PRNMNU10     ; cMsg := "Comprimido"
   CASE nMsg == MSG1_S2PRNMNU11     ; cMsg := "Pa&ginas"
   CASE nMsg == MSG1_S2PRNMNU12     ; cMsg := "&Margines"
   CASE nMsg == MSG1_S2PRNMNU13     ; cMsg := "Impresora n. "
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISWP01     ; cMsg := "Impresoras Windows"
   CASE nMsg == MSG1_S2PDISWP02     ; cMsg := "Imprimir &on"
   CASE nMsg == MSG1_S2PDISWP03     ; cMsg := "&Propriedad"
   CASE nMsg == MSG1_S2PDISWP04     ; cMsg := "&Set silueta"
   CASE nMsg == MSG1_S2PDISWP05     ; cMsg := "Formato &Papel"
   CASE nMsg == MSG1_S2PDISWP06     ; cMsg := "Carga de pape&l"
   CASE nMsg == MSG1_S2PDISWP07     ; cMsg := "Copi&as"
   CASE nMsg == MSG1_S2PDISWP08     ; cMsg := "No Windows impresora instalada"
   CASE nMsg == MSG1_S2PDISWP09     ; cMsg := "(desconosido)"
   CASE nMsg == MSG1_S2PDISWP10     ; cMsg := "no tengo capacidad de imprimir on//"
   CASE nMsg == MSG1_S2PDISWP11     ; cMsg := "//Error en el piloto de la Impresora"
   CASE nMsg == MSG1_S2PDISWP12     ; cMsg := "%printer% on %name%"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDIS01       ; cMsg := "Impresora Generica"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISCL01     ; cMsg := "Imprimir sobre Clipboard"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISPR01     ; cMsg := "Visualizar"
   CASE nMsg == MSG1_S2PDISPR02     ; cMsg := "no puedo usar la Impresora//"
   CASE nMsg == MSG1_S2PDISPR03     ; cMsg := "//Error en el piloto de la Impresora"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISFI01     ; cMsg := "Imprimir sobre Archivo"
   CASE nMsg == MSG1_S2PDISFI02     ; cMsg := "&archivo nombre"
   CASE nMsg == MSG1_S2PDISFI03     ; cMsg := "&Browse"
   CASE nMsg == MSG1_S2PDISFI04     ; cMsg := "Creacion archivo"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISMF01     ; cMsg := "Imprimir  FAX (MAPI)"
   CASE nMsg == MSG1_S2PDISMF02     ; cMsg := "&Telephone numero"
   CASE nMsg == MSG1_S2PDISMF03     ; cMsg := "Falta numero Fax"
   CASE nMsg == MSG1_S2PDISMF04     ; cMsg := "Enviando FAX...//"
   CASE nMsg == MSG1_S2PDISMF05     ; cMsg := "Imprimir"
   CASE nMsg == MSG1_S2PDISMF06     ; cMsg := "Mirar archivo insertado"
   CASE nMsg == MSG1_S2PDISMF07     ; cMsg := "Error enviando Fax:"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISMM01     ; cMsg := "Imprimir sobre E-Mail (MAPI)"
   CASE nMsg == MSG1_S2PDISMM02     ; cMsg := "&E-Mail direccion"
   CASE nMsg == MSG1_S2PDISMM03     ; cMsg := "Direccion E-Mail no especificada"
   CASE nMsg == MSG1_S2PDISMM04     ; cMsg := "Enviando mensaje...//"
   CASE nMsg == MSG1_S2PDISMM05     ; cMsg := "Imprimir"
   CASE nMsg == MSG1_S2PDISMM06     ; cMsg := "Mirar archivo insertado"
   CASE nMsg == MSG1_S2PDISMM07     ; cMsg := "Error enviando E-Mail:"
   CASE nMsg == MSG1_S2PDISMM08     ; cMsg := "Terminated Mapi E-mail Sending"
   CASE nMsg == MSG1_S2PDISMM09     ; cMsg := "&ZIP file"
   CASE nMsg == MSG1_S2PDISMM10     ; cMsg := "Zip file: %file%"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISSM01     ; cMsg := "Imprimir sobre E-Mail (SMTP)"
   CASE nMsg == MSG1_S2PDISSM02     ; cMsg := "&E-Mail direccion"
   CASE nMsg == MSG1_S2PDISSM03     ; cMsg := "Direccion E-Mail no especificada"
   CASE nMsg == MSG1_S2PDISSM04     ; cMsg := "SMTP Server no especificado (XBaseSMTPServer)"
   CASE nMsg == MSG1_S2PDISSM05     ; cMsg := "E-Mail mitente no especificado (XBaseSMTPFrom)"
   CASE nMsg == MSG1_S2PDISSM06     ; cMsg := "Enviando mensaje...//"
   CASE nMsg == MSG1_S2PDISSM07     ; cMsg := "Imprimir"
   CASE nMsg == MSG1_S2PDISSM08     ; cMsg := "Mirar archivo insertado"
   CASE nMsg == MSG1_S2PDISSM09     ; cMsg := "Error enviando E-Mail:"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISDP01     ; cMsg := "Impresora DOS"
   CASE nMsg == MSG1_S2PDISDP02     ; cMsg := "Impresora &on"
   CASE nMsg == MSG1_S2PDISDP03     ; cMsg := "&Printer puerta"
   CASE nMsg == MSG1_S2PDISDP04     ; cMsg := "Calidad"
   CASE nMsg == MSG1_S2PDISDP05     ; cMsg := "N&ormal"
   CASE nMsg == MSG1_S2PDISDP06     ; cMsg := "&Alto"
   CASE nMsg == MSG1_S2PDISDP07     ; cMsg := "Impostacion"
   CASE nMsg == MSG1_S2PDISDP08     ; cMsg := "Use impostacion &1"
   CASE nMsg == MSG1_S2PDISDP09     ; cMsg := "Use impostacion &2"
   CASE nMsg == MSG1_S2PDISDP10     ; cMsg := "Use impostacion &3"
   CASE nMsg == MSG1_S2PDISDP11     ; cMsg := "Copi&as"
   CASE nMsg == MSG1_S2PDISDP12     ; cMsg := "Impresora DOS no enstalada"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFWINPRN01     ; cMsg := "Imponer Silueta"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFWINPRD01     ; cMsg := "Normal"
   CASE nMsg == MSG1_DFWINPRD02     ; cMsg := "Imponer"
   CASE nMsg == MSG1_DFWINPRD03     ; cMsg := "Normal Silueta"
   CASE nMsg == MSG1_DFWINPRD04     ; cMsg := "Silueta grande"
   CASE nMsg == MSG1_DFWINPRD05     ; cMsg := "Silueta comprimida"
   CASE nMsg == MSG1_DFWINPRD06     ; cMsg := "Silueta grande y comprimida"
   CASE nMsg == MSG1_DFWINPRD07     ; cMsg := "&Ok"
   CASE nMsg == MSG1_DFWINPRD08     ; cMsg := "&Cancelar"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DBMSGERR01     ; cMsg := "Error"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFALERT01      ; cMsg := "Atencion"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_DFYESNO01      ; cMsg := "Pedido"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISCP01     ; cMsg := "Windows Impresora"
   CASE nMsg == MSG1_S2PDISCP02     ; cMsg := "Falta de archivo: "
   CASE nMsg == MSG1_S2PDISCP03     ; cMsg := "archivo creado: "
   CASE nMsg == MSG1_S2PDISCP04     ; cMsg := "Error cargando Crystal Report Print Engine (CRPE32.DLL)"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISCV01     ; cMsg := "Visualizar"
   CASE nMsg == MSG1_S2PDISCV02     ; cMsg := "Falta archivo: "
   CASE nMsg == MSG1_S2PDISCV03     ; cMsg := "archivo creado: "
   CASE nMsg == MSG1_S2PDISCV04     ; cMsg := "Error cargando Crystal Report Print Engine (CRPE32.DLL)"
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE nMsg == MSG1_S2PDISCF01     ; cMsg := "Imprimir sobre Archivo"
   CASE nMsg == MSG1_S2PDISCF02     ; cMsg := "File not found: "
   CASE nMsg == MSG1_S2PDISCF03     ; cMsg := "File created: "
   CASE nMsg == MSG1_S2PDISCF04     ; cMsg := "Error loading Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCF05     ; cMsg := "Error exporting: "
   CASE nMsg == MSG1_S2PDISCF06     ; cMsg := "Export not available"
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
   CASE nMsg == MSG1_DFWAIT01       ; cMsg := "Por favor atender..."
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
