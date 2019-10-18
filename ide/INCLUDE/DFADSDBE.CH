/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                          Xbase ++ Parameters                         |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFADSDBE_CH

   #define _DFADSDBE_CH

   #include "dmlb.ch"

   #define ADSRDD              "ADSDBE"
   #define ADSRDD_EXT_DBF      "DBF"
   #define ADSRDD_EXT_MEMO_NTX "DBT"
   #define ADSRDD_EXT_NDX_NTX  "NTX"

   #define ADSRDD_EXT_MEMO_CDX "FPT"
   #define ADSRDD_EXT_NDX_CDX  "CDX"

   #define ADSRDD_EXT_ADT      "ADT"
   #define ADSRDD_EXT_MEMO_ADT "ADM"
   #define ADSRDD_EXT_NDX_ADT  "ADI"

   #define ADSRDD_EXT_ADD      "ADD"

   // ---------------------------------------------------
   // Extract from file ADSDBE.CH. without the use of
   // ADSUTIL.DLL
   // This #define are used with ALS (Advantage Local Server)
   // support
   //
   // ---------------------------------------------------

   // ADSDBE generics - use them to specify default
   // behaviour of the database engine. (DbeInfo)
   //
   #define ADSDBE_MEMOFILE_EXT    (DBE_USER+1) // RO
   #define ADSDBE_INDEX_EXT       (DBE_USER+2) // RW
   #define ADSDBE_TBL_MODE        (DBE_USER+3) // RW
   #define ADSDBE_LOCK_MODE       (DBE_USER+4) // RW
   #define ADSDBE_RIGHTS_MODE     (DBE_USER+5) // RW
   #define ADSDBE_MEMOBLOCKSIZE   (DBE_USER+6) // RW
   #define ADSDBE_PASSWORD        (DBE_USER+7) // RW
   #define ADSDBE_FREETABLE          (DBE_USER+8)  // RW
   #define ADSDBE_TABLENAME_IS_ALIAS (DBE_USER+9)  // RW
   #define ADSDBE_DELETEOBJECT       (DBE_USER+10) // RW

   // Use DbInfo() with the following defines to
   // inquire details about the current workarea
   //
   #define ADSDBO_MEMOBLOCKSIZE   (DBE_USER+1)  // RO
   #define ADSDBO_LOCALFILTER     (DBE_USER+2)  // RO
   #define ADSDBO_TABLE_HANDLE    (DBE_USER+3)  // RO
   #define ADSDBO_REFRESHRECORD   (DBE_USER+4)  // RW
   #define ADSDBO_READAHEAD       (DBE_USER+5)  // RW
   #define ADSDBO_DELETEOBJECT    (DBE_USER+6)  // RW

   // Use OrdInfo() with the following defines to
   // inquire details about the current workarea
   //
   #define ADSORD_INDEX_HANDLE    (DBE_USER+1)  // RO


   // oDacSession:setProperty() supports those additional
   // defines in the context of the ADS DatabaseEngine
   //
   #define ADSDBE_SERVER_TYPE    (DAC_USER+1)  // RO
   #define ADSDBE_SERVER_VERSION (DAC_USER+2)  // RO
   #define ADSDBE_OEM_LANG       (DAC_USER+3)  // RO
   #define ADSDBE_ANSI_LANG      (DAC_USER+4)  // RO

   // Return types of ADSDBE_TBL_MODE
   //
   #define ADSDBE_DATABASE 0
   #define ADSDBE_NTX 1
   #define ADSDBE_CDX 2
   #define ADSDBE_ADT      3


   // Return types of ADSDBE_LOCK_MODE
   //
   #define ADSDBE_COMPATIBLE_LOCKING  0
   #define ADSDBE_PROPRIETARY_LOCKING 1


   // Return types of ADSDBE_RIGHTS_MODE
   //
   #define ADSDBE_CHECKRIGHTS  1
   #define ADSDBE_IGNORERIGHTS 2


   // Return types of ADSDBE_SERVER_TYPE
   //
   #define ADSDBE_NETWARE 1
   #define ADSDBE_NT      2
   #define ADSDBE_LOCAL   3
   #define ADSDBE_WIN9X    4
   #define ADSDBE_NETWARE5 5
   #define ADSDBE_LINUX    6


   // For calls that can optionally use filters
   //
   #define ADS_RESPECTFILTERS       1
   #define ADS_IGNOREFILTERS        2
   #define ADS_RESPECTSCOPES        3


   // Alaska library for Data access chain
   #pragma library("ADAC20B.LIB")
#endif
