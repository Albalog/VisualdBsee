/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                          Xbase ++ Parameters                         |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFXBASE_CH


   #define _DFXBASE_CH

   #define TOOLBAR_DEFAULT_HEIGHT 26

   #include "AppEvent.ch"
   #include "font.ch"

   // ---------------------------------------------
   // Eventi aggiuntivi non definiti in Appevent.ch
   // ---------------------------------------------
   // #define xbeMenu_HighLight   (xbeB_Event + 384)
   // #define xbeMenu_Select      (xbeB_Event + 385)
   // #define xbeMenu_DropDown    (xbeB_Event + 386)
   #define xbeK_CTRL_SH_TAB    720905

   // ---------------------------------------------
   // Eventi aggiuntivi per il generato dBsee
   // ---------------------------------------------
   #define EVENT_MOUSE_DOWN     -100  // Gestito solo in dfInkey e dbAct

   #define EVENT_REALTIME       9997
   #define EVENT_KEYBOARD       9998
   #define EVENT_MENU_SELECTION 9999
   #define EVENT_OPENMENU       9996
   #define EVENT_OPENMENU_EXEC  9995
   #define EVENT_CODEBLOCK      9994

   // ---------------------------------------------
   // User event return values
   // ---------------------------------------------
   #define XBASE_APPEVENT_NONE       0    // Continue processing the event
   #define XBASE_APPEVENT_IGNORE     1    // Ignore event
   #define XBASE_APPEVENT_EXIT_ABORT 2    // Exit the reader event loop
   #define XBASE_APPEVENT_EXIT_OK    3    // Exit the reader event loop


   // -------------------------------------
   // Define applicazioni
   // -------------------------------------
   //#define APPLICATION_FONT (IIF(dfSet("XbaseApplicationFont")==NIL,FONT_COURIER_SMALL,dfSet("XbaseApplicationFont")))
   #define APPLICATION_FONT (IIF(dfSet("XbaseApplicationFont")==NIL,"10.Courier New",dfSet("XbaseApplicationFont")))
   #define BROWSE_FONT      (IIF(dfSet("XbaseBrowseFont")==NIL,APPLICATION_FONT,dfSet("XbaseBrowseFont")))

   #define COL_SIZE          8  // Larghezza di 1 colonna
   #define ROW_SIZE         22  // Altezza   di 1 colonna

   // #define SCREEN_MAX_ROW   25
   // #define SCREEN_MAX_COL   80

   #define APPCOLOR_SAY       1
   #define APPCOLOR_FUN       2
   #define APPCOLOR_FUNPROMPT 3
   #define APPCOLOR_GETPROMPT 4
   #define APPCOLOR_CHK       5
   #define APPCOLOR_RAD       6
   #define APPCOLOR_CMB       7
   #define APPCOLOR_SPN       8
   #define APPCOLOR_FUNBOX    9
   #define APPCOLOR_BACKGROUND 10
   #define APPCOLOR_GET        11
   #define APPCOLOR_GETFOCUS   12
   #define APPCOLOR_TXT        13
   #define APPCOLOR_TXTPROMPT  14
   #define APPCOLOR_BTN        15
   #define APPCOLOR_SPNPROMPT  16
   #define APPCOLOR_LSBPROMPT  17
   #define APPCOLOR_HILITE     18

   // ---------------
   // Windows Hot key
   // ---------------
   #define STD_HOTKEYCHAR   "~"

   // --------------------------------
   // Define per FORM/BROWSE:extStatus
   // --------------------------------
   #define DBOBJ_ES_OK                0
   #define DBOBJ_ES_ERR_RESOURCELOW  -1

//   // --------------------
//   // Define per S2ListBox
//   // --------------------
//   #define S2LISTBOX_OFFSET_LEFT   3
//   #define S2LISTBOX_OFFSET_BOTTOM 4
//   #define S2LISTBOX_OFFSET_TOP    24
//   #define S2LISTBOX_OFFSET_RIGHT  11

   // ------------------
   // Comandi aggiuntivi
   // ------------------
   #command ACCESSVAR <var> IN <objvar> ;
         => VAR <var>;; INLINE ACCESS ASSIGN METHOD <var>(xVar); RETURN IIF(xVar==NIL, <objvar>, <objvar>:=xVar)

   #command  DLLFUNCTION <Func>([<x,...>]) ;
                   USING <sys:CDECL,OSAPI,STDCALL,SYSTEM> ;
                   FROM <(Dll)> ;
                   NAME <(name)> ;
       => ;
             FUNCTION <Func>([<x>]);;
                LOCAL nDll:=DllLoad(<(Dll)>);;
                LOCAL xRet:=DllCall(nDll,__Sys(<sys>),<(name)>[,<x>]);;
                      DllUnLoad(nDll);;
               RETURN xRet

   #xcommand REPEAT        => while .t.
   #xcommand UNTIL <uExpr> => if <uExpr>; exit; end; end

   // -------------------------------------------------
   // Valori di ritorno per funzione S2WAPIGetDriveType
   // -------------------------------------------------
   #define S2WAPIGDT_ERROR             -1
   #define S2WAPIGDT_UNKNOWN            0
   #define S2WAPIGDT_NO_ROOT_DIR        1
   #define S2WAPIGDT_REMOVABLE          2
   #define S2WAPIGDT_FIXED              3
   #define S2WAPIGDT_REMOTE             4
   #define S2WAPIGDT_CDROM              5
   #define S2WAPIGDT_RAMDISK            6

   // --------------------------------------------------
   // Valori di ritorno per funzione S2AppDesktopChkSize
   // --------------------------------------------------
   #define S2APPDESKTOPSIZE_UNKNOWN     -1
   #define S2APPDESKTOPSIZE_640x480    100
   #define S2APPDESKTOPSIZE_800x600    200
   #define S2APPDESKTOPSIZE_1024x768   300
   #define S2APPDESKTOPSIZE_1152x864   350
   #define S2APPDESKTOPSIZE_1280x1024  400

   // --------------------------------------------------
   // Define per funzione dfEmailGeneric
   // --------------------------------------------------
   #define DFEMAILGENERIC_SMTP         "smtp"
   #define DFEMAILGENERIC_MAPI         "mapi"

#endif
