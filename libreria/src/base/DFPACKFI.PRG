/*******************************************************************************
Progetto       : dBsee 4.4
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
// Metodi implementati :=   0 : Storing
//                          1 : Rle
//                          2 : Pair

#include "Common.ch"
#include "dfPack.ch"

#define MHEAD_SIGNATURE           1
#define MHEAD_MAXVER              2
#define MHEAD_MINVER              3
#define MHEAD_DATE                4
#define MHEAD_TIME                5
#define MHEAD_CRC32               6
#define MHEAD_COMPSIZE            7
#define MHEAD_UNCOSIZE            8
#define MHEAD_NAMELEN             9
#define MHEAD_FILENAME           10

#define CHUNK_LEN                 1
#define CHUNK_BUFFER              2

#define MPACKER_SIGNATURE        aPar[1]
#define MPACKER_BUFFERLEN        aPar[2]
#define MPACKER_MAXVER           aPar[3]
#define MPACKER_MINVER           aPar[4]
#define MPACKER_ROW              aPar[5]

STATIC aPar := {"TWT!",16000,0,1,0} // 65516 == MAX Clipper Character len
//* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
//FUNCTION main (z,x,c,v)
//* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
//RETURN dfPackFile(z,x,c,{|a,b|dfPro( MPACKER_ROW, 10, 50, a, b, "W+/B" )})

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfPackFile( cSource, cOutput, cPar, bWhile )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL nTotal    := 0
LOCAL nTotalCmp := 0
LOCAL nStartTime, nEndTime
LOCAL nHanIn, nHanOut, cInputBuffer, nInput, nChunk, nFileSize
LOCAL aHeader, aChunk, cOutputBuffer
LOCAL lRet := .T.

DEFAULT bWhile TO {||NIL}

MPACKER_ROW := ROW()

nHanIn       := FOPEN( cSource )
nHanOut      := FCREATE( cOutput )
cInputBuffer := SPACE(MPACKER_BUFFERLEN)
DO CASE
   CASE cPar==MPACKER_COMPRESS
        nFileSize := dfFileSize( nHanIn )

        nStartTime := SECONDS()

        MWriteHeader( nHanOut      ,; // Handle
                      ""           ,; // MHEAD_DATE
                      ""           ,; // MHEAD_TIME
                      0            ,; // MHEAD_CRC32
                      nFileSize    ,; // MHEAD_COMPSIZE
                      nFileSize    ,; // MHEAD_UNCOSIZE
                      LEN(cSource) ,; // MHEAD_NAMELEN
                      cSource       ) // MHEAD_FILENAME

        WHILE (nInput:=FREAD( nHanIn, @cInputBuffer, MPACKER_BUFFERLEN ))>0
           cOutputBuffer := MPack( LEFT( cInputBuffer, nInput ) )
           nTotalCmp += MWriteChunk( nHanOut, cOutputBuffer )
           nTotal    += nInput
           EVAL( bWhile, nTotal, nFileSize )
        ENDDO

        nEndTime   := SECONDS()

   CASE cPar==MPACKER_EXPAND
        aHeader := MReadHead( nHanIn )

        nFileSize := dfFileSize( nHanOut )
        nTotal    := 0
        IF MHeadSig( aHeader )==MPACKER_SIGNATURE
           WHILE .T.
              IF (aChunk:=MReadChunk( nHanIn ))==NIL
                 EXIT
              ENDIF

              cInputBuffer := MDePack( aChunk )
              FWRITE( nHanOut, cInputBuffer, LEN(cInputBuffer) )

              nTotal += MChunkLen( aChunk ) +4
              EVAL( bWhile, nTotal, nFileSize )
           ENDDO
        ELSE
           lRet := .F.
        ENDIF
ENDCASE

FCLOSE( nHanIn  )
FCLOSE( nHanOut )

#ifdef DEBUG

//
// Database with compression results
//

IF cPar==MPACKER_COMPRESS
   IF !FILE("Result.dbf")
      DBCREATE("result",{ ;
                          {"cFile"  ,"C",30,0},;
                          {"nLen"   ,"N", 7,0},;
                          {"nCmp"   ,"N", 7,0},;
                          {"nRatio" ,"N", 6,3},;
                          {"nSec"   ,"N", 6,2},;
                          {"dDate"  ,"D", 8,0},;
                          {"cBufLen","N", 5,0} ;
                        })
   ENDIF

   USE result NEW
   APPEND BLANK

   result->cFile   := cSource
   result->nLen    := nTotal
   result->nCmp    := nTotalCmp
   result->nRatio  := nTotalCmp*100/nTotal
   result->nSec    := nEndTime-nStartTime
   result->dDate   := DATE()
   result->cBufLen := MPACKER_BUFFERLEN

   CLOSE

   ? "谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪目"
   ? "� File                                                       砇atio 砈econds �"
   ? "媚哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪呐哪哪哪拍哪哪哪拇"
   ? "�" +PADR(cSource,60) +"�" +TRANSFORM(nTotalCmp*100/nTotal,"999.99") +"�" +TRANSFORM(nEndTime-nStartTime," 9999.99") +"�"
   ? "滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪馁"
ENDIF

#endif

RETURN lRet

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC FUNCTION MReadHead( nHandle )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL aParameter   := {,,,,,,,,,}
LOCAL cInputBuffer := SPACE(1024)
LOCAL cFileNameLen

// TWT! Signature
FREAD( nHandle, @cInputBuffer, 4 )
aParameter[MHEAD_SIGNATURE] := LEFT(  cInputBuffer,4)

// Version need to extract
FREAD( nHandle, @cInputBuffer, 2 )
aParameter[MHEAD_MAXVER   ] := ASC(LEFT(  cInputBuffer,1))
aParameter[MHEAD_MINVER   ] := ASC(RIGHT( cInputBuffer,1))

// DOS Date & Time
FREAD( nHandle, @cInputBuffer, 4 )
aParameter[MHEAD_DATE     ] := RIGHT( cInputBuffer,2)
aParameter[MHEAD_TIME     ] := RIGHT( cInputBuffer,2)

// CRC 32
FREAD( nHandle, @cInputBuffer, 4 )
aParameter[MHEAD_CRC32    ] := BIN2L( cInputBuffer  )

// Compressed file SIZE
FREAD( nHandle, @cInputBuffer, 4 )
aParameter[MHEAD_COMPSIZE ] := BIN2L( cInputBuffer  )

// UnCompressed file SIZE
FREAD( nHandle, @cInputBuffer, 4 )
aParameter[MHEAD_UNCOSIZE ] := BIN2L( cInputBuffer  )

// LEN o file name
FREAD( nHandle, @cInputBuffer, 2 )
aParameter[MHEAD_NAMELEN  ] := BIN2W( cInputBuffer  )

// File Name
FREAD( nHandle, @cInputBuffer, MHeadNameL( aParameter ) )
aParameter[MHEAD_FILENAME ] := LEFT( cInputBuffer, MHeadNameL( aParameter ) )

RETURN aParameter

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC FUNCTION MHeadSig(   aParameter ); RETURN aParameter[MHEAD_SIGNATURE]
STATIC FUNCTION MHeadMaxVe( aParameter ); RETURN aParameter[MHEAD_MAXVER   ]
STATIC FUNCTION MHeadMinVe( aParameter ); RETURN aParameter[MHEAD_MINVER   ]
STATIC FUNCTION MHeadDate(  aParameter ); RETURN aParameter[MHEAD_DATE     ]
STATIC FUNCTION MHeadTime(  aParameter ); RETURN aParameter[MHEAD_TIME     ]
STATIC FUNCTION MHeadCrc32( aParameter ); RETURN aParameter[MHEAD_CRC32    ]
STATIC FUNCTION MHeadCompS( aParameter ); RETURN aParameter[MHEAD_COMPSIZE ]
STATIC FUNCTION MHeadUnCoS( aParameter ); RETURN aParameter[MHEAD_UNCOSIZE ]
STATIC FUNCTION MHeadNameL( aParameter ); RETURN aParameter[MHEAD_NAMELEN  ]
STATIC FUNCTION MHeadFileN( aParameter ); RETURN aParameter[MHEAD_FILENAME ]
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC PROCEDURE MWriteHeader( nHanOut    ,; // Handle
                        cDate      ,; // MHEAD_DATE
                        cTime      ,; // MHEAD_TIME
                        nCrc32     ,; // MHEAD_CRC32
                        nFileSizeC ,; // MHEAD_COMPSIZE
                        nFileSizeU ,; // MHEAD_UNCOSIZE
                        nLenName   ,; // MHEAD_NAMELEN
                        cName       ) // MHEAD_FILENAME
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FWRITE( nHanOut, MPACKER_SIGNATURE   )
FWRITE( nHanOut, CHR(MPACKER_MAXVER) )
FWRITE( nHanOut, CHR(MPACKER_MINVER) )
FWRITE( nHanOut, PADR(cTime,2)       )
FWRITE( nHanOut, PADR(cDate,2)       )
FWRITE( nHanOut, L2BIN(nCrc32)       )
FWRITE( nHanOut, L2BIN(nFileSizeC)   )
FWRITE( nHanOut, L2BIN(nFileSizeU)   )
FWRITE( nHanOut, I2BIN(nLenName)     )
FWRITE( nHanOut, cName               )
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC FUNCTION MWriteChunk( nHanOut, cBuffer )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FWRITE( nHanOut, I2BIN(LEN(cBuffer)) )
FWRITE( nHanOut, cBuffer )
RETURN LEN(cBuffer)

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC FUNCTION MReadChunk( nHanIn )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL aChunk := {,}, nInput, cInputBuffer

cInputBuffer := SPACE(2)

nInput := FREAD( nHanIn, @cInputBuffer, 2 ) // Buffer LEN
IF nInput>0
   aChunk[CHUNK_LEN   ] := BIN2W(cInputBuffer)
   cInputBuffer := SPACE(MChunkLen( aChunk ))
   FREAD( nHanIn, @cInputBuffer, MChunkLen( aChunk ) )
   aChunk[CHUNK_BUFFER] := LEFT( cInputBuffer, MChunkLen( aChunk ) )
ELSE
   aChunk := NIL
ENDIF

RETURN aChunk

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC FUNCTION MChunkBuff( aChunk ); RETURN aChunk[CHUNK_BUFFER]
STATIC FUNCTION MChunkLen(  aChunk ); RETURN aChunk[CHUNK_LEN   ]
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC FUNCTION MDePack( aChunk )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL cCmp    := LEFT(MChunkBuff( aChunk ),1)
LOCAL cBuf    := SUBSTR(MChunkBuff( aChunk ),2)

DO CASE
   CASE cCmp==CHR(0)     // Storing
        cBuf := cBuf
   CASE cCmp==CHR(1)     // RLE
        cBuf := dfRLDeCmp(cBuf)
   CASE cCmp==CHR(2)     // PAIR
        cBuf := dfPairDeCmp(cBuf)
   CASE cCmp==CHR(3)     // PAIR
        cBuf := dfRLDeCmp(cBuf)
        cBuf := dfPairDeCmp(cBuf)

   /*

   //
   // Expand is a copyrighted library
   //

   CASE cCmp==CHR(10)     // Compress
        cBuf := Expand(cBuf)
   CASE cCmp==CHR(11)     // Compress
        cBuf := Expand(cBuf)
        cBuf := dfRLDeCmp(cBuf)
   CASE cCmp==CHR(12)     // Compress
        cBuf := Expand(cBuf)
        cBuf := dfPairDeCmp(cBuf)
   CASE cCmp==CHR(13)     // Compress
        cBuf := Expand(cBuf)
        cBuf := dfRLDeCmp(cBuf)
        cBuf := dfPairDeCmp(cBuf)
   */

ENDCASE

RETURN cBuf

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC FUNCTION MPack( cBuffer )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL cCmp, cCpr, cRet

LOCAL cRle , lRLE := .F.
LOCAL cPai , lPai := .F.
LOCAL cRle1, lRLE1:= .F.

// Storing
cCmp := CHR(0)
cRet := cBuffer

// RLE Compression
cRle := dfRLCmp( cBuffer )
IF LEN(cRle)<LEN(cRet)
   lRLE := .T.
   cCmp := CHR(1)
   cRet := cRle
ENDIF

// Compress Pair 哪哪哪哪哪哪哪�
cPai := dfPairCmp( cBuffer ) //�
IF LEN(cPai)<LEN(cRet)       //�
   lPAI := .T.               //�
   cCmp := CHR(2)            //�
   cRet := cPai              //�
ENDIF                        //�
// 哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

IF lPAI
   // Compress Pair 哪哪哪哪哪哪哪�
   cRle1:=dfRLCmp( cPai )       //�
   IF LEN(cRle1)<LEN(cRet)      //�
      lRle1:= .T.               //�
      cCmp := CHR(3)            //�
      cRet := cRle1             //�
   ENDIF                        //�
   // 哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
ENDIF


/*

//
// Expand is a copyrighted library
//

// Compress Normal & RLE 哪哪目
cCpr := Compress( cBuffer ) //�
IF LEN(cCpr)<LEN(cRet)      //�
   cCmp := CHR(10)          //�
   cRet := cCpr             //�
ENDIF                       //�
IF lRLE                     //�
   cCpr := Compress( cRle ) //�
   IF LEN(cCpr)<LEN(cRet)   //�
      cCmp := CHR(11)       //�
      cRet := cCpr          //�
   ENDIF                    //�
ENDIF                       //�
IF lPAI                     //�
   cCpr := Compress( cPai ) //�
   IF LEN(cCpr)<LEN(cRet)   //�
      cCmp := CHR(12)       //�
      cRet := cCpr          //�
   ENDIF                    //�
ENDIF                       //�
IF lRLE1                    //�
   cCpr := Compress( cRle1) //�
   IF LEN(cCpr)<LEN(cRet)   //�
      cCmp := CHR(13)       //�
      cRet := cCpr          //�
   ENDIF                    //�
ENDIF                       //�
// 哪哪哪哪哪哪哪哪哪哪哪哪哪馁

*/

RETURN (cCmp+cRet)
