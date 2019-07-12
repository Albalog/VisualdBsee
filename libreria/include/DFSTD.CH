/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                          STANDARD functions                          |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFSTD_CH
   #define _DFSTD_CH

   #stdout Visual dBsee The STANDARD CASE for Xbase++ by Albalog Srl

   #define WEND  END

   #define DFISSELECT( cFile )   SELECT(cFile)#0

   #define DFCOMPILE( cString )  &("{||" +cString +"}")

   #define DFDISPBEGIN()         M_CurOff();DISPBEGIN()
   #define DFDISPEND()           DISPEND();M_CurOn()

   #ifdef __XPP__
      #xtranslate DFAADD(<x>, <y>, <z> ) => ( AADD(<x>, <y>, <z>) )
   #else
      #xtranslate DFAADD(<x>, <y>, <z> ) => ( AADD(<x>, NIL);AINS(<x>, <z>);<x>\[<z>\]:=<y>)
   #endif

   #ifdef __XPP__
      #xtranslate DFAERASE(<aSrc>,<nInd>) => (AREMOVE(<aSrc>, <nInd>))
   #else
      #xtranslate DFAERASE(<aSrc>,<nInd>) => (ADEL( <aSrc>, <nInd> );ASIZE( <aSrc>, LEN( <aSrc> )-1 ))
   #endif

   #xtranslate DFXPPCLRSELECT( <xbase>, <clp>) => <xbase>

   #define CRLF                  CHR(13)+CHR(10)
   #define NEWPAGE               CHR(12)

   #define USE_FLOAT             "0"
   #define USE_EXCLUSIVE         "1"
   #define USE_SHARED            "2"

   #define NTX_DBDD              1
   #define NTX_DBTABD            2
   #define NTX_DBHLP             4

   // VGA Modes

   #define VGA_80x25x16        3
   #define VGA_640x350x16     16
   #define VGA_640x480x16     18
   #define VGA_320x200x256    19

   #command ???  [ <list,...> ] => FWRITE( 1, CRLF ) ; FWRITE( 1, <list> )
   #command ???? [ <list,...> ] => FWRITE( 1, <list> )

   #xcommand IF EMPTY <v1> ASSIGN <x1> [, <vn> ASSIGN <xn> ] ;
             =>                                      ;
             IF EMPTY(<v1>); <v1> := <x1> ; END      ;
             [; IF EMPTY(<vn>); <vn> := <xn> ; END ]

   #ifndef __HARBOUR__
      #xcommand UPPERCASE <v1> [, <vn> ]   ;
                =>                         ;
                <v1> := UPPER( <v1> )      ;
                [; <vn> := UPPER( <vn> ) ]

      #xcommand LOWERCASE <v1> [, <vn> ]   ;
                =>                         ;
                <v1> := LOWER( <v1> )      ;
                [; <vn> := LOWER( <vn> ) ]

      #xcommand INCREASE <v1> WITH <n1> [ RANGE <r1> TO <r2> ]  ;
                =>                                              ;
                <v1> := <v1> + <n1>                             ;
                [; IF <v1> > <r2> ; <v1> := <r1> ; END ]

      #xcommand DECREASE <v1> WITH <n1> [ RANGE <r1> TO <r2> ]  ;
                =>                                              ;
                <v1> := <v1> - <n1>                             ;
                [; IF <r1> > <v1> ; <v1> := <r2> ; END ]

      #xcommand IF EMPTY <v1> DELETE [, <vn> DELETE ] ;
                =>                                    ;
                IF EMPTY(<v1>); <v1> := NIL ; END     ;
                [; IF EMPTY(<vn>); <vn> := NIL  ; END ]

      #xcommand IF DIFFERENT <v1> AND <x1> REPLACE    ;
                =>                                    ;
                IF !( (<v1>)==(<x1>) ); <v1> := <x1> ; END
   #endif

   // MEMVAR Definition

   #command LOCAL <xIdentifier,...> AS STRING       => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS CHAR         => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS MEMO         => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS INT          => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS LONG DOUBLE  => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS LONG         => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS WORD         => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS OBJECT       => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS LOGICAL      => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS ARRAY        => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS BLOCK        => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS DATE         => ;
           LOCAL <xIdentifier>

   #command LOCAL <xIdentifier,...> AS CODEBLOCK    => ;
           LOCAL <xIdentifier>

   #ifdef __XPP__
      #include "dfClpsup.ch"
      #include "dfxres.ch"
   #endif

   #ifdef __XPP__
      // Fix for problems in division by 0
      #xtranslate DFFIXDIV(<x>, <y> ) => ( IIF(<y>==0, 0, <x> / <y>) )
   #else
      #xtranslate DFFIXDIV(<x>, <y> ) => (<x> / <y>)
   #endif


   #ifdef __XPP__
      #xtranslate DFCHAR(<x>, <y> ) => ( <x>\[<y>\] )
   #else
      #xtranslate DFCHAR(<x>, <y> ) => ( SUBSTR(<x>, <y>, 1) )
   #endif

   // Change functions on the fly
   #xcommand  SUBSFUNCTION <funcName>([<p1> [, <pN>]]) => ;
   FUNC <funcName>([<p1>] [, <pN>]);;
   RETURN IIF(isFunction("_dbs_"+<"funcName">), ;
              &("_dbs_"+<"funcName">)([@<p1>] [, @<pN>]), ;
                  __<funcName>([@<p1>] [, @<pN>]));;
   STATIC FUNC __<funcName>([<p1>] [, <pN>]);

   #xcommand  SUBSPROCEDURE <procName>([<p1> [, <pN>]]) => ;
   PROC <procName>([<p1>] [, <pN>]);;
     IIF(isFunction("_dbs_"+<"procName">), ;
              &("_dbs_"+<"procName">)([@<p1>] [, @<pN>]), ;
                  __<procName>([@<p1>] [, @<pN>]));;
   RETURN;;
   STATIC PROC __<procName>([<p1>] [, <pN>]);


  #command  TSTATIC <fld1> [:= <val1>] [[,] <fldN> [:= <valN>] ] ;
      =>  dfTSV_Register(<"fld1">, <val1>, __FILE__, __FILEPATH__) [; dfTSV_Register(<"fldN">,  <valN>, __FILE__, __FILEPATH__)]

//      =>  FIELD-><fld1> := <val1> [; FIELD-><fldN> := <valN>]

#endif
