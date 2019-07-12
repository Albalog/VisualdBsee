/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                          Resource Parameters                         |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFGFRES_CH

   #define _DFGFRES_CH

   #define S2GFR_MEMORYLOAD    1    // percent of memory in use
   #define S2GFR_TOTALPHYS     2    // bytes of physical memory
   #define S2GFR_AVAILPHYS     3    // free physical memory bytes
   #define S2GFR_TOTALPAGEFILE 4    // bytes of paging file
   #define S2GFR_AVAILPAGEFILE 5    // free bytes of paging file
   #define S2GFR_TOTALVIRTUAL  6    // user bytes of address space
   #define S2GFR_AVAILVIRTUAL  7    // free user bytes

   #define S2GFR_NUMELEM       7

   #define S2GFRP_MEMORYLOAD   1    // percent of memory in use
   #define S2GFRP_PHYS         2    // percent of free physical memory
   #define S2GFRP_PAGEFILE     3    // percent of free paging file
   #define S2GFRP_VIRTUAL      4    // percent of free user bytes

   #define S2GFRP_NUMELEM      4

   #define S2GFR95_SYSTEM      1    // percent of system resources free
   #define S2GFR95_USER        2    // percent of user resources free
   #define S2GFR95_GDI         3    // percent of GDI resources free

#endif
