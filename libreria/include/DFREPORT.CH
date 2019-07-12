/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                       Standard Report Header                         |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFREPORT_CH
   #define _DFREPORT_CH

   //-------------------------------------------------------------------------
   // Virtual Record Header
   //-------------------------------------------------------------------------
   #define VR_NAME           1       // File Name

   #define VR_COND           2       // Condition
      #define VR_ORDER       2][1       // Order
      #define VR_KEY         2][2       // Key
      #define VR_FILTER      2][3       // Filter
      #define VR_BREAK       2][4       // Break
      #define VR_DEFAULT     2][5       // Default
      #define VR_DEF_ORDER   2][5][1    //         Order
      #define VR_DEF_KEY     2][5][2    //         Key
      #define VR_DEF_FILTER  2][5][3    //         Filter
      #define VR_DEF_BREAK   2][5][4    //         Break

      #define VR_DEF_LEN           4    // Default LEN

   #define VR_EOF_MODE       3       // EOF Mode
      #define VR_RECOVER     1          // Skip Record     <- DEFAULT 1:N
      #define VR_ABORT       2          // ABORT Report
      #define VR_IGNORE      3          // Continue Report <- DEFAULT Normal

   #define VR_EJECT          4       // EJECT After group

   #define VR_CB             5       // Code Block
      #define VR_HEADER      5][1       // Header
      #define VR_ROWHEADER   5][2       // Header Row
      #define VR_BRKHEADER   5][3       // ENABLE EJECT on Header
      #define VR_POSHEADER   5][4       // Header position
      #define VR_CANHEADER   5][5       // Can be printed

      #define VR_BODY        5][6       // Body
      #define VR_ROWBODY     5][7       // Body row
      #define VR_BRKBODY     5][8       // ENABLE EJECT on Body
      #define VR_EJECTBODY   5][9       // EJECT after Body
      #define VR_FILLFUN     5][10      // Fill Function
      #define VR_FLOATBODY   5][11      // Float Body
      #define VR_CANBODY     5][12      // Can be printed
      #define VR_BODY2HEAD   5][13      // Print Head after page Footer
      #define VR_BODY2FOOT   5][14      // Print footer before page Footer
      #define VR_BODYHEAD    5][15      // Header Block
      #define VR_BODYPOSHEAD 5][16      // Header Pos
      #define VR_BODYROWHEAD 5][17      // Header Row
      #define VR_BODYCANHEAD 5][18      // Can be printed
      #define VR_BODYFOOT    5][19      // Footer Block
      #define VR_BODYPOSFOOT 5][20      // Footer Pos
      #define VR_BODYROWFOOT 5][21      // Footer Row
      #define VR_BODYCANFOOT 5][22      // Can be printed

      #define VR_FOOTER      5][23      // Footer
      #define VR_ROWFOOTER   5][24      // Footer row
      #define VR_BRKFOOTER   5][25      // ENABLE EJECT on Footer
      #define VR_POSFOOTER   5][26      // Footer Position
      #define VR_CANFOOTER   5][27      // Can be printed

   #define VR_CALC_CLEAR     6       // Calculated Clear
   #define VR_CALC_ADD       7       // Calculated Add
   #define VR_PRECALC_CLEAR  8       // Precalculated Clear
   #define VR_PRECALC_ADD    9       // Precalculated Add

   #define VR_GRP_ARR       10       // Group
      #define VR_GRP_BLK            1  // Group Block

      #define VR_GRP_HEADER         2  // Group Header
      #define VR_GRP_ROWHEADER      3  // Group Row Header
      #define VR_GRP_BRKHEADER      4  // Group Activate page break on header
      #define VR_GRP_POSHEADER      5  // Header Position
      #define VR_GRP_CANHEADER      6  // Can be printed

      #define VR_GRP_FOOTER         7  // Group Footer
      #define VR_GRP_ROWFOOTER      8  // Group Row Footer
      #define VR_GRP_BRKFOOTER      9  // Group Activate page break on footer
      #define VR_GRP_POSFOOTER     10  // Footer Position
      #define VR_GRP_CANFOOTER     11  // Can be printed

      #define VR_GRP_EJECT         12  // Group EJECT after footer
      #define VR_GRP_PRECALC_CLEAR 13  // Precalculated Clear
      #define VR_GRP_PRECALC_ADD   14  // Precalculated Add
      #define VR_GRP_CALC_CLEAR    15  // Calculated Clear
      #define VR_GRP_COMPARE       16  // Block evaluated

   #define VR_CHILD         11       // File Child

   #define VR_STABLE        12       // File is stable

   #define VR_SKIPARRAY     13       // Skip array of the file
   #define VR_SKIPPOS       14       // Position in the skip array
   //-------------------------------------------------------------------------

   //-------------------------------------------------------------------------
   // Report Configuration         //                           ASSIGNED BY
   //-------------------------------------------------------------------------
   #define REP_ACT_ROW         1   // Actual Row                  DFPRINT
   #define REP_ACT_COL         2   // Actual Column               DFPRINT
   #define REP_ACT_PAGE        3   // Actual Page                 DFPRINT
   #define REP_BAN_ROW         4   // Band Start Row              DFPRINT
   #define REP_IS_FOOTER       5   // IS IN FOOTER                DFPRINT
   #define REP_IS_ABORT        6   // ABORTING REPORT             DFPRINT
   #define REP_IS_BANNER       7   // IS in PAGE BANNER        HEADER/FOOTER
   #define REP_ITEMINPAGE      8   // Item in page                DFPRINT
   #define REP_POSINFILE       9   // Page pos in file            DFPRINT

   #define REP_IS_QUIT        10   // Report in quit              DFSTA
   #define REP_NO_EJECT       11   // Eject                       DFSTA

   #define REP_IS_NLQ         12   // NLQ  ON                     LAYOUT
   #define REP_IS_CONDENSED   13   // Bold ON                     LAYOUT

   #define REP_FNAME          14   // File Name                CONFIGURATION
   #define REP_FHANDLE        15   // File Handle              CONFIGURATION

   #define REP_PAGELENGHT     16   // Max Row                     LAYOUT
   #define REP_FOOTER_LINE    17   // Footer starting line        LAYOUT

   #define REP_SETUP          18   // SETUP                       LAYOUT
   #define REP_RESET          19   // RESET                       LAYOUT
   #define REP_BOLD_ON        20   // Bold ON                     LAYOUT
   #define REP_BOLD_OFF       21   // Bold OFF                    LAYOUT
   #define REP_ENL_ON         22   // Enlarged ON                 LAYOUT
   #define REP_ENL_OFF        23   // Enlarged OFF                LAYOUT
   #define REP_UND_ON         24   // Underline ON                LAYOUT
   #define REP_UND_OFF        25   // Underline OFF               LAYOUT
   #define REP_SUPER_ON       26   // SuperScript ON              LAYOUT
   #define REP_SUPER_OFF      27   // SuperScript OFF             LAYOUT
   #define REP_SUBS_ON        28   // SubScript ON                LAYOUT
   #define REP_SUBS_OFF       29   // SubScript OFF               LAYOUT
   #define REP_COND_ON        30   // Condensed ON                LAYOUT
   #define REP_COND_OFF       31   // Condensed OFF               LAYOUT
   #define REP_ITA_ON         32   // Italic ON                   LAYOUT
   #define REP_ITA_OFF        33   // Italic OFF                  LAYOUT
   #define REP_NLQ_ON         34   // NLQ ON                      LAYOUT
   #define REP_NLQ_OFF        35   // NLQ OFF                     LAYOUT
   #define REP_USER1ON        36   // USER 1 ON                   LAYOUT
   #define REP_USER1OFF       37   // USER 1 OFF                  LAYOUT
   #define REP_USER2ON        38   // USER 2 ON                   LAYOUT
   #define REP_USER2OFF       39   // USER 2 OFF                  LAYOUT
   #define REP_USER3ON        40   // USER 3 ON                   LAYOUT
   #define REP_USER3OFF       41   // USER 3 OFF                  LAYOUT

   #define REP_RB             42   // Block Report Banner       ASSIGNABLE
   #define REP_POSRB          43   // Absolute Banner Position  ASSIGNABLE
   #define REP_ROWRB          44   // Row in Report Banner      ASSIGNABLE
   #define REP_EJECT_RB       45   // Eject on Report Banner    ASSIGNABLE
   #define REP_BANNER_FORMAT  46   // Format Report Banner      ASSIGNABLE
   #define REP_BANNER_INPAGE  47   // Count Report Banner       ASSIGNABLE

   #define REP_PH             48   // Block Page Header         ASSIGNABLE
   #define REP_ROWPH          49   // Row un Page Header        ASSIGNABLE
   #define REP_CANPH          50   // Header Can be printed     ASSIGNABLE

   #define REP_RF             51   // Block Report Footer       ASSIGNABLE
   #define REP_POSRF          52   // Absolute Footer Position  ASSIGNABLE
   #define REP_CANRF          53   // Footer can be Printed     ASSIGNABLE

   #define REP_PF             54   // Block Page Footer         ASSIGNABLE
   #define REP_FLOATPF        55   // PAGE Footer float         ASSIGNABLE
   #define REP_CANPF          56   // Footer Can be printed     ASSIGNABLE

   #define REP_NAME           57   // Report Name               ASSIGNABLE

   #define REP_MGN_TOP        58   // Margin TOP                  LAYOUT
   #define REP_MGN_BOTTOM     59   // Margin BOTTOM               LAYOUT
   #define REP_MGN_LEFT       60   // Margin LEFT                 LAYOUT
   #define REP_COPY           61   // Number of Copy              LAYOUT
   #define REP_SPOOLER        62   // Spooler                     LAYOUT
   #define REP_PRINTERARR     63   // Printer Array               LAYOUT
   #define REP_PRINTERPORT    64   // Printer Port                LAYOUT
   #define REP_QRY_BLOCK      65   // Block of Query Expression   LAYOUT

   #define REP_QRY_DES        66   // Query Description           QUERY
   #define REP_QRY_EXP        67   // Query Expression            QUERY

   #define REP_IS_LAST        68   // Body is LAST               DFPRINT

   #define REP_NO_LAST_EJECT  69   // Disable last Eject        ASSIGNABLE

   #define REP_PRINTERID      70   // Printer ID                ASSIGNABLE

   #define REP_USEUSER1       71   // Report setup with user 1  ASSIGNABLE
   #define REP_USEUSER2       72   // Report setup with user 2  ASSIGNABLE
   #define REP_USEUSER3       73   // Report setup with user 3  ASSIGNABLE

   #define REP_ALLPAGE        74   // Print all pages           ASSIGNABLE
   #define REP_FROMPAGE       75   // Print from page           ASSIGNABLE
   #define REP_TOPAGE         76   // Print to page             ASSIGNABLE

   #define REP_DISABLE        77   // Disable get information   ASSIGNABLE

   #define REP_EMPTYREPORT    78   // Enabled if empty report   ASSIGNABLE

   #define REP_VREC           79   // Virtual Record           CONFIGURATION

   #define REP_NO_PAGE_EJECT  80   // Disable page eject        ASSIGNABLE

   #define REP_ASCII_REPORT   81   // Enable ASCII report       ASSIGNABLE

   // Used in Xbase++ version
   #define REP_XBASEPRINTDISP   82  // Printer output              LAYOUT
   #define REP_XBASEPRINTOBJ    83  // Printer Object              LAYOUT
   #define REP_XBASEPRINTEXTRA  84  // Extra parameter             LAYOUT
   #define REP_XBASEUSERPRNDISP 85  // Extra parameter             LAYOUT
   // Used in Xbase++ version

   #define REP_CARGO            86  // CARGO                     ASSIGNABLE

   // Used in Xbase++ version
   #define REP_XBASEFONT        87  // Extra parameter             LAYOUT
   #define REP_XBASEREPORTTYPE  88  // Report Type             CONFIGURATION
   // Used in Xbase++ version

   #define REP_PDF_PAGE_FORMAT  89  // Pdf Page Format         CONFIGURATION
   #define REP_PDF_ORIENTATION  90  // Pdf Page Orientation    CONFIGURATION

   #define REP_MAX_ROW          91   // Max Row                  DFPRINT
   #define REP_MAX_COL          92   // Max Column               DFPRINT
   #define REP_MAX_PAGE         93   // Max Page                 DFPRINT

   #define REP_EMAIL            94   // Informazioni Email
      #define REP_EMAIL_OBJECT     1   // Email Object 
      #define REP_EMAIL_BODY       2   // Email Body
      #define REP_EMAIL_TO         3   // Email TO
      #define REP_EMAIL_ARRLEN     3   // Email Max element

   #define REP_PAGE_FORMAT      95   // To store Page Format    CONFIGURATION
   #define REP_ORIENTATION      96   // To store Orientation    CONFIGURATION


   #define REP_BUFFER_LEN       96
   //-------------------------------------------------------------------------

   //-------------------------------------------------------------------------
   // Query
   //-------------------------------------------------------------------------
   #define QRY_PAR                  1   // Parentesis
   #define QRY_FIELD                2   // Field
   #define QRY_COND                 3   // Condition
   #define QRY_LINK                 4   // Link
   #define QRY_EXP                  5   // Expression

   #COMMAND ATTACH TO QUERY <aParent> DESCRIPTION <cDes>  ;
                                      [BUFFER    <uBuf>]  ;
                                      [FIELD     <cFie>]  ;
                                      [TYPE      <cType>] ;
                                      [LEN       <nLen>]  ;
                                      [DEC       <nDec>]  ;
                                      [ALIAS     <cAli>]  ;
                                      [RELATION  <cPos>]  ;
                                                          ;
         => AADD( <aParent>, { <cDes>, <cFie>, <uBuf>, <cAli>  ,;
                               <cType>, <nLen>, <nDec>, <cPos> })


   #define AQRY_DESC                1   // Description
   #define AQRY_FIELD               2   // Field
   #define AQRY_BUFFER              3   // Buffer
   #define AQRY_ALIAS               4   // Alias
   #define AQRY_TYPE                5   // Type
   #define AQRY_LEN                 6   // Len
   #define AQRY_DEC                 7   // Decimal
   #define AQRY_RELATION            8   // Relation


   #COMMAND ATTACH TO QUERYEXP <aParent> TYPE       <cDes>  ;
                                         PARAMETER  <cPar>  ;
                                                            ;
         => AADD( <aParent>, { <cDes>, <cPar> } )

   #define ASEQ_TYPE                1   // Type
   #define ASEQ_PARAMETER           2   // Parameter

   //-------------------------------------------------------------------------
   // Attribute
   //-------------------------------------------------------------------------
   #define PRN_NORMAL               0
   #define PRN_BOLD                 1
   #define PRN_ENLARGED             2
   #define PRN_UNDERLINE            4
   #define PRN_SUPERSCRIPT          8
   #define PRN_SUBSCRIPT           16
   #define PRN_CONDENSED           32
   #define PRN_ITALIC              64
   #define PRN_NLQ                128
   #define PRN_USER01             256
   #define PRN_USER02             512
   #define PRN_USER03            1024
   //-------------------------------------------------------------------------

   //-------------------------------------------------------------------------
   // Printing Method
   //-------------------------------------------------------------------------
   #define PRINT_ALL                1
   #define PRINT_CURRENT            2
   //-------------------------------------------------------------------------

   //-------------------------------------------------------------------------
   // Printer Structure
   //-------------------------------------------------------------------------
   #define PRINTER_ID               1
   #define PRINTER_INFO             2
   #define PRINTER_SETUP            3
   #define PRINTER_RESET            4
   #define PRINTER_BOLDON           5
   #define PRINTER_BOLDOFF          6
   #define PRINTER_ENLARGEDON       7
   #define PRINTER_ENLARGEDOFF      8
   #define PRINTER_UNDERLINEON      9
   #define PRINTER_UNDERLINEOFF    10
   #define PRINTER_SUPERSCRIPTON   11
   #define PRINTER_SUPERSCRIPTOFF  12
   #define PRINTER_SUBSCRIPTON     13
   #define PRINTER_SUBSCRIPTOFF    14
   #define PRINTER_CONDENSEDON     15
   #define PRINTER_CONDENSEDOFF    16
   #define PRINTER_ITALICON        17
   #define PRINTER_ITALICOFF       18
   #define PRINTER_NLQON           19
   #define PRINTER_NLQOFF          20
   #define PRINTER_USER01ON        21
   #define PRINTER_USER01OFF       22
   #define PRINTER_USER02ON        23
   #define PRINTER_USER02OFF       24
   #define PRINTER_USER03ON        25
   #define PRINTER_USER03OFF       26
   #define PRINTER_PAGELENGHT      27

   #define PRINTER_LEN             27
   //-------------------------------------------------------------------------

   //-------------------------------------------------------------------------
   // Report preferences
   //-------------------------------------------------------------------------
   #define PRN_PRF_NAME         1
   #define PRN_PRF_VALUE        2
   #define PRN_PRF_PAGELENGHT   2][ 1
   #define PRN_PRF_MGN_TOP      2][ 2
   #define PRN_PRF_MGN_BOTTOM   2][ 3
   #define PRN_PRF_MGN_LEFT     2][ 4
   #define PRN_PRF_CONDENSED    2][ 5
   #define PRN_PRF_NLQ          2][ 6
   #define PRN_PRF_PRINTERID    2][ 7
   #define PRN_PRF_PRINTERPORT  2][ 8
   #define PRN_PRF_USEUSER1     2][ 9
   #define PRN_PRF_USEUSER2     2][10
   #define PRN_PRF_USEUSER3     2][11
   #define PRN_PRF_NO_EJECT     2][12
   #define PRN_PRF_ALLPAGE      2][13
   #define PRN_PRF_FROMPAGE     2][14
   #define PRN_PRF_TOPAGE       2][15
   #define PRN_PRF_COPY         2][16
   #define PRN_PRF_PAGE         2][17
   #define PRN_PRF_ORIENTATION  2][18

   #define PRN_PRF_LEN          18

   #define PRN_PRF_ORIENTATION_LANSCAPE "L"
   #define PRN_PRF_ORIENTATION_VERTICAL "V"


   //-------------------------------------------------------------------------

   //-------------------------------------------------------------------------
   // PrinterMenuMode
   //-------------------------------------------------------------------------
   #define PM_MENU                  1
   #define PM_MESSAGE               2
   #define PM_NUL                   3
   //-------------------------------------------------------------------------

   //-------------------------------------------------------------------------
   // Query Optimizer
   //-------------------------------------------------------------------------
   #define QRY_OPT_DESC      1 // Query description
   #define QRY_OPT_FLTGET    2 // Query filter
   #define QRY_OPT_INDEX     3 // Query,file master, INDEX
   #define QRY_OPT_KEY       4 // Query,file master, KEY
   #define QRY_OPT_FILTER    5 // Query,file master, FILTER
   #define QRY_OPT_BREAK     6 // Query,file master, BREAK
   #define QRY_OPT_STRKEY    7 // Query,file master, KEY   (STRING for DEBUG)
   #define QRY_OPT_STRFILTER 8 // Query,file master, FILTER(STRING for DEBUG)
   #define QRY_OPT_STRBREAK  9 // Query,file master, BREAK (STRING for DEBUG)

   #define QRY_OPT_LEN              9
   //-------------------------------------------------------------------------

   //-------------------------------------------------------------------------
   // Calc/Precalc
   //-------------------------------------------------------------------------
   #define PRN_FILE_LEVEL           0
   #define PRN_PRECALC             .T.
   #define PRN_CALC                .F.

   //-------------------------------------------------------------------------
   // Disable
   //-------------------------------------------------------------------------
   #define PRN_DISABLE_QUALITY         1
   #define PRN_DISABLE_CHARACTER       2
   #define PRN_DISABLE_SETUP           4
   #define PRN_DISABLE_PORT            8
   #define PRN_DISABLE_MARGIN         16
   #define PRN_DISABLE_PRINTER        32
   #define PRN_DISABLE_PAGE           64
   #define PRN_DISABLE_INFO          128
   #define PRN_DISABLE_PREVIEW       256
   #define PRN_DISABLE_SPOOLER       512
   #define PRN_DISABLE_COPY         1024
   #define PRN_DISABLE_FILE         2048
   #define PRN_DISABLE_FILTER       4096

   //-------------------------------------------------------------------------
   // Internal Printer Ports
   //-------------------------------------------------------------------------
   #define PRN_LPT1   1
   #define PRN_LPT2   2
   #define PRN_LPT3   3
   #define PRN_LPT4   4
   #define PRN_LPT5   5
   #define PRN_LPT6   6
   #define PRN_LPT7   7
   #define PRN_LPT8   8
   #define PRN_LPT9   9
   #define PRN_COM1  10
   #define PRN_COM2  11
   #define PRN_COM3  12
   #define PRN_COM4  13

   //-------------------------------------------------------------------------
   // Report Type
   //-------------------------------------------------------------------------
   #define REP_XBASE_RT_DBSEE         "dbs"
   #define REP_XBASE_RT_CRW           "crw"
   #define REP_XBASE_RT_REPORTMANAGER "rmn"
   #define REP_XBASE_RT_LnL           "l&l"          // not implemented
   #define REP_XBASE_RT_RnR           "r&r"          // not implemented


   #include "dfStd.ch"
   #include "dfWin.ch"
   #include "dfSet.ch"

#endif
