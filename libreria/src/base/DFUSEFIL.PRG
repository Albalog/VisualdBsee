// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Description : Centralised file opening functions
// *****************************************************************************
#include "Common.ch"
#include "dfSet.ch"
#include "dfStd.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfUseFile( cFName, cAlias, lEsclusive, cDriver, lReadOnly, lNewArea )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.
DEFAULT lEsclusive TO .T.              // Exclusive use
DEFAULT cDriver    TO RDDSETDEFAULT()  // Used driver
DEFAULT lReadOnly  TO dfIsCDRom()      // READONLY
DEFAULT lNewArea   TO .T.              // New Area

IF EMPTY(cAlias)                       // Alias default
   cAlias := dfFindName( cFName )
ENDIF

#ifdef _IGNORE_THIS_ // non supportato
IF dfASDriver( cDriver )
   cAlias := SUBSTR( cAlias, RAT(":",cAlias)+1 )
ENDIF
#endif

// If the AXS is loaded change the RDD to the default RDD of the AXS
IF VALTYPE(cDriver) == "O"
   // Š gi… una DACSession, non faccio niente
//ELSEIF dfDACConnADSDDSession(@cFName, @cDriver) disattivato perche vengono aperti anche gli indici e potrebbe dare problemi!
   // esiste una DACSession, non faccio niente
ELSEIF dfAXSLoaded( cFName, cDriver )
   //cDriver := dfAXSDriver()
   cDriver := dfAxsSession()
ENDIF

#ifdef _IGNORE_THIS_ // non supportato
// Now is possible to use cript database. Link dBsee4cr.obj
IF dBsee4CR() .AND. !("-"+UPPER(cAlias)+"-"$"-DBDD-DBHLP-DBLOGIN-")
   cDriver := dfCRRDD()
   cFName  := "[" +dfSet( AI_CRIPTKEY ) +"]" +cFName
ENDIF
#endif

// DBFCDX of Clipper 5.2e has a BUGS if the database is opened with
// a different alias
// If the application run on CD-ROM dBsee open the database in
// READONLY MODE
DBUSEAREA( lNewArea, cDriver, cFName, cAlias, !lEsclusive, lReadOnly )

// simone 28/11/08
// supporto DBF criptati con ADS o ALS
dfADSDbfSetPwd(cFName)

// simone 22/11/07 se serve si pu• implementare codeblock anche all'apertura
// comunque ci sono gi… AI_OPENFILECB  e AI_CLOSEFILECB
//IF ! EMPTY(dfSet(AI_NETWORKCB))
//   EVAL(dfSet(AI_NETWORKCB), "open")
//ENDIF
RETURN DFISSELECT( cAlias )