#define MONTH01 "Janeiro"
#define MONTH02 "Fevereiro"
#define MONTH03 "Mar‡o"
#define MONTH04 "Abril"
#define MONTH05 "Maio"
#define MONTH06 "Junho"
#define MONTH07 "Julho"
#define MONTH08 "Agosto"
#define MONTH09 "Setembro"
#define MONTH10 "Outubro"
#define MONTH11 "Novembro"
#define MONTH12 "Dezembro"

#define DAY1    "Domingo"
#define DAY2    "Segunda-feira"
#define DAY3    "Ter‡a-feira"
#define DAY4    "Quarta-feira"
#define DAY5    "Quinta-feira"
#define DAY6    "Sexta-feira"
#define DAY7    "S bado"

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

