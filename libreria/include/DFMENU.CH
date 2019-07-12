/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                           Menu Definition                            |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFMENU_CH
   // Menu Definition
   #define _DFMENU_CH

   // Menu Type
   #define MN_LABEL   1 // Normal Label
   #define MN_LINE    2 // Line
   #define MN_SYSTEM  3 // (Internal)

   // Menu Security
   #define MN_ON      1 //  ON      You can See and Select
   #define MN_SECRET  2 //  SECRET  You can't see but you can select
   #define MN_OFF     3 //  OFF     You can See but no select
   #define MN_HIDDEN  4 //  HIDDEN  You can't see and can't select

   // Menu Color
   #define MNC_ROW         1 // Menu COLOR First Row
   #define MNC_LABEL       2 //            Label Color
   #define MNC_HOTLABEL    3 //            Label Hot Color
   #define MNC_SELLABEL    4 //            Label Selected Color
   #define MNC_SELHOTLABEL 5 //            Label Selected Hot Color
   #define MNC_OFFLABEL    6 //            Label Off
   #define MNC_BOXLABEL    7 //            Label Box

   // Menu Hot char
   #define MNI_HOTCHAR   "^"

   // Menu Structure
   #define MNI_CHILD      1 // Label for child
   #define MNI_LABEL      2 // Label string
   #define MNI_TYPE       3 // Label type
   #define MNI_ARRAY      4 // Array
   #define MNI_TOP        5 // Coordinates
   #define MNI_LEFT       6
   #define MNI_BOTTOM     7
   #define MNI_RIGHT      8
   #define MNI_POS        9
   #define MNI_BSECURITY 10 // block to valutate before seeing the label
   #define MNI_SECURITY  11 // return of bSecurity
   #define MNI_BRUNTIME  12 // Code Block to evaluate at RunTime
   #define MNI_ACTION    13 // Action to activate
   #define MNI_SACTION   14 // String Action to display
   #define MNI_HELP      15 // Help at last row
   #define MNI_BLOCK     16 // Block to call
   #define MNI_LENACTION 17 // Len of LABEL
   #define MNI_ID        18 // LABEL ID
   #define MNI_IN_FORM   19 // Menu in form
   #define MNI_IMAGES    20 // Images

   #define MNI_LEN       20 // Menu array len

   // -------------------------------------------------------------------------
   // Define MENU ATTACH
   // -------------------------------------------------------------------------
   #COMMAND ATTACH <cId> TO MENU <aMenu> [AS       <nType>]  ;
                                         [BLOCK    <bBlock>] ;
                                         [RUNTIME  <bRun>]   ;
                                         [PROMPT   <cPrompt>];
                                         [SHORTCUT <cAct>]   ;
                                         [EXECUTE  <bExec>]  ;
                                         [MESSAGE  <cMes>]   ;
                                         [ID       <cID>]    ;
                                         [<lIF:INFORM>]      ;
                                         [IMAGES   <aImg>]   ;
                                                             ;
         => dfMenuAdd( <aMenu>, <cId>, <nType>, <bBlock>, <bRun>,;
                       <cPrompt>, <cAct>, <bExec>, <cMes>, <cID>,  <.lIF.>, <aImg> )



#endif
