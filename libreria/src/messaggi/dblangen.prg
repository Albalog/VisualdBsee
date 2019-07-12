#define MONTH01 "January"
#define MONTH02 "February"
#define MONTH03 "March"
#define MONTH04 "April"
#define MONTH05 "May"
#define MONTH06 "June"
#define MONTH07 "July"
#define MONTH08 "August"
#define MONTH09 "September"
#define MONTH10 "October"
#define MONTH11 "November"
#define MONTH12 "December"

#define DAY1    "Sunday"
#define DAY2    "Monday"
#define DAY3    "Tuesday"
#define DAY4    "Wednesday"
#define DAY5    "Thursday"
#define DAY6    "Friday"
#define DAY7    "Saturday"

FUNCTION _S2CMonth( dDate )
   LOCAL cRet   := ""
   LOCAL nMonth := 0
   LOCAL aMonths:= { MONTH01 , ;
                     MONTH02 , ;
                     MONTH03 , ;
                     MONTH04 , ;
                     MONTH05 , ;
                     MONTH06 , ;
                     MONTH07 , ;
                     MONTH08 , ;
                     MONTH09 , ;
                     MONTH10 , ;
                     MONTH11 , ;
                     MONTH12   }

   IF ! EMPTY(dDate) .AND. VALTYPE(dDate) == "D"
      nMonth := MONTH(dDate)
      IF nMonth >= 1 .AND. nMonth <= 12
         cRet := aMonths[nMonth]
      ENDIF
   ENDIF
RETURN cRet

FUNCTION _S2CDow( dDate )
   LOCAL cRet   := ""
   LOCAL nDay   := 0
   LOCAL aDays  := { DAY1 , ;
                     DAY2 , ;
                     DAY3 , ;
                     DAY4 , ;
                     DAY5 , ;
                     DAY6 , ;
                     DAY7   }

   IF ! EMPTY(dDate) .AND. VALTYPE(dDate) == "D"
      nDay := DOW(dDate)
      IF nDay >= 1 .AND. nDay <= 7
         cRet := aDays[nDay]
      ENDIF
   ENDIF
RETURN cRet

