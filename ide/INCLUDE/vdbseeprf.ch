/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2008 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                          PROFILER interface                          |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _VDBSEEPRF_CH
   #define _VDBSEEPRF_CH

   #define __DFPROFILER_ENABLED__
   #define __XPP_PROFILE__

   #pragma Library("VDBSEE1PRF.lib")

   #xcommand RETURN => dfProfEndCall(PROCNAME(), 0);RETU
   #xcommand RETURN <exp> => _prf_x_:= (<exp>); dfProfEndCall(PROCNAME(), 0);RETU _prf_x_
   #xcommand RETURN () => dfProfEndCall(PROCNAME(), 0);RETU
   #xcommand RETURN (<exp>) => _prf_x_:= (<exp>); dfProfEndCall(PROCNAME(), 0);RETU _prf_x_
   #xcommand RETURN() => dfProfEndCall(PROCNAME(), 0);RETU
   #xcommand RETURN(<exp>) => _prf_x_:= (<exp>); dfProfEndCall(PROCNAME(), 0);RETU _prf_x_

   #xcommand  FUNCTION <funcName>([<p1> [, <pN>]]) => ;
   FUNC <funcName>([<p1>] [, <pN>]);;
      LOCAL _prf_x_:= dfProfStartCall(PROCNAME(), PROCLINE(1), [@<p1>] [, @<pN>]);

   #xcommand  PROCEDURE <procName>([<p1> [, <pN>]]) => ;
   PROC <procName>([<p1>] [, <pN>]);;
      LOCAL _prf_x_:= dfProfStartCall(PROCNAME(), PROCLINE(1), [@<p1>] [, @<pN>]);

   #xcommand  STATIC FUNCTION <funcName>([<p1> [, <pN>]]) => ;
   STATIC FUNC <funcName>([<p1>] [, <pN>]);;
      LOCAL _prf_x_:= dfProfStartCall(PROCNAME(), PROCLINE(1), [@<p1>] [, @<pN>]);

   #xcommand  STATIC PROCEDURE <procName>([<p1> [, <pN>]]) => ;
   STATIC PROC <procName>([<p1>] [, <pN>]);;
      LOCAL _prf_x_:= dfProfStartCall(PROCNAME(), PROCLINE(1), [@<p1>] [, @<pN>]);

   #xcommand  INIT PROCEDURE <procName>([<p1> [, <pN>]]) => ;
   INIT PROC <procName>([<p1>] [, <pN>]);;
      LOCAL _prf_x_:= dfProfStartCall(PROCNAME(), PROCLINE(1), [@<p1>] [, @<pN>]);

   #xcommand  EXIT PROCEDURE <procName>([<p1> [, <pN>]]) => ;
   EXIT PROC <procName>([<p1>] [, <pN>]);;
      LOCAL _prf_x_:= dfProfStartCall(PROCNAME(), PROCLINE(1), [@<p1>] [, @<pN>]);

   #xcommand  INIT PROCEDURE <procName> => ;
   INIT PROC <procName>;;
      LOCAL _prf_x_:= dfProfStartCall(PROCNAME(), PROCLINE(1));

   #xcommand  EXIT PROCEDURE <procName> => ;
   EXIT PROC <procName>;;
      LOCAL _prf_x_:= dfProfStartCall(PROCNAME(), PROCLINE(1));

#endif