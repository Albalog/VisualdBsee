/*****************************
* Source : HRTimer.prg
* System : <unkown>
* Author : Phil Ide
* Created: 26/01/2004
*
* Purpose:
* ----------------------------
* History:
* ----------------------------
*    26/01/2004 14:19 PPI - Created
*****************************/

/* High Resolution Timer - for those times when Seconds() just isn't
   fine enough.

   Usage:
          oTimer := HRTimer():new()

          // start or restart timer
          oTimer:start()

          // check if timer is running
          oTimer:isRunning()

          // stop timer
          oTimer:stop()

          // get elapsed time
          nElapsed := oTimer:duration

          // print showing high precision
          ? Str(nElapsed,15,12)

          // how accurate is the timer?
          ? oTimer:precision() // smallest part of a second that can be measured

   On my P4/2.4Ghz running XP-Pro, I have a precision of 0.0000002793651 of a second.
*/


#include "Common.ch"
#include "dll.ch"

CLASS dfHRTimer
   HIDDEN:
      VAR iStart
      VAR isRunning
      VAR granule

   EXPORTED:
      VAR duration
      METHOD init
      METHOD start
      METHOD stop
      METHOD isRunning
      METHOD precision
      METHOD startValue
      METHOD elapsed
ENDCLASS

METHOD dfHRTimer:init()
   local i := Replicate(Chr(0),8)

   QueryPerformanceFrequency(@i)
   i := Bin2U(i)+(2**32)*(Bin2U(Right(i,4)))
   ::granule := i
   ::isRunning := FALSE
   ::iStart := 0
   ::duration := 0
   return self

METHOD dfHRTimer:start()
   local i := Replicate(Chr(0),8)

   QueryPerformanceCounter(@i)
   i := Bin2U(i)+(2**32)*(Bin2U(Right(i,4)))
   ::iStart := i
   ::isRunning := TRUE
   ::duration := 0
   return self

METHOD dfHRTimer:stop()
   local i := Replicate(Chr(0),8)
   if ::isRunning
      QueryPerformanceCounter(@i)
      i := Bin2U(i)+(2**32)*(Bin2U(Right(i,4)))
      ::isRunning := FALSE
      ::duration := (i - ::iStart)/::granule
   endif
   return self

METHOD dfHRTimer:elapsed()
   local i := Replicate(Chr(0),8)
   local nRet := -1
   if ::isRunning
      QueryPerformanceCounter(@i)
      i := Bin2U(i)+(2**32)*(Bin2U(Right(i,4)))
      nRet := (i - ::iStart)/::granule
   endif
   return nRet

METHOD dfHRTimer:isRunning()
   return ::isRunning

METHOD dfHRTimer:precision()
   return 1/::granule

METHOD dfHRTimer:startValue()
   return ::iStart

DLLFUNCTION GetTickCount() USING STDCALL FROM Kernel32.dll
DLLFUNCTION QueryPerformanceCounter(@n) USING STDCALL FROM Kernel32.dll
DLLFUNCTION QueryPerformanceFrequency(@n) USING STDCALL FROM Kernel32.dll

