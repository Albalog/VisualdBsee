/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                               CONTROL                                |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#include "dfWin.ch"

#ifndef _DFCTRL_CH
   #define _DFCTRL_CH

   // Control type

   #define CTRL_SAY          1     // SAY
   #define CTRL_BOX          2     // BOX
   #define CTRL_FUNCTION     3     // FUNCTION
   #define CTRL_GET          4     // GET
   #define CTRL_CMB          5     // COMBOBOX
   #define CTRL_TEXT         6     // TEXTBOX
   #define CTRL_CHECK        7     // CHECKBOX
   #define CTRL_RADIO        8     // RADIOBUTTON
   #define CTRL_BUTTON       9     // PUSHBUTTON
   #define CTRL_LISTBOX     10     // LISTBOX
   #define CTRL_SPIN        11     // SPINBUTTON
   #define CTRL_USERCB      12     // USER CODEBLOCK

   // Position in all the control
                                   //                         DEFAULT
   #define FORM_CTRL_TYP       1   // Control TYPE
   #define FORM_CTRL_ID        2   //         ID
   #define FORM_CTRL_RID       3   //         REFRESH ID        ""
   #define FORM_CTRL_PAGE      4   //         PAGE               1
   #define FORM_CTRL_STABLE    5   //         STABLE            .F.
   #define FORM_CTRL_DISPLAYIF 6   //         DISPLAY IF      {||.T.}

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> SAY <uVar>         ;
                                AT        <nRow>, <nCol> ;
                                [SIZE            <aSize>];
                                [COORDINATE     <nCoordMode>];
                                [PAGE            <nPage>];
                                [COLOR            <aCol>];
                                [DISPLAYIF       <uDiIf>];
                                [REFRESHID        <cRID>];
                                [FONT            <cFont>];
                                [ALIGNMENT      <cAlign>];
                                [ROTATION         <nRot>];
                                [SHADOWDEPTH   <nShadow>];
                                [PAINTSTYLE    <nPaintStyle>];
                                                         ;
         => aAdd( <aParent>, { CTRL_SAY ,;
                               <cId>,  <cRID>,  <nPage>, .F., <{uDiIf}>,;
                               <uVar>, <nRow>,  <nCol>,;
                               <aCol>, <cFont>, <nCoordMode>, <aSize>, <cAlign>,;
                               <nRot>, <nShadow>, <nPaintStyle> })

                                           //                 DEFAULT
   #define FORM_SAY_VAR         7          // Var
   #define FORM_SAY_ROW         8          // Row
   #define FORM_SAY_COL         9          // Col
   #define FORM_SAY_CLRID      10          // COLOR ARRAY
      #define FORM_SAY_CLRTEXT     10][1   //       TEXT
      #define FORM_SAY_CLRNULL     10][2   //       NULL
   #define FORM_SAY_FONTCOMPOUNDNAME  11   // Font Compound Name (XBASE)
   #define FORM_SAY_COORDINATE_MODE   12   // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_SAY_SIZE              13   // Say Control Size
      #define FORM_SAY_SIZE_WIDTH  13][1   // Say Control Size WIDTH
      #define FORM_SAY_SIZE_HEIGHT 13][2   // Say Control Size Height
   #define FORM_SAY_ALIGNMENT_TYPE    14   // Say String Alignment type
   #define FORM_SAY_ROTATION          15   // Say Rotation
   #define FORM_SAY_SHADOWDEPTH       16   // Say Shadow depth
   #define FORM_SAY_PAINTSTYLE        17   // Say PaintStyle
   #define FORM_SAY_CTRLARRLEN        17   // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> BOX <nType>   ;
                                AT  <nTop>, <nLeft>, <nBottom>, <nRight>;
                                [BOXTYPE  <cBoxType>] ;
                                [COORDINATE <nCoordMode>] ;
                                [PAGE        <nPage>] ;
                                [COLOR        <aCol>] ;
                                [FILL        <cFill>] ;
                                [DISPLAYIF   <uDiIf>] ;
                                [REFRESHID    <cRID>] ;
                                [ALIGNMENT  <cAlign>] ;
                                [BOXTEXT     <cText>] ;
                                                      ;
         => aAdd( <aParent>, { CTRL_BOX ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                               <nType>, <nTop>, <nLeft>, <nBottom>, <nRight> ,;
                               <aCol>, <cFill>, <nCoordMode>, <cAlign>,<cBoxType>,;
                               <cText> })

                                            //                     DEFAULT
   #define FORM_BOX_TYPE       7            // Type                   1
   #define FORM_BOX_TOP        8            // Top
   #define FORM_BOX_LEFT       9            // Left
   #define FORM_BOX_BOTTOM    10            // Bottom
   #define FORM_BOX_RIGHT     11            // Right
   #define FORM_BOX_CLRID     12            // COLOR ARRAY
      #define FORM_BOX_CLRTOPLEFT     12][1 //       TOP LEFT
      #define FORM_BOX_CLRFILLER      12][2 //       FILLER
      #define FORM_BOX_CLRBOTTOMRIGHT 12][3 //       BOTTOM RIGHT
      #define FORM_BOX_CLRNULL        12][4 //       NULL
   #define FORM_BOX_FILL       13           // Filler                ""
   #define FORM_BOX_COORDINATE_MODE  14     // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_BOX_ALIGNMENT_TYPE   15     // Box Caption Alignment type
   #define FORM_BOX_TYPEOUTPUT       16     // Box Type
   #define FORM_BOX_TEXT             17     // Box Text
   #define FORM_BOX_CTRLARRLEN       17     // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> FUNCTION <uVar>    ;
                                      AT  <nTop>, <nLeft>, <nBottom>, <nRight> ;
                                      [COORDINATE <nCoordMode>];
                                      [PAGE    <nPage>]  ;
                                      [PICTURESAY <cPicSay>];
                                      [PROMPT  <cPrompt>] ;
                                      [PROMPTAT <nPRow>, <nPCol>] ;
                                      [BOX       <nBox>] ;
                                      [COLOR   <aCol>]   ;
                                      [DISPLAYIF <uDiIf>];
                                      [<Rti:REALTIME>]   ;
                                      [BEFORE  <uBefore>];
                                      [COMPUTEDEXP <uCmpExp>];
                                      [COMPUTEDGRP <uCmpGrp>];
                                      [REFRESHID    <cRID>];
                                      [<lBmp:BITMAP>]       ;
                                      [BITMAPOPTION <nBmp>];
                                      [FONT        <cFont>];
                                      [PROMPTFONT <cPFont>];
                                      [ALIGNMENT  <cAlign>];
                                      [ROTATION     <nRot>];
                                      [SHADOWDEPTH <nShadow>];
                                      [PAINTSTYLE    <nPaintStyle>];
                                                           ;
         => aAdd( <aParent>, { CTRL_FUNCTION ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                               <{uVar}>, <nTop>, <nLeft>     ,;
                               <nBottom>, <nRight>, <cPicSay>,;
                               <cPrompt>, <nPRow>, <nPCol>, <nBox>,;
                               <aCol>, <{uBefore}>, <.Rti.>,;
                               <{uCmpExp}>, <uCmpGrp>,"" , , ,IIF(<.lBmp.>, .T., <nBmp>),;
                               <cFont>, <cPFont>, <nCoordMode>, <cAlign>, <nRot>, <nShadow>,;
                               <nPaintStyle> })

                                             //                    DEFAULT
   #define FORM_FUN_VAR        7             // Var
   #define FORM_FUN_TOP        8             // Top
   #define FORM_FUN_LEFT       9             // Left
   #define FORM_FUN_BOTTOM    10             // Bottom
   #define FORM_FUN_RIGHT     11             // Right
   #define FORM_FUN_PICTURE   12             // Picture              ""
   #define FORM_FUN_PROMPT    13             // Prompt
   #define FORM_FUN_PROW      14             // Prompt row
   #define FORM_FUN_PCOL      15             // Prompt col
   #define FORM_FUN_BOX       16             // Box                  0
   #define FORM_FUN_CLRID     17             // COLOR ARRAY
      #define FORM_FUN_CLRPROMPT      17][1  //       PROMPT
      #define FORM_FUN_CLRHOTKEY      17][2  //       HOT KEY
      #define FORM_FUN_CLRDATA        17][3  //       DATA
      #define FORM_FUN_CLRTOPLEFT     17][4  //       TOP LEFT
      #define FORM_FUN_CLRBOTTOMRIGHT 17][5  //       BOTTOM RIGHT
      #define FORM_FUN_CLRNULL        17][6  //       NULL
   #define FORM_FUN_BEFORE    18             // Before             {||.T.}
   #define FORM_FUN_REALTIME  19             // RealTime             .F.
   #define FORM_FUN_COMPEXP   20             // Computed exp       {||.T.}
   #define FORM_FUN_COMPGRP   21             // Computed group
   #define FORM_FUN_COMPREF   22             // Computed refresh
   #define FORM_FUN_ROW       23             // Memo Row
   #define FORM_FUN_COL       24             // Memo Col
   #define FORM_FUN_BITMAP    25             // Bitmap display (XBASE)
   #define FORM_FUN_FONTCOMPOUNDNAME  26     // Font Compound Name (XBASE)
   #define FORM_FUN_PFONTCOMPOUNDNAME 27     // Prompt Font Compound Name (XBASE)
   #define FORM_FUN_COORDINATE_MODE   28     // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_FUN_ALIGNMENT_TYPE    29     // Function Caption Alignment type
   #define FORM_FUN_ROTATION          30     // Rotation
   #define FORM_FUN_SHADOWDEPTH       31     // Shadow Depth
   #define FORM_FUN_PAINTSTYLE        32     // Paint Style
   #define FORM_FUN_CTRLARRLEN        32     // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> GET AS FUNCTION <uVar>    ;
                                      AT  <nTop>, <nLeft>, <nBottom>, <nRight> ;
                                      [COORDINATE <nCoordMode>];
                                      [PAGE    <nPage>]  ;
                                      [PICTURESAY <cPicSay>];
                                      [PROMPT  <cPrompt>] ;
                                      [PROMPTAT <nPRow>, <nPCol>] ;
                                      [BOX       <nBox>] ;
                                      [COLOR   <aCol>]   ;
                                      [DISPLAYIF <uDiIf>];
                                      [<Rti:REALTIME>]   ;
                                      [BEFORE  <uBefore>];
                                      [COMPUTEDEXP <uCmpExp>];
                                      [COMPUTEDGRP <uCmpGrp>];
                                      [REFRESHID    <cRID>];
                                      [<lBmp:BITMAP>]       ;
                                      [BITMAPOPTION <nBmp>];
                                      [FONT        <cFont>];
                                      [PROMPTFONT <cPFont>];
                                      [ALIGNMENT  <cAlign>];
                                      [ROTATION     <nRot>];
                                      [SHADOWDEPTH <nShadow>];
                                      [PAINTSTYLE    <nPaintStyle>];
                                                           ;
         => aAdd( <aParent>, { CTRL_FUNCTION ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                               {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)}, <nTop>, <nLeft>     ,;
                               <nBottom>, <nRight>, <cPicSay>,;
                               <cPrompt>, <nPRow>, <nPCol>, <nBox>,;
                               <aCol>, <{uBefore}>, <.Rti.>,;
                               <{uCmpExp}>, <uCmpGrp>,"" , , ,IIF(<.lBmp.>, .T., <nBmp>),;
                               <cFont>, <cPFont>, <nCoordMode>, <cAlign>, <nRot>, <nShadow>,;
                               <nPaintStyle> })

                                             //                    DEFAULT
                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> GET <uVar>         ;
                                      AT  <nRow>, <nCol> ;
                                      [SIZE      <aSize>];
                                      [COORDINATE <nCoordMode>];
                                      [PAGE      <nPage>];
                                      [PICTUREGET <cPicGet>] ;
                                      [PICTURESAY <cPicSay>] ;
                                      [CONDITION <uCond>] ;
                                      [ACTIVE <uActive>]   ;
                                      [PROMPT  <cPrompt>] ;
                                      [PROMPTAT <nPRow>, <nPCol>] ;
                                      [DISPLAYIF <uDiIf>] ;
                                      [SYSFUNCTION <uSys>];
                                      [REFRESHGRP  <uGrp>];
                                      [COMPUTEDEXP <uCmpExp>];
                                      [COMPUTEDGRP <uCmpGrp>];
                                      [<Cmb:COMBO>]       ;
                                      [GAP         <nGap>];
                                      [MESSAGE <cMes>]    ;
                                      [PFK <aPfk>]        ;
                                      [VARNAME <cVarName>];
                                      [ACT <cAct>]        ;
                                      [COLOR   <aCol>]    ;
                                      [REFRESHID <cRID>]  ;
                                      [FONT       <cFont>];
                                      [PROMPTFONT <cPFont>];
                                      [ALIGNMENT <cAlign>];
                                      [PAINTSTYLE    <nPaintStyle>];
                                      [CHECKS        <nChecks>];
                                                          ;
     => aAdd( <aParent>, { CTRL_GET ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                         {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
                         <nRow>, <nCol>,;
                         <cPrompt>, <nPRow>, <nPCol>,;
                         <cPicGet>, <cPicSay>,;
                         <cMes>, <aPfk>, <cVarName>, <uCond>,;
                         <{uActive}>,;
                         <aCol>, <{uSys}>, <.Cmb.>,;
                         <nGap>, <cAct>, <uGrp>, <{uCmpExp}>, <uCmpGrp>, "",;
                         <cFont>, <cPFont>, <nCoordMode>, <aSize>, <cAlign>,;
                         <nPaintStyle>, <nChecks> })

                                             //                      DEFAULT
   #define FORM_GET_VAR         7            // Var
   #define FORM_GET_ROW         8            // Row
   #define FORM_GET_COL         9            // Col
   #define FORM_GET_PROMPT     10            // Prompt                  ""
   #define FORM_GET_PROW       11            // Prompt Row
   #define FORM_GET_PCOL       12            // Prompt Col
   #define FORM_GET_PICTUREGET 13            // Picture GET           PICSAY
   #define FORM_GET_PICTURESAY 14            // Picture SAY           PICGET
   #define FORM_GET_MESSAGE    15            // Message                 ""
   #define FORM_GET_PFK        16            // PFK Array               {}
   #define FORM_GET_CVAR       17            // Var Name
   #define FORM_GET_CONDITION  18            // Condition             {||.T.}
   #define FORM_GET_ACTIVE     19            // Active                {||.T.}
   #define FORM_GET_CLRID      20            // COLOR ARRAY
      #define FORM_GET_CLRPROMPT  20][1      //       PROMPT
      #define FORM_GET_CLRHOTKEY  20][2      //       HOT KEY
      #define FORM_GET_CLRDATA    20][3      //       DATA
      #define FORM_GET_CLRHILITE  20][4      //       DATA HILITE
      #define FORM_GET_CLRICON    20][5      //       ICON
      #define FORM_GET_CLRNULL    20][6      //       NULL
   #define FORM_GET_SYS        21            // Function SYS          {||NIL}
   #define FORM_GET_COMBO      22            // Combo
   #define FORM_GET_GAP        23            // Combo GAP
   #define FORM_GET_ACT        24            // Exit ACTION
   #define FORM_GET_CTRLGRP    25            // Refresh GRP             ""
   #define FORM_GET_COMPEXP    26            // Computed Exp          {||.T.}
   #define FORM_GET_COMPGRP    27            // Computed Group
   #define FORM_GET_COMPREF    28            // Computed Refresh
   #define FORM_GET_FONTCOMPOUNDNAME  29     // Font Compound Name (XBASE)
   #define FORM_GET_PFONTCOMPOUNDNAME 30     // Prompt Font Compound Name (XBASE)
   #define FORM_GET_COORDINATE_MODE   31     // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_GET_SIZE              32     // GET Control Size
      #define FORM_GET_SIZE_WIDTH  32][1     // GET Control Size WIDTH
      #define FORM_GET_SIZE_HEIGHT 32][2     // GET Control Size Height
   #define FORM_GET_ALIGNMENT_TYPE    33     // GET String Alignment type
   #define FORM_GET_PAINTSTYLE        34     // GET Paint Style
   #define FORM_GET_CHECKS            35     // Type of checks
   #define FORM_GET_CTRLARRLEN        35     // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> GET AS COMBO <uVar>;
                                      AT  <nRow>, <nCol> ;
                                      [SIZE      <aSize>];
                                      [COORDINATE <nCoordMode>];
                                      [PAGE      <nPage>];
                                      [PICTUREGET <cPicGet>] ;
                                      [PICTURESAY <cPicSay>] ;
                                      [CONDITION <uCond>] ;
                                      [ACTIVE <uActive>]   ;
                                      [PROMPT  <cPrompt>] ;
                                      [PROMPTAT <nPRow>, <nPCol>] ;
                                      [DISPLAYIF <uDiIf>] ;
                                      [SYSFUNCTION <uSys>];
                                      [REFRESHGRP  <uGrp>];
                                      [LISTBOX <oList>]   ;
                                      [MESSAGE <cMes>]    ;
                                      [GAP     <nGap>]    ;
                                      [PFK <aPfk>]        ;
                                      [VARNAME <cVarName>];
                                      [ACT <cAct>]        ;
                                      [COLOR   <aCol>]    ;
                                      [DATACHECK <bChk>]  ;
                                      [REFRESHID <cRID>]  ;
                                      [FONT       <cFont>];
                                      [PROMPTFONT <cPFont>];
                                      [LISTBOXFONT <cLFont>];
                                      [ALIGNMENT  <cAlign>];
                                                           ;
     => aAdd( <aParent>, { CTRL_CMB ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                         {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
                         <nRow>, <nCol>, ;
                         <cPrompt>, <nPRow>, <nPCol>,;
                         <cPicGet>, <cPicSay>,;
                         <cMes>, <aPfk>, <cVarName>, <{uCond}>,;
                         <{uActive}>,;
                         <aCol>, <{uSys}>, <oList>,;
                         <nGap>, <cAct>, <uGrp>, <{bChk}>,;
                         <cFont>, <cPFont>, <cLFont>, <nCoordMode>,;
                         <aSize>, <cAlign> })

                                             //                      DEFAULT
   #define FORM_CMB_VAR         7            // Var
   #define FORM_CMB_ROW         8            // Row
   #define FORM_CMB_COL         9            // Col
   #define FORM_CMB_PROMPT     10            // Prompt                  ""
   #define FORM_CMB_PROW       11            // Prompt Row
   #define FORM_CMB_PCOL       12            // Prompt Col
   #define FORM_CMB_PICTUREGET 13            // Picture GET           PICSAY
   #define FORM_CMB_PICTURESAY 14            // Picture SAY           PICGET
   #define FORM_CMB_MESSAGE    15            // Message                 ""
   #define FORM_CMB_PFK        16            // PFK Array               {}
   #define FORM_CMB_CVAR       17            // Var Name
   #define FORM_CMB_CONDITION  18            // Condition             {||.T.}
   #define FORM_CMB_ACTIVE     19            // Active                {||.T.}
   #define FORM_CMB_CLRID      20            // COLOR ARRAY
      #define FORM_CMB_CLRPROMPT  20][1      //       PROMPT
      #define FORM_CMB_CLRHOTKEY  20][2      //       HOT KEY
      #define FORM_CMB_CLRDATA    20][3      //       DATA
      #define FORM_CMB_CLRHILITE  20][4      //       DATA HILITE
      #define FORM_CMB_CLRICON    20][5      //       ICON
      #define FORM_CMB_CLRNULL    20][6      //       NULL
   #define FORM_CMB_SYS        21            // Function SYS          {||NIL}
   #define FORM_CMB_LISTBOX    22            // LISTBOX
   #define FORM_CMB_GAP        23            // Combo GAP
   #define FORM_CMB_ACT        24            // Exit ACTION
   #define FORM_CMB_CTRLGRP    25            // Refresh GRP             ""
   #define FORM_CMB_DATACHECK  26            // Data Check
   #define FORM_CMB_FONTCOMPOUNDNAME  27     // Font Compound Name (XBASE)
   #define FORM_CMB_PFONTCOMPOUNDNAME 28     // Prompt Font Compound Name (XBASE)
   #define FORM_CMB_LFONTCOMPOUNDNAME 29     // ListBox Font Compound Name (XBASE)
   #define FORM_CMB_COORDINATE_MODE   30     // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_CMB_SIZE              31     // CMB Control Size
      #define FORM_CMB_SIZE_WIDTH  31][1     // CMB Control Size WIDTH
      #define FORM_CMB_SIZE_HEIGHT 31][2     // CMB Control Size Height
   #define FORM_CMB_ALIGNMENT_TYPE    32     // CMB Alignment type
   #define FORM_CMB_CTRLARRLEN        32     // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> GET AS TEXTFIELD <uVar> ;
                                      AT  <nTop>, <nLeft>, <nBottom>, <nRight>;
                                      [COORDINATE <nCoordMode>];
                                      [CONDITION <uCond>];
                                      [ACTIVE <uActive>]   ;
                                      [PAGE    <nPage>]  ;
                                      [PROMPT  <cPrompt>];
                                      [BOX       <nBox>] ;
                                      [DISPLAYIF <uDiIf>];
                                      [<Ink:NOINKEY>]    ;
                                      [SYSFUNCTION <uSys>];
                                      [MESSAGE    <cMes>];
                                      [VARNAME <cVarName>];
                                      [COLOR   <aCol>]   ;
                                      [PFK <aPfk>]       ;
                                      [REFRESHID <cRID>] ;
                                      [MEMOWIDTH <nLen>] ;
                                      [FONT       <cFont>];
                                      [PROMPTFONT <cPFont>];
                                      [ALIGNMENT <cAlign>];
                                      [PAINTSTYLE    <nPaintStyle>];
                                                         ;
         => aAdd( <aParent>, { CTRL_TEXT ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                             {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
                             <nTop>, <nLeft>, <nBottom>, <nRight>,;
                             <cPrompt>, <nBox>, <{uCond}>,;
                             <{uActive}>,;
                             <.Ink.>, <uSys>, <cMes>,;
                             <cVarName>, <aCol>, <aPfk>,,,<nLen>,;
                             <cFont>,<cPFont>,<nCoordMode>, <cAlign>, <nPaintStyle>})

                                              //                   DEFAULT
   #define FORM_TXT_VAR        7              // Var
   #define FORM_TXT_TOP        8              // Top
   #define FORM_TXT_LEFT       9              // Left
   #define FORM_TXT_BOTTOM    10              // Bottom
   #define FORM_TXT_RIGHT     11              // Right
   #define FORM_TXT_PROMPT    12              // Prompt              ""
   #define FORM_TXT_BOX       13              // Box                  0
   #define FORM_TXT_CONDITION 14              // Condition          {||.T.}
   #define FORM_TXT_ACTIVE    15              // Active             {||.T.}
   #define FORM_TXT_NOINKEY   16              // No Inkey
   #define FORM_TXT_SYS       17              // SYS Function
   #define FORM_TXT_MESSAGE   18              // Message             ""
   #define FORM_TXT_CVAR      19              // Var Name
   #define FORM_TXT_CLRID     20              // COLOR ARRAY
      #define FORM_TXT_CLRPROMPT       20][1  //       PROMPT
      #define FORM_TXT_CLRHOTKEY       20][2  //       HOT KEY
      #define FORM_TXT_CLRDATA         20][3  //       DATA
      #define FORM_TXT_CLRHILITE       20][4  //       DATA HILITE
      #define FORM_TXT_CLRTOPLEFT      20][5  //       TOP LEFT
      #define FORM_TXT_CLRBOTTOMRIGHT  20][6  //       BOTTOM RIGHT
      #define FORM_TXT_CLRNULL         20][7  //       NULL
   #define FORM_TXT_PFK       21              // PFK Array
   #define FORM_TXT_ROW       22              // Memo view row
   #define FORM_TXT_COL       23              // Memo view col
   #define FORM_TXT_MEMOLEN   24              // Memo line LENGHT
   #define FORM_TXT_FONTCOMPOUNDNAME  25      // Font Compound Name (XBASE)
   #define FORM_TXT_PFONTCOMPOUNDNAME 26      // Prompt Font Compound Name (XBASE)
   #define FORM_TXT_COORDINATE_MODE   27      // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_TXT_ALIGNMENT_TYPE    28      // Txt Caption Alignment type
   #define FORM_TXT_PAINTSTYLE        29      // Paint Style
   #define FORM_TXT_CTRLARRLEN        29      // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> GET AS CHECKBOX <uVar> ;
                                      PROMPT <cPrompt>;
                                      AT  <nRow>, <nCol> ;
                                      [SIZE    <aSize>]  ;
                                      [COORDINATE <nCoordMode>];
                                      VALUEON  <uValOn>  ;
                                      VALUEOFF <uValOff> ;
                                      [ACTIVE <uActive>] ;
                                      [DISPLAYIF <uDiIf>];
                                      [REFRESHGRP  <uGrp>];
                                      [GAP         <nGap>];
                                      [PAGE    <nPage>]  ;
                                      [COLOR   <aCol>]   ;
                                      [MESSAGE    <cMes>];
                                      [REFRESHID <cRID>] ;
                                      [VARNAME <cVarName>];
                                      [WHENCLICKED <bClick>];
                                      [FONT       <cFont>];
                                      [ALIGNMENT  <cAlign>];
                                      [PAINTSTYLE    <nPaintStyle>];
                                                         ;
         => aAdd( <aParent>, { CTRL_CHECK ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                             <uGrp> ,;
                             {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
                             <cPrompt>, <nRow>, <nCol>,;
                             <{uActive}>,;
                             <aCol>, <cMes>, <nGap>, <{bClick}>, <cVarName>,;
                             <uValOn>, <uValOff>, <cFont>, <nCoordMode>,;
                             <aSize>, <cAlign>, <nPaintStyle> })

                                              //                     DEFAULT
   #define FORM_CHK_CTRLGRP    7              // Refresh GRP
   #define FORM_CHK_VAR        8              // Var
   #define FORM_CHK_PROMPT     9              // Prompt                ""
   #define FORM_CHK_ROW       10              // Row
   #define FORM_CHK_COL       11              // Col
   #define FORM_CHK_ACTIVE    12              // Active              {||.T.}
   #define FORM_CHK_CLRID     13              // COLOR ARRAY
      #define FORM_CHK_CLRPROMPT        13][1 //       PROMPT
      #define FORM_CHK_CLRHOTKEY        13][2 //       HOTKEY
      #define FORM_CHK_CLRHILITEPROMPT  13][3 //       HILITE PROMPT
      #define FORM_CHK_CLRICON          13][4 //       ICON COLOR
      #define FORM_CHK_CLRNULL          13][5 //       NULL
   #define FORM_CHK_MESSAGE   14              // Message
   #define FORM_CHK_GAP       15              // Gap                   0
   #define FORM_CHK_CLICKED   16              // When Clicked        {||.T.}
   #define FORM_CHK_CVAR      17              // Var Name
   #define FORM_CHK_VALUEON   18              // Value ON
   #define FORM_CHK_VALUEOFF  19              // Value OFF
   #define FORM_CHK_FONTCOMPOUNDNAME 20       // Font Compound Name (XBASE)
   #define FORM_CHK_COORDINATE_MODE  21       // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_CHK_SIZE             22       // CHK Control Size
      #define FORM_CHK_SIZE_WIDTH  22][1      // CHK Control Size WIDTH
      #define FORM_CHK_SIZE_HEIGHT 22][2      // CHK Control Size Height
   #define FORM_CHK_ALIGNMENT_TYPE   23       // CHK Caption Alignment type
   #define FORM_CHK_PAINTSTYLE       24       // CHK Paint Style
   #define FORM_CHK_CTRLARRLEN       24       // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> GET AS RADIOBUTTON <uVar> ;
                                      PROMPT <cPrompt>;
                                      AT  <nRow>, <nCol> ;
                                      [SIZE    <aSize>]  ;
                                      [COORDINATE <nCoordMode>];
                                      VALUE  <uVal>      ;
                                      [ACTIVE <uActive>] ;
                                      [DISPLAYIF <uDiIf>];
                                      [REFRESHGRP  <uGrp>];
                                      [PAGE    <nPage>]  ;
                                      [GAP         <nGap>];
                                      [COLOR   <aCol>]   ;
                                      [MESSAGE    <cMes>];
                                      [REFRESHID <cRID>] ;
                                      [VARNAME <cVarName>];
                                      [WHENCLICKED <bClick>];
                                      [FONT      <cFont>];
                                      [ALIGNMENT <cAlign>];
                                      [PAINTSTYLE    <nPaintStyle>];
                                                         ;
         => aAdd( <aParent>, { CTRL_RADIO ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                               <uGrp> ,;
                               {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
                               <cPrompt>, <nRow>, <nCol>,;
                               <{uActive}>,;
                               <aCol>,  <cMes>,;
                               <nGap>, <{bClick}>, <cVarName>, <{uVal}>,;
                               <cFont>, <nCoordMode>, <aSize>, <cAlign>, <nPaintStyle> })

                                              //                     DEFAULT
   #define FORM_RAD_CTRLGRP    7              // Refresh GRP
   #define FORM_RAD_VAR        8              // Var
   #define FORM_RAD_PROMPT     9              // Prompt
   #define FORM_RAD_ROW       10              // Row
   #define FORM_RAD_COL       11              // Col
   #define FORM_RAD_ACTIVE    12              // Active              {||.T.}
   #define FORM_RAD_CLRID     13              // COLOR ARRAY
      #define FORM_RAD_CLRPROMPT        13][1 //       PROMPT
      #define FORM_RAD_CLRHOTKEY        13][2 //       HOTKEY
      #define FORM_RAD_CLRHILITEPROMPT  13][3 //       HILITE PROMPT
      #define FORM_RAD_CLRICON          13][4 //       ICON COLOR
      #define FORM_RAD_CLRNULL          13][5 //       NULL
   #define FORM_RAD_MESSAGE   14              // Message
   #define FORM_RAD_GAP       15              // Gap                   0
   #define FORM_RAD_CLICKED   16              // When Clicked        {||.T.}
   #define FORM_RAD_CVAR      17              // Var Name
   #define FORM_RAD_VALUE     18              // Value
   #define FORM_RAD_FONTCOMPOUNDNAME 19       // Font Compound Name (XBASE)
   #define FORM_RAD_COORDINATE_MODE  20       // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_RAD_SIZE              21      // RADIO Control Size
      #define FORM_RAD_SIZE_WIDTH  21][1      // RADIO Control Size WIDTH
      #define FORM_RAD_SIZE_HEIGHT 21][2      // RADIO Control Size Height
   #define FORM_RAD_ALIGNMENT_TYPE   22       // RADIO Caption Alignment type
   #define FORM_RAD_PAINTSTYLE       23       // RADIO Paint Style
   #define FORM_RAD_CTRLARRLEN       23       // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> GET AS PUSHBUTTON <cPrompt>;
                                      AT  <nTop>, <nLeft>, <nBottom>, <nRight>;
                                      [COORDINATE <nCoordMode>];
                                      [PAGE    <nPage>]    ;
                                      [FUNCTION <uFun>]    ;
                                      [COLOR   <aCol>]     ;
                                      [ACTIVE <uActive>]   ;
                                      [REFRESHID <cRID>]   ;
                                      [MESSAGE <cMes>]     ;
                                      [<Pack:PACK>]        ;
                                      [BITMAP <nBmp>]      ;
                                      [BITMAPID <xBmp>]    ;
                                      [FONT       <cFont>] ;
                                      [PAINTSTYLE <nPaintStyle>] ;
                                                           ;
      => aAdd( <aParent>, { CTRL_BUTTON ,;
                            <cId>, <cRID>, <nPage>, .F.,  NIL     ,;
                            <cPrompt>, <nTop>, <nLeft>, <nBottom>, <nRight>,;
                            <aCol>, <{uActive}>, <{uFun}>, <cMes>, <.Pack.>,;
                            <cFont>, <nBmp>, <xBmp>, <nCoordMode>, <nPaintStyle> })

                                                //                    DEFAULT
   #define FORM_BUT_PROMPT    7                 // Prompt
   #define FORM_BUT_TOP       8                 // Top
   #define FORM_BUT_LEFT      9                 // Left
   #define FORM_BUT_BOTTOM   10                 // Bottom
   #define FORM_BUT_RIGHT    11                 // Right
   #define FORM_BUT_CLRID    12                 // COLOR ARRAY
      #define FORM_BUT_CLRTOPLEFT        12][1  //       TOP LEFT
      #define FORM_BUT_CLRPROMPT         12][2  //       PROMPT
      #define FORM_BUT_CLRHOTKEY         12][3  //       HOT KEY
      #define FORM_BUT_CLRBOTTOMRIGHT    12][4  //       BOTTOM RIGHT
      #define FORM_BUT_CLRHILITEPROMPT   12][5  //       PROMPT HILITE
      #define FORM_BUT_CLRHILITEHOTKEY   12][6  //       HOTKEY HILITE
      #define FORM_BUT_CLRNULL           12][7  //       NULL
      #define FORM_BUT_CLRDISABLEDPROMPT 12][8  //       NULL
      #define FORM_BUT_CLRDISABLEDHOTKEY 12][9  //       NULL
   #define FORM_BUT_ACTIVE   13                 // Active             {||.T.}
   #define FORM_BUT_FUNCTION 14                 // Function           {||.T.}
   #define FORM_BUT_MESSAGE  15                 // Message              ""
   #define FORM_BUT_PACK     16                 // Packed
   #define FORM_BUT_FONTCOMPOUNDNAME 17         // Font Compound Name (XBASE)
   #define FORM_BUT_BITMAP           18         // Bitmap (XBASE)
   #define FORM_BUT_BITMAPID         19         // Bitmap ID (XBASE)
   #define FORM_BUT_COORDINATE_MODE  20     // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_BUT_PAINTSTYLE       21     // Paint Style
   #define FORM_BUT_CTRLARRLEN       21         // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> GET AS LISTBOX USING <oList>;
                                      [PAGE    <nPage>]  ;
                                      [ACTIVE <uActive>]   ;
                                      [REFRESHID <cRID>]   ;
                                      [FONT       <cFont>];
                                      [COORDINATE <nCoordMode>];
                                      [PAINTSTYLE    <nPaintStyle>];
                                                     ;
         => aAdd( <aParent>, { CTRL_LISTBOX ,;
                               <cId>, <cRID>, <nPage>, .F.,  NIL     ,;
                               <oList>, <{uActive}>, NIL, <cFont>    ,;
                         {|uVal|IF(PCOUNT()==0, <oList>, <oList>:=uVal)}, <nCoordMode>, <nPaintStyle> })

   #define FORM_LIST_OBJECT    7
   #define FORM_LIST_ACTIVE    8
   #define FORM_LIST_CLRNULL   9
   #define FORM_LIST_FONTCOMPOUNDNAME 10
   #define FORM_LIST_OBJECTVAR        11
   #define FORM_LIST_COORDINATE_MODE  12     // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_LIST_PAINTSTYLE       13     // Paint Style
   #define FORM_LIST_CTRLARRLEN       13     // Len of control array

                         /*-----------------*/

   #COMMAND ATTACH <cId> TO <aParent> GET AS SPINBUTTON <uVar> ;
                                      AT  <nRow>, <nCol> ;
                                      [SIZE    <aSize>]  ;
                                      [COORDINATE <nCoordMode>];
                                      [PAGE    <nPage>]  ;
                                      [GAP         <nGap>];
                                      [PICTURESAY <cPicSay>] ;
                                      [DISPLAYIF <uDiIf>] ;
                                      [ARRAY   <aSource>] ;
                                      [MIN        <nMin>] ;
                                      [MAX        <nMax>] ;
                                      [STEP      <nStep>] ;
                                      [REFRESHGRP  <uGrp>];
                                      [MESSAGE <cMes>]    ;
                                      [COLOR   <aCol>]    ;
                                      [PROMPT  <cPrompt>] ;
                                      [PROMPTAT <nPRow>, <nPCol>] ;
                                      [REFRESHID <cRID>]  ;
                                      [ACTIVE <uActive>]  ;
                                      [VARNAME <cVarName>];
                                      [WHENCLICKED <bClick>];
                                      [FONT       <cFont>];
                                      [PROMPTFONT <cPFont>];
                                      [ALIGNMENT  <cAlign>];
                                                           ;
     => aAdd( <aParent>, { CTRL_SPIN ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                         {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
                         <nRow>, <nCol>, ;
                         <cPrompt>, <nPRow>, <nPCol>,;
                         <cPicSay>, <cMes>, <cVarName>,;
                         <{uActive}>,;
                         <aCol>, <nGap>,;
                         <uGrp>, <aSource>, <nMin>, <nMax>, <nStep>,;
                         <{bClick}>, <cFont>, <cPFont>, <nCoordMode>,;
                         <aSize> , <cAlign>})

                                              //                     DEFAULT
   #define FORM_SPN_VAR         7             // Var
   #define FORM_SPN_ROW         8             // Row
   #define FORM_SPN_COL         9             // Col
   #define FORM_SPN_PROMPT     10             // Prompt                ""
   #define FORM_SPN_PROW       11             // Prompt Row
   #define FORM_SPN_PCOL       12             // Prompt Col
   #define FORM_SPN_PICTURESAY 13             // Picture Say           ""
   #define FORM_SPN_MESSAGE    14             // Message
   #define FORM_SPN_CVAR       15             // Var Name
   #define FORM_SPN_ACTIVE     16             // Active
   #define FORM_SPN_CLRID      17             // COLOR ARRAY
      #define FORM_SPN_CLRPROMPT  17][1       //       PROMPT
      #define FORM_SPN_CLRHOTKEY  17][2       //       HOTKEY
      #define FORM_SPN_CLRDATA    17][3       //       DATA
      #define FORM_SPN_CLRHILITE  17][4       //       DATA HILITE
      #define FORM_SPN_CLRICON    17][5       //       ICON
      #define FORM_SPN_CLRNULL    17][6       //       NULL
   #define FORM_SPN_GAP        18             // Gap                    0
   #define FORM_SPN_CTRLGRP    19             // Refresh GRP            ""
   #define FORM_SPN_ARRAY      20             // Array
   #define FORM_SPN_MIN        21             // Min
   #define FORM_SPN_MAX        22             // Max
   #define FORM_SPN_STEP       23             // Step
   #define FORM_SPN_CLICKED    24             // When Clicked        {||.T.}
   #define FORM_SPN_FONTCOMPOUNDNAME  25      // Font Compound Name (XBASE)
   #define FORM_SPN_PFONTCOMPOUNDNAME 26      // Prompt Font Compound Name (XBASE)
   #define FORM_SPN_COORDINATE_MODE   27      // Coordinate in Pixel or Row/Column format (VdBsee)
   #define FORM_SPN_SIZE              28      // SPIN Control Size
      #define FORM_SPN_SIZE_WIDTH  28][1      // SPIN Control Size WIDTH
      #define FORM_SPN_SIZE_HEIGHT 28][2      // SPIN Control Size Height
   #define FORM_SPN_ALIGNMENT_TYPE    29      // SPIN Alignment type
   #define FORM_SPN_CTRLARRLEN        29      // Len of control array


   #COMMAND ATTACH <cId> TO <aParent> USERCB <bCB> ;
                                      [AT  <nRow>, <nCol>] ;
                                      [SIZE    <aSize>]  ;
                                      [DISPLAYIF <uDiIf>];
                                      [PAGE    <nPage>]  ;
                                      [REFRESHID <cRID>] ;
                                      [USERDATA  <cProp> IS <xVal>] [, <cPropN> IS <xValN>] ;
                                                         ;
         => aAdd( <aParent>, { CTRL_USERCB ,;
                               <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
                               <bCB>, <nRow>, <nCol> ,<aSize>,;
                               { [{<cProp> , <xVal>}] [, {<cPropN> , <xValN>}] }})

                                              
   #define FORM_UCB_CB           7        // Codeblock
   #define FORM_UCB_ROW          8        // Row
   #define FORM_UCB_COL          9        // Col
   #define FORM_UCB_SIZE        10        // Control Size Array
      #define FORM_UCB_SIZE_WIDTH  10][1  // Control Size Width
      #define FORM_UCB_SIZE_HEIGHT 10][2  // Control Size Height
   #define FORM_UCB_USERDATA    11        // Control User data
   #define FORM_UCB_CTRLARRLEN  11        // Len of control array

   // Normal GET CONDITION CALL

   #define FORM_PREGET   1
   #define FORM_POSTGET  2
   #define FORM_CHKGET   3


   // GET CARGO Structure

   #define G_ACTION     CARGO[1]
   #define G_FUNCTION   CARGO[2]

   #define G_LEN              2


   // BOX Type

   #define BOX_NORMAL  1
   #define BOX_BUTTON  2
   #define BOX_FILL    3

   // BUTTON BITMAP Type

   #define BUT_BMP_NO    1
   #define BUT_BMP_YES   2
   #define BUT_BMP_SIZE  3

   // FUNCTION BITMAP Options

   #define FUN_BMP_NO_BMP              0
   #define FUN_BMP_AUTOSIZE            1
   #define FUN_BMP_NORMAL              2
   #define FUN_BMP_SCALE               3
   #define FUN_BMP_STRETCH             4
   #define FUN_BMP_OPTIONS             0x00FFFF
   #define FUN_BMP_CENTER              0x010000
   #define FUN_BMP_REPEAT              0x020000  // not implemented

   // Alignment Type

   #define XBPALIGN_AUTOFILL           1048576
   #define XBPALIGN_DEFAULT            -9999999  //the ABS() must be higher of all the other #define


   // Paint Style for controls
   #define PS_STD             0
   #define PS_ROUNDBORDER     1
   #define PS_POINTFOCUS      2
   #define PS_BORDER          4

   // BOX Type
   #define XBPSTATIC_TYPE_DEFAULT      -1
   #define XBPSTATIC_TYPE_GROUPBOXFANCY1     1000
   #define XBPSTATIC_TYPE_GROUPBOXFANCY2     1001
   #define XBPSTATIC_TYPE_GROUPBOXFANCY3     1002

   // Paint Style for GET controls
   #define GET_PS_STD             0
   #define GET_PS_FLAT            1

   // Paint Style for BOX controls
   #define BOX_PS_STD             XBPSTATIC_TYPE_GROUPBOX
   #define BOX_PS_FLAT            XBPSTATIC_TYPE_GROUPBOXFANCY3

   // Paint Style for CHECK controls
   #define CHK_PS_STD             0
   #define CHK_PS_FLAT            1

   // Paint Style for RADIO controls
   #define RAD_PS_STD             0
   #define RAD_PS_FLAT            1

   // Paint Style for SAY controls
   #define SAY_PS_STD             PS_STD
   #define SAY_PS_BORDER          PS_BORDER
   #define SAY_PS_ROUNDBORDER     PS_ROUNDBORDER

   // Paint Style for Function controls
   #define FUN_PS_STD             PS_STD
   #define FUN_PS_BORDER          PS_BORDER
   #define FUN_PS_ROUNDBORDER     PS_ROUNDBORDER
   #define FUN_PS_GETLOOK         PS_BORDER+0x010000

   // Paint Style for Button controls
   #define BUT_PS_STD         0
   #define BUT_PS_FLAT1       1
   #define BUT_PS_FLAT2       2

   // Columns Count Mode
   #define COLUMN_DEFAULT_COUNT    0
   #define COLUMN_TAG_COUNT        1
   #define COLUMN_ALL_COUNT        2

   // Checks type
   #define GET_CHK_NOCHECK         0
   #define GET_CHK_MANDATORY       1
   #define GET_CHK_VALIDATION      2
#endif
