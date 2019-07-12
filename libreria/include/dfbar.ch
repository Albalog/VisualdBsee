/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                          BARCODE Interface                           |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFBAR_CH
   #define _DFBAR_CH

   //+----------------------------------------------------+
   //| Type | Description                                 |
   //Ã------|---------------------------------------------|
   //| EAN  | European Articles Numbering                 |
   //| UPC  | United Product Code                         |
   //+----------------------------------------------------+

   //
   // BarCode TYPE                                   | Len | Type      |
   //                                                |-----+-----------|
   #define BARCODE_EAN13     1    // Ean 13          | 13  | Numeric   |
   #define BARCODE_EAN8      2    // Ean 8           |  8  | Numeric   |
   #define BARCODE_UPCA      3    // Upc A           | 12  | Numeric   |
   #define BARCODE_UPCE      4    // Upc E           |  6  | Numeric   |
   #define BARCODE_39        5    // 39              |  N  | Character |
   #define BARCODE_25INT     6    // 2/5 Interleaved |  N  | Numeric   |
   #define BARCODE_25IND     7    // 2/5 Industrial  |  N  | Numeric   |

   // Printer Type
   #define PRN_EPSON_9       1    // EPSON printer  9 pins
   #define PRN_EPSON_24      2    // EPSON printer 24 pins
   #define PRN_HPDJ          3    // HP Deskjet
   #define PRN_HPDJPLUS      4    // HP Deskjet +
   #define PRN_HP_LASERJET   5    // HP Laserjet
#endif
