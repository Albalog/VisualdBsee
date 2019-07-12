/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                          Xbase ++ Resources                          |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFXRES_CH
   #define _DFXRES_CH

   #define RESOURCE_BITMAP_BASE      1000

   #define GET_BTN_DOWNARROWBMP      RESOURCE_BITMAP_BASE + 00
   #define BACKGROUND01_BMP          RESOURCE_BITMAP_BASE + 01
   #define BACKGROUND02_BMP          RESOURCE_BITMAP_BASE + 02
   #define BACKGROUND03_BMP          RESOURCE_BITMAP_BASE + 03
   #define BACKGROUND04_BMP          RESOURCE_BITMAP_BASE + 04
   #define BACKGROUND05_BMP          RESOURCE_BITMAP_BASE + 05
   #define BACKGROUND06_BMP          RESOURCE_BITMAP_BASE + 06
   #define BACKGROUND07_BMP          RESOURCE_BITMAP_BASE + 07
   #define BACKGROUND08_BMP          RESOURCE_BITMAP_BASE + 08
   #define BACKGROUND09_BMP          RESOURCE_BITMAP_BASE + 09
   #define BACKGROUND10_BMP          RESOURCE_BITMAP_BASE + 10
   #define BACKGROUND11_BMP          RESOURCE_BITMAP_BASE + 11
   #define BACKGROUND12_BMP          RESOURCE_BITMAP_BASE + 12
   #define BACKGROUND13_BMP          RESOURCE_BITMAP_BASE + 13
   #define BACKGROUND14_BMP          RESOURCE_BITMAP_BASE + 14
   #define BACKGROUND15_BMP          RESOURCE_BITMAP_BASE + 15
   #define BACKGROUND16_BMP          RESOURCE_BITMAP_BASE + 16
   #define BACKGROUND17_BMP          RESOURCE_BITMAP_BASE + 17
   #define BACKGROUND18_BMP          RESOURCE_BITMAP_BASE + 18
   #define BACKGROUND19_BMP          RESOURCE_BITMAP_BASE + 19
   #define BACKGROUND20_BMP          RESOURCE_BITMAP_BASE + 20
   #define BACKGROUND21_BMP          RESOURCE_BITMAP_BASE + 31
   #define BACKGROUND22_BMP          RESOURCE_BITMAP_BASE + 32
   #define BACKGROUND23_BMP          RESOURCE_BITMAP_BASE + 33
   #define BACKGROUND24_BMP          RESOURCE_BITMAP_BASE + 34
   #define BACKGROUND25_BMP          RESOURCE_BITMAP_BASE + 35
   #define BACKGROUND26_BMP          RESOURCE_BITMAP_BASE + 36
   #define BACKGROUND27_BMP          RESOURCE_BITMAP_BASE + 37
   #define BACKGROUND28_BMP          RESOURCE_BITMAP_BASE + 38
   #define BACKGROUND29_BMP          RESOURCE_BITMAP_BASE + 39
   #define BACKGROUND30_BMP          RESOURCE_BITMAP_BASE + 40
   #define BACKGROUND31_BMP          RESOURCE_BITMAP_BASE + 41

   #define CARTA_VERT_BMP            RESOURCE_BITMAP_BASE + 21
   #define CARTA_ORIZ_BMP            RESOURCE_BITMAP_BASE + 22
   #define PRINTER_WIN_BMP           RESOURCE_BITMAP_BASE + 23
   #define PRINTER_DOS_BMP           RESOURCE_BITMAP_BASE + 24

   #define ICON_INFO_BMP             RESOURCE_BITMAP_BASE + 50
   #define ICON_QUESTION_BMP         RESOURCE_BITMAP_BASE + 51
   #define ICON_WARNING_BMP          RESOURCE_BITMAP_BASE + 52
   #define ICON_ERROR_BMP            RESOURCE_BITMAP_BASE + 53

   #define BUTT_OK                   RESOURCE_BITMAP_BASE + 60
   #define BUTT_CANCEL               RESOURCE_BITMAP_BASE + 61

   #define BTN_BASE                  RESOURCE_BITMAP_BASE+100
   #define BTN_GOTOP                 BTN_BASE+0
   #define BTN_GOBOTTOM              BTN_BASE+1
   #define BTN_PREV                  BTN_BASE+2
   #define BTN_NEXT                  BTN_BASE+3
   #define BTN_PREV2                 BTN_BASE+4
   #define BTN_NEXT2                 BTN_BASE+5
   #define BTN_PRINT                 BTN_BASE+6
   #define BTN_RULER                 BTN_BASE+7

   #define FORMMENU_BASE             RESOURCE_BITMAP_BASE+150
   #define FORMMENU_UP               FORMMENU_BASE + 0
   #define FORMMENU_DOWN             FORMMENU_BASE + 1
   #define FORMMENU_EXIT             FORMMENU_BASE + 2

   #define TOOLBAR_BASE              RESOURCE_BITMAP_BASE+200
   //#define TOOLBAR_WRITE             TOOLBAR_BASE + 0
   #define TOOLBAR_WRITE_H           TOOLBAR_BASE + 1
   //#define TOOLBAR_ESC               TOOLBAR_BASE + 2
   #define TOOLBAR_ESC_H             TOOLBAR_BASE + 3
   //#define TOOLBAR_HELP              TOOLBAR_BASE + 4
   #define TOOLBAR_HELP_H            TOOLBAR_BASE + 5
   //#define TOOLBAR_KEYHELP           TOOLBAR_BASE + 6
   #define TOOLBAR_KEYHELP_H         TOOLBAR_BASE + 7

   #define TOOLBAR_ADD               TOOLBAR_BASE + 8
   #define TOOLBAR_MOD               TOOLBAR_BASE + 9
   #define TOOLBAR_DEL               TOOLBAR_BASE +10
   #define TOOLBAR_FIND              TOOLBAR_BASE +11
   #define TOOLBAR_FIND_ALPHA        TOOLBAR_BASE +12
   #define TOOLBAR_PG_PREV           TOOLBAR_BASE +13
   #define TOOLBAR_PG_NEXT           TOOLBAR_BASE +14
   #define TOOLBAR_GOTOP             TOOLBAR_BASE +15
   #define TOOLBAR_GOBOTTOM          TOOLBAR_BASE +16
   #define TOOLBAR_PREV              TOOLBAR_BASE +17
   #define TOOLBAR_NEXT              TOOLBAR_BASE +18
   #define TOOLBAR_PRINT             TOOLBAR_BASE +19
   #define TOOLBAR_FIND_WIN          TOOLBAR_BASE +20
   #define TOOLBAR_BOOKHELP          TOOLBAR_BASE +21
   #define TOOLBAR_DATE              TOOLBAR_BASE +22
   #define TOOLBAR_USER              TOOLBAR_BASE +23
   #define TOOLBAR_MENU              TOOLBAR_BASE +24
   #define TOOLBAR_FIND_CONTEXT      TOOLBAR_BASE +25

   #define COLUMN_TAG_SELECTED       RESOURCE_BITMAP_BASE+300
   #define COLUMN_TAG_NOT_SELECTED   RESOURCE_BITMAP_BASE+301

   #define DFINITSCREEN_BITMAP       RESOURCE_BITMAP_BASE+1000  // ID del bitmap
   #define DFINITSCREEN_BITMAP_WIDTH        480   // Larghezza del bitmap
   #define DFINITSCREEN_BITMAP_HEIGHT       320   // Altezza del bitmap

   #define DFAPPLICATION_LOGO        RESOURCE_BITMAP_BASE+1200  // application logo

   // I puntatori (cursori) iniziano da 5000
   #define RESOURCE_POINTER_BASE     5000
   #define PTR_MAGNIFY_PLUS          RESOURCE_POINTER_BASE + 1

   #define RESOURCE_ICONS_BASE       8000
   #define APPLICATION_ICON          RESOURCE_ICONS_BASE + 1

   #define DBUSER_RESOURCE_BASE      9000
   #define DBUSER_RES01_BMP          DBUSER_RESOURCE_BASE + 1
   #define DBUSER_RES02_BMP          DBUSER_RESOURCE_BASE + 2
   #define DBUSER_RES03_BMP          DBUSER_RESOURCE_BASE + 3
   #define DBUSER_RES04_BMP          DBUSER_RESOURCE_BASE + 4
   #define DBUSER_RES05_BMP          DBUSER_RESOURCE_BASE + 5
   #define DBUSER_RES06_BMP          DBUSER_RESOURCE_BASE + 6
   #define DBUSER_RES07_BMP          DBUSER_RESOURCE_BASE + 7
   #define DBUSER_RES08_BMP          DBUSER_RESOURCE_BASE + 8
   #define DBUSER_RES09_BMP          DBUSER_RESOURCE_BASE + 9
   #define DBUSER_RES10_BMP          DBUSER_RESOURCE_BASE +10
   #define DBUSER_RES11_BMP          DBUSER_RESOURCE_BASE +11
   #define DBUSER_RES12_BMP          DBUSER_RESOURCE_BASE +12
   #define DBUSER_RES13_BMP          DBUSER_RESOURCE_BASE +13
   #define DBUSER_RES14_BMP          DBUSER_RESOURCE_BASE +14
   #define DBUSER_RES15_BMP          DBUSER_RESOURCE_BASE +15
   #define DBUSER_RES16_BMP          DBUSER_RESOURCE_BASE +16
   #define DBUSER_RES17_BMP          DBUSER_RESOURCE_BASE +17
   #define DBUSER_RES18_BMP          DBUSER_RESOURCE_BASE +18
   #define DBUSER_RES19_BMP          DBUSER_RESOURCE_BASE +19
   #define DBUSER_RES20_BMP          DBUSER_RESOURCE_BASE +20

   #define USER_RESOURCE_BASE       10000
#endif
