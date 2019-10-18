// Compile with
//    XPP CONVDBF.PRG /M/N/W/Q/LINK
//
// Use
//    CONVDBF origdbf dbf2create [type_of_conversion]
//
// Example           
//    CONVDBF CUSTOMER CUSTFOX   -> converts CUSTOMER.DBF and CUSTOMER.DBT 
//                                  to CUSTFOX.DBF and CUSTFOX.FPT
//
//    CONVDBF CUSTFOX  CUSTOMER FOX2DBF
//                               -> converts CUSTFOX.DBF and CUSTFOX.FPT 
//                                  to CUSTOMER.DBF and CUSTOMER.DBF

PROCEDURE MAIN( cOri, cOut, cType)
   LOCAL aStru

   IF EMPTY(cType)
      cType := "DBF2FOX"
   ENDIF
   cType := UPPER(cType)

   IF cType == "DBF2FOX"
      // Convert from DBF+NTX to FOX+FPT
      USE (cOri) VIA DBFNTX
      aStru := DBSTRUCT()
      DBCREATE(cOut, aStru, "FOXCDX")
      USE
      ? "File created", cOut
      ? "Appending data from ", cOri, "..."
      USE (cOut) VIA FOXCDX
      APPEND FROM (cOri) VIA DBFNTX
      ? "Done."
   ELSE
      // Convert from FOX+FPT to DBF+NTX
      USE (cOri) VIA FOXCDX
      aStru := DBSTRUCT()
      CvtStru( aStru )

      DBCREATE(cout, aStru, "DBFNTX")
      USE

      ? "File created", cOut
      ? "Appending data from ", cOri, "..."
      USE (cOut) VIA DBFNTX 
      APPEND FROM (cOri) VIA FOXCDX
      ? "Done."
   ENDIF

RETURN

STATIC FUNCTION CvtStru(aStruct)
LOCAL n, cType
FOR n := 1 TO LEN(aStruct)  
   cType := aStruct[n][2]
   DO CASE
      CASE cType $ "I"
	aStruct[n][2] := "N"
	aStruct[n][3] := 5
   ENDCASE
NEXT

/*                                                                      
Mapping of FoxPro field types in the Xbase++ DDL 

  Description           Field type  Length   Field type  Valtype()    

                                                                      
  FoxPro                                     Xbase++                  

  Double                B           8        F           N            
  Character (text)  *)  C           1-254    C           C            
  Character (binary)    C           1-254    X           C            
  Date                  D           8        D           D            

  Float                 F           1-20     N           N            
  Generic               G           4        O           M            
  Long signed integer   I           4        I           N            
  Logical               L           1        L           L            
  Memo (text)       *)  M           4 or 10  M           M            
  Memo (binary)         M           4 or 10  V           M            
  Numeric               N           1-20     N           N            

  Time stamp            T           8        T           C            
  Currency              Y           8        Y           N            
*/
RETURN aStruct


//////////////////////////////////////////////////////////////////////
//
//  DBESYS.PRG
//
//  Copyright:
//      Alaska Software Inc., (c) 1998-2000. All rights reserved.
//
//  Contents:
//      Xbase++ DatabaseEngine startup/preloader
//
//  Syntax:
//      DbeSys() is called automatically at program start before the
//      function MAIN.
//
//////////////////////////////////////////////////////////////////////


#define MSG_DBE_NOT_LOADED   " database engine not loaded"
#define MSG_DBE_NOT_CREATED  " database engine could not be created"

*******************************************************************************
* DbeSys() is always executed at program startup
*******************************************************************************
PROCEDURE dbeSys()
/*
 *   The lHidden parameter is set to .T. for all database engines
 *   which will be combined to a new abstract database engine.
 */
LOCAL aDbes := { { "FOXDBE", .T.},;
                 { "CDXDBE", .T.},;
                 { "DBFDBE", .T.},;
                 { "NTXDBE", .T.} }
LOCAL aBuild :={ { "FOXCDX", 1, 2 }, ;
                 { "DBFNTX", 3, 4 }   }
LOCAL i

  /*
   *   Set the sorting order and the date format
   */
  SET COLLATION TO AMERICAN
  SET DATE TO AMERICAN

  /*
   *   load all database engines
   */
  FOR i:= 1 TO len(aDbes)
      IF ! DbeLoad( aDbes[i][1], aDbes[i][2])
         Alert( aDbes[i][1] + MSG_DBE_NOT_LOADED , {"OK"} )
      ENDIF
  NEXT i

  /*
   *   create database engines
   */
  FOR i:= 1 TO len(aBuild)
      IF ! DbeBuild( aBuild[i][1], aDbes[aBuild[i][2]][1], aDbes[aBuild[i][3]][1])
         Alert( aBuild[i][1] + MSG_DBE_NOT_CREATED , {"OK"} )
      ENDIF
  NEXT i

RETURN

//
// EOF

