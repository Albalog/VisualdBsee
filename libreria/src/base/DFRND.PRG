//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' Varie
//Programmatore  : Baccan Matteo
//*****************************************************************************
//
//           NB_RND.PRG     FUNCTION
//
// CLAIM:    {This isn't gold, but...}
//
//           Returns a psuedo-random number between
//           zero (inclusive) and one (exclusive).
//
// DESIGNED BY:
//
//           Nathan C. Baker
//           HC 83 Box 49
//           Ellenboro, West Virginia
//           26346 U.S.A.
//
//           Phone: (304) 659-2026
//           CIS: 73514,1031
//
// WRITTEN IN:
//
//           CA-Clipper 5.x
//           (Should work with all six flavors)
//
// TERMS:
//
//           This function (source code, object, and executable) are
//           placed in the public domain.  As PUBLIC DOMAIN software,
//           it may be used by anyone for any purpose without fee or
//           charge of any kind from me.  If you can make money from
//           it, please do.  If you want to take credit for it, be my
//           guest.  I developed the main algorithm in the Spring of
//           1993 in response to Clipper's lack of such a function.
//           Uploaded to CompuServe on December 27, 1993.  Object
//           compiled using CA-Clipper 5.2c.  Please feel free to
//           disperse these files to other online services, bulletin
//           board systems (BBS), or library collections.  I wish
//           you the best of luck converting the algorithm to other
//           languages and/or platforms.
//


#define Pi 3.14159265358979   // One natural number.
#define Epsilon Exp(1)        // Another natural number.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfRnd() //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

LOCAL nA, nB, nC, nD
STATIC nClock := 0
STATIC nSeed := 0

IF nClock == 0
     nClock := nSeed := Seconds()
ENDIF
IF nClock == Seconds()
     nSeed := nSeed * Pi/Epsilon
ELSE
     nClock := nSeed := Seconds()
ENDIF
IF nSeed == 0                 // When the clock strikes midnight,
     nSeed := Pi + Epsilon    // the mouse takes another byte.
ENDIF

nA := (nSeed * 100) / (Pi - Int(Pi) + Epsilon - Int(Epsilon))
nB := (nA - Int(nA)) / nSeed
nC := nB + 1 / If(nB == 0, Pi + Epsilon, nB)
nD := Exp(nB + Log(nC)) - Int(Exp(nB + Log(nC)))

RETURN nD

//--------------------------------------------------------
// This function takes advantage of the error introduced
// when subtracting the Int(x) from x as illustrated below:
//
// 9110939.05395725200000000
// 0000000.05395725183188915
//
// The first number above is x and the second number is x - Int(x).
//
//--------------------------------------------------------
// All values obtained with CA-Clipper 5.2c running on a
// non-Intel 386sx with no co-processor (saving money for
// a DEC Alpha machine because Santa didn't bring it <G>).
//--------------------------------------------------------
