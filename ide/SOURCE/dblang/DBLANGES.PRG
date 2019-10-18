#define MONTH01 "Enero"
#define MONTH02 "Febrero"
#define MONTH03 "Marzo"
#define MONTH04 "Abril"
#define MONTH05 "Mayo"
#define MONTH06 "junio"
#define MONTH07 "julio"
#define MONTH08 "Agosto"
#define MONTH09 "Septiembre"
#define MONTH10 "Octubre"
#define MONTH11 "Noviembre"
#define MONTH12 "Diciembre"

#define DAY1    "Domingo"
#define DAY2    "Lunes"
#define DAY3    "Martes"
#define DAY4    "Miercoles"
#define DAY5    "jueves"
#define DAY6    "Viernes"
#define DAY7    "Sabado"

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

