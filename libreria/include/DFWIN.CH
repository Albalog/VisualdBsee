/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                      tBrowse  Cargo Structure                        |
   |                      tBColumn Cargo Structure                        |
   |                       SYS Function Parameter                         |
   |                            Inh Parameter                             |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFWIN_CH
   #define _DFWIN_CH

   // -------------------------------------------------------------------------
   // OBJECT definition
   // -------------------------------------------------------------------------
   // Cargo Structure
   #define W_OBJ_BRW                   1       // BROWSE
   #define W_OBJ_FRM                   2       // FORM
   #define W_OBJ_ARRWIN                3       // WINDOW on ARRAY
   #define W_OBJ_ARRAYBOX              4       // LISTBOX (ARRAY)
   #define W_OBJ_BROWSEBOX             5       // LISTBOX (FILE)

   #define W_BG_TOP              W_BORDERGAP[1]
   #define W_BG_LEFT             W_BORDERGAP[2]
   #define W_BG_BOTTOM           W_BORDERGAP[3]
   #define W_BG_RIGHT            W_BORDERGAP[4]
   #define W_RP_TOP              W_RELATIVEPOS[1]
   #define W_RP_LEFT             W_RELATIVEPOS[2]
   #define W_RP_BOTTOM           W_RELATIVEPOS[3]
   #define W_RP_RIGHT            W_RELATIVEPOS[4]
   #define W_MM_ESCAPE            1
   #define W_MM_MOVE              2
   #define W_MM_MINIMIZE          4
   #define W_MM_MAXIMIZE          8
   #define W_MM_VSCROLLBAR       16
   #define W_MM_SIZE             32
   #define W_MM_HSCROLLBAR       64
   #define W_MM_EDIT            128
   #define W_MM_PAGE            256
   #define W_R_CONTROL           W_REFRESH[1]
   #define W_R_GROUP             W_REFRESH[2]
   #define W_BT_NONE              0
   #define W_BT_SIMPLE            1
   #define W_DEF_ORDER           W_DEFAULT[1]
   #define W_DEF_KEY             W_DEFAULT[2]
   #define W_DEF_FILTER          W_DEFAULT[3]
   #define W_DEF_BREAK           W_DEFAULT[4]
   #define W_DEF_STRKEY          W_DEFAULT[5]
   #define W_DEF_STRFILTER       W_DEFAULT[6]
   #define W_DEF_STRBREAK        W_DEFAULT[7]

   // #define W_TITLE             title


   // Windows Object Event
   #define WO_EVENT_ACTIVATE   1
   #define WO_EVENT_INKEY      2
   #define WO_EVENT_EXIT       3

   // Windows Object Close
   #define W_OC_RESTORE       "r"
   #define W_OC_DESTROY       "d"

   // Windows Object Position
   #define W_POSITIONTOP       1
   #define W_POSITIONBOTTOM    2

   // Optimization methods
   #define W_OPT_NOOPT         0
   #define W_OPT_FILTER        1
   #define W_OPT_INDEX         2
   #define W_OPT_SUBSET        3

   // Coordinate Type
   #define W_COORDINATE_PIXEL       1
   #define W_COORDINATE_ROW_COLUMN  2

   // Menu Style
   #define W_MENU_STYLE_SYSTEM         0
   #define W_MENU_STYLE_TOOLBAR        1
   #define W_MENU_STYLE_ONLYTOOLBAR    2
   #define W_MENU_STYLE_ONLYSUBTOOLBAR 3

   // -------------------------------------------------------------------------
   // COLUMN definition
   // -------------------------------------------------------------------------
   #COMMAND ATTACH COLUMN <cId> TO <oParent> BLOCK <bBlock> ;
                                  [PROMPT        <cPrompt>] ;
                                  [WIDTH          <nWidth>] ;
                                  [TOTAL          <bTotal>] ;
                                  [PICTURE      <cPicture>] ;
                                  [FPICTURE <cFootPicture>] ;
                                  [LABEL          <cLabel>] ;
                                  [INFO            <bInfo>] ;
                                  [EDIT           <cField>] ;
                                  [COLTYPE         <nType>] ;
                                  [MESSAGE         <cMess>] ;
                                  [COUNTMODE  <nCountMode>] ;
                                  [COLOR            <aCol>] ;
                                                            ;
   => tbAddColumn(     <oParent>  ,;
                       <{bBlock}> ,;
                       <nWidth>   ,;
                       <cId>      ,;
                       <cPrompt>  ,;
                       <{bTotal}> ,;
                       <cPicture> ,;
                   <cFootPicture> ,;
                       <cLabel>   ,;
                       <{bInfo}>  ,;
                       <cField>   ,;
                       <cMess>    ,;
                       <aCol>     ,;
                       <nType>    ,;
                       <nCountMode>)

   #define WC_CC_HEADER         1
   #define WC_CC_DATA           2
   #define WC_CC_CURSOR         3

   #define WC_CC_LEN            3

   // -------------------------------------------------------------------------
   // inherited fields
   // -------------------------------------------------------------------------

   //
   // Costants used as 2nd parameter in function call to dbInhGet()
   // They identify the Code-Block to evaluate or write the inherited
   // fields
   //

   #define INH_DEF         1      // Define inherited field variable
   #define INH_WRI         2      // Write inherited field to disk

   // -------------------------------------------------------------------------
   // Key Definition
   // -------------------------------------------------------------------------

   #COMMAND ATTACH KEY <cName> TO <aParent>               ;
                               [KEYTYPE      <nKeyType>]  ;
                               [BLOCK        <bBlock>  ]  ;
                               [VARTYPE      <cVarType>]  ;
                               [VARLEN       <nVarLen> ]  ;
                               [EXPRESSION   <cExp>    ]  ;
                                                          ;
   => AADD( <aParent> ,;
              { <cName>    ,;
                <nKeyType> ,;
                <bBlock>   ,;
                <cVarType> ,;
                <nVarLen>  ,;
                <cExp>     })

   #define PK_NAME            1 // Name of key field
   #define PK_KEY_TYPE        2 // Type (0-1-2-3) of key
   #define PK_BLOCK           3 // CodeBlock for key field
   #define PK_VAR_TYPE        4 // Type of data
   #define PK_LEN             5 // Key field length
   #define PK_EXPRESSION      6 // Key expression

   //
   // Tipologie di chiave
   //
   #define KEY_FREE           0 // No control
   #define KEY_PROGRESS       1 // Automatically increasing
   #define KEY_DIGIT          2 // Entered but not repeated
   #define KEY_FILE_COUNTER   3 // Automatically on counters

   // -------------------------------------------------------------------------
   // Inh Definition
   // -------------------------------------------------------------------------

   #COMMAND ATTACH INH TO <aParent>              ;
                          INHFIELD     <cField>  ;
                          INHBLOCK     <bBlock>  ;
                                                 ;
   => AADD( <aParent> ,;
              { <cField> ,;
                <bBlock> })

   #define INH_FIELD          1 // Field name
   #define INH_BLOCK          2 // Block to assign

   // -------------------------------------------------------------------------
   // REFRESH Definition
   // -------------------------------------------------------------------------

   #COMMAND ATTACH REFRESH GROUP <cGroup> TO <aParent> ;
                                                       ;
   => AADD( <aParent> , <cGroup> )

   // -------------------------------------------------------------------------
   // PAGE Definition
   // -------------------------------------------------------------------------

   #COMMAND ATTACH PAGE LABEL <cPage> TO <aParent> ;
                                                   ;
   => AADD( <aParent> , <cPage> )

   // -------------------------------------------------------------------------
   // PAGE CodeBlock
   // -------------------------------------------------------------------------

   #COMMAND ATTACH PAGE CODEBLOCK <cBlock> TO <aParent> ;
                                                   ;
   => AADD( <aParent> , <cBlock> )

   // -------------------------------------------------------------------------
   // PAGE Resize
   // -------------------------------------------------------------------------

   #COMMAND ATTACH PAGE RESIZE <aResize> TO <aParent> ;
                                                   ;
   => AADD( <aParent> , <aResize> )

   // -------------------------------------------------------------------------
   // DEFINE
   // -------------------------------------------------------------------------

   #define TBISOPT( oTbr, nOpt ) dfAnd( oTbr:W_MOUSEMETHOD, nOpt )!=0

   #define TBREALTOP( oTbr )     (oTbr:nTop -oTbr:W_BG_TOP)
   #define TBREALLEFT( oTbr )    (oTbr:nLeft -oTbr:W_BG_LEFT)
   #define TBREALBOTTOM( oTbr )  (oTbr:nBottom +oTbr:W_BG_BOTTOM)
   #define TBREALRIGHT( oTbr )   (oTbr:nRight +oTbr:W_BG_RIGHT)

   // -------------------------------------------------------------------------
   // DEFINE STANDARD KEY
   // -------------------------------------------------------------------------

   #COMMAND ADDKEY <cId> TO <aParent> [BLOCK <bBlock>]  ;
                                      [WHEN <bWhen>]    ;
                                      [RUNTIME <bRun>]  ;
                                      [MESSAGE <cMess>] ;
                                                        ;
   => aAdd( <aParent>, { <cId>, <{bWhen}>, <{bRun}>, <{bBlock}>, <cMess> })

   #define MTD_ACT    1
   #define MTD_WHEN   2
   #define MTD_RUN    3
   #define MTD_BLOCK  4
   #define MTD_MSG    5

   // -------------------------------------------------------------------------
   // Define ATTACH TOOLITEM
   // -------------------------------------------------------------------------
   #COMMAND ATTACH TOOLITEM TO <aParent>   ;
                           [EXECUTE  <bExec>]  ;
                           [WHEN     <bWhen>]  ;
                           [RUNTIME  <bRun>]   ;
                           [PROMPT   <cPrompt>];
                           [TOOLTIP  <cTip>]   ;
                           [IMAGES   <aImg>]   ;
                           [ID       <cId>]    ;
                                               ;
   => <aParent>:addToolItem(<cId>, <aImg>, <cPrompt>, <{bExec}>, <{bWhen}>, <{bRun}>, <cTip>)

   // -------------------------------------------------------------------------
   // Define ATTACH TOOLITEM
   // -------------------------------------------------------------------------
   #COMMAND ATTACH TOOLSEPARATOR TO <aParent>  ;
                                               ;
   => <aParent>:addToolSeparator()


   #include "dfreport.ch"
   #include "dfState.ch"
   #include "Xbp.ch"
#endif
