/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                      dfReportManager export types                    |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFREPMAN_CH
   #define _DFREPMAN_CH

   #define RM_EXPORT_TEXT            1
   #define RM_EXPORT_CSV             2
   #define RM_EXPORT_CUSTOMTEXT      3
   #define RM_EXPORT_EXCEL           6
   #define RM_EXPORT_HTML           11
   #define RM_EXPORT_PDF            12
   #define RM_EXPORT_CSV2          102
   #define RM_EXPORT_EXCEL2        106
   #define RM_EXPORT_SVG           110
   #define RM_EXPORT_METAFILE      120

   // Structure of array returned from
   // dfRMGetExportTypes()
   #define DFRMET_DEX     1   // description
   #define DFRMET_EXT     2   // extension
   #define DFRMET_ID      3   // ID
   #define DFRMET_NUMELEM 3


#endif

