/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                          dbLook Parameters                           |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFLOOK_CH
   #define _DFLOOK_CH

   #define LK_ORDER         1          // Search order
   #define LK_SEEK          2          // Key for the seek
   #define LK_VAL           3          // Inheritance fields
   #define LK_FIELD         4          // Key for the DBDD
   #define LK_WIN           5          // Window
   #define LK_KEY           6          // Key    for the Window
   #define LK_FILTER        7          // Filter for the Window
   #define LK_BREAK         8          // Breack for the Window
   #define LK_TYPE          9          // LOOKUP type
                                       //   LT_NOTMANDATORY
                                       //   LT_MANDATORY
                                       //   LT_FREE         (Query)
   #define LK_EDIT         10          // Edit form for the lookup
   #define LK_INS          11          // Insert from Lookup
   #define LK_KBD          12          // Skip to the next control
   #define LK_KEYORDER     13          // Default order for the ddkey
   #define LK_WINDOWORDER  14          // Default order for the window

   #define LK_ARRAYLEN     14

   #define LT_NOTMANDATORY  "0"
   #define LT_MANDATORY     "1"
   #define LT_FREE          "2"
#endif
