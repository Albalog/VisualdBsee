//Luca 18/12/2006
//Si usano direttamente le funzioni di xbase ANSI.
//ConvToOemCP( <cAnsiFormatString> ) --> cOemFormatString 
//ConvToAnsiCP( <cOemFormatString> ) --> cAnsiFormatString
FUNCTION dfANSI2OEM(cStr) ;  RETURN ConvToOemCP( cStr) 
FUNCTION dfOEM2ANSI(cStr) ;  RETURN ConvToAnsiCP(cStr) 

