/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "os.ch" 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfMemStatus()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfAlert("Status of available memory //"                                                  +;
         "//Available memory for the current process         : "+ STR(Memory(MEM_VIRT_AVAIL) )+" Kb" +;
         "//Entire available system memory                   : "+ STR(Memory(MEM_VIRT_TOTAL) )+" Kb" +;
         "//Available random access memory (RAM) in kilobyte : "+ STR(Memory(MEM_RAM_AVAIL)  )+" Kb" +;
         "//Installed RAM in kilobyte                        : "+ STR(Memory(MEM_RAM_TOTAL)  )+" Kb"  )

//Modificato luca 2/02/2006
//dbMsgErr( "Status of available memory //"                                                  +;
//          "//Variables space (0)                  : " +STR(MEMORY(  0)             )+" Kb" +;
//          "//Largest string object (1)            : " +STR(MEMORY(  1)             )+" Kb" +;
//          "//Free RUN memory (2)                  : " +STR(MEMORY(  2)             )+" Kb" +;
//          "//Size of virtueal (SVOS) memory (3)   : " +STR(MEMORY(  3)             )+" Kb" +;
//          "//Size of available EMS Memory (4+105) : " +STR(MEMORY(  4) +MEMORY(105))+" Kb" +;
//          "//Fixed Heap size (101)                : " +STR(MEMORY(101)             )+" Kb" +;
//          "//Segments in fixed Heap (102)         : " +STR(MEMORY(102)             )+" Kb" +;
//          "//Free memory for swapping (0+103)     : " +STR(MEMORY(  0) +MEMORY(103))+" Kb" +;
//          "//Unused Conventional-Memory (104)     : " +STR(MEMORY(104)             )+" Kb" )
RETURN
