/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                              dfInt86                                 |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFINT86_CH
   #define _DFINT86_CH

   #define INT86_MAX_REGS       10

   #define AX         1
   #define BX         2
   #define CX         3
   #define DX         4
   #define SI         5
   #define DI         6
   #define BP         7
   #define DS         8
   #define ES         9
   #define FLAGS     10

   #define FLAG_CARRY     0     // Carry flag
   #define FLAG_PARITY    2     // Parity flag
   #define FLAG_AUX       4     // Auxillary flag
   #define FLAG_ZERO      6     // Zero flag
   #define FLAG_SIGN      7     // Sign flag
   #define FLAG_TRAP      8     // Trap flag
   #define FLAG_INT       9     // Interrupt flag
   #define FLAG_DIR      10     // Direction flag
   #define FLAG_OFLOW    11     // Overflow flag

   #translate dfmakehi( <X> )        => ((<X>) * 256)
   #translate REG_DS                 => .T.
   #translate REG_ES                 => .F.
   #translate dfcarrySet( <XFLAGS> ) => (dfAnd(<XFLAGS>, 1)>0)

   #translate dfhighbyte( <X> )      ;
              => (int( (<X>) / 256 ) + if( (<X>) >= 0,0,255))

   #translate dflowbyte( <X> )       ;
              => (int( (<X>) % 256 ) + if( (<X>) >= 0,0,256))

#endif
