/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                    ddBackup/ddRestore Parameters                     |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFEXETYPE_CH
   #define _DFEXETYPE_CH

/* +----------------------------------------------------------------------+
   |  |Description                                                        |
   |--+-------------------------------------------------------------------|
   |MZ|old-style DOS executable                                           |
   |NE|Windows or OS/2 1.x segmented ("new") executable                   |
   |LE|Windows virtual device driver (VxD) linear executable              |
   |LX|variant of LE used in OS/2 2.x                                     |
   |W3|Windows WIN386.EXE file; a collection of LE files                  |
   |PE|Win32/Windows NT/Win32s portable executable based on Unix COFF     |
   |DL|HP 100LX/200LX system manager compliant executable (.EXM)          |
   |MP|old PharLap .EXP                                                   |
   |P2|PharLap 286 .EXP                                                   |
   |P3|PharLap 386 .EXP                                                   |
   +----------------------------------------------------------------------+ */

   #define EXE_TYPE_UNKNOWN 0
   #define EXE_TYPE_MZ      1
   #define EXE_TYPE_NE      2
   #define EXE_TYPE_LE      3
   #define EXE_TYPE_LX      4
   #define EXE_TYPE_W3      5
   #define EXE_TYPE_PE      6
   #define EXE_TYPE_DL      7
   #define EXE_TYPE_MP      8
   #define EXE_TYPE_P2      9
   #define EXE_TYPE_P3     10

#endif
