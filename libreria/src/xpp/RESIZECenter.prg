#include "Common.ch"
#include "xbp.ch"

// Simone 13/3/06
// mantis 0001003: migliorare resize nelle form

//-----------------------------------------------------------------------------
CLASS ResizeCenter
//-----------------------------------------------------------------------------
EXPORTED:
   METHOD resizeDataArea      // called from the resize event callback slot
   INLINE METHOD GETaResizeList(); RETURN ::aResizeList
   INLINE METHOD GETaCenter();     RETURN ::aCenter 
   INLINE METHOD GETaOrgSize();    RETURN ::aOrgSize


PROTECTED:
   DEFERRED METHOD resizeArea // this method has to return the Xbase Part which
                              // is the parent of the resize objects (resize parent)
                              // TO IMPLEMENT IN THE DERIVED CLASS !!!
   METHOD resizeInit          // see implementation
   METHOD resizeControl       
   METHOD _calcResize

HIDDEN:
   VAR _getFrameState
   VAR aResizeList
   VAR aCenter
   VAR aOrgSize               // original size of resize parent
ENDCLASS

METHOD ResizeCenter:resizeInit( aResizeList, aCenter )  
   LOCAL nMax, n

   IF EMPTY(aResizeList) .OR. EMPTY(aCenter)
      RETURN self
   ENDIF

   ::aOrgSize       := ::resizeArea():currentSize()
   ::aResizeList    := ACLONE(aResizeList)
   ::aCenter        := ACLONE(aCenter)
   ::_getFrameState := NIL

   nMax := MIN(LEN(aResizeList), LEN(aCenter))

   IF LEN(::aResizeList) > nMax
      ASIZE(::aResizeList, nMax)
   ENDIF
   IF LEN(::aCenter) > nMax
      ASIZE(::aCenter, nMax)
   ENDIF
   FOR n := 1 TO nMax
      ::_calcResize(::aResizeList[n], aCenter[n])
   NEXT

   // set the resize event callback slot
   ::resizeArea():Resize := dfMergeBlocks(::resizeArea():Resize, ;
                                          {| mp1, mp2, obj | ::resizeDataArea( mp1, mp2 ) })

RETURN self

//-----------------------------------------------------------------------------
METHOD ResizeCenter:_calcResize( aResizeList, aCenter ) 
//
// [aResizeList]: array with childs of the resize parent.
//
// All objects in this list will be resized according to their position in the
// window. All child not in this list will be moved according to their position
// in the window but will not change their size.
//-----------------------------------------------------------------------------
   LOCAL i, n, j
   LOCAL numChilds
   LOCAL aPos
   LOCAL aSize
   LOCAL oObj
   LOCAL nEndX
   LOCAL nEndY
   LOCAL lOnBase 
   LOCAL aRescan

   IF EMPTY(aCenter)
      RETURN self
   ENDIF

   IF aCenter[1] <= 0 .AND. aCenter[2] <= 0
      RETURN self
   ENDIF

   IF aCenter[1] <= 0
      aCenter[1] := 1000000
   ELSEIF aCenter[2] <= 0
      aCenter[2] := 1000000
   ENDIF

   numChilds    := LEN( aResizeList )
   aRescan      := {}

   FOR i:=1 TO numChilds
      oObj := aResizeList[i]
//      IF VALTYPE(oObj) != "O"
//         AREMOVE(::aResizeList, i)
//         i--
//         numChilds--
//         LOOP
//      ENDIF

      aSize := oObj:currentSize()
      aPos := ACLONE( oObj:currentPos() )

      // se l'oggetto non Š nel ResizeStatic
      // potrebbe essere in un groupbox dentro il ResizeStatic
      // (vedi S2Form:adjustParents())
      // quindi calcolo la posizione rispetto al ResizeStatic
      lOnBase := oObj:setParent() == ::resizeArea()
      IF ! lOnBase
         aPos := dfCalcAbsolutePosition(aPos, oObj:setParent(), ::resizeArea())
      ENDIF

      AADD(aPos, aSize[1])
      AADD(aPos, aSize[2])

      // cerco il quadrante
      nEndX := aPos[1]+aSize[1]
      nEndY := aPos[2]+aSize[2]

      IF nEndX < aCenter[1]
         nEndX := -1 // quadrante sx
         IF nEndY < aCenter[2]
            nEndY := -1 // quadrante basso/sx
         ELSEIF aPos[2] > aCenter[2]
            nEndY := +1 // quadrante alto/sx
         ELSE
            nEndY := 0  // quadrante centro/sx
         ENDIF

      ELSEIF aPos[1] > aCenter[1]
         nEndX := +1 // quadrante dx
         IF nEndY < aCenter[2]
            nEndY := -1 // quadrante basso/dx
         ELSEIF aPos[2] > aCenter[2]
            nEndY := +1 // quadrante alto/dx
         ELSE
            nEndY := 0  // quadrante centro/dx
         ENDIF
      ELSE
         nEndX := 0 // quadrante centro
         IF nEndY < aCenter[2]
            nEndY := -1 // quadrante basso/centro
         ELSEIF aPos[2] > aCenter[2]
            nEndY := +1 // quadrante alto/centro
         ELSE
            nEndY := 0  // quadrante centro/centro
         ENDIF
      ENDIF

      AADD(aPos, nEndX)
      AADD(aPos, nEndY)

      // salvo posizione reale del control (non quella assoluta)
      aPos[1] := oObj:currentPos()[1]
      aPos[2] := oObj:currentPos()[2]
      aResizeList[i] := {oObj, aPos}

      // Correzione: se il control Š in un BOX
      // e sarebbe da spostare (X o Y) lo salvo 
      // per il controllo sottostante
      IF (! lOnBase) .AND. (nEndX==1 .OR. nEndY==1)
         AADD(aRescan, {i, oObj:setParent()})
      ENDIF
   NEXT

   // Correzione: se il control Š in un BOX
   // e sarebbe da spostare (X o Y) 
   // allora disabilito lo spostamento 
   // perchŠ Š gestito automaticamente 
   // quando sposto il BOX
   FOR j := 1 TO LEN(aRescan)
      i := aRescan[j][1]
      oObj := aRescan[j][2]
      n := ASCAN(aResizeList, {|x|x[1] == oObj})
      IF n > 0
         aPos := aResizeList[i][2]
         // se devo spostare a DX e il BOX Š da spostare a DX
         // disabilito spostamento control
         IF aPos[5] == 1 .AND. aResizeList[n][2][5] == 1
            aPos[5] := -1
         ENDIF
         // se devo spostare in ALTO e il BOX Š da spostare in ALTO
         // disabilito spostamento control
         IF aPos[6] == 1 .AND. aResizeList[n][2][6] == 1
            aPos[6] := -1
         ENDIF
      ENDIF
   NEXT

RETURN self

//-----------------------------------------------------------------------------
METHOD ResizeCenter:resizeDataArea( aOldSize, aNewSize )
//
// for all childs: calculate their new position and size relative to their
//                 original position
//-----------------------------------------------------------------------------
   LOCAL i, n := 0, nPage := 0
   LOCAL aOrgDelta
   LOCAL oObj

   // calculate delta between original size and new size
   aOrgDelta := { aNewSize[1] - ::aOrgSize[1], aNewSize[2] - ::aOrgSize[2] }

// simone d 16/2/07 questo controllo non va bene
// in caso si apra form->massimizza->minimizza
//   IF aOrgDelta[1]==0 .AND. aOrgDelta[2]==0
//      RETURN self
//   ENDIF

   // simone d 23/4/07 correzione per resize errato quando si minimizza/massimizza finestra
   oObj := self
   IF ! oObj:isDerivedFrom("XbpDialog")
      oObj := dfGetParentForm(oObj)
   ENDIF
   IF ! EMPTY(oObj)
      IF oObj:getFrameState() == XBPDLG_FRAMESTAT_MINIMIZED
         ::_getFrameState := XBPDLG_FRAMESTAT_MINIMIZED
         RETURN self
      ENDIF
   ENDIF
   IF ::_getFrameState == XBPDLG_FRAMESTAT_MINIMIZED
      ::_getFrameState := NIL
      RETURN self
   ENDIF

   ::resizeArea():lockUpdate(.T.)

   FOR nPage := 1 TO LEN(::aResizeList)

      IF EMPTY(::aCenter[nPage])
         LOOP
      ENDIF

      IF ::aCenter[nPage][1] < 0 .AND. ::aCenter[nPage][2] < 0
         LOOP
      ENDIF

      n := LEN( ::aResizeList[nPage] )

      // set new position and size for all childs
      FOR i:=1 TO n
          ::resizeControl(::aResizeList[nPage][i][1], ::aResizeList[nPage][i][2], aOrgDelta)
      NEXT
   NEXT

   ::resizeArea():lockUpdate(.F.)
   ::resizeArea():invalidateRect()
RETURN self

METHOD ResizeCenter:resizeControl(oObj, aOrig, aOrgDelta )
   LOCAL nX := aOrgDelta[1]
   LOCAL nY := aOrgDelta[2]

   nX := MAX(nX, 0)
   nY := MAX(nY, 0)

   IF aOrig[5] == -1
      IF aOrig[6] == -1
         // sono nel quadrante basso/sx, ripristino posiz. originale
         oObj:setPos(  {aOrig[1], aOrig[2]}, .F. )
      ELSEIF aOrig[6] == +1
         // sono nel quadrante alto/sx, SPOSTO in ALTO
         oObj:setPos(  {aOrig[1], aOrig[2]+nY}, .F. )
      ELSE
         // sono nel quadrante centro/sx, ridimensiono Y
         oObj:setSize( {aOrig[3], aOrig[4]+nY}, .F. )
      ENDIF

   ELSEIF aOrig[5] == +1
      IF aOrig[6] == -1
         // sono nel quadrante basso/dx, SPOSTO a DESTRA
         oObj:setPos(  {aOrig[1]+nX, aOrig[2]}, .F. )
      ELSEIF aOrig[6] == +1
         // sono nel quadrante alto/dx, SPOSTO in ALTO e a DESTRA
         oObj:setPos(  {aOrig[1]+nX, aOrig[2]+nY}, .F. )
      ELSE
         // sono nel quadrante centro/dx, SPOSTO a DESTRA e ridimensiono Y
         oObj:setPosAndSize(  {aOrig[1]+nX, aOrig[2]}, {aOrig[3], aOrig[4]+nY}, .F. )
      ENDIF

   ELSE
      IF aOrig[6] == -1
         // sono nel quadrante basso/centro, ridimensiono X
         oObj:setSize( {aOrig[3]+nX, aOrig[4]}, .F. )
      ELSEIF aOrig[6] == +1
         // sono nel quadrante alto/centro, SPOSTO in ALTO e ridimensiono X
         oObj:setPosAndSize(  {aOrig[1], aOrig[2]+nY}, {aOrig[3]+nX, aOrig[4]}, .F. )
      ELSE
         // sono nel quadrante centro/centro, ridimensiono X e Y
         oObj:setSize( {aOrig[3]+nX, aOrig[4]+nY}, .F. )
      ENDIF
   ENDIF
//oobj:invalidateRect()
   // se sono sotto dimensioni Y minime allineo i controls in alto
//   nY := aOrgDelta[2]
//   IF nY < 0
//      oObj:setPos({oObj:currentPos()[1], oObj:currentPos()[2]+nY}, .t.)
//   ENDIF
RETURN self
