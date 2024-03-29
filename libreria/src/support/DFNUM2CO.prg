/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfNum2Col( nBios )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
STATIC fpColorF := { "N" , "B" , "G" , "BG" , "R" , "RB" , "GR" , "W" ,;
                     "N+", "B+", "G+", "BG+", "R+", "RB+", "GR+", "W+" }

STATIC fpColorB := { "N" , "B" , "G" , "BG" , "R" , "RB" , "GR" , "W" ,;
                     "N*", "B*", "G*", "BG*", "R*", "RB*", "GR*", "W*" }

LOCAL cCol := ""

cCol += fpColorF[ MOD(nBios,16)+1 ]
cCol += "/"
cCol += fpColorB[ INT(nBios/16)+1 ]

RETURN cCol
