#define MONTH01 "Gennaio"
#define MONTH02 "Febbraio"
#define MONTH03 "Marzo"
#define MONTH04 "Aprile"
#define MONTH05 "Maggio"
#define MONTH06 "Giugno"
#define MONTH07 "Luglio"
#define MONTH08 "Agosto"
#define MONTH09 "Settembre"
#define MONTH10 "Ottobre"
#define MONTH11 "Novembre"
#define MONTH12 "Dicembre"

#define DAY1    "Domenica"
#define DAY2    "Luned"
#define DAY3    "Marted"
#define DAY4    "Mercoled"
#define DAY5    "Gioved"
#define DAY6    "Venerd"
#define DAY7    "Sabato"

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

