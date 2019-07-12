/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                             DLL interface                            |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFDLL_CH

   #define _DFDLL_CH

   // #xtranslate DllLoad([<list,...>]) => dfDllLoad(<list>, "_dbs_")
   #xtranslate DllLoad(<dll>) => dfDllLoad(<dll>, "_dbs_")

   #xcommand  FUNCTION <funcName>([<p1> [, <pN>]]) => ;
   FUNC <funcName>([<p1>] [, <pN>]);;
      STATIC __lDll___;;
      IF __lDll___ == NIL ;;
         __lDll___ := isFunction("_dbs_"+<"funcName">) ;;
      ENDIF ;;
      IF __lDll___;;
         RETURN &("_dbs_"+<"funcName">)([@<p1>] [, @<pN>]);;
      ENDIF;;
   RETURN __<funcName>([@<p1>] [, @<pN>]);;
   STATIC FUNC __<funcName>([<p1>] [, <pN>]);

   #xcommand  PROCEDURE <procName>([<p1> [, <pN>]]) => ;
   PROC <procName>([<p1>] [, <pN>]);;
      STATIC __lDll___;;
      IF __lDll___ == NIL ;;
         __lDll___ := isFunction("_dbs_"+<"procName">) ;;
      ENDIF ;;
      IF __lDll___;;
         &("_dbs_"+<"procName">)([@<p1>] [, @<pN>]);;
         RETURN;;
      ENDIF;;
      __<procName>([@<p1>] [, @<pN>]);;
   RETURN;;
   STATIC PROC __<procName>([<p1>] [, <pN>]);


//   #xcommand  FUNCTION <funcName>([<p1> [, <pN>]]) => ;
//   FUNC <funcName>([<p1>] [, <pN>]);;
//   RETURN IIF(isFunction("_dbs_"+<"funcName">), ;
//              &("_dbs_"+<"funcName">)([@<p1>] [, @<pN>]), ;
//                  __<funcName>([@<p1>] [, @<pN>]));;
//   STATIC FUNC __<funcName>([<p1>] [, <pN>]);
//
//   #xcommand  PROCEDURE <procName>([<p1> [, <pN>]]) => ;
//   PROC <procName>([<p1>] [, <pN>]);;
//     IIF(isFunction("_dbs_"+<"procName">), ;
//              &("_dbs_"+<"procName">)([@<p1>] [, @<pN>]), ;
//                  __<procName>([@<p1>] [, @<pN>]));;
//   RETURN;;
//   STATIC PROC __<procName>([<p1>] [, <pN>]);

//   #xcommand  FUNCTION <funcName>([<p1> [, <pN>]]) => ;
//   FUNC <funcName>([<p1>] [, <pN>]);;
//      STATIC __cDll ;;
//      LOCAL xRet;;
//      IF __cDLL == NIL ;;
//         __cDLL := dfDllPrepareCall("_dbs_"+<"funcName">);;
//      ENDIF;;
//      xRet := IIF(EMPTY(__cDLL), ;
//                  __<funcName>([@<p1>] [, @<pN>]), ;
//                  DLLExecuteCall(__cDLL [, @<p1>] [, @<pN>]));;
//   RETURN xRet;;
//   STATIC FUNC __<funcName>([<p1>] [, <pN>]);
//
//   #xcommand  PROCEDURE <procName>([<p1> [, <pN>]]) => ;
//   PROC <procName>([<p1>] [, <pN>]);;
//      STATIC __cDll ;;
//      IF __cDLL == NIL ;;
//         __cDLL := dfDllPrepareCall("_dbs_"+<"procName">);;
//      ENDIF;;
//      IIF(EMPTY(__cDLL), ;
//          __<procName>([@<p1>] [, @<pN>]), ;
//          DLLExecuteCall(__cDLL [, @<p1>] [, @<pN>]));;
//   RETURN;;
//   STATIC PROC __<procName>([<p1>] [, <pN>]);


//    #xtranslate DllLoad(<dll>) => DllLoad(<dll>, "_dbs_")
//
//    #xcommand  FUNCTION <funcName>([<list,...>]) => ;
//    FUNC <funcName>(<list>);;
//    RETURN &("_dbs_"+<"funcName">)(<list>);;
//    ;;
//    FUNC _dbs_<funcName>(<list>)
//
//    #xcommand  PROCEDURE <procName>([<list,...>]) => ;
//    PROC <procName>(<list>);;
//       &("_dbs_"+<"procName">)(<list>);;
//    RETURN;;
//    ;;
//    PROC _dbs_<procName>(<list>)


#endif
