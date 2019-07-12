/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                          Xbase Image related defines                 |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFIMAGE_CH
   #define _DFIMAGE_CH

   // dfGetBmpTAG()
   // -------------
   #define BMPTAG_IDCODE          1
   #define BMPTAG_FILESIZE        2
   #define BMPTAG_RESERVED        3
   #define BMPTAG_OFFSET          4
   #define BMPTAG_HEADERSIZE      5
   #define BMPTAG_WIDTH           6
   #define BMPTAG_HEIGHT          7
   #define BMPTAG_PLANES          8
   #define BMPTAG_BITSPERPIXEL    9
   #define BMPTAG_COMPRESSION     10
   #define BMPTAG_BITMAPDATASIZE  11
   #define BMPTAG_XRESOLUTION     12
   #define BMPTAG_YRESOLUTION     13
   #define BMPTAG_COLORS          14

   #define BMPTAG_LEN             14


   // Jpeg quality
   // ------------
   #define JPEG_DEFAULT        0
   #define JPEG_FAST           1
   #define JPEG_ACCURATE       2
   #define JPEG_QUALITYSUPERB  0x80
   #define JPEG_QUALITYGOOD    0x100
   #define JPEG_QUALITYNORMAL  0x200
   #define JPEG_QUALITYAVERAGE 0x400
   #define JPEG_QUALITYBAD     0x800

   //Save BMP Format
   //----------------
   #define BMP_DEFAULT         0
   #define BMP_SAVE_RLE        1

   //Save Other Format grafic Files
   //------------------------------
   #define CUT_DEFAULT         0
   #define ICO_DEFAULT         0
   #define ICO_FIRST           0
   #define ICO_SECOND          0
   #define ICO_THIRD           0
   #define IFF_DEFAULT         0
   #define KOALA_DEFAULT       0
   #define LBM_DEFAULT         0
   #define MNG_DEFAULT         0
   #define PCD_DEFAULT         0
   #define PCD_BASE            1
   #define PCD_BASEDIV4        2
   #define PCD_BASEDIV16       3
   #define PCX_DEFAULT         0
   #define PNG_DEFAULT         0
   #define PNG_IGNOREGAMMA     1       // avoid gamma correction
   #define PNM_DEFAULT         0
   #define PNM_SAVE_RAW        0       // If set the writer saves in RAW format (i.e. P4, P5 or P6)
   #define PNM_SAVE_ASCII      1       // If set the writer saves in ASCII format (i.e. P1, P2 or P3)
   #define RAS_DEFAULT         0
   #define TARGA_DEFAULT       0
   #define TARGA_LOAD_RGB888   1       // If set the loader converts RGB555 and ARGB8888 -> RGB888.
   #define TARGA_LOAD_RGB555   2       // This flag is obsolete
   #define WBMP_DEFAULT        0
   #define PSD_DEFAULT         0


   //Save TIFF Format
   //----------------
   #define TIFF_DEFAULT        0
   #define TIFF_PACKBITS       0x0100  // save using PACKBITS compression
   #define TIFF_DEFLATE        0x0200  // save using DEFLATE compression
   #define TIFF_ADOBE_DEFLATE  0x0400  // save using ADOBE DEFLATE compression
   #define TIFF_NONE           0x0800  // save without any compression

   // dfGetTifTAG()
   // -------------
   #define TIFFTAG_SUBFILETYPE        254   /* subfile data descriptor */
   #define TIFFTAG_OSUBFILETYPE       255   /* +kind of data in subfile */
   #define TIFFTAG_IMAGEWIDTH         256   /* image width in pixels */
   #define TIFFTAG_IMAGELENGTH        257   /* image height in pixels */
   #define TIFFTAG_BITSPERSAMPLE      258   /* bits per channel (sample) */
   #define TIFFTAG_COMPRESSION        259   /* data compression technique */
   #define TIFFTAG_PHOTOMETRIC        262   /* photometric interpretation */
   #define TIFFTAG_THRESHHOLDING      263   /* +thresholding used on data */
   #define TIFFTAG_CELLWIDTH          264   /* +dithering matrix width */
   #define TIFFTAG_CELLLENGTH         265   /* +dithering matrix height */
   #define TIFFTAG_FILLORDER          266   /* data order within a byte */
   #define TIFFTAG_DOCUMENTNAME       269   /* name of doc. image is from */
   #define TIFFTAG_IMAGEDESCRIPTION   270     /* info about image */
   #define TIFFTAG_MAKE               271   /* scanner manufacturer name */
   #define TIFFTAG_MODEL              272   /* scanner model name/number */
   #define TIFFTAG_STRIPOFFSETS       273   /* offsets to data strips */
   #define TIFFTAG_ORIENTATION        274   /* +image orientation */
   #define TIFFTAG_SAMPLESPERPIXEL    277   /* samples per pixel */
   #define TIFFTAG_ROWSPERSTRIP       278   /* rows per strip of data */
   #define TIFFTAG_STRIPBYTECOUNTS    279     /* bytes counts for strips */
   #define TIFFTAG_MINSAMPLEVALUE     280     /* +minimum sample value */
   #define TIFFTAG_MAXSAMPLEVALUE     281     /* +maximum sample value */
   #define TIFFTAG_XRESOLUTION        282   /* pixels/resolution in x */
   #define TIFFTAG_YRESOLUTION        283   /* pixels/resolution in y */
   #define TIFFTAG_PLANARCONFIG       284   /* storage organization */
   #define TIFFTAG_PAGENAME           285   /* page name image is from */
   #define TIFFTAG_XPOSITION          286   /* x page offset of image lhs */
   #define TIFFTAG_YPOSITION          287   /* y page offset of image lhs */
   #define TIFFTAG_FREEOFFSETS        288   /* +byte offset to free block */
   #define TIFFTAG_FREEBYTECOUNTS     289     /* +sizes of free blocks */
   #define TIFFTAG_GRAYRESPONSEUNIT   290     /* $gray scale curve accuracy */
   #define TIFFTAG_GRAYRESPONSECURVE  291   /* $gray scale response curve */
   #define TIFFTAG_GROUP3OPTIONS      292     /* 32 flag bits */
   #define TIFFTAG_T4OPTIONS          292   /* TIFF 6.0 proper name alias */
   #define TIFFTAG_T6OPTIONS          293   /* TIFF 6.0 proper name */
   #define TIFFTAG_GROUP4OPTIONS      293   /* 32 flag bits */
   #define TIFFTAG_RESOLUTIONUNIT     296   /* units of resolutions */
   #define TIFFTAG_PAGENUMBER         297   /* page numbers of multi-page */
   #define TIFFTAG_COLORRESPONSEUNIT  300   /* $color curve accuracy */
   #define TIFFTAG_TRANSFERFUNCTION   301   /* !colorimetry info */
   #define TIFFTAG_SOFTWARE           305   /* name & release */
   #define TIFFTAG_DATETIME           306   /* creation date and time */
   #define TIFFTAG_ARTIST             315   /* creator of image */
   #define TIFFTAG_HOSTCOMPUTER       316   /* machine where created */
   #define TIFFTAG_PREDICTOR          317   /* prediction scheme w/ LZW */
   #define TIFFTAG_WHITEPOINT         318   /* image white point */
   #define TIFFTAG_PRIMARYCHROMATICITIES   319     /* !primary chromaticities */
   #define TIFFTAG_COLORMAP           320   /* RGB map for pallette image */
   #define TIFFTAG_HALFTONEHINTS      321   /* !highlight+shadow info */
   #define TIFFTAG_TILEWIDTH          322   /* !rows/data tile */
   #define TIFFTAG_TILELENGTH         323   /* !cols/data tile */
   #define TIFFTAG_TILEOFFSETS        324   /* !offsets to data tiles */
   #define TIFFTAG_TILEBYTECOUNTS     325   /* !byte counts for tiles */
   #define TIFFTAG_BADFAXLINES        326   /* lines w/ wrong pixel count */
   #define TIFFTAG_CLEANFAXDATA       327   /* regenerated line info */
   #define TIFFTAG_CONSECUTIVEBADFAXLINES   328   /* max consecutive bad lines */
   #define TIFFTAG_SUBIFD             330   /* subimage descriptors */
   #define TIFFTAG_INKSET             332   /* !inks in separated image */
   #define TIFFTAG_INKNAMES           333   /* !ascii names of inks */
   #define TIFFTAG_NUMBEROFINKS       334   /* !number of inks */
   #define TIFFTAG_DOTRANGE           336   /* !0% and 100% dot codes */
   #define TIFFTAG_TARGETPRINTER      337   /* !separation target */
   #define TIFFTAG_EXTRASAMPLES       338   /* !info about extra samples */
   #define TIFFTAG_SAMPLEFORMAT       339   /* !data sample format */
   #define TIFFTAG_SMINSAMPLEVALUE    340   /* !variable MinSampleValue */
   #define TIFFTAG_SMAXSAMPLEVALUE    341   /* !variable MaxSampleValue */
   #define TIFFTAG_JPEGTABLES         347   /* %JPEG table stream */

#endif
