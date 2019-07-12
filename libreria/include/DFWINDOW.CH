/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                          Windows Parameters                          |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFWINDOWS_CH
   #define _DFWINDOWS_CH

   // Windows Clipboard
   #define WIN_CLP_DATA_TEXT    dfHex2Dec("01") // text
   #define WIN_CLP_DATA_BMP     dfHex2Dec("02") // bitmap
   #define WIN_CLP_DATA_META    dfHex2Dec("03") // metafile picture
   #define WIN_CLP_DATA_SYLK    dfHex2Dec("04") // SYLK
   #define WIN_CLP_DATA_DIF     dfHex2Dec("05") // DIF
   #define WIN_CLP_DATA_TIFF    dfHex2Dec("06") // TIFF
   #define WIN_CLP_DATA_OEMTEXT dfHex2Dec("07") // OEM text
   #define WIN_CLP_DATA_DIBBMP  dfHex2Dec("08") // DIB bitmap
   #define WIN_CLP_DATA_SPECIAL dfHex2Dec("80") // special format
   #define WIN_CLP_DATA_DSPTEXT dfHex2Dec("81") // DSP text
   #define WIN_CLP_DATA_DSPBMP  dfHex2Dec("82") // DSP bitmap

   // Windows 95 File Info
   #define WIN_INFO_ATTRIBUTES          1
   #define WIN_INFO_CREATION            2
   #define WIN_INFO_LAST_ACCESS         3
   #define WIN_INFO_LAST_WRITE          4
   #define WIN_INFO_VOLUME_SERIAL       5
   #define WIN_INFO_HIGH_SIZE           6
   #define WIN_INFO_LOW_SIZE            7
   #define WIN_INFO_LINKS               8
   #define WIN_INFO_HIGH_IDENTIFIER     9
   #define WIN_INFO_LOW_IDENTIFIER     10

   #define WIN_INFO_LEN                10

   // Windows 95 SubSt
   #define DRIVE_DEFAULT                0
   #define DRIVE_A                      1
   #define DRIVE_B                      2
   #define DRIVE_C                      3
   #define DRIVE_D                      4
   #define DRIVE_E                      5
   #define DRIVE_F                      6
   #define DRIVE_G                      7
   #define DRIVE_H                      8
   #define DRIVE_I                      9
   #define DRIVE_J                     10
   #define DRIVE_K                     11
   #define DRIVE_L                     12
   #define DRIVE_M                     13
   #define DRIVE_N                     14
   #define DRIVE_O                     15
   #define DRIVE_P                     16
   #define DRIVE_Q                     17
   #define DRIVE_R                     18
   #define DRIVE_S                     19
   #define DRIVE_T                     20
   #define DRIVE_U                     21
   #define DRIVE_V                     22
   #define DRIVE_W                     23
   #define DRIVE_X                     24
   #define DRIVE_Y                     25
   #define DRIVE_Z                     26

#endif
