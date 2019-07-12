/*****************************
* Source : test2.prg
* System : <unkown>
* Author : Phil Ide
* Created: 09/04/2003
*
* Purpose:
* ----------------------------
* History:
* ----------------------------
*    09/04/2003 13:00 PPI - Created
*****************************/

// Classe per disegnare uno sfondo di un XbasePart
// con colori riempiti in modalit… graduale
//
// Esempio:
//
//   CLASS TrigradientDialog FROM XbpDialog, trigradientPaint
//   EXPORTED
//      METHOD Init
//   ENDCLASS
//
//   METHOD _TriGradientForm:init( oParent, oOwner, aPos, aDim, aPres, lVis )
//      ::XbpDialog:init( oParent, oOwner, aPos, aDim, aPres, lVis )
//      ::trigradientPaint:init(::drawingArea)
//      ::setVertexColor(1,247, 247, 247)
//      ::setVertexColor(2,239, 231, 206)
//      ::setVertexColor(3,239, 231, 206)
//   RETURN self

#include "Common.ch"
#include "dll.ch"
#include "class.ch"

#define CRLF Chr(13)+Chr(10)

CLASS TriGradientPaint FROM GradientPaint
   EXPORTED:
      METHOD init
      METHOD buildVertex
ENDCLASS

METHOD TriGradientPaint:init( oParent, oOwner, aPos, aDim, aPres, lVis )
   ::GradientPaint:init( oParent, oOwner, aPos, aDim, aPres, lVis )
   aadd(::aColor,{w2bin(0),w2bin(0),w2bin(0xff00)})
   ::aColor[1] := {w2bin(0),w2bin(0),w2bin(0x0b00)}
   ::gRect += l2bin(2)
   ::gradientDirection := 2 // 0=horiz, v=vert, 2=triangle
   RETURN (self)

METHOD TriGradientPaint:buildVertex()
   ::vertex    := ::TriVertEx(1)+;
                  ::TriVertEx(2,::currentSize()[1]*2,0)+;
                  ::TriVertEx(2,0,::currentSize()[1]*2)
   RETURN (self)

CLASS GradientPaint
   PROTECTED:
      VAR aColor
      VAR gRect
      VAR gradientDirection
      VAR vertex
      VAR oParent

   EXPORTED:
      VAR bVertex
      VAR lGradientPaint

      METHOD init
      METHOD gradientpaint
      METHOD TriVertEx
      METHOD setVertexColor
      METHOD buildVertex
ENDCLASS

METHOD GradientPaint:init( oParent )
   ::oParent := oParent
   ::aColor := {{w2bin(0),w2bin(0),w2bin(0x8b00)},;
                {w2bin(0),w2bin(0),w2bin(0xff00)}}
   ::gRect := l2bin(0)+l2bin(1)
   ::gradientDirection := 0 // 0=horiz, v=vert, 2=triangle
   ::lGradientPaint    := .T.

   ::oParent:clipChildren := .T. //!::drawingArea:clipChildren
//   ::oParent:paint := {|aRect| self:gradientPaint(aRect) }
   ::oParent:paint := dfMergeBlocks(::oParent:paint, {|aRect| self:gradientPaint(aRect) })

RETURN (self)


METHOD GradientPaint:setVertexColor( nIndx, nRed, nGreen, nBlue )
   DEFAULT nRed TO 0,;
           nGreen TO 0,;
           nBlue TO 0,;
           nIndx TO 0

   IF nIndx > 0 .AND. nIndx <= len(::aColor)
      ::aColor[nIndx][1] := w2bin(nRed*256)
      ::aColor[nIndx][2] := w2bin(nGreen*256)
      ::aColor[nIndx][3] := w2bin(nBlue*256)
   ENDIF
RETURN (self)


METHOD GradientPaint:TriVertEx(nColor, nX, nY)
   LOCAL cBuff := ''

   DEFAULT nX TO 0, nY TO 0

   cBuff += l2bin(nX)               // x
   cBuff += l2bin(nY)               // y

   cBuff += ::aColor[nColor][1]
   cBuff += ::aColor[nColor][2]
   cBuff += ::aColor[nColor][3]

   cBuff += w2bin(0)                // alpha
RETURN cBuff

METHOD GradientPaint:buildVertex()
   ::vertex    := ::TriVertEx(1)+::TriVertEx(2,::currentSize()[1],::currentSize()[2])
RETURN (self)

METHOD GradientPaint:gradientpaint(aDim)
   STATIC cTemplate
   LOCAL nHdc
   LOCAL nVertLen
   LOCAL nGRectLen

   IF ! ::lGradientPaint // disabilitato?
      RETURN self
   ENDIF

   // Simone 15/7/2005
   // mantis 0000750: Run time in generazione. 
   // mantis 0000744: Run time in generazione in aggiornamento della Vdbwait.
   IF EMPTY(::oParent) .OR. EMPTY(::oParent:winDevice())
      RETURN self
   ENDIF

   nHdc := ::oParent:winDevice():getHDC()

   IF cTemplate == NIL
      //cTemplate := DLLPrepareCall("Msimg32",DLL_OSAPI,"GradientFill")
      cTemplate := DLLPrepareCall("gdi32.dll",DLL_OSAPI,"GdiGradientFill")
   ENDIF
   IF ::vertex = NIL
      IF ::bVertex == NIL
         ::buildVertex()
      ELSE
         ::vertex := Eval(::bVertex, self)
      ENDIF
   ENDIF
   nVertLen  := len(::vertex)/16
   nGRectLen := len(::grect)/(4*iif( ::gradientDirection > 1, 3, 2 ))

   DLLExecuteCall(cTemplate,nHdc,::vertex,nVertLen,::gRect,nGRectLen,::gradientDirection)
RETURN (self)