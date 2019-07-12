/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                        ALASKA Clipper support                        |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFCLPSUP_CH
   #define _DFCLPSUP_CH

   // For multilingual support
   // ------------------------
   #xtranslate CDOW( <d> )              => _S2CDOW( <d> )
   #xtranslate CMONTH( <d> )            => _S2CMONTH( <d> )

   // This is for functions TRANS, TRANSF, ...
   // ----------------------------------------
   #translate TRANSFORM( <exp>, <picture> ) => TRANSFORM( <exp>, <picture> )

   // Translated functions
   // --------------------
   #xtranslate ALERT( <cMsg> [, <aOpt>] )  => dfAlert( <cMsg>, <aOpt> )
   #xtranslate FIELD( <x> )  => FIELDNAME( <x> )
   #xtranslate RDDSETDEFAULT( [<x>] )  => DbeSetDefault( <x> )

   // WorkAround functions
   // --------------------
   #xtranslate SQRT( <n> ) => SQRT_XPP( <n> )

   // #xtranslate DBCREATE( [<list,...>] )  => DBCREATE_XPP( <list> )
   // #xtranslate DBUSEAREA( [<list,...>] )  => DBUSEAREA_XPP( <list> )
   // #xtranslate DBAPPEND( [<list,...>] )  => DBAPPEND_XPP( <list> )

   #xtranslate DISPBEGIN([<list,...>])  => S2DispBegin( <list> )
   #xtranslate DISPEND([<list,...>])  => S2DispEnd( <list> )
   #xtranslate DISPCOUNT([<list,...>])  => S2DispCount( <list> )

   // Not supported functions
   // -----------------------
   #xtranslate ALTD( [<list,...>])  =>
   #xtranslate SAVESCREEN([<list,...>]) => ("")
   #xtranslate RESTSCREEN([<list,...>]) =>
   #xtranslate SCROLL([<list,...>]) =>

   // #xtranslate SETCURSOR([<list,...>]) => (0)

   // This enable the METHOD Scroll
   #xtranslate :scroll([<list,...>]) => :scroll(<list>)

   // This enable the METHOD SetColor
   #xtranslate :SetColor([<list,...>]) => :SetColor(<list>)

   // This disable the FUNCTION SetColor because we are in GUI environment
   #xtranslate SETCOLOR([<list,...>]) =>

   // This enable the METHOD Setpos
   #xtranslate :SetPos([<list,...>]) => :SetPos(<list>)

   // This disable the FUNCTION SetPos because we are in GUI environment
   #xtranslate SETPOS([<list,...>]) =>

#endif
