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
   CASE nMsg == MSG_LANGUAGE       ; cMsg := "ESPANOL"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INITERROR      ; cMsg := "No logro abrir el file de INI"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_STD_YES        ; cMsg := "^Si"
   CASE nMsg == MSG_STD_NO         ; cMsg := "^No"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TABGET01       ; cMsg := "Falta la referencia en dbDD//Campo "
   CASE nMsg == MSG_TABGET02       ; cMsg := " no encontrado "
   CASE nMsg == MSG_TABGET03       ; cMsg := "Error de apertura DBDD.DBF"
   CASE nMsg == MSG_TABGET04       ; cMsg := "Error de apertura DBTABD.DBF"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TABCHK01       ; cMsg := "Ventana sobre "
   CASE nMsg == MSG_TABCHK02       ; cMsg := " no disponible !//"
   CASE nMsg == MSG_TABCHK03       ; cMsg := "El archivo "
   CASE nMsg == MSG_TABCHK04       ; cMsg := " est… vacio !"
   CASE nMsg == MSG_TABCHK05       ; cMsg := "Imposible dejar vacio el campo//("
   CASE nMsg == MSG_TABCHK06       ; cMsg := "Campo//("
   CASE nMsg == MSG_TABCHK07       ; cMsg := ")//el valor://"
   CASE nMsg == MSG_TABCHK08       ; cMsg := "no existe en archivo: "
   CASE nMsg == MSG_TABCHK09       ; cMsg := "//introducir"
   CASE nMsg == MSG_TABCHK10       ; cMsg := "Campo//("
   CASE nMsg == MSG_TABCHK11       ; cMsg := ")//el valor://"
   CASE nMsg == MSG_TABCHK12       ; cMsg := "no existe en tabla"
   CASE nMsg == MSG_TABCHK13       ; cMsg := "Campo llave tabla"
   CASE nMsg == MSG_TABCHK14       ; cMsg := "No encontrado"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ERRSYS01       ; cMsg := "N—mero no valido de funci•n"
   CASE nMsg == MSG_ERRSYS02       ; cMsg := "Archivo no encontrado"
   CASE nMsg == MSG_ERRSYS03       ; cMsg := "Recorrido no encontrado"
   CASE nMsg == MSG_ERRSYS04       ; cMsg := "Demasiados archivos abiertos"
   CASE nMsg == MSG_ERRSYS05       ; cMsg := "Acceso negado"
   CASE nMsg == MSG_ERRSYS06       ; cMsg := "Memoria Insuficiente"
   CASE nMsg == MSG_ERRSYS07       ; cMsg := "Reservado"
   CASE nMsg == MSG_ERRSYS08       ; cMsg := "Tentativo de escritura sobre disco protegido"
   CASE nMsg == MSG_ERRSYS09       ; cMsg := "Comando desconocido"
   CASE nMsg == MSG_ERRSYS10       ; cMsg := "Error de escritura"
   CASE nMsg == MSG_ERRSYS11       ; cMsg := "Error de lectura"
   CASE nMsg == MSG_ERRSYS12       ; cMsg := "Error general"
   //   nMsg == MSG_ERRSYS13       ; cMsg := "Acceso negado"
   CASE nMsg == MSG_ERRSYS14       ; cMsg := "Archivo ya existente"
   CASE nMsg == MSG_ERRSYS15       ; cMsg := "Este error ha sido memorizado en el archivo :"
   CASE nMsg == MSG_ERRSYS16       ; cMsg := "Oprimir una tecla por continuar ..."
   CASE nMsg == MSG_ERRSYS17       ; cMsg := "Invalid handle"
   CASE nMsg == MSG_ERRSYS18       ; cMsg := "Bloco de control de la memoria destrozado"
   CASE nMsg == MSG_ERRSYS19       ; cMsg := "Direccion de el bloco de la memoria no valido"
   CASE nMsg == MSG_ERRSYS20       ; cMsg := "Contexto de sistema envalido"
   CASE nMsg == MSG_ERRSYS21       ; cMsg := "Formato envalido"
   CASE nMsg == MSG_ERRSYS22       ; cMsg := "Codigo de engreso envalido"
   CASE nMsg == MSG_ERRSYS23       ; cMsg := "Dato envalido"
   CASE nMsg == MSG_ERRSYS24       ; cMsg := "Fue especificado un envalido piloto"
   CASE nMsg == MSG_ERRSYS25       ; cMsg := "Se intenta de remover la directory corriente"
   CASE nMsg == MSG_ERRSYS26       ; cMsg := "No tiene mismo suporte"
   CASE nMsg == MSG_ERRSYS27       ; cMsg := "No muchos archivos"
   CASE nMsg == MSG_ERRSYS28       ; cMsg := "Unitad desconosida"
   CASE nMsg == MSG_ERRSYS29       ; cMsg := "Suporte no pronto"
   CASE nMsg == MSG_ERRSYS30       ; cMsg := "Error de dato(CRC)"
   CASE nMsg == MSG_ERRSYS31       ; cMsg := "Malo pedido de estutura larga"
   CASE nMsg == MSG_ERRSYS32       ; cMsg := "Error de seek"
   CASE nMsg == MSG_ERRSYS33       ; cMsg := "Unknown media type"
   CASE nMsg == MSG_ERRSYS34       ; cMsg := "Sector no encontrado"
   CASE nMsg == MSG_ERRSYS35       ; cMsg := "Impresora sin papel"
   CASE nMsg == MSG_ERRSYS36       ; cMsg := "Violacion de uso conjunto"
   CASE nMsg == MSG_ERRSYS37       ; cMsg := "Violacion de bloque"
   CASE nMsg == MSG_ERRSYS38       ; cMsg := "Envalido cambio de disco"
   CASE nMsg == MSG_ERRSYS39       ; cMsg := "FCB no disponible"
   CASE nMsg == MSG_ERRSYS40       ; cMsg := "Sharing buffer overflow"
   CASE nMsg == MSG_ERRSYS41       ; cMsg := "Pedido de red no suportada"
   CASE nMsg == MSG_ERRSYS42       ; cMsg := "Remote computer no responde"
   CASE nMsg == MSG_ERRSYS43       ; cMsg := "Nombre duplicado sobre la red"
   CASE nMsg == MSG_ERRSYS44       ; cMsg := "Nombre de red no busquedo"
   CASE nMsg == MSG_ERRSYS45       ; cMsg := "Red satura"
   CASE nMsg == MSG_ERRSYS46       ; cMsg := "Network device no longer exists"
   CASE nMsg == MSG_ERRSYS47       ; cMsg := "Network BIOS command limit exceeded"
   CASE nMsg == MSG_ERRSYS48       ; cMsg := "Network adapter hardware error"
   CASE nMsg == MSG_ERRSYS49       ; cMsg := "Incorrect response from network"
   CASE nMsg == MSG_ERRSYS50       ; cMsg := "Unexpected network error"
   CASE nMsg == MSG_ERRSYS51       ; cMsg := "Incompatible remote adapter"
   CASE nMsg == MSG_ERRSYS52       ; cMsg := "Print queue full"
   CASE nMsg == MSG_ERRSYS53       ; cMsg := "Not enough space for print archivo"
   CASE nMsg == MSG_ERRSYS54       ; cMsg := "Print archivo deleted (not enough space)"
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
   CASE nMsg == MSG_ERRSYS70       ; cMsg := "Quit"
   CASE nMsg == MSG_ERRSYS71       ; cMsg := "Retry"
   CASE nMsg == MSG_ERRSYS72       ; cMsg := "Default"
   CASE nMsg == MSG_ERRSYS73       ; cMsg := "DOS Error :="
   CASE nMsg == MSG_ERRSYS74       ; cMsg := "Break"
   CASE nMsg == MSG_ERRSYS75       ; cMsg := "Llamado de"
   CASE nMsg == MSG_ERRSYS76       ; cMsg := "Error "
   CASE nMsg == MSG_ERRSYS77       ; cMsg := "Warning "
   CASE nMsg == MSG_ERRSYS78       ; cMsg := "Error desconocido"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBPATH01       ; cMsg := "Elaboraci•n path : @"
   CASE nMsg == MSG_DBPATH02       ; cMsg := "Nombre variable inexistente"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDUSE01        ; cMsg := "No existe archivo :"
   CASE nMsg == MSG_DDUSE02        ; cMsg := "Abertura archivo :"
   CASE nMsg == MSG_DDUSE03        ; cMsg := "Error en nombre variable :"
   CASE nMsg == MSG_DDUSE04        ; cMsg := "Modalidad desconocida!"
   CASE nMsg == MSG_DDUSE05        ; cMsg := "Indice archivo :"
   //   nMsg == MSG_DDUSE06        ; cMsg := "Error en nombre variable :"
   CASE nMsg == MSG_DDUSE07        ; cMsg := "Error abertura archivo"
   CASE nMsg == MSG_DDUSE08        ; cMsg := "No logro abrir el archivo"
   CASE nMsg == MSG_DDUSE09        ; cMsg := "TimeOut :"
   CASE nMsg == MSG_DDUSE10        ; cMsg := "Indice no encontrado"
   CASE nMsg == MSG_DDUSE11        ; cMsg := "Unable to open file %file%. The file is used by other users.//Please try again later."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBMSGERR       ; cMsg := "OK"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DE_STATE_INK   ; cMsg := "іConsultaі"
   CASE nMsg == MSG_DE_STATE_ADD   ; cMsg := "іIntroducirі"
   CASE nMsg == MSG_DE_STATE_MOD   ; cMsg := "іCorrecci•nі"
   CASE nMsg == MSG_DE_STATE_DEL   ; cMsg := "іCancelaci•nі"
   CASE nMsg == MSG_DE_STATE_COPY  ; cMsg := "іCopyі"
   CASE nMsg == MSG_DE_STATE_QRY   ; cMsg := "іQueryі"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBSKIP01       ; cMsg := " est… vacido !!"
   CASE nMsg == MSG_TBSKIP02       ; cMsg := "Alcanzado el inicio de : "
   CASE nMsg == MSG_TBSKIP03       ; cMsg := "Alcanzado el fin de : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DE_DEL         ; cMsg := "Confirmaci•n para eliminar RECORD !"
   CASE nMsg == MSG_DE_NOTMOD      ; cMsg := "No hay renglones para modificar !"
   CASE nMsg == MSG_DE_NOTDEL      ; cMsg := "No hay renglones para cancelar !"
   CASE nMsg == MSG_DE_NOTADD      ; cMsg := "It is not possible to add Record if the head table is empty: "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_NUM2WORD01     ; cMsg := "uno"
   CASE nMsg == MSG_NUM2WORD02     ; cMsg := "dos"
   CASE nMsg == MSG_NUM2WORD03     ; cMsg := "tres"
   CASE nMsg == MSG_NUM2WORD04     ; cMsg := "cuatro"
   CASE nMsg == MSG_NUM2WORD05     ; cMsg := "cinco"
   CASE nMsg == MSG_NUM2WORD06     ; cMsg := "seis"
   CASE nMsg == MSG_NUM2WORD07     ; cMsg := "siete"
   CASE nMsg == MSG_NUM2WORD08     ; cMsg := "ocho"
   CASE nMsg == MSG_NUM2WORD09     ; cMsg := "nueve"
   CASE nMsg == MSG_NUM2WORD10     ; cMsg := "diez"
   CASE nMsg == MSG_NUM2WORD11     ; cMsg := "once"
   CASE nMsg == MSG_NUM2WORD12     ; cMsg := "doce"
   CASE nMsg == MSG_NUM2WORD13     ; cMsg := "trece"
   CASE nMsg == MSG_NUM2WORD14     ; cMsg := "catorce"
   CASE nMsg == MSG_NUM2WORD15     ; cMsg := "quince"
   CASE nMsg == MSG_NUM2WORD16     ; cMsg := "dieciseis"
   CASE nMsg == MSG_NUM2WORD17     ; cMsg := "diecisiete"
   CASE nMsg == MSG_NUM2WORD18     ; cMsg := "dieciocho"
   CASE nMsg == MSG_NUM2WORD19     ; cMsg := "diecinueve"
   CASE nMsg == MSG_NUM2WORD20     ; cMsg := "diez"
   CASE nMsg == MSG_NUM2WORD21     ; cMsg := "veinte"
   CASE nMsg == MSG_NUM2WORD22     ; cMsg := "treinta"
   CASE nMsg == MSG_NUM2WORD23     ; cMsg := "cuarenta"
   CASE nMsg == MSG_NUM2WORD24     ; cMsg := "cincuenta"
   CASE nMsg == MSG_NUM2WORD25     ; cMsg := "sesenta"
   CASE nMsg == MSG_NUM2WORD26     ; cMsg := "setenta"
   CASE nMsg == MSG_NUM2WORD27     ; cMsg := "ochenta"
   CASE nMsg == MSG_NUM2WORD28     ; cMsg := "noventa"
   CASE nMsg == MSG_NUM2WORD29     ; cMsg := " mil millones"
   CASE nMsg == MSG_NUM2WORD30     ; cMsg := " millones"
   CASE nMsg == MSG_NUM2WORD31     ; cMsg := " mil"
   CASE nMsg == MSG_NUM2WORD32     ; cMsg := "cero"
   CASE nMsg == MSG_NUM2WORD33     ; cMsg := "mil"
   CASE nMsg == MSG_NUM2WORD34     ; cMsg := "un millon"
   CASE nMsg == MSG_NUM2WORD35     ; cMsg := "mil millones"
   CASE nMsg == MSG_NUM2WORD36     ; cMsg := "cien"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_NTXSYS01       ; cMsg := "Reconstrucci•n indices del sistema"
   //   nMsg == MSG_NTXSYS02       ; cMsg := "Cancelaci•n indices sobre disco"
   CASE nMsg == MSG_NTXSYS03       ; cMsg := "Reconstrucci•n indices dbDD"
   CASE nMsg == MSG_NTXSYS04       ; cMsg := "Reconstrucci•n indices Help"
   CASE nMsg == MSG_NTXSYS05       ; cMsg := "Reconstrucci•n indices tablas"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_PGLIST01       ; cMsg := "Elenco de las p…ginas"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBCFGOPE01     ; cMsg := "Reindicizaci•n"
   CASE nMsg == MSG_DBCFGOPE02     ; cMsg := "No logro abrir el archivo del sistema"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_HLP01          ; cMsg := "^Pr•ximo"
   CASE nMsg == MSG_HLP02          ; cMsg := "Ante^rior"
   CASE nMsg == MSG_HLP03          ; cMsg := "^Men—"
   CASE nMsg == MSG_HLP04          ; cMsg := "^archivo"
   CASE nMsg == MSG_HLP05          ; cMsg := "^Info"
   CASE nMsg == MSG_HLP06          ; cMsg := "^Sistema"
   CASE nMsg == MSG_HLP07          ; cMsg := "Sumari^o"
   CASE nMsg == MSG_HLP08          ; cMsg := "^Anterior"
   CASE nMsg == MSG_HLP09          ; cMsg := "C^erca"
   CASE nMsg == MSG_HLP10          ; cMsg := "^archivo"
   CASE nMsg == MSG_HLP11          ; cMsg := "^Imprimir Argumento"
   CASE nMsg == MSG_HLP12          ; cMsg := "^Salir"
   CASE nMsg == MSG_HLP13          ; cMsg := "^Uso de la guЌa"
   CASE nMsg == MSG_HLP14          ; cMsg := "Abreviaci•n por encontrar"
   CASE nMsg == MSG_HLP15          ; cMsg := "Abreviaci•n no encontrada"
   CASE nMsg == MSG_HLP16          ; cMsg := "Auxilio"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBRID01        ; cMsg := "Integridad tipo RESTRICT imposible borrar el RECORD"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_USRHELP01      ; cMsg := "Help contestual no disponible//"
   CASE nMsg == MSG_USRHELP02      ; cMsg := "en este ambiente!"
   CASE nMsg == MSG_USRHELP03      ; cMsg := " Teclas disponibles "
   CASE nMsg == MSG_USRHELP04      ; cMsg := "Regreso a la p…gina anterior"
   CASE nMsg == MSG_USRHELP05      ; cMsg := "Calculadora"
   CASE nMsg == MSG_USRHELP06      ; cMsg := "Fin de la sesi•n de trabajo"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDINDEX01      ; cMsg := "Reconstrucci•n Indices"
   CASE nMsg == MSG_DDINDEX02      ; cMsg := "^Global"
   CASE nMsg == MSG_DDINDEX03      ; cMsg := "^Parcial"
   CASE nMsg == MSG_DDINDEX04      ; cMsg := "^archivo de Sistema"
   CASE nMsg == MSG_DDINDEX05      ; cMsg := "  Indice   іRecordіExpresi•n"
   CASE nMsg == MSG_DDINDEX06      ; cMsg := "Reconstrucci•n indices"
   CASE nMsg == MSG_DDINDEX07      ; cMsg := " COMPATAMIENTO archivos"
   CASE nMsg == MSG_DDINDEX08      ; cMsg := "Seleccionar los archivo INDICE por reconstruir.RETURN confirmar ! "
   CASE nMsg == MSG_DDINDEX09      ; cMsg := "PAUSA - Una tecla para confirmar - PAUSA"
   CASE nMsg == MSG_DDINDEX10      ; cMsg := "SPACE=PausaіReconstrucci•n INDICES en curso !"
   CASE nMsg == MSG_DDINDEX11      ; cMsg := "...Pack del archivo ("
   CASE nMsg == MSG_DDINDEX12      ; cMsg := ") en curso !..."
   CASE nMsg == MSG_DDINDEX13      ; cMsg := "Indice archivo :"
   CASE nMsg == MSG_DDINDEX14      ; cMsg := "Error en nombre variable :"
   CASE nMsg == MSG_DDINDEX15      ; cMsg := "Check"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDINDEXFL01    ; cMsg := "Indice archivo :"
   CASE nMsg == MSG_DDINDEXFL02    ; cMsg := "Error en nombre variable :"
   CASE nMsg == MSG_DDINDEXFL03    ; cMsg := "PACK del archivo :"
   CASE nMsg == MSG_DDINDEXFL04    ; cMsg := " en curso "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDWIN01        ; cMsg := "Ventana "
   CASE nMsg == MSG_DDWIN02        ; cMsg := "//No disponible !"
   CASE nMsg == MSG_DDWIN03        ; cMsg := "Nada por cancelar !"
   CASE nMsg == MSG_DDWIN04        ; cMsg := "BORRA ELEMENTO CORRIENTE"
   CASE nMsg == MSG_DDWIN05        ; cMsg := "Nada para modificar !"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFAUTOFORM01   ; cMsg := "C^onfirmar"
   CASE nMsg == MSG_DFAUTOFORM02   ; cMsg := "^Renuncia"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCOLOR01      ; cMsg := "Label color"
   CASE nMsg == MSG_DFCOLOR02      ; cMsg := "No encontrada"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFALERT01      ; cMsg := "Oprimir una tecla para continuar ..."
   CASE nMsg == MSG_DFALERT02      ; cMsg := "Oprimir uno de las teclas indicadas"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFMEMO01       ; cMsg := "Confirmaci•n texto"
   CASE nMsg == MSG_DFMEMO02       ; cMsg := "Lectura da disco"
   CASE nMsg == MSG_DFMEMO03       ; cMsg := "Escribir sobre disco"
   CASE nMsg == MSG_DFMEMO05       ; cMsg := "Anular el total"
   CASE nMsg == MSG_DFMEMO06       ; cMsg := "Suma total"
   CASE nMsg == MSG_DFMEMO07       ; cMsg := "Visualizar el total"
   CASE nMsg == MSG_DFMEMO08       ; cMsg := "Volver a llevar el total en el texto"
   CASE nMsg == MSG_DFMEMO09       ; cMsg := "Soluciona expresiones posponiendo el resultado"
   CASE nMsg == MSG_DFMEMO10       ; cMsg := "Resuelve espresiones substituyendo el resultado"
   CASE nMsg == MSG_DFMEMO11       ; cMsg := "archivo por leer"
   CASE nMsg == MSG_DFMEMO12       ; cMsg := "Lectura Memo de Disco"
   CASE nMsg == MSG_DFMEMO13       ; cMsg := "Sistema autom…tico de totalizaci•n, valores sumados :"
   CASE nMsg == MSG_DFMEMO14       ; cMsg := "Total obtenido con calculadora//"
   //   nMsg == MSG_DFMEMO15       ; cMsg := "Sistema autom…tico de totalizaci•n, valores sumados :"
   CASE nMsg == MSG_DFMEMO16       ; cMsg := "Falta car…cter de identificaci•n inicial !"
   CASE nMsg == MSG_DFMEMO17       ; cMsg := "Esta seguro de querer abandonar las modificaciones"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFQRY01        ; cMsg := "Menor de"
   CASE nMsg == MSG_DFQRY02        ; cMsg := "Mayor de"
   CASE nMsg == MSG_DFQRY03        ; cMsg := "Menor o Igual a"
   CASE nMsg == MSG_DFQRY04        ; cMsg := "Mayor o Igual a"
   CASE nMsg == MSG_DFQRY05        ; cMsg := "Igual a"
   CASE nMsg == MSG_DFQRY06        ; cMsg := "Diverso de"
   CASE nMsg == MSG_DFQRY07        ; cMsg := "Contiene"
   CASE nMsg == MSG_DFQRY08        ; cMsg := "esta contenido en"
   CASE nMsg == MSG_DFQRY09        ; cMsg := "Exactamente igual"
   CASE nMsg == MSG_DFQRY10        ; cMsg := "verdadero"
   CASE nMsg == MSG_DFQRY11        ; cMsg := "falso"
   CASE nMsg == MSG_DFQRY12        ; cMsg := " y "
   CASE nMsg == MSG_DFQRY13        ; cMsg := " o "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_VALID01        ; cMsg := "Imposible dejar el campo vacido"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINI01        ; cMsg := "Trae una versi•n no corecta"
   CASE nMsg == MSG_DFINI02        ; cMsg := "Regenerar dbStart.ini de Visual dBsee"
   CASE nMsg == MSG_DFINI03        ; cMsg := "Cargar acciones"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFFILE2PRN01   ; cMsg := "Impresora no lista//Intentar nuevamente"
   CASE nMsg == MSG_DFFILE2PRN02   ; cMsg := "Impresi•n en curso"
   CASE nMsg == MSG_DFFILE2PRN03   ; cMsg := "Interrumpir impresi•n"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFNET01        ; cMsg := "Imposible bloquear el archivo :"
   CASE nMsg == MSG_DFNET02        ; cMsg := "Imposible bloquear RECORD nш. %2%"
   CASE nMsg == MSG_DFNET03        ; cMsg := "Imposible agregar el RECORD"
   //   nMsg == MSG_DFNET04        ; cMsg := "FUNCION DESCONOCIDA !!"
   //   nMsg == MSG_DFNET05        ; cMsg := "Time Out: "
   CASE nMsg == MSG_DFNET06        ; cMsg := "Intento de LOCK"
   CASE nMsg == MSG_DFNET07        ; cMsg := "Segundos"
   CASE nMsg == MSG_DFNET08        ; cMsg := "LOCK archivo :"
   CASE nMsg == MSG_DFNET09        ; cMsg := "A travez de semaforo"
   CASE nMsg == MSG_DFNET10        ; cMsg := "Unable to find"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFMEMOWRI01    ; cMsg := "archivo para escribir: "
   CASE nMsg == MSG_DFMEMOWRI02    ; cMsg := "Digitar nombre archivo para escribir.|F10=confirma|Esc=rechaza"
   CASE nMsg == MSG_DFMEMOWRI03    ; cMsg := "Escritura memo sobre disco"
   CASE nMsg == MSG_DFMEMOWRI04    ; cMsg := "archivo existente, cubrir nuevamente ?"
   //   nMsg == MSG_DFMEMOWRI05    ; cMsg := "Escritura archivo "
   //   nMsg == MSG_DFMEMOWRI06    ; cMsg := " completa !"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPATH01    ; cMsg := "Carga Path de la aplicacion"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIFONT01    ; cMsg := "Carga Silueta"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPRN01     ; cMsg := "Carga de la impresora"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPROGIND01    ; cMsg := "Anular"
   CASE nMsg == MSG_DFPROGIND02    ; cMsg := "Estas seguro de que quieres interrumpir"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBLOOK01       ; cMsg := "No es posible dejar el campo//"
   CASE nMsg == MSG_DBLOOK02       ; cMsg := "vacio"
   CASE nMsg == MSG_DBLOOK03       ; cMsg := "Atencion: //"
   CASE nMsg == MSG_DBLOOK04       ; cMsg := "//inexistente !!"
   CASE nMsg == MSG_DBLOOK05       ; cMsg := "Atenci•n : el c•digo//"
   CASE nMsg == MSG_DBLOOK06       ; cMsg := "//no existe en el archivo"
   CASE nMsg == MSG_DBLOOK07       ; cMsg := "//quiere insertarlo?"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABDE01      ; cMsg := "Elenco de tablas del archivo"
   CASE nMsg == MSG_DFTABDE02      ; cMsg := "Tablas"
   CASE nMsg == MSG_DFTABDE03      ; cMsg := "Correcci•n"
   CASE nMsg == MSG_DFTABDE04      ; cMsg := "No hay tablas en esta aplicaci•n"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBINK01        ; cMsg := "Time out de teclado"
   CASE nMsg == MSG_DBINK02        ; cMsg := "Segundos"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   //   nMsg == MSG_DFINIPP01      ; cMsg := "Carga de la impresi•n"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPOR01     ; cMsg := "Carga de las puertas"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFGET01        ; cMsg := "Salida de la p…gina"
   CASE nMsg == MSG_DFGET02        ; cMsg := "Salvar la p…gina"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBBRWNEW01     ; cMsg := "Restablecer las dimensiones originales de la ventana"
   CASE nMsg == MSG_TBBRWNEW02     ; cMsg := "Reubicar la ventana en la pantalla"
   CASE nMsg == MSG_TBBRWNEW03     ; cMsg := "Cambiar las dimensiones de la ventana"
   CASE nMsg == MSG_TBBRWNEW04     ; cMsg := "Reducir al minimo de las dimensiones consentidas"
   CASE nMsg == MSG_TBBRWNEW05     ; cMsg := "Ampliar al m…ximo de las dimensiones consentidas"
   CASE nMsg == MSG_TBBRWNEW06     ; cMsg := "Remover la ventana en curso y todas las relacionadas en la pantalla"
   CASE nMsg == MSG_TBBRWNEW07     ; cMsg := "Presenta una lista de las p…ginas en actividad"
   CASE nMsg == MSG_TBBRWNEW08     ; cMsg := "Sucesivo"
   CASE nMsg == MSG_TBBRWNEW09     ; cMsg := "Anterior"
   CASE nMsg == MSG_TBBRWNEW10     ; cMsg := "Primero"
   CASE nMsg == MSG_TBBRWNEW11     ; cMsg := "Ultimo"
   CASE nMsg == MSG_TBBRWNEW12     ; cMsg := "Derecha"
   CASE nMsg == MSG_TBBRWNEW13     ; cMsg := "Izquierda"
   CASE nMsg == MSG_TBBRWNEW14     ; cMsg := "P…gina de arriba"
   CASE nMsg == MSG_TBBRWNEW15     ; cMsg := "P…gina de abajo"
   CASE nMsg == MSG_TBBRWNEW16     ; cMsg := "Fija/Libera las columnas a Izquierda"
   CASE nMsg == MSG_TBBRWNEW17     ; cMsg := "Ensancha la Columna"
   CASE nMsg == MSG_TBBRWNEW18     ; cMsg := "Restringe la Columna"
   CASE nMsg == MSG_TBBRWNEW19     ; cMsg := "Deselecci•n de todos los elementos"
   CASE nMsg == MSG_TBBRWNEW20     ; cMsg := "Selecci•n  de Elemento"
   CASE nMsg == MSG_TBBRWNEW21     ; cMsg := "Selecci•n de todos los elementos"
   CASE nMsg == MSG_TBBRWNEW22     ; cMsg := "Modificar el Elemento en Curso"
   CASE nMsg == MSG_TBBRWNEW23     ; cMsg := "P…gina siguiente"
   CASE nMsg == MSG_TBBRWNEW24     ; cMsg := "^Restablece"
   CASE nMsg == MSG_TBBRWNEW25     ; cMsg := "^Desplaza"
   CASE nMsg == MSG_TBBRWNEW26     ; cMsg := "Re^dimesiona"
   CASE nMsg == MSG_TBBRWNEW27     ; cMsg := "Reduce a ^icona"
   CASE nMsg == MSG_TBBRWNEW28     ; cMsg := "Amplia"
   CASE nMsg == MSG_TBBRWNEW29     ; cMsg := "Cierra"
   CASE nMsg == MSG_TBBRWNEW30     ; cMsg := "^Pasa a ..."
   CASE nMsg == MSG_TBBRWNEW31     ; cMsg := "Teclas"
   CASE nMsg == MSG_TBBRWNEW32     ; cMsg := "P…gina anterior"
   CASE nMsg == MSG_TBBRWNEW33     ; cMsg := "Impresi•n record"
   CASE nMsg == MSG_TBBRWNEW34     ; cMsg := "Label Print"
   CASE nMsg == MSG_TBBRWNEW35     ; cMsg := "Statistic"
   CASE nMsg == MSG_TBBRWNEW36     ; cMsg := "Select/Unselect row"
   CASE nMsg == MSG_TBBRWNEW37     ; cMsg := "Unselect all"
   CASE nMsg == MSG_TBBRWNEW38     ; cMsg := "Select all"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDGENDBF01     ; cMsg := "archivo"
   CASE nMsg == MSG_DDGENDBF02     ; cMsg := "sin campos"
   CASE nMsg == MSG_DDGENDBF03     ; cMsg := "Creaci•n del archivo"
   CASE nMsg == MSG_DDGENDBF04     ; cMsg := "Attention!!! The Directory not exist:// "
   CASE nMsg == MSG_DDGENDBF05     ; cMsg := "//Create the Directory now?"
   CASE nMsg == MSG_DDGENDBF06     ; cMsg := "Unable to Create the Directory://"
   CASE nMsg == MSG_DDGENDBF07     ; cMsg := "Serious error in Table creation!!!//Operation aborted ...//Table :"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABPRINT01   ; cMsg := "Ninguna tabla por imprimir"
   CASE nMsg == MSG_DFTABPRINT02   ; cMsg := "ю Tablas ю"
   CASE nMsg == MSG_DFTABPRINT03   ; cMsg := "Impresi•n de tablas"
   //   nMsg == MSG_DFTABPRINT04   ; cMsg := "Impresi•n de tablas"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPRNSTART01   ; cMsg := "Error en apertura del archivo"
   CASE nMsg == MSG_DFPRNSTART02   ; cMsg := "Oprimir Enter para imprimir//"
   CASE nMsg == MSG_DFPRNSTART03   ; cMsg := "archivo principal"
   CASE nMsg == MSG_DFPRNSTART04   ; cMsg := "Imprenta conectada"
   CASE nMsg == MSG_DFPRNSTART05   ; cMsg := "Impresora en curso"
   CASE nMsg == MSG_DFPRNSTART06   ; cMsg := "Puerta de impresi•n"
   CASE nMsg == MSG_DFPRNSTART07   ; cMsg := "Calidad"
   CASE nMsg == MSG_DFPRNSTART08   ; cMsg := "No^rmal"
   CASE nMsg == MSG_DFPRNSTART09   ; cMsg := "A^lta"
   CASE nMsg == MSG_DFPRNSTART10   ; cMsg := "Tipo de imprenta"
   CASE nMsg == MSG_DFPRNSTART11   ; cMsg := "Norm^al"
   CASE nMsg == MSG_DFPRNSTART12   ; cMsg := "Comprimi^do"
   CASE nMsg == MSG_DFPRNSTART13   ; cMsg := "Cambio de ^puerta"
   CASE nMsg == MSG_DFPRNSTART14   ; cMsg := "^M…rgenes"
   CASE nMsg == MSG_DFPRNSTART15   ; cMsg := "Impre^soras"
   CASE nMsg == MSG_DFPRNSTART16   ; cMsg := "Impres^ora en funci•n"
   CASE nMsg == MSG_DFPRNSTART17   ; cMsg := "Cop^ias:"
   CASE nMsg == MSG_DFPRNSTART18   ; cMsg := "^Numero de copias"
   CASE nMsg == MSG_DFPRNSTART19   ; cMsg := "^archivo :"
   CASE nMsg == MSG_DFPRNSTART20   ; cMsg := "^Visualizar"
   CASE nMsg == MSG_DFPRNSTART21   ; cMsg := "^Impresi•n"
   CASE nMsg == MSG_DFPRNSTART22   ; cMsg := "A^bandona"
   CASE nMsg == MSG_DFPRNSTART23   ; cMsg := "Renglones por p…gina"
   CASE nMsg == MSG_DFPRNSTART24   ; cMsg := "M…rgen Superior"
   CASE nMsg == MSG_DFPRNSTART25   ; cMsg := "M…rgen inferior"
   CASE nMsg == MSG_DFPRNSTART26   ; cMsg := "M…rgen izquierdo"
   CASE nMsg == MSG_DFPRNSTART27   ; cMsg := "M…rgenes"
   CASE nMsg == MSG_DFPRNSTART28   ; cMsg := "ю Puertas fisicas ю"
   CASE nMsg == MSG_DFPRNSTART29   ; cMsg := "ю Puertas de impresi•n ю"
   CASE nMsg == MSG_DFPRNSTART30   ; cMsg := "Impresi•n sin saltar p…ginas"
   CASE nMsg == MSG_DFPRNSTART31   ; cMsg := "Nada de imprimir"
   CASE nMsg == MSG_DFPRNSTART32   ; cMsg := "Nombre Report"
   CASE nMsg == MSG_DFPRNSTART33   ; cMsg := "Descripcion Filtro"
   CASE nMsg == MSG_DFPRNSTART34   ; cMsg := "Expresion de el filtro"
   CASE nMsg == MSG_DFPRNSTART35   ; cMsg := "I^nformacion"
   CASE nMsg == MSG_DFPRNSTART36   ; cMsg := "Disponer"
   CASE nMsg == MSG_DFPRNSTART37   ; cMsg := "Usar disposicion ^1"
   CASE nMsg == MSG_DFPRNSTART38   ; cMsg := "Usar disposicion ^2"
   CASE nMsg == MSG_DFPRNSTART39   ; cMsg := "Usar disposicion ^3"
   CASE nMsg == MSG_DFPRNSTART40   ; cMsg := "Pa^ginas"
   CASE nMsg == MSG_DFPRNSTART41   ; cMsg := "Todas Paginas"
   //   nMsg == MSG_DFPRNSTART42   ; cMsg := "Todas paginas"
   CASE nMsg == MSG_DFPRNSTART43   ; cMsg := "De Pagina :"
   CASE nMsg == MSG_DFPRNSTART44   ; cMsg := "De Pagina "
   CASE nMsg == MSG_DFPRNSTART45   ; cMsg := "A Pagina  :"
   CASE nMsg == MSG_DFPRNSTART46   ; cMsg := "A  Pagina "
   CASE nMsg == MSG_DFPRNSTART47   ; cMsg := "Paginas"
   CASE nMsg == MSG_DFPRNSTART48   ; cMsg := "^Filtro"
   CASE nMsg == MSG_DFPRNSTART49   ; cMsg := "Cambiar el filtro Corriente"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDDE01         ; cMsg := "Cuadro autom…tico//"
   CASE nMsg == MSG_DDDE02         ; cMsg := "//no definido !"
   CASE nMsg == MSG_DDDE03         ; cMsg := "Cuadro autom…tico//"
   CASE nMsg == MSG_DDDE04         ; cMsg := "//Llave principal no definida !"
   CASE nMsg == MSG_DDDE05         ; cMsg := "Cuadro "
   CASE nMsg == MSG_DDDE06         ; cMsg := "LLAVE PRIMARIA//"
   CASE nMsg == MSG_DDDE07         ; cMsg := "//Duplicada !"
   CASE nMsg == MSG_DDDE08         ; cMsg := "Campo Obligatorio"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBINK01        ; cMsg := "El Record corriente ha sido cancelado"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBGETKEY01     ; cMsg := "Llama la ventana de b—squeda"
   CASE nMsg == MSG_TBGETKEY02     ; cMsg := "Llama las llaves de b—squeda"
   //   nMsg == MSG_TBGETKEY03     ; cMsg := "Llama la ventana de b—squeda"
   CASE nMsg == MSG_TBGETKEY04     ; cMsg := "Entra en edit sobre memo"
   CASE nMsg == MSG_TBGETKEY05     ; cMsg := "Selecciona/Deselecciona el valor"
   CASE nMsg == MSG_TBGETKEY06     ; cMsg := "Selecciona el valor"
   CASE nMsg == MSG_TBGETKEY07     ; cMsg := "Confirma el pulsante"
   CASE nMsg == MSG_TBGETKEY08     ; cMsg := "Incrementa el valor"
   CASE nMsg == MSG_TBGETKEY09     ; cMsg := "Disminuye  el valor"
   CASE nMsg == MSG_TBGETKEY10     ; cMsg := "Incrementa 10 veces el valor"
   CASE nMsg == MSG_TBGETKEY11     ; cMsg := "Disminuye  10 veces el valor"
   CASE nMsg == MSG_TBGETKEY14     ; cMsg := "Copia en el buffer"
   CASE nMsg == MSG_TBGETKEY15     ; cMsg := "Introducir desde el buffer"
   CASE nMsg == MSG_TBGETKEY16     ; cMsg := "Record anterior"
   CASE nMsg == MSG_TBGETKEY17     ; cMsg := "Record sucesivo"
   CASE nMsg == MSG_TBGETKEY18     ; cMsg := "Primer record"
   CASE nMsg == MSG_TBGETKEY19     ; cMsg := "Ultimo record"
   CASE nMsg == MSG_TBGETKEY20     ; cMsg := "Llama el Dietario"
   CASE nMsg == MSG_TBGETKEY21     ; cMsg := "Fecha Cercana"
   CASE nMsg == MSG_TBGETKEY22     ; cMsg := "Fecha Anterior"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFSVILLEV01    ; cMsg := "Interrumpir impresi•n"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFLOGIN01      ; cMsg := "No logro abrir el archivo del Password"
   CASE nMsg == MSG_DFLOGIN02      ; cMsg := "Digitar el password"
   CASE nMsg == MSG_DFLOGIN03      ; cMsg := "*      CODIGO DE ACCESO      *//"
   CASE nMsg == MSG_DFLOGIN04      ; cMsg := " Ya utilizado en el sist‚ma //"
   CASE nMsg == MSG_DFLOGIN05      ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД//"
   CASE nMsg == MSG_DFLOGIN06      ; cMsg := "El Password"
   CASE nMsg == MSG_DFLOGIN07      ; cMsg := "//no ha sido encontrado//"
   CASE nMsg == MSG_DFLOGIN08      ; cMsg := "Digitar nuevamente el Password"
   CASE nMsg == MSG_DFLOGIN09      ; cMsg := "*      ACCESO  NEGADO    *//"
   CASE nMsg == MSG_DFLOGIN10      ; cMsg := "  Usuario no autorizado ! //"
   CASE nMsg == MSG_DFLOGIN11      ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДД"
   CASE nMsg == MSG_DFLOGIN12      ; cMsg := "Error de digitaci•n del Password//"
   CASE nMsg == MSG_DFLOGIN13      ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
   CASE nMsg == MSG_DFLOGIN14      ; cMsg := "PASSWORD"
   CASE nMsg == MSG_DFLOGIN15      ; cMsg := "Digitar el nuevo Password"
   CASE nMsg == MSG_DFLOGIN16      ; cMsg := "Redigitar el Password"
   CASE nMsg == MSG_DFLOGIN17      ; cMsg := "Nombre del usuario"
   CASE nMsg == MSG_DFLOGIN18      ; cMsg := "Quieres digitar un nuevo password"
   CASE nMsg == MSG_DFLOGIN19      ; cMsg := "For the new laws on the Privacy //the Password must at least be of 8 characters!"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDWIT01        ; cMsg := "Adicionar un elemento"
   CASE nMsg == MSG_DDWIT02        ; cMsg := "Modifica el elemento corriente"
   CASE nMsg == MSG_DDWIT03        ; cMsg := "Cancela el elemento corriente"
   CASE nMsg == MSG_DDWIT04        ; cMsg := "B—squeda"
   CASE nMsg == MSG_DDWIT05        ; cMsg := "C•digo "
   CASE nMsg == MSG_DDWIT06        ; cMsg := " inexistente ! "
   CASE nMsg == MSG_DDWIT07        ; cMsg := "BORRA ELEMENTO CORRIENTE"
   CASE nMsg == MSG_DDWIT08        ; cMsg := "B—squeda "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDKEY01        ; cMsg := "Llave no disponible//- archivo "
   CASE nMsg == MSG_DDKEY02        ; cMsg := " sin Ќndice ! -"
   CASE nMsg == MSG_DDKEY03        ; cMsg := "Imposible evaluar la llave de b—squeda//"
   CASE nMsg == MSG_DDKEY04        ; cMsg := "B—squeda secuencial activada s•lo sobre campos de caracteres !"
   CASE nMsg == MSG_DDKEY05        ; cMsg := "Ventana de busqueda"
   CASE nMsg == MSG_DDKEY06        ; cMsg := "B—squeda por contenido"
   CASE nMsg == MSG_DDKEY07        ; cMsg := "Ventana en el archivo de LOOKUP"
   CASE nMsg == MSG_DDKEY08        ; cMsg := "Construcci•n interactiva de la llave de b—squeda"
   CASE nMsg == MSG_DDKEY09        ; cMsg := "Llave: "
   CASE nMsg == MSG_DDKEY10        ; cMsg := "//no hallada!"
   CASE nMsg == MSG_DDKEY11        ; cMsg := " Apretar una tecla para interrumpir la b—squeda "
   CASE nMsg == MSG_DDKEY12        ; cMsg := "//Por favor atender...//"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDUPDDBF01     ; cMsg := "Actualizaci•n"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABFRM03     ; cMsg := "2ш control de c•digo duplicado !//Acceso suspendido !!"
   CASE nMsg == MSG_DFTABFRM04     ; cMsg := "Error: c•digo duplicado en "
   CASE nMsg == MSG_DFTABFRM05     ; cMsg := "Atencion!"
   CASE nMsg == MSG_DFTABFRM06     ; cMsg := "^Ya utilizado en"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPK01         ; cMsg := "principal"
   CASE nMsg == MSG_DFPK02         ; cMsg := "unЌvoca"
   CASE nMsg == MSG_DFPK03         ; cMsg := "Llave "
   CASE nMsg == MSG_DFPK04         ; cMsg := " duplicada !//"
   CASE nMsg == MSG_DFPK05         ; cMsg := " vacЌa !//"
   CASE nMsg == MSG_DFPK06         ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД//"
   CASE nMsg == MSG_DFPK07         ; cMsg := "     digitar nueva llave !   "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDQRY01        ; cMsg := "e         Ы .AND.Ы"
   CASE nMsg == MSG_DDQRY02        ; cMsg := "o tambiЉn Ы .OR. Ы"
   CASE nMsg == MSG_DDQRY17        ; cMsg := "parЉntesisЫ  )   Ы"
   CASE nMsg == MSG_DDQRY03        ; cMsg := "Fin       Ы      Ы"
   CASE nMsg == MSG_DDQRY04        ; cMsg := " <   Menor de.............. "
   CASE nMsg == MSG_DDQRY05        ; cMsg := " >   Mayor de ............. "
   CASE nMsg == MSG_DDQRY06        ; cMsg := " <=  Menor o Igual a....... "
   CASE nMsg == MSG_DDQRY07        ; cMsg := " >=  Mayor o Igual a ...... "
   CASE nMsg == MSG_DDQRY08        ; cMsg := " =   Igual a .............. "
   CASE nMsg == MSG_DDQRY09        ; cMsg := " #   Diverso de............ "
   CASE nMsg == MSG_DDQRY10        ; cMsg := " $   Est… contenido.......... "
   CASE nMsg == MSG_DDQRY11        ; cMsg := " њ   Contiene.............. "
   CASE nMsg == MSG_DDQRY12        ; cMsg := "Campos del archivo"
   CASE nMsg == MSG_DDQRY13        ; cMsg := "Condiciones"
   CASE nMsg == MSG_DDQRY14        ; cMsg := "Conexiones l•gicas"
   CASE nMsg == MSG_DDQRY15        ; cMsg := "іFILTRO CORRECTOі"
   CASE nMsg == MSG_DDQRY16        ; cMsg := "іFILTRO INCORRECTOі"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBGET01        ; cMsg := "Espacio=Modificaci•n і "
   CASE nMsg == MSG_TBGET02        ; cMsg := "F10 para registrar і "
   CASE nMsg == MSG_TBGET03        ; cMsg := "El valor  digitado es incorrecto"
   CASE nMsg == MSG_TBGET04        ; cMsg := "NO puedo editar el CONTROL"
   CASE nMsg == MSG_TBGET05        ; cMsg := "El dato es cambiado"
   CASE nMsg == MSG_TBGET06        ; cMsg := "^Guardar"
   CASE nMsg == MSG_TBGET07        ; cMsg := "^Salir"
   CASE nMsg == MSG_TBGET08        ; cMsg := "Continuar"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFSTA01        ; cMsg := "Tiempo transcurrido"
   CASE nMsg == MSG_DFSTA02        ; cMsg := "Tiempo estimado"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIREP01     ; cMsg := "Cargamento de las siluetas de impresi•n"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCALC01       ; cMsg := "Suma"
   CASE nMsg == MSG_DFCALC02       ; cMsg := "Multiplicaci•n"
   CASE nMsg == MSG_DFCALC03       ; cMsg := "Sustracci•n"
   CASE nMsg == MSG_DFCALC04       ; cMsg := "Divisi•n"
   CASE nMsg == MSG_DFCALC06       ; cMsg := "Totalizaci•n"
   CASE nMsg == MSG_DFCALC07       ; cMsg := "Encendido"
   CASE nMsg == MSG_DFCALC08       ; cMsg := "Apagado"
   CASE nMsg == MSG_DFCALC09       ; cMsg := "Salida con contenido en el buffer del teclado"
   CASE nMsg == MSG_DFCALC10       ; cMsg := "Conversion from LIRE to EURO"
   CASE nMsg == MSG_DFCALC11       ; cMsg := "Conversion from EURO to LIRE"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INTCOL01       ; cMsg := "NEGRO"
   CASE nMsg == MSG_INTCOL02       ; cMsg := "GRIS OSCURO"
   CASE nMsg == MSG_INTCOL03       ; cMsg := "GRIS CLARO"
   CASE nMsg == MSG_INTCOL04       ; cMsg := "AZUL OSCURO"
   CASE nMsg == MSG_INTCOL05       ; cMsg := "AZUL"
   CASE nMsg == MSG_INTCOL06       ; cMsg := "AZUL CLARO"
   CASE nMsg == MSG_INTCOL07       ; cMsg := "VERDE OSCURO"
   CASE nMsg == MSG_INTCOL08       ; cMsg := "VERDE"
   CASE nMsg == MSG_INTCOL09       ; cMsg := "VERDE CLARO"
   CASE nMsg == MSG_INTCOL10       ; cMsg := "ROJO OSCURO"
   CASE nMsg == MSG_INTCOL11       ; cMsg := "ROJO"
   CASE nMsg == MSG_INTCOL12       ; cMsg := "ROJO CLARO"
   CASE nMsg == MSG_INTCOL13       ; cMsg := "AMARILLO OSCURO"
   CASE nMsg == MSG_INTCOL14       ; cMsg := "AMARILLO"
   CASE nMsg == MSG_INTCOL15       ; cMsg := "AMARILLO CLARO"
   CASE nMsg == MSG_INTCOL16       ; cMsg := "BLANCO"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INTPRN01       ; cMsg := "IMPRESORA SIN CARACTERES DE ESCAPE"
   //   nMsg == MSG_INTPRN02       ; cMsg := "EPSON FX-80"
   //   nMsg == MSG_INTPRN03       ; cMsg := "HP LASERJET PLUS"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ACTINT001      ; cMsg := "Home"
   CASE nMsg == MSG_ACTINT002      ; cMsg := "Ctrl-Flecha derecha"
   CASE nMsg == MSG_ACTINT003      ; cMsg := "Pag. abajo"
   CASE nMsg == MSG_ACTINT004      ; cMsg := "Flecha derecha"
   CASE nMsg == MSG_ACTINT005      ; cMsg := "Flecha arriba"
   CASE nMsg == MSG_ACTINT006      ; cMsg := "Fin"
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
   CASE nMsg == MSG_ACTINT019      ; cMsg := "Ctrl-Enter"
   CASE nMsg == MSG_ACTINT020      ; cMsg := "Enter"
   CASE nMsg == MSG_ACTINT021      ; cMsg := "Pag.arriba"
   CASE nMsg == MSG_ACTINT022      ; cMsg := "Flecha izquierda"
   CASE nMsg == MSG_ACTINT023      ; cMsg := "Ins"
   CASE nMsg == MSG_ACTINT024      ; cMsg := "Ctrl-Fin"
   CASE nMsg == MSG_ACTINT025      ; cMsg := "Flecha abajo"
   CASE nMsg == MSG_ACTINT026      ; cMsg := "Ctrl-Flecha izquierda"
   CASE nMsg == MSG_ACTINT027      ; cMsg := "Esc"
   CASE nMsg == MSG_ACTINT028      ; cMsg := "F1"
   CASE nMsg == MSG_ACTINT029      ; cMsg := "Ctrl-Home"
   CASE nMsg == MSG_ACTINT030      ; cMsg := "Ctrl-Pag. abajo"
   CASE nMsg == MSG_ACTINT031      ; cMsg := "Ctrl-Pag.arriba"
   CASE nMsg == MSG_ACTINT032      ; cMsg := "Space"
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
   CASE nMsg == MSG_ACTINT127      ; cMsg := "Ctrl-Flecha arriba"
   CASE nMsg == MSG_ACTINT128      ; cMsg := "Ctrl-Flecha abajo"
   CASE nMsg == MSG_ACTINT129      ; cMsg := "Ctrl-Ins"
   CASE nMsg == MSG_ACTINT130      ; cMsg := "Ctrl-Canc"
   CASE nMsg == MSG_ACTINT131      ; cMsg := "Ctrl-Tab"
   CASE nMsg == MSG_ACTINT132      ; cMsg := "Ctrl-Slash"
   CASE nMsg == MSG_ACTINT133      ; cMsg := "Alt-Home"
   CASE nMsg == MSG_ACTINT134      ; cMsg := "Alt-Flecha arriba"
   CASE nMsg == MSG_ACTINT135      ; cMsg := "Alt-Pag.arriba"
   CASE nMsg == MSG_ACTINT136      ; cMsg := "Alt Flecha izquierda"
   CASE nMsg == MSG_ACTINT137      ; cMsg := "Alt-Flecha derecha"
   CASE nMsg == MSG_ACTINT138      ; cMsg := "Alt-Fin"
   CASE nMsg == MSG_ACTINT139      ; cMsg := "Alt-Flecha abajo"
   CASE nMsg == MSG_ACTINT140      ; cMsg := "Alt-Pag. abajo"
   CASE nMsg == MSG_ACTINT141      ; cMsg := "Alt-Ins"
   CASE nMsg == MSG_ACTINT142      ; cMsg := "Alt-Canc"
   CASE nMsg == MSG_ACTINT143      ; cMsg := "Alt-Tab"
   //   nMsg == MSG_ACTINT144      ; cMsg := "Ctrl-F"
   CASE nMsg == MSG_ACTINT145      ; cMsg := "Ctrl-Backslash"
   CASE nMsg == MSG_ACTINT146      ; cMsg := "Ctrl-Space"
   CASE nMsg == MSG_ACTINT147      ; cMsg := "Alt-Space"
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
   CASE nMsg == MSG_ADDMENUUND     ; cMsg := "Acci•n desconocida !"
   CASE nMsg == MSG_ATTBUTUND      ; cMsg := "Funci•n desconocida !"
   CASE nMsg == MSG_FORMESC        ; cMsg := "Fin de las operaciones"
   CASE nMsg == MSG_FORMWRI        ; cMsg := "Confirma de los datos"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INFO01         ; cMsg := "Sint…xis:"
   CASE nMsg == MSG_INFO02         ; cMsg := "[Opciones] [Inifile.ext]"
   CASE nMsg == MSG_INFO03         ; cMsg := "Opciones:  /?|/h = Este help"
   CASE nMsg == MSG_INFO04         ; cMsg := "           /UPD  = Controla la BASE DATOS de la aplicaci•n"
   CASE nMsg == MSG_INFO05         ; cMsg := "Inifile.ext:   Nombre del archivo INI de configuraci•n"
   CASE nMsg == MSG_INFO06         ; cMsg := "               El nombre de default es DBSTART.INI"
   CASE nMsg == MSG_INFO07         ; cMsg := "           /FAST = Fast Mouse reset"
   CASE nMsg == MSG_INFO08         ; cMsg := "Programa Generado con Visual dBsee  %VER% the STANDARD CASE for Xbase++"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFISPIRATE01   ; cMsg := "Program currently free//Make the protection"
   CASE nMsg == MSG_DFISPIRATE02   ; cMsg := "Problems during the protection"
   CASE nMsg == MSG_DFISPIRATE03   ; cMsg := "Progeam currently free//You must protect the program"
   CASE nMsg == MSG_DFISPIRATE04   ; cMsg := "Illegal copy of the program//contact the technical support"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCFGPAL01     ; cMsg := "The colors are changed//do you want to save"
   CASE nMsg == MSG_DFCFGPAL02     ; cMsg := "Waiting ..."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_AS40001        ; cMsg := "Server Name : "
   CASE nMsg == MSG_AS40002        ; cMsg := "AS/400 Connection"
   CASE nMsg == MSG_AS40003        ; cMsg := "Connection Error//Check the W400ENV environment setting"
   CASE nMsg == MSG_AS40004        ; cMsg := "Check archivo (%FILE%)"
   CASE nMsg == MSG_AS40005        ; cMsg := "Nombre de la libreria de configuracion : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFDATEFT01     ; cMsg := "De fecha :"
   CASE nMsg == MSG_DFDATEFT02     ; cMsg := "A  Fecha :"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPRNLAB01     ; cMsg := "Etiqueta por lineas"
   CASE nMsg == MSG_DFPRNLAB02     ; cMsg := "Etiqueta por espacio"
   CASE nMsg == MSG_DFPRNLAB03     ; cMsg := "Largo de la etiqueta"
   CASE nMsg == MSG_DFPRNLAB04     ; cMsg := "Etiqueta"
   CASE nMsg == MSG_DFPRNLAB05     ; cMsg := "Funcion que se aplica"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCOL2PRN01    ; cMsg := "Columna a Imprimir"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCHKDBF01     ; cMsg := "Encabezado de el Archivo//"
   CASE nMsg == MSG_DFCHKDBF02     ; cMsg := "//Tienes un numero de records equivocado"
   CASE nMsg == MSG_DFCHKDBF03     ; cMsg := "//Header setting   : "
   CASE nMsg == MSG_DFCHKDBF04     ; cMsg := "//Real setting     : "
   CASE nMsg == MSG_DFCHKDBF05     ; cMsg := "//Correct the error ?"
   CASE nMsg == MSG_DFCHKDBF06     ; cMsg := "////Se no te pone al dia el indice "
   CASE nMsg == MSG_DFCHKDBF07     ; cMsg := "//tu puede destrozar algunos datos cuando tu pediras la reconstruccion de el indice"
   CASE nMsg == MSG_DFCHKDBF08     ; cMsg := "//RECUERDA : Hacer el BACKUP antes de poner al dia el database"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDFILEST01     ; cMsg := "Eligir Campo Estadistico"
   CASE nMsg == MSG_DDFILEST02     ; cMsg := "Otros"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFFILEDLG01    ; cMsg := "^Path"
   CASE nMsg == MSG_DFFILEDLG02    ; cMsg := "^Tree"
   CASE nMsg == MSG_DFFILEDLG03    ; cMsg := "^Unit"
   CASE nMsg == MSG_DFFILEDLG04    ; cMsg := "^WildCard"
   CASE nMsg == MSG_DFFILEDLG05    ; cMsg := "^Files"
   CASE nMsg == MSG_DFFILEDLG06    ; cMsg := "Nombre"
   CASE nMsg == MSG_DFFILEDLG07    ; cMsg := "Dimension"
   CASE nMsg == MSG_DFFILEDLG08    ; cMsg := "Fecha"
   CASE nMsg == MSG_DFFILEDLG09    ; cMsg := "Tiempo"
   CASE nMsg == MSG_DFFILEDLG10    ; cMsg := "Archivo Dialog"
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
