// Struttura
#define TDB_TYPE        1
   #define TDB_TYPE_DEL      "d"
   #define TDB_TYPE_FIX      "f"

#define TDB_RECDEL      2
#define TDB_FIEDEL      3
#define TDB_FIELDS      4
   #define TDB_DBS_NAME        1
   #define TDB_DBS_TYPE        2
   #define TDB_DBS_LEN         3
   #define TDB_DBS_DEC         4
   #define TDB_DBS_PICTURE     5
      #define TDB_PIC_NUM_INT   "I"
      #define TDB_PIC_NUM_DEC   "D"
   #define TDB_DBS_CVTBLOCK    6
   #define TDB_DBS_NUMELEM     6

#define TDB_TXTSTRUCT   5
#define TDB_CURRREC     6
#define TDB_RECLEN      7
#define TDB_EOF         8
#define TDB_NUMELEM     8

// Default
#define TDB_DEF_RECDEL   CRLF
#define TDB_DEF_FIEDEL   "|"

#define TDB_READBLOCK    256

