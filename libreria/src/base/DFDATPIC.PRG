/*
* Program Produces a Datestring like in Excel
* i.e. "DDDD, the D. MMMM YYYY" -> "Thursdy, the 4. May 1994"
* Author: Kai Froeb, Munich
* Can be included in dbSee if you like
*/
#include "dfStd.ch" // Server per XPP
#include "common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfdatpic(cDate,dDate,cTime)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
local cYear, cMonth, cWMonth, cDay, cWday, cHour, cMinute, cSecond

if valtype(dDate) == "N"
   dDate := date() +dDate
else
   default dDate TO date()
endif

/*
* important : first change Hours/Mintutes/Seconds
* otherwise, you will get Tuesday -> Tue58day
*/
default cTime TO time()
// 12345678
// HH:MM:SS
if "hh" $ cDate
   cHour   := left(cTime,2)
   cDate   := strtran(cDate,"hh",cHour)
endif
if "mm" $  cDate
   cMinute := substr(cTime,4,2)
   cDate   := strtran(cDate,"mm",cMinute)
endif
if "ss" $  cDate
   cSecond := substr(cTime,7,2)
   cDate   := strtran(cDate,"ss",cSecond)
endif

while "YY" $ cDate
   cYear   := left(dtos(dDate),4)
   if "YYYY" $ cDate
      cDate   := strtran(cDate,"YYYY",cYear)
   else
      cDate   := strtran(cDate,"YY"  ,right(cYear,2))
      exit
   endif
enddo

while "M" $ cDate
   cMonth  := substr(dtos(dDate),5,2)
   cWMonth := cmonth(dDate)
   if "MMMM" $ cDate
      cDate   := strtran(cDate,"MMMM",cWMonth)
   elseif "MMM" $ cDate
      cDate   := strtran(cDate,"MMM" ,left(cWMonth,3))
   elseif "MM" $ cDate
      cDate   := strtran(cDate,"MM"  ,cMonth)
   else
      // in case you use M only it will also change the Monday->1onday
      cDate   := strtran(cDate,"M "   ,ltrim(str(val(cMonth)))+" ")
      cDate   := strtran(cDate,"M."   ,ltrim(str(val(cMonth)))+".")
      cDate   := strtran(cDate,"M-"   ,ltrim(str(val(cMonth)))+"-")
      cDate   := strtran(cDate,"M/"   ,ltrim(str(val(cMonth)))+"/")
      cDate   := strtran(cDate,"M,"   ,ltrim(str(val(cMonth)))+",")
      exit
   endif
enddo

while "D" $ cDate
   cDay    := substr(dtos(dDate),7,2)
   cWDay   := cdow(dDate)
   if "DDDD" $ cDate
      cDate   := strtran(cDate,"DDDD",cWDay)
   elseif "DDD" $ cDate
      cDate   := strtran(cDate,"DDD" ,left(cWDay,3))
   elseif "DD" $ cDate
      cDate   := strtran(cDate,"DD"  ,cDay)
   else
      // in case you use D only it will also change the December -> 12ecember
      cDate   := strtran(cDate,"D "   ,ltrim(str(val(cDay)))+" ")
      cDate   := strtran(cDate,"D."   ,ltrim(str(val(cDay)))+".")
      cDate   := strtran(cDate,"D-"   ,ltrim(str(val(cDay)))+"-")
      cDate   := strtran(cDate,"D/"   ,ltrim(str(val(cDay)))+"/")
      cDate   := strtran(cDate,"D,"   ,ltrim(str(val(cDay)))+",")
      exit
   endif
enddo

return cDate
