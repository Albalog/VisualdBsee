#include "common.ch"
// nFlags:
// #define OFN_READONLY                 0x00000001
// #define OFN_OVERWRITEPROMPT          0x00000002
// #define OFN_HIDEREADONLY             0x00000004
// #define OFN_NOCHANGEDIR              0x00000008
// #define OFN_SHOWHELP                 0x00000010
// #define OFN_ENABLEHOOK               0x00000020
// #define OFN_ENABLETEMPLATE           0x00000040
// #define OFN_ENABLETEMPLATEHANDLE     0x00000080
// #define OFN_NOVALIDATE               0x00000100
// #define OFN_ALLOWMULTISELECT         0x00000200
// #define OFN_EXTENSIONDIFFERENT       0x00000400
// #define OFN_PATHMUSTEXIST            0x00000800
// #define OFN_FILEMUSTEXIST            0x00001000
// #define OFN_CREATEPROMPT             0x00002000
// #define OFN_SHAREAWARE               0x00004000
// #define OFN_NOREADONLYRETURN         0x00008000
// #define OFN_NOTESTFILECREATE         0x00010000
// #define OFN_NONETWORKBUTTON          0x00020000
// #define OFN_NOLONGNAMES              0x00040000     // force no long names for 4.x modules
// #if(WINVER >= 0x0400)
// #define OFN_EXPLORER                 0x00080000     // new look commdlg
// #define OFN_NODEREFERENCELINKS       0x00100000
// #define OFN_LONGNAMES                0x00200000     // force long names for 3.x modules
// #endif /* WINVER >= 0x0400 */

// xWild = stringa es. "*.dbf"
// array 1 dimensione es {"*.dbf;*.ntx", "*.prg"}
// array 2 dimensioni es {{"File database (*.dbf,*.ntx)", "*.dbf;*.ntx"}, {"Sorgenti" "*.prg"}}
// usare ";" come separatore per le varie estensioni. Non usare SPAZI nella stringa delle estensioni
FUNCTION dfWinFileDlg(cPath, xWild, cTitle, cFile, nFlags, lSave)
   LOCAL cFilter := NIL
   LOCAL oWin := S2FormCurr()
   LOCAL hWnd
   LOCAL nInd
   LOCAL xRet
   LOCAL cSavePath := dfPathGet()

   IF oWin == NIL
      hWnd := 0
   ELSE
      hWnd := oWin:getHWnd()
   ENDIF

   DEFAULT cPath  TO dfCurPath()
   DEFAULT nFlags TO 0
   DEFAULT lSave  TO .F.

   IF ! EMPTY(xWild)
      IF VALTYPE(xWild) $ "CM"
         xWild := {xWild}
      ENDIF

      cFilter := ""

      FOR nInd = 1 TO LEN(xWild)
         IF VALTYPE(xWild[nInd]) == "A"
            cFilter += xWild[nInd][1]+CHR(0)+xWild[nInd][2]+CHR(0)
         ELSE
            cFilter += "File "+STRTRAN(xWild[nInd], "*.", "")+CHR(0)+xWild[nInd]+CHR(0)
         ENDIF
      NEXT
      cFilter += CHR(0)
   ENDIF

   xRet := _dfFileDlg(hWnd, cTitle, cPath, cFile, cFilter, nFlags, lSave)

   IF xRet == NIL
      xRet := ""
   ENDIF

   // Reimposto il path perchŠ la _dfFileDlg() lo sposta
   dfPathSet(cSavePath)

RETURN xRet

// FUNCTION OpenFile( oWin, cTitel, aFilter, cPath, nFlags )
// *********************************************************
// *
// * oWin = ParentWindow Objekt
// * cTitel = Titel of FileDialog
// * aFilter = Array with FilterStrings {{'Spooldateien (*.spl)','*.spl'},{...,...}...}
// * cPath = Startpath
// * nFlags = s.u.
//
//
// LOCAL hWnd := IIF(oWIn=NIL,SetAppWindow():getHWND(),oWin:getHWND())
// LOCAL cLeer := ''
// LOCAL cFilter := ''
// LOCAL cFileName := PADR('',256,CHR(0))
// LOCAL aOFN
// LOCAL cOFN
// LOCAL i
// LOCAL ret := ''
//
// cTitel = IIF(cTitel=NIL,'Öffne',cTitel)+CHR(0)
// aFilter = IIF(aFilter=NIL,{},aFilter)
// cPath = IIF(cPath=NIL,cLeer,cPath+CHR(0))
// nFlags = IIF(nFlags=NIL,0,nFlags)
//
// // Filterstring bilden
// IF LEN(aFilter) > 0
// FOR i = 1 TO LEN(aFilter)
// cFilter += aFilter[i,1]+CHR(0)+aFilter[i,2]+CHR(0)
// NEXT
// cFilter += CHR(0)
// ENDIF
//
// aOFN = BaInit(20) // BAP.DLL from Gernot Trautmann
//
// BaStruct(aOFN,76) // lStructSize
// BaStruct(aOFN,hWnd) // hwndOwner
// BaStruct(aOFN,@cLeer) // hInstance
// BaStruct(aOFN,@cFilter) // lpstrFilter
// BaStruct(aOFN,@cLeer) // lpstrCustomFilter
// BaStruct(aOFN,0) // nMaxCustFilter
// BaStruct(aOFN,1) // nFilterIndex
// BaStruct(aOFN,@cFileName) // lpstrFile
// BaStruct(aOFN,LEN(cFileName)) // nMaxFile
// BaStruct(aOFN,@cLeer) // lpstrFileTitle
// BaStruct(aOFN,0) // nMaxFileTitle
// BaStruct(aOFN,@cPath) // lpstrInitialDir
// BaStruct(aOFN,@cTitel) // lpstrTitle
// BaStruct(aOFN,nflags) // Flags
// BaStruct(aOFN,WORD) // nFileOffset
// BaStruct(aOFN,WORD) // nFileExtension
// BaStruct(aOFN,@cLeer) // lpstrDefExt
// BaStruct(aOFN,@cLeer) // lCustData
// BaStruct(aOFN,@cLeer) // lpfnHook
// BaStruct(aOFN,@cLeer) // lpTemplateName
//
// cOFN = BaAccess(aOFN)
//
// GetOpenFileNameA(cOFN)
//
// FOR i = 1 TO 8
// ret = BaExtract(aOFN)
// NEXT
//
// RETURN(IIF(LEFT(ret,1)=CHR(0),'',ret))

