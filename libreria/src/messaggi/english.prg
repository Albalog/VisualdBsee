// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Description    : Library messages
// *****************************************************************************
#include "dfMsg.ch"
#include "dfState.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStdMsg( nMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cMsg := ""
DO CASE
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_LANGUAGE       ; cMsg := "ENGLISH"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INITERROR      ; cMsg := "Unable to open Init File"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_STD_YES        ; cMsg := "^Yes"
   CASE nMsg == MSG_STD_NO         ; cMsg := "^No"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TABGET01       ; cMsg := "No reference in dbDD//Field "
   CASE nMsg == MSG_TABGET02       ; cMsg := " not found "
   CASE nMsg == MSG_TABGET03       ; cMsg := "Error opening DBDD.DBF"
   CASE nMsg == MSG_TABGET04       ; cMsg := "Error opening DBTABD.DBF"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TABCHK01       ; cMsg := "Window on "
   CASE nMsg == MSG_TABCHK02       ; cMsg := " not available!//"
   CASE nMsg == MSG_TABCHK03       ; cMsg := "File: "
   CASE nMsg == MSG_TABCHK04       ; cMsg := " is empty !"
   CASE nMsg == MSG_TABCHK05       ; cMsg := "Can not leave empty field//("
   CASE nMsg == MSG_TABCHK06       ; cMsg := "Field//("
   CASE nMsg == MSG_TABCHK07       ; cMsg := ")//value://"
   CASE nMsg == MSG_TABCHK08       ; cMsg := "not in file: "
   CASE nMsg == MSG_TABCHK09       ; cMsg := "//insert"
   CASE nMsg == MSG_TABCHK10       ; cMsg := "Field//("
   CASE nMsg == MSG_TABCHK11       ; cMsg := ")//value://"
   CASE nMsg == MSG_TABCHK12       ; cMsg := "not in table"
   CASE nMsg == MSG_TABCHK13       ; cMsg := "Key field of the table"
   CASE nMsg == MSG_TABCHK14       ; cMsg := "not found"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ERRSYS01       ; cMsg := "Invalid function number"
   CASE nMsg == MSG_ERRSYS02       ; cMsg := "File not found"
   CASE nMsg == MSG_ERRSYS03       ; cMsg := "Path not found"
   CASE nMsg == MSG_ERRSYS04       ; cMsg := "Too many open files"
   CASE nMsg == MSG_ERRSYS05       ; cMsg := "Access denied"
   CASE nMsg == MSG_ERRSYS06       ; cMsg := "Insufficient memory"
   CASE nMsg == MSG_ERRSYS07       ; cMsg := "Reserved"
   CASE nMsg == MSG_ERRSYS08       ; cMsg := "Disk is write protected"
   CASE nMsg == MSG_ERRSYS09       ; cMsg := "Unknown command"
   CASE nMsg == MSG_ERRSYS10       ; cMsg := "Write error"
   CASE nMsg == MSG_ERRSYS11       ; cMsg := "Read error"
   CASE nMsg == MSG_ERRSYS12       ; cMsg := "General failure"
   //   nMsg == MSG_ERRSYS13       ; cMsg := "Access denied"
   CASE nMsg == MSG_ERRSYS14       ; cMsg := "File already exists"
   CASE nMsg == MSG_ERRSYS15       ; cMsg := "This error has been saved in file :"
   CASE nMsg == MSG_ERRSYS16       ; cMsg := "Press any key to continue..."
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
   CASE nMsg == MSG_ERRSYS29       ; cMsg := "Drive not ready"
   CASE nMsg == MSG_ERRSYS30       ; cMsg := "Data error (CRC)"
   CASE nMsg == MSG_ERRSYS31       ; cMsg := "Bad request structure length"
   CASE nMsg == MSG_ERRSYS32       ; cMsg := "Seek error"
   CASE nMsg == MSG_ERRSYS33       ; cMsg := "Unknown media type"
   CASE nMsg == MSG_ERRSYS34       ; cMsg := "Sector not found"
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
   CASE nMsg == MSG_ERRSYS70       ; cMsg := "Quit"
   CASE nMsg == MSG_ERRSYS71       ; cMsg := "Retry"
   CASE nMsg == MSG_ERRSYS72       ; cMsg := "Default"
   CASE nMsg == MSG_ERRSYS73       ; cMsg := "DOS Error :="
   CASE nMsg == MSG_ERRSYS74       ; cMsg := "Break"
   CASE nMsg == MSG_ERRSYS75       ; cMsg := "Called from"
   CASE nMsg == MSG_ERRSYS76       ; cMsg := "Error "
   CASE nMsg == MSG_ERRSYS77       ; cMsg := "Warning "
   CASE nMsg == MSG_ERRSYS78       ; cMsg := "UNKNOW"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBPATH01       ; cMsg := "Reading path : @"
   CASE nMsg == MSG_DBPATH02       ; cMsg := "Variable name does not exist"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDUSE01        ; cMsg := "File does not exist:"
   CASE nMsg == MSG_DDUSE02        ; cMsg := "Opening file :"
   CASE nMsg == MSG_DDUSE03        ; cMsg := "Error in variable name: "
   CASE nMsg == MSG_DDUSE04        ; cMsg := "Unknown mode!"
   CASE nMsg == MSG_DDUSE05        ; cMsg := "File index :"
   //   nMsg == MSG_DDUSE06        ; cMsg := "Error in variable name: "
   CASE nMsg == MSG_DDUSE07        ; cMsg := "Error opening file"
   CASE nMsg == MSG_DDUSE08        ; cMsg := "Unable to open file"
   CASE nMsg == MSG_DDUSE09        ; cMsg := "Timeout :"
   CASE nMsg == MSG_DDUSE10        ; cMsg := "Index not found"
   CASE nMsg == MSG_DDUSE11        ; cMsg := "Unable to open file %file%. The file is used by other users.//Please try again later."
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBMSGERR       ; cMsg := "OK"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DE_STATE_INK   ; cMsg := "іViewі"
   CASE nMsg == MSG_DE_STATE_ADD   ; cMsg := "іInsertі"
   CASE nMsg == MSG_DE_STATE_MOD   ; cMsg := "іModifyі"
   CASE nMsg == MSG_DE_STATE_DEL   ; cMsg := "іDeleteі"
   CASE nMsg == MSG_DE_STATE_COPY  ; cMsg := "іCopyі"
   CASE nMsg == MSG_DE_STATE_QRY   ; cMsg := "іQueryі"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBSKIP01       ; cMsg := " is empty !!"
   CASE nMsg == MSG_TBSKIP02       ; cMsg := "Beginning of : "
   CASE nMsg == MSG_TBSKIP03       ; cMsg := "End of : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DE_DEL         ; cMsg := "Confirm RECORD deletion !"
   CASE nMsg == MSG_DE_NOTMOD      ; cMsg := "No records to modify !"
   CASE nMsg == MSG_DE_NOTDEL      ; cMsg := "No records to delete !"
   CASE nMsg == MSG_DE_NOTADD      ; cMsg := "It is not possible to add Record if the head table is empty: "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_NUM2WORD01     ; cMsg := "one"
   CASE nMsg == MSG_NUM2WORD02     ; cMsg := "two"
   CASE nMsg == MSG_NUM2WORD03     ; cMsg := "three"
   CASE nMsg == MSG_NUM2WORD04     ; cMsg := "four"
   CASE nMsg == MSG_NUM2WORD05     ; cMsg := "five"
   CASE nMsg == MSG_NUM2WORD06     ; cMsg := "six"
   CASE nMsg == MSG_NUM2WORD07     ; cMsg := "seven"
   CASE nMsg == MSG_NUM2WORD08     ; cMsg := "eight"
   CASE nMsg == MSG_NUM2WORD09     ; cMsg := "nine"
   CASE nMsg == MSG_NUM2WORD10     ; cMsg := "ten"
   CASE nMsg == MSG_NUM2WORD11     ; cMsg := "eleven"
   CASE nMsg == MSG_NUM2WORD12     ; cMsg := "twelve"
   CASE nMsg == MSG_NUM2WORD13     ; cMsg := "thirteen"
   CASE nMsg == MSG_NUM2WORD14     ; cMsg := "fourteen"
   CASE nMsg == MSG_NUM2WORD15     ; cMsg := "fifteen"
   CASE nMsg == MSG_NUM2WORD16     ; cMsg := "sixteen"
   CASE nMsg == MSG_NUM2WORD17     ; cMsg := "seventeen"
   CASE nMsg == MSG_NUM2WORD18     ; cMsg := "eightteen"
   CASE nMsg == MSG_NUM2WORD19     ; cMsg := "ninteen"
   CASE nMsg == MSG_NUM2WORD20     ; cMsg := "ten"
   CASE nMsg == MSG_NUM2WORD21     ; cMsg := "twenty"
   CASE nMsg == MSG_NUM2WORD22     ; cMsg := "thirty"
   CASE nMsg == MSG_NUM2WORD23     ; cMsg := "forty"
   CASE nMsg == MSG_NUM2WORD24     ; cMsg := "fifty"
   CASE nMsg == MSG_NUM2WORD25     ; cMsg := "sixty"
   CASE nMsg == MSG_NUM2WORD26     ; cMsg := "seventy"
   CASE nMsg == MSG_NUM2WORD27     ; cMsg := "eighty"
   CASE nMsg == MSG_NUM2WORD28     ; cMsg := "ninety"
   CASE nMsg == MSG_NUM2WORD29     ; cMsg := " billion"
   CASE nMsg == MSG_NUM2WORD30     ; cMsg := " million"
   CASE nMsg == MSG_NUM2WORD31     ; cMsg := " thousand"
   CASE nMsg == MSG_NUM2WORD32     ; cMsg := "zero"
   CASE nMsg == MSG_NUM2WORD33     ; cMsg := "one thousand"
   CASE nMsg == MSG_NUM2WORD34     ; cMsg := "one million"
   CASE nMsg == MSG_NUM2WORD35     ; cMsg := "one billion"
   CASE nMsg == MSG_NUM2WORD36     ; cMsg := "hundred"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_NTXSYS01       ; cMsg := "Rebuilding system index files"
   //   nMsg == MSG_NTXSYS02       ; cMsg := "Deleting index files from disk"
   CASE nMsg == MSG_NTXSYS03       ; cMsg := "Rebuilding dbDD index files"
   CASE nMsg == MSG_NTXSYS04       ; cMsg := "Rebuilding Help index files"
   CASE nMsg == MSG_NTXSYS05       ; cMsg := "Rebuilding Table index files"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_PGLIST01       ; cMsg := "List of pages"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBCFGOPE01     ; cMsg := "Reindexing"
   CASE nMsg == MSG_DBCFGOPE02     ; cMsg := "Unable to open system files"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_HLP01          ; cMsg := "^Next"
   CASE nMsg == MSG_HLP02          ; cMsg := "P^revious"
   CASE nMsg == MSG_HLP03          ; cMsg := "^Menu"
   CASE nMsg == MSG_HLP04          ; cMsg := "^File"
   CASE nMsg == MSG_HLP05          ; cMsg := "^Info"
   CASE nMsg == MSG_HLP06          ; cMsg := "^System"
   CASE nMsg == MSG_HLP07          ; cMsg := "S^ummary"
   CASE nMsg == MSG_HLP08          ; cMsg := "^Previous"
   CASE nMsg == MSG_HLP09          ; cMsg := "F^ind"
   CASE nMsg == MSG_HLP10          ; cMsg := "^File"
   CASE nMsg == MSG_HLP11          ; cMsg := "Print ^Topic"
   CASE nMsg == MSG_HLP12          ; cMsg := "^Exit"
   CASE nMsg == MSG_HLP13          ; cMsg := "^Using the guide"
   CASE nMsg == MSG_HLP14          ; cMsg := "String to locate"
   CASE nMsg == MSG_HLP15          ; cMsg := "String not found"
   CASE nMsg == MSG_HLP16          ; cMsg := "Help"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBRID01        ; cMsg := "RESTRICT integrity. Unable to delete RECORD"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_USRHELP01      ; cMsg := "Contextual help not available//"
   CASE nMsg == MSG_USRHELP02      ; cMsg := "in this environment !"
   CASE nMsg == MSG_USRHELP03      ; cMsg := " Available keys "
   CASE nMsg == MSG_USRHELP04      ; cMsg := "Back to previous mask"
   CASE nMsg == MSG_USRHELP05      ; cMsg := "Calculator"
   CASE nMsg == MSG_USRHELP06      ; cMsg := "Exit to operating system"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDINDEX01      ; cMsg := "Reindex files"
   CASE nMsg == MSG_DDINDEX02      ; cMsg := "^Global"
   CASE nMsg == MSG_DDINDEX03      ; cMsg := "^Partial"
   CASE nMsg == MSG_DDINDEX04      ; cMsg := "^System files"
   CASE nMsg == MSG_DDINDEX05      ; cMsg := "  Index    іRecordіExpression"
   CASE nMsg == MSG_DDINDEX06      ; cMsg := "Reindex files"
   CASE nMsg == MSG_DDINDEX07      ; cMsg := " with PACK"
   CASE nMsg == MSG_DDINDEX08      ; cMsg := "Select INDEX file to rebuild. Enter=Accept ! "
   CASE nMsg == MSG_DDINDEX09      ; cMsg := "PAUSING - Press any key to resume - PAUSING"
   CASE nMsg == MSG_DDINDEX10      ; cMsg := "Space=Pause і Reindexing files !"
   CASE nMsg == MSG_DDINDEX11      ; cMsg := "...Packing file ("
   CASE nMsg == MSG_DDINDEX12      ; cMsg := ") in progress !..."
   CASE nMsg == MSG_DDINDEX13      ; cMsg := "Index of file :"
   CASE nMsg == MSG_DDINDEX14      ; cMsg := "Error in variable name :"
   CASE nMsg == MSG_DDINDEX15      ; cMsg := "^Check"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDINDEXFL01    ; cMsg := "Index file :"
   CASE nMsg == MSG_DDINDEXFL02    ; cMsg := "Error in variable name :"
   CASE nMsg == MSG_DDINDEXFL03    ; cMsg := "PACK file :"
   CASE nMsg == MSG_DDINDEXFL04    ; cMsg := " in progress "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDWIN01        ; cMsg := "Window "
   CASE nMsg == MSG_DDWIN02        ; cMsg := "//Not available !"
   CASE nMsg == MSG_DDWIN03        ; cMsg := "Nothing to delete !"
   CASE nMsg == MSG_DDWIN04        ; cMsg := "DELETE CURRENT ELELEMT"
   CASE nMsg == MSG_DDWIN05        ; cMsg := "Nothing to modify !"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   //   nMsg == MSG_DFAUTOFORM01   ; cMsg := "^Accept"
   CASE nMsg == MSG_DFAUTOFORM01   ; cMsg := "  O^k  "
   CASE nMsg == MSG_DFAUTOFORM02   ; cMsg := "Ca^ncel"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCOLOR01      ; cMsg := "Label Color"
   CASE nMsg == MSG_DFCOLOR02      ; cMsg := "Not found"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFALERT01      ; cMsg := "Press any key to continue..."
   CASE nMsg == MSG_DFALERT02      ; cMsg := "Press one of the indicated keys"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFMEMO01       ; cMsg := "Accept key"
   CASE nMsg == MSG_DFMEMO02       ; cMsg := "Read from disk"
   CASE nMsg == MSG_DFMEMO03       ; cMsg := "Write to disk"
   CASE nMsg == MSG_DFMEMO05       ; cMsg := "Reset total"
   CASE nMsg == MSG_DFMEMO06       ; cMsg := "Sum to total"
   CASE nMsg == MSG_DFMEMO07       ; cMsg := "Display total"
   CASE nMsg == MSG_DFMEMO08       ; cMsg := "Paste total to text"
   CASE nMsg == MSG_DFMEMO09       ; cMsg := "Solve expression putting result behind"
   CASE nMsg == MSG_DFMEMO10       ; cMsg := "Solve expression overwriting with result"
   CASE nMsg == MSG_DFMEMO11       ; cMsg := "File to read"
   CASE nMsg == MSG_DFMEMO12       ; cMsg := "Reading Memo from disk"
   CASE nMsg == MSG_DFMEMO13       ; cMsg := "Automatic computed total. Summed values :"
   CASE nMsg == MSG_DFMEMO14       ; cMsg := "Total obtained by calculator//"
   //   nMsg == MSG_DFMEMO15       ; cMsg := "Automatic computed total. Summed values :"
   CASE nMsg == MSG_DFMEMO16       ; cMsg := "Unable to find beginning of expression !"
   CASE nMsg == MSG_DFMEMO17       ; cMsg := "Quit without saving changes"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFQRY01        ; cMsg := "Less than"
   CASE nMsg == MSG_DFQRY02        ; cMsg := "Greater than"
   CASE nMsg == MSG_DFQRY03        ; cMsg := "Less than or equal to"
   CASE nMsg == MSG_DFQRY04        ; cMsg := "Greater than or equal to"
   CASE nMsg == MSG_DFQRY05        ; cMsg := "Equal to"
   CASE nMsg == MSG_DFQRY06        ; cMsg := "Not equal to"
   CASE nMsg == MSG_DFQRY07        ; cMsg := "Contains"
   CASE nMsg == MSG_DFQRY08        ; cMsg := "is contained in"
   CASE nMsg == MSG_DFQRY09        ; cMsg := "Exactly equal to"
   CASE nMsg == MSG_DFQRY10        ; cMsg := "true"
   CASE nMsg == MSG_DFQRY11        ; cMsg := "false"
   CASE nMsg == MSG_DFQRY12        ; cMsg := " and "
   CASE nMsg == MSG_DFQRY13        ; cMsg := " or "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_VALID01        ; cMsg := "Can not leave field empty"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINI01        ; cMsg := "Reports a different version"
   CASE nMsg == MSG_DFINI02        ; cMsg := "Regenerate DBSTART.INI by Visual dBsee"
   CASE nMsg == MSG_DFINI03        ; cMsg := "Loading actions"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFFILE2PRN01   ; cMsg := "Printer not ready//Retry"
   CASE nMsg == MSG_DFFILE2PRN02   ; cMsg := "Printing..."
   CASE nMsg == MSG_DFFILE2PRN03   ; cMsg := "Printing halted"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFNET01        ; cMsg := "Unable to lock File :"
   CASE nMsg == MSG_DFNET02        ; cMsg := "Unable to lock Record n§. %2%"
   CASE nMsg == MSG_DFNET03        ; cMsg := "Unable to append Record"
   //   nMsg == MSG_DFNET04        ; cMsg := "UNKNOWN FUNCTION !!"
   //   nMsg == MSG_DFNET05        ; cMsg := "Time out: "
   CASE nMsg == MSG_DFNET06        ; cMsg := "Lock attempt"
   CASE nMsg == MSG_DFNET07        ; cMsg := "Seconds"
   CASE nMsg == MSG_DFNET08        ; cMsg := "Lock File :"
   CASE nMsg == MSG_DFNET09        ; cMsg := "Using semaphore"
   CASE nMsg == MSG_DFNET10        ; cMsg := "Unable to find"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFMEMOWRI01    ; cMsg := "File to write : "
   CASE nMsg == MSG_DFMEMOWRI02    ; cMsg := "Enter file name.іF10=AcceptіEsc=Abort"
   CASE nMsg == MSG_DFMEMOWRI03    ; cMsg := "Writing memo to disk"
   CASE nMsg == MSG_DFMEMOWRI04    ; cMsg := "File already exists. Overwrite ?"
   //   nMsg == MSG_DFMEMOWRI05    ; cMsg := "File "
   //   nMsg == MSG_DFMEMOWRI06    ; cMsg := " has been written !"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPATH01    ; cMsg := "Loading application paths"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIFONT01    ; cMsg := "Loading fonts"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPRN01     ; cMsg := "Loading printers"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPROGIND01    ; cMsg := "Abort"
   CASE nMsg == MSG_DFPROGIND02    ; cMsg := "Are you sure you want to interrupt"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBLOOK01       ; cMsg := "Unable to leave field//"
   CASE nMsg == MSG_DBLOOK02       ; cMsg := "empty"
   CASE nMsg == MSG_DBLOOK03       ; cMsg := "Warning: //"
   CASE nMsg == MSG_DBLOOK04       ; cMsg := "//does not exist !!"
   CASE nMsg == MSG_DBLOOK05       ; cMsg := "Warning: code//"
   CASE nMsg == MSG_DBLOOK06       ; cMsg := "//not in file"
   CASE nMsg == MSG_DBLOOK07       ; cMsg := "//insert now"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABDE01      ; cMsg := "Table files"
   CASE nMsg == MSG_DFTABDE02      ; cMsg := "Tables"
   CASE nMsg == MSG_DFTABDE03      ; cMsg := "Modify"
   CASE nMsg == MSG_DFTABDE04      ; cMsg := "No Table files in application"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DBINK01        ; cMsg := "Keyboard time out"
   CASE nMsg == MSG_DBINK02        ; cMsg := "Seconds"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   //   nMsg == MSG_DFINIPP01      ; cMsg := "Loading printer ports"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIPOR01     ; cMsg := "Loading ports"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFGET01        ; cMsg := "Leave mask"
   CASE nMsg == MSG_DFGET02        ; cMsg := "Save mask"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBBRWNEW01     ; cMsg := "Restore original window size"
   CASE nMsg == MSG_TBBRWNEW02     ; cMsg := "Move window"
   CASE nMsg == MSG_TBBRWNEW03     ; cMsg := "Resize window"
   CASE nMsg == MSG_TBBRWNEW04     ; cMsg := "Reduce window to minimum allowed size"
   CASE nMsg == MSG_TBBRWNEW05     ; cMsg := "Enlarge window to maximum allowed size"
   CASE nMsg == MSG_TBBRWNEW06     ; cMsg := "Remove current and associated windows from screen"
   CASE nMsg == MSG_TBBRWNEW07     ; cMsg := "Show list of active pages"
   CASE nMsg == MSG_TBBRWNEW08     ; cMsg := "Next"
   CASE nMsg == MSG_TBBRWNEW09     ; cMsg := "Previous"
   CASE nMsg == MSG_TBBRWNEW10     ; cMsg := "First"
   CASE nMsg == MSG_TBBRWNEW11     ; cMsg := "Last"
   CASE nMsg == MSG_TBBRWNEW12     ; cMsg := "Left"
   CASE nMsg == MSG_TBBRWNEW13     ; cMsg := "Right"
   CASE nMsg == MSG_TBBRWNEW14     ; cMsg := "Page up"
   CASE nMsg == MSG_TBBRWNEW15     ; cMsg := "Page down"
   CASE nMsg == MSG_TBBRWNEW16     ; cMsg := "Freeze/Free columns a left side"
   CASE nMsg == MSG_TBBRWNEW17     ; cMsg := "Enlarge column"
   CASE nMsg == MSG_TBBRWNEW18     ; cMsg := "Reduce column"
   CASE nMsg == MSG_TBBRWNEW19     ; cMsg := "Deselect all"
   CASE nMsg == MSG_TBBRWNEW20     ; cMsg := "Select element"
   CASE nMsg == MSG_TBBRWNEW21     ; cMsg := "Select all"
   CASE nMsg == MSG_TBBRWNEW22     ; cMsg := "Modify current element"
   CASE nMsg == MSG_TBBRWNEW23     ; cMsg := "Next page"
   CASE nMsg == MSG_TBBRWNEW24     ; cMsg := "^Restore"
   CASE nMsg == MSG_TBBRWNEW25     ; cMsg := "^Move"
   CASE nMsg == MSG_TBBRWNEW26     ; cMsg := "Re^size"
   CASE nMsg == MSG_TBBRWNEW27     ; cMsg := "^Iconize"
   CASE nMsg == MSG_TBBRWNEW28     ; cMsg := "M^aximize"
   CASE nMsg == MSG_TBBRWNEW29     ; cMsg := "C^lose"
   CASE nMsg == MSG_TBBRWNEW30     ; cMsg := "^Switch to..."
   CASE nMsg == MSG_TBBRWNEW31     ; cMsg := "Key"
   CASE nMsg == MSG_TBBRWNEW32     ; cMsg := "Previous page"
   CASE nMsg == MSG_TBBRWNEW33     ; cMsg := "Print database"
   CASE nMsg == MSG_TBBRWNEW34     ; cMsg := "Label Print"
   CASE nMsg == MSG_TBBRWNEW35     ; cMsg := "Statistic"
   CASE nMsg == MSG_TBBRWNEW36     ; cMsg := "Select/Unselect row"
   CASE nMsg == MSG_TBBRWNEW37     ; cMsg := "Unselect all"
   CASE nMsg == MSG_TBBRWNEW38     ; cMsg := "Select all"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDGENDBF01     ; cMsg := "File"
   CASE nMsg == MSG_DDGENDBF02     ; cMsg := "without fields"
   CASE nMsg == MSG_DDGENDBF03     ; cMsg := "Creating file"
   CASE nMsg == MSG_DDGENDBF04     ; cMsg := "Attention!!! The Directory not exist:// "
   CASE nMsg == MSG_DDGENDBF05     ; cMsg := "//Create the Directory now?"
   CASE nMsg == MSG_DDGENDBF06     ; cMsg := "Unable to Create the Directory://"
   CASE nMsg == MSG_DDGENDBF07     ; cMsg := "Serious error in Table creation!!!//Operation aborted ...//Table: "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABPRINT01   ; cMsg := "No Table file to print"
   CASE nMsg == MSG_DFTABPRINT02   ; cMsg := "ю Tables ю"
   CASE nMsg == MSG_DFTABPRINT03   ; cMsg := "Print Tables"
   //   nMsg == MSG_DFTABPRINT04   ; cMsg := "Print Tables"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPRNSTART01   ; cMsg := "Error opening file"
   CASE nMsg == MSG_DFPRNSTART02   ; cMsg := "Press enter to print"
   CASE nMsg == MSG_DFPRNSTART03   ; cMsg := "Master file"
   CASE nMsg == MSG_DFPRNSTART04   ; cMsg := "Print to"
   CASE nMsg == MSG_DFPRNSTART05   ; cMsg := "Current printer"
   CASE nMsg == MSG_DFPRNSTART06   ; cMsg := "Printer port"
   CASE nMsg == MSG_DFPRNSTART07   ; cMsg := "Quality"
   CASE nMsg == MSG_DFPRNSTART08   ; cMsg := "Normal"
   CASE nMsg == MSG_DFPRNSTART09   ; cMsg := "High"
   CASE nMsg == MSG_DFPRNSTART10   ; cMsg := "Character"
   CASE nMsg == MSG_DFPRNSTART11   ; cMsg := "Normal"
   CASE nMsg == MSG_DFPRNSTART12   ; cMsg := "Compressed"
   CASE nMsg == MSG_DFPRNSTART13   ; cMsg := "C^hange port"
   CASE nMsg == MSG_DFPRNSTART14   ; cMsg := "^Margins"
   CASE nMsg == MSG_DFPRNSTART15   ; cMsg := "P^rinters"
   CASE nMsg == MSG_DFPRNSTART16   ; cMsg := "Sp^ooler active"
   CASE nMsg == MSG_DFPRNSTART17   ; cMsg := "Cop^ies :"
   CASE nMsg == MSG_DFPRNSTART18   ; cMsg := "^Number of copies"
   CASE nMsg == MSG_DFPRNSTART19   ; cMsg := "^File :"
   CASE nMsg == MSG_DFPRNSTART20   ; cMsg := "Pre^view"
   CASE nMsg == MSG_DFPRNSTART21   ; cMsg := "^Print"
   CASE nMsg == MSG_DFPRNSTART22   ; cMsg := "^Quit"
   CASE nMsg == MSG_DFPRNSTART23   ; cMsg := "Lines per page"
   CASE nMsg == MSG_DFPRNSTART24   ; cMsg := "Top margin"
   CASE nMsg == MSG_DFPRNSTART25   ; cMsg := "Bottom margin"
   CASE nMsg == MSG_DFPRNSTART26   ; cMsg := "Left margin"
   CASE nMsg == MSG_DFPRNSTART27   ; cMsg := "Margins"
   CASE nMsg == MSG_DFPRNSTART28   ; cMsg := "ю Physical ports ю"
   CASE nMsg == MSG_DFPRNSTART29   ; cMsg := "ю Printer ports ю"
   CASE nMsg == MSG_DFPRNSTART30   ; cMsg := "Report without page breaks"
   CASE nMsg == MSG_DFPRNSTART31   ; cMsg := "Nothing to print"
   CASE nMsg == MSG_DFPRNSTART32   ; cMsg := "Report Name"
   CASE nMsg == MSG_DFPRNSTART33   ; cMsg := "Filter Description"
   CASE nMsg == MSG_DFPRNSTART34   ; cMsg := "Filter Expression"
   CASE nMsg == MSG_DFPRNSTART35   ; cMsg := "I^nformation"
   CASE nMsg == MSG_DFPRNSTART36   ; cMsg := "Setup"
   CASE nMsg == MSG_DFPRNSTART37   ; cMsg := "Use Setup ^1"
   CASE nMsg == MSG_DFPRNSTART38   ; cMsg := "Use Setup ^2"
   CASE nMsg == MSG_DFPRNSTART39   ; cMsg := "Use Setup ^3"
   CASE nMsg == MSG_DFPRNSTART40   ; cMsg := "Pa^ges"
   CASE nMsg == MSG_DFPRNSTART41   ; cMsg := "Print All pages"
   //   nMsg == MSG_DFPRNSTART42   ; cMsg := "Print All pages"
   CASE nMsg == MSG_DFPRNSTART43   ; cMsg := "From Page :"
   CASE nMsg == MSG_DFPRNSTART44   ; cMsg := "Print From Page"
   CASE nMsg == MSG_DFPRNSTART45   ; cMsg := "To Page   :"
   CASE nMsg == MSG_DFPRNSTART46   ; cMsg := "Print to page"
   CASE nMsg == MSG_DFPRNSTART47   ; cMsg := "Pages"
   CASE nMsg == MSG_DFPRNSTART48   ; cMsg := "Fi^lter"
   CASE nMsg == MSG_DFPRNSTART49   ; cMsg := "Change current filter"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDDE01         ; cMsg := "Automatic form//"
   CASE nMsg == MSG_DDDE02         ; cMsg := "//not defined !"
   CASE nMsg == MSG_DDDE03         ; cMsg := "Automatic form//"
   CASE nMsg == MSG_DDDE04         ; cMsg := "//Primary key not defined !"
   CASE nMsg == MSG_DDDE05         ; cMsg := "Form "
   CASE nMsg == MSG_DDDE06         ; cMsg := "PRIMARY KEY//"
   CASE nMsg == MSG_DDDE07         ; cMsg := "//Duplicated !"
   CASE nMsg == MSG_DDDE08         ; cMsg := "Mandatory field"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBINK01        ; cMsg := "Current record has been deleted"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBGETKEY01     ; cMsg := "Call search window"
   CASE nMsg == MSG_TBGETKEY02     ; cMsg := "Call search keys"
   //   nMsg == MSG_TBGETKEY03     ; cMsg := "Call search window"
   CASE nMsg == MSG_TBGETKEY04     ; cMsg := "Edit memo"
   CASE nMsg == MSG_TBGETKEY05     ; cMsg := "Select/Deselect value"
   CASE nMsg == MSG_TBGETKEY06     ; cMsg := "Select value"
   CASE nMsg == MSG_TBGETKEY07     ; cMsg := "Press pushbutton"
   CASE nMsg == MSG_TBGETKEY08     ; cMsg := "Increase value"
   CASE nMsg == MSG_TBGETKEY09     ; cMsg := "Decrease value"
   CASE nMsg == MSG_TBGETKEY10     ; cMsg := "Increase value 10 times"
   CASE nMsg == MSG_TBGETKEY11     ; cMsg := "Decrease value 10 times"
   CASE nMsg == MSG_TBGETKEY14     ; cMsg := "Copy"
   CASE nMsg == MSG_TBGETKEY15     ; cMsg := "Paste"
   CASE nMsg == MSG_TBGETKEY16     ; cMsg := "Previous record"
   CASE nMsg == MSG_TBGETKEY17     ; cMsg := "Next Record"
   CASE nMsg == MSG_TBGETKEY18     ; cMsg := "First record"
   CASE nMsg == MSG_TBGETKEY19     ; cMsg := "Last record"
   CASE nMsg == MSG_TBGETKEY20     ; cMsg := "Call the calendar"
   CASE nMsg == MSG_TBGETKEY21     ; cMsg := "Next Date"
   CASE nMsg == MSG_TBGETKEY22     ; cMsg := "Previous Date"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFSVILLEV01    ; cMsg := "Printing halted"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFLOGIN01      ; cMsg := "Unable to open passwords file"
   CASE nMsg == MSG_DFLOGIN02      ; cMsg := "Enter password"
   CASE nMsg == MSG_DFLOGIN03      ; cMsg := "*        ACCESS CODE         *//"
   CASE nMsg == MSG_DFLOGIN04      ; cMsg := "   Already in use in system   //"
   CASE nMsg == MSG_DFLOGIN05      ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД//"
   CASE nMsg == MSG_DFLOGIN06      ; cMsg := "Password"
   CASE nMsg == MSG_DFLOGIN07      ; cMsg := "//has not been found//"
   CASE nMsg == MSG_DFLOGIN08      ; cMsg := "Enter password again"
   CASE nMsg == MSG_DFLOGIN09      ; cMsg := "*      ACCESS DENIED      *//"
   CASE nMsg == MSG_DFLOGIN10      ; cMsg := "    Unauthorized user !    //"
   CASE nMsg == MSG_DFLOGIN11      ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДД"
   CASE nMsg == MSG_DFLOGIN12      ; cMsg := "   Error entering Password    //"
   CASE nMsg == MSG_DFLOGIN13      ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
   CASE nMsg == MSG_DFLOGIN14      ; cMsg := "PASSWORD"
   CASE nMsg == MSG_DFLOGIN15      ; cMsg := "Enter new password"
   CASE nMsg == MSG_DFLOGIN16      ; cMsg := "Re-enter password"
   CASE nMsg == MSG_DFLOGIN17      ; cMsg := "Name  User"
   CASE nMsg == MSG_DFLOGIN18      ; cMsg := "Enter new PASSWORD"
   CASE nMsg == MSG_DFLOGIN19      ; cMsg := "For the new laws on the Privacy //the Password must at least be of 8 characters!"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDWIT01        ; cMsg := "Add element"
   CASE nMsg == MSG_DDWIT02        ; cMsg := "Modify current element"
   CASE nMsg == MSG_DDWIT03        ; cMsg := "Delete current element"
   CASE nMsg == MSG_DDWIT04        ; cMsg := "Search"
   CASE nMsg == MSG_DDWIT05        ; cMsg := "Code "
   CASE nMsg == MSG_DDWIT06        ; cMsg := " does not exist"
   CASE nMsg == MSG_DDWIT07        ; cMsg := "Delete current item"
   CASE nMsg == MSG_DDWIT08        ; cMsg := "Search "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDKEY01        ; cMsg := "No search keys available//- File "
   CASE nMsg == MSG_DDKEY02        ; cMsg := " has no indexes ! -"
   CASE nMsg == MSG_DDKEY03        ; cMsg := "Unable to evaluate search key//"
   CASE nMsg == MSG_DDKEY04        ; cMsg := "Sequential search only active on character fields !"
   CASE nMsg == MSG_DDKEY05        ; cMsg := "Search window"
   CASE nMsg == MSG_DDKEY06        ; cMsg := "Matching string research"
   CASE nMsg == MSG_DDKEY07        ; cMsg := "Window on LookUp file"
   CASE nMsg == MSG_DDKEY08        ; cMsg := "Interactive creation of search key"
   CASE nMsg == MSG_DDKEY09        ; cMsg := "Key: "
   CASE nMsg == MSG_DDKEY10        ; cMsg := "//not found!"
   CASE nMsg == MSG_DDKEY11        ; cMsg := " Press any key to stop "
   CASE nMsg == MSG_DDKEY12        ; cMsg := "//Wait please...//"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDUPDDBF01     ; cMsg := "Updating"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFTABFRM03     ; cMsg := "2ш control. Duplicated code !//Insertion aborted !!"
   CASE nMsg == MSG_DFTABFRM04     ; cMsg := "Error: code duplicated in "
   CASE nMsg == MSG_DFTABFRM05     ; cMsg := "Warning!"
   CASE nMsg == MSG_DFTABFRM06     ; cMsg := "^Already used in"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPK01         ; cMsg := "primary"
   CASE nMsg == MSG_DFPK02         ; cMsg := "unique"
   CASE nMsg == MSG_DFPK03         ; cMsg := "Key "
   CASE nMsg == MSG_DFPK04         ; cMsg := " duplicated !//"
   CASE nMsg == MSG_DFPK05         ; cMsg := " empty !//"
   CASE nMsg == MSG_DFPK06         ; cMsg := "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД//"
   CASE nMsg == MSG_DFPK07         ; cMsg := "        Enter new key !        "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDQRY01        ; cMsg := "and     Ы .AND.Ы"
   CASE nMsg == MSG_DDQRY02        ; cMsg := "or      Ы .OR. Ы"
   CASE nMsg == MSG_DDQRY17        ; cMsg := "bracket Ы  )   Ы"
   CASE nMsg == MSG_DDQRY03        ; cMsg := "Finish  Ы      Ы"
   CASE nMsg == MSG_DDQRY04        ; cMsg := " Is LESS than................ "
   CASE nMsg == MSG_DDQRY05        ; cMsg := " Is GREATER than............. "
   CASE nMsg == MSG_DDQRY06        ; cMsg := " Is LESS than or EQUAL to.... "
   CASE nMsg == MSG_DDQRY07        ; cMsg := " Is GREATER than or EQUAL to. "
   CASE nMsg == MSG_DDQRY08        ; cMsg := " Is EQUAL to................. "
   CASE nMsg == MSG_DDQRY09        ; cMsg := " Is NOT EQUAL to............. "
   CASE nMsg == MSG_DDQRY10        ; cMsg := " Is CONTAINED IN............. "
   CASE nMsg == MSG_DDQRY11        ; cMsg := " CONTAINS.................... "
   CASE nMsg == MSG_DDQRY12        ; cMsg := "Fields of file"
   CASE nMsg == MSG_DDQRY13        ; cMsg := "Conditions"
   CASE nMsg == MSG_DDQRY14        ; cMsg := "Logical links"
   CASE nMsg == MSG_DDQRY15        ; cMsg := "іFilter OKі"
   CASE nMsg == MSG_DDQRY16        ; cMsg := "іBAD filterі"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_TBGET01        ; cMsg := "Space=Modify і "
   CASE nMsg == MSG_TBGET02        ; cMsg := "F10=Save і "
   CASE nMsg == MSG_TBGET03        ; cMsg := "The value entered is incorrect"
   CASE nMsg == MSG_TBGET04        ; cMsg := "Unable to edit CONTROL"
   CASE nMsg == MSG_TBGET05        ; cMsg := "The Data has Changed"
   CASE nMsg == MSG_TBGET06        ; cMsg := "^Save"
   CASE nMsg == MSG_TBGET07        ; cMsg := "^Quit"
   CASE nMsg == MSG_TBGET08        ; cMsg := "^Continue"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFSTA01        ; cMsg := "Elapsed time"
   CASE nMsg == MSG_DFSTA02        ; cMsg := "Estimated time"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFINIREP01     ; cMsg := "Loading report definition"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCALC01       ; cMsg := "Sum"
   CASE nMsg == MSG_DFCALC02       ; cMsg := "Multiply"
   CASE nMsg == MSG_DFCALC03       ; cMsg := "Subtract"
   CASE nMsg == MSG_DFCALC04       ; cMsg := "Divide"
   CASE nMsg == MSG_DFCALC06       ; cMsg := "Add"
   CASE nMsg == MSG_DFCALC07       ; cMsg := "On"
   CASE nMsg == MSG_DFCALC08       ; cMsg := "Off"
   CASE nMsg == MSG_DFCALC09       ; cMsg := "Exit and paste"
   CASE nMsg == MSG_DFCALC10       ; cMsg := "Conversion from LIRE to EURO"
   CASE nMsg == MSG_DFCALC11       ; cMsg := "Conversion from EURO to LIRE"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INTCOL01       ; cMsg := "Black"
   CASE nMsg == MSG_INTCOL02       ; cMsg := "Dark grey"
   CASE nMsg == MSG_INTCOL03       ; cMsg := "Bright grey"
   CASE nMsg == MSG_INTCOL04       ; cMsg := "Dark blue"
   CASE nMsg == MSG_INTCOL05       ; cMsg := "Blue"
   CASE nMsg == MSG_INTCOL06       ; cMsg := "Bright blue"
   CASE nMsg == MSG_INTCOL07       ; cMsg := "Dark green"
   CASE nMsg == MSG_INTCOL08       ; cMsg := "Green"
   CASE nMsg == MSG_INTCOL09       ; cMsg := "Bright green"
   CASE nMsg == MSG_INTCOL10       ; cMsg := "Dark red"
   CASE nMsg == MSG_INTCOL11       ; cMsg := "Red"
   CASE nMsg == MSG_INTCOL12       ; cMsg := "Bright red"
   CASE nMsg == MSG_INTCOL13       ; cMsg := "Dark yellow"
   CASE nMsg == MSG_INTCOL14       ; cMsg := "Yellow"
   CASE nMsg == MSG_INTCOL15       ; cMsg := "Bright yellow"
   CASE nMsg == MSG_INTCOL16       ; cMsg := "White"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INTPRN01       ; cMsg := "Generic text (without ESCape sequences)"
   //   nMsg == MSG_INTPRN02       ; cMsg := "EPSON FX-80"
   //   nMsg == MSG_INTPRN03       ; cMsg := "HP LASERJET PLUS"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ACTINT001      ; cMsg := "Home"
   CASE nMsg == MSG_ACTINT002      ; cMsg := "Ctrl+RightArrow"
   CASE nMsg == MSG_ACTINT003      ; cMsg := "PageDn"
   CASE nMsg == MSG_ACTINT004      ; cMsg := "RightArrow"
   CASE nMsg == MSG_ACTINT005      ; cMsg := "UpArrow"
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
   CASE nMsg == MSG_ACTINT019      ; cMsg := "Ctrl+Enter"
   CASE nMsg == MSG_ACTINT020      ; cMsg := "Enter"
   CASE nMsg == MSG_ACTINT021      ; cMsg := "PageUp"
   CASE nMsg == MSG_ACTINT022      ; cMsg := "LeftArrow"
   CASE nMsg == MSG_ACTINT023      ; cMsg := "Ins"
   CASE nMsg == MSG_ACTINT024      ; cMsg := "Ctrl+End"
   CASE nMsg == MSG_ACTINT025      ; cMsg := "DownArrow"
   CASE nMsg == MSG_ACTINT026      ; cMsg := "Ctrl+LeftArrow"
   CASE nMsg == MSG_ACTINT027      ; cMsg := "Esc"
   CASE nMsg == MSG_ACTINT028      ; cMsg := "F1"
   CASE nMsg == MSG_ACTINT029      ; cMsg := "Ctrl+Home"
   CASE nMsg == MSG_ACTINT030      ; cMsg := "Ctrl+PageUp"
   CASE nMsg == MSG_ACTINT031      ; cMsg := "Ctrl+PageDn"
   CASE nMsg == MSG_ACTINT032      ; cMsg := "Space"
   //   nMsg == MSG_ACTINT033      ; cMsg := "+"
   //   nMsg == MSG_ACTINT034      ; cMsg := "-"
   //   nMsg == MSG_ACTINT035      ; cMsg := "<"
   //   nMsg == MSG_ACTINT036      ; cMsg := ">"
   //   nMsg == MSG_ACTINT037      ; cMsg := "Shft+F1"
   //   nMsg == MSG_ACTINT038      ; cMsg := "Shft+F2"
   //   nMsg == MSG_ACTINT039      ; cMsg := "Shft+F3"
   //   nMsg == MSG_ACTINT040      ; cMsg := "Shft+F4"
   //   nMsg == MSG_ACTINT041      ; cMsg := "Shft+F5"
   //   nMsg == MSG_ACTINT042      ; cMsg := "Shft+F6"
   //   nMsg == MSG_ACTINT043      ; cMsg := "Shft+F7"
   //   nMsg == MSG_ACTINT044      ; cMsg := "Shft+F8"
   //   nMsg == MSG_ACTINT045      ; cMsg := "Shft+F9"
   //   nMsg == MSG_ACTINT046      ; cMsg := "Shft+F10"
   //   nMsg == MSG_ACTINT047      ; cMsg := "Ctrl+F1"
   //   nMsg == MSG_ACTINT048      ; cMsg := "Ctrl+F2"
   //   nMsg == MSG_ACTINT049      ; cMsg := "Ctrl+F3"
   //   nMsg == MSG_ACTINT050      ; cMsg := "Ctrl+F4"
   //   nMsg == MSG_ACTINT051      ; cMsg := "Ctrl+F5"
   //   nMsg == MSG_ACTINT052      ; cMsg := "Ctrl+F6"
   //   nMsg == MSG_ACTINT053      ; cMsg := "Ctrl+F7"
   //   nMsg == MSG_ACTINT054      ; cMsg := "Ctrl+F8"
   //   nMsg == MSG_ACTINT055      ; cMsg := "Ctrl+F9"
   //   nMsg == MSG_ACTINT056      ; cMsg := "Ctrl+F10"
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
   CASE nMsg == MSG_ACTINT067      ; cMsg := "Ctrl+BackSpace"
   CASE nMsg == MSG_ACTINT068      ; cMsg := "Alt+Esc"
   CASE nMsg == MSG_ACTINT069      ; cMsg := "Alt+BackSpace"
   CASE nMsg == MSG_ACTINT070      ; cMsg := "Shift+Tab"
   CASE nMsg == MSG_ACTINT071      ; cMsg := "Alt+Q"
   CASE nMsg == MSG_ACTINT072      ; cMsg := "Alt+W"
   CASE nMsg == MSG_ACTINT073      ; cMsg := "Alt+E"
   CASE nMsg == MSG_ACTINT074      ; cMsg := "Alt+R"
   CASE nMsg == MSG_ACTINT075      ; cMsg := "Alt+T"
   CASE nMsg == MSG_ACTINT076      ; cMsg := "Alt+Y"
   CASE nMsg == MSG_ACTINT077      ; cMsg := "Alt+U"
   CASE nMsg == MSG_ACTINT078      ; cMsg := "Alt+I"
   CASE nMsg == MSG_ACTINT079      ; cMsg := "Alt+O"
   CASE nMsg == MSG_ACTINT080      ; cMsg := "Alt+P"
   CASE nMsg == MSG_ACTINT081      ; cMsg := "Alt+Љ"
   CASE nMsg == MSG_ACTINT082      ; cMsg := "Alt+"
   CASE nMsg == MSG_ACTINT083      ; cMsg := "Alt+Enter"
   CASE nMsg == MSG_ACTINT084      ; cMsg := "Alt+A"
   CASE nMsg == MSG_ACTINT085      ; cMsg := "Alt+S"
   CASE nMsg == MSG_ACTINT086      ; cMsg := "Alt+D"
   CASE nMsg == MSG_ACTINT087      ; cMsg := "Alt+F"
   CASE nMsg == MSG_ACTINT088      ; cMsg := "Alt+G"
   CASE nMsg == MSG_ACTINT089      ; cMsg := "Alt+H"
   CASE nMsg == MSG_ACTINT090      ; cMsg := "Alt+J"
   CASE nMsg == MSG_ACTINT091      ; cMsg := "Alt+K"
   CASE nMsg == MSG_ACTINT092      ; cMsg := "Alt+L"
   CASE nMsg == MSG_ACTINT093      ; cMsg := "Alt+•"
   CASE nMsg == MSG_ACTINT094      ; cMsg := "Alt+…"
   CASE nMsg == MSG_ACTINT095      ; cMsg := "Alt+Backslash"
   CASE nMsg == MSG_ACTINT096      ; cMsg := "Alt+—"
   CASE nMsg == MSG_ACTINT097      ; cMsg := "Alt+Z"
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
   CASE nMsg == MSG_ACTINT117      ; cMsg := "Alt+'"
   CASE nMsg == MSG_ACTINT118      ; cMsg := "Alt+Ќ"
   CASE nMsg == MSG_ACTINT119      ; cMsg := "F11"
   CASE nMsg == MSG_ACTINT120      ; cMsg := "F12"
   //   nMsg == MSG_ACTINT121      ; cMsg := "Shft+F11"
   //   nMsg == MSG_ACTINT122      ; cMsg := "Shft+F12"
   //   nMsg == MSG_ACTINT123      ; cMsg := "Ctrl+F11"
   //   nMsg == MSG_ACTINT124      ; cMsg := "Ctrl+F12"
   //   nMsg == MSG_ACTINT125      ; cMsg := "Alt+F11"
   //   nMsg == MSG_ACTINT126      ; cMsg := "Alt+F12"
   CASE nMsg == MSG_ACTINT127      ; cMsg := "Ctrl+UpArrow"
   CASE nMsg == MSG_ACTINT128      ; cMsg := "Ctrl+DownArrow"
   CASE nMsg == MSG_ACTINT129      ; cMsg := "Ctrl+Ins"
   CASE nMsg == MSG_ACTINT130      ; cMsg := "Ctrl+Del"
   CASE nMsg == MSG_ACTINT131      ; cMsg := "Ctrl+Tab"
   CASE nMsg == MSG_ACTINT132      ; cMsg := "Ctrl+Slash"
   CASE nMsg == MSG_ACTINT133      ; cMsg := "Alt+Home"
   CASE nMsg == MSG_ACTINT134      ; cMsg := "Alt+UpArrow"
   CASE nMsg == MSG_ACTINT135      ; cMsg := "Alt+PageUp"
   CASE nMsg == MSG_ACTINT136      ; cMsg := "Alt+LeftArrow"
   CASE nMsg == MSG_ACTINT137      ; cMsg := "Alt+RightArrow"
   CASE nMsg == MSG_ACTINT138      ; cMsg := "Alt+End"
   CASE nMsg == MSG_ACTINT139      ; cMsg := "Alt+DownArrow"
   CASE nMsg == MSG_ACTINT140      ; cMsg := "Alt+PageDn"
   CASE nMsg == MSG_ACTINT141      ; cMsg := "Alt+Ins"
   CASE nMsg == MSG_ACTINT142      ; cMsg := "Alt+Del"
   CASE nMsg == MSG_ACTINT143      ; cMsg := "Alt+Tab"
   //   nMsg == MSG_ACTINT144      ; cMsg := "Ctrl+F"
   CASE nMsg == MSG_ACTINT145      ; cMsg := "Ctrl+Backslash"
   CASE nMsg == MSG_ACTINT146      ; cMsg := "Ctrl+Space"
   CASE nMsg == MSG_ACTINT147      ; cMsg := "Alt+Space"
   CASE nMsg == MSG_ACTINT148      ; cMsg := "Shft+Del"
   CASE nMsg == MSG_ACTINT149      ; cMsg := "Shft+Ins"
   CASE nMsg == MSG_ACTINT150      ; cMsg := "Alt+?"
   CASE nMsg == MSG_ACTINT151      ; cMsg := "Alt+Shift+Tab"
   //   nMsg == MSG_ACTINT152      ; cMsg := "Ctrl+P"
   CASE nMsg == MSG_ACTINT153      ; cMsg := "Ctrl"
   CASE nMsg == MSG_ACTINT154      ; cMsg := "Alt"
   CASE nMsg == MSG_ACTINT155      ; cMsg := "Shft"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_ADDMENUUND     ; cMsg := "Undefined action !"
   CASE nMsg == MSG_ATTBUTUND      ; cMsg := "Undefined Function !"
   CASE nMsg == MSG_FORMESC        ; cMsg := "Exit"
   CASE nMsg == MSG_FORMWRI        ; cMsg := "Save"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_INFO01         ; cMsg := "Syntax:"
   CASE nMsg == MSG_INFO02         ; cMsg := "[options] [Inifile.ext]"
   CASE nMsg == MSG_INFO03         ; cMsg := "Options:   /?|/h = This info"
   CASE nMsg == MSG_INFO04         ; cMsg := "           /UPD  = Check Application DATA BASE"
   CASE nMsg == MSG_INFO05         ; cMsg := "Inifile.ext:   Name of INI file"
   CASE nMsg == MSG_INFO06         ; cMsg := "               The default name is DBSTART.INI"
   CASE nMsg == MSG_INFO07         ; cMsg := "           /FAST = Fast Mouse reset"
   CASE nMsg == MSG_INFO08         ; cMsg := "Program Generated with Visual dBsee %VER% the STANDARD CASE for Xbase++"
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
   CASE nMsg == MSG_AS40004        ; cMsg := "Check file (%FILE%)"
   CASE nMsg == MSG_AS40005        ; cMsg := "Name of the configuration library : "
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFDATEFT01     ; cMsg := "From date :"
   CASE nMsg == MSG_DFDATEFT02     ; cMsg := "To date :"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFPRNLAB01     ; cMsg := "Label Rows Per Page"
   CASE nMsg == MSG_DFPRNLAB02     ; cMsg := "Lines Per Label"
   CASE nMsg == MSG_DFPRNLAB03     ; cMsg := "Line Length For Each Label"
   CASE nMsg == MSG_DFPRNLAB04     ; cMsg := "Label"
   CASE nMsg == MSG_DFPRNLAB05     ; cMsg := "Functions to apply"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCOL2PRN01    ; cMsg := "Column to print"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DFCHKDBF01     ; cMsg := "The header of file//"
   CASE nMsg == MSG_DFCHKDBF02     ; cMsg := "//has an incorrect number of records"
   CASE nMsg == MSG_DFCHKDBF03     ; cMsg := "//Header setting   : "
   CASE nMsg == MSG_DFCHKDBF04     ; cMsg := "//Real setting     : "
   CASE nMsg == MSG_DFCHKDBF05     ; cMsg := "//Correct the error ?"
   CASE nMsg == MSG_DFCHKDBF06     ; cMsg := "////If you dont' update the index "
   CASE nMsg == MSG_DFCHKDBF07     ; cMsg := "//you can destroy some data when you call a rebuild index"
   CASE nMsg == MSG_DFCHKDBF08     ; cMsg := "//REMEMBER : Make a BACKUP before database update"
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   // ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
   CASE nMsg == MSG_DDFILEST01     ; cMsg := "Choise the statistic field"
   CASE nMsg == MSG_DDFILEST02     ; cMsg := "Other"
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
