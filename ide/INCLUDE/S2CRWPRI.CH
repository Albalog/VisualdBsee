/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                          DevMode Structure                           |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _S2CRWPRI_CH
   #define _S2CRWPRI_CH

   #define S2DM_COLLATION       1
   #define S2DM_COLOR           2
   #define S2DM_DUPLEX          3
   #define S2DM_FONT            4
   #define S2DM_FORMSIZE        5
   #define S2DM_NUMCOPIES       6
   #define S2DM_ORIENTATION     7
   #define S2DM_PAPERBIN        8
   #define S2DM_PRINTFILE       9
   #define S2DM_RESOLUTION1    10
   #define S2DM_RESOLUTION2    11


   // Export Destinations
   #define S2UXDDiskType                        1
   #define S2UXDApplicationType                 2

   // Export Format
   #define S2UXF_ASKUSER                        0

   #define S2UXFTextType                        1
   #define S2UXFCharSeparatedType               2
   #define S2UXFPaginatedTextType               3
   #define S2UXFRichTextFormatType              4
   #define S2UXFTabbedTextType                  5
   #define S2UXFXls5Type                        6
   #define S2UXFWordWinType                     7
   #define S2UXFCrystalReportType               8
   #define S2UXFRecordType                      9
   #define S2UXFDIFType                        10
   #define S2UXFHTML3Type                      11
   #define S2UXFPDFType                        12
   #define S2UXFXMLType                        13

   // Structure of array returned from
   // dfCRWGetExportTypes()
   #define DFCRWET_DEX     1   // description
   #define DFCRWET_EXT     2   // extension
   #define DFCRWET_ID      3   // ID
   #define DFCRWET_DLL     4   // Dll
   #define DFCRWET_RNF     5   // number format (.t./.f.)
   #define DFCRWET_RDF     6   // data format (.t./.f.)
   #define DFCRWET_LPP     7   // lines per page
   #define DFCRWET_SD      8   // string delimiter
   #define DFCRWET_FD      9   // field delimiter
   #define DFCRWET_NUMELEM 9

#endif
