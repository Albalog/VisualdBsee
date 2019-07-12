/****************************************************************************
*
* Projekt ...........: XbpPrinter
* Modulname .........: XbpPrinter.cpp
*
* Programmierer .....: S.Braun
* Datum .............: 11.11.1999
* Version ...........: V1.00
*
* Beschreibung ......: Funktionen für Druckermanipulation ohne Benutzerabfrage
*
*****************************************************************************/
#include <stdio.h>
#include <tapi.h>
#include <string.h>
#include <winspool.h>
#include <wingdi.h>

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

int __dfXppSetBin(char *cPrinterName,int nBin);
DEVMODE *__dfXppGetBin(char *cPrinterName);

XPPRET XPPENTRY DFXPPSETBIN( XppParamList paramList ){
   LONG nPar1Len = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(nPar1Len+1) );
   char *cPrinterName = _momLock( hNew1 );

   int nBin = _parni( paramList, 2 );

   _parc( cPrinterName, nPar1Len+1, paramList, 1 );

   _retni(paramList, __dfXppSetBin(cPrinterName,nBin) );

   _momUnlock(hNew1);
   _momFree(hNew1);
}

XPPRET XPPENTRY DFXPPGETBIN( XppParamList paramList ){
   LONG nPar1Len = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(nPar1Len+1) );
   char *cPrinterName = _momLock( hNew1 );
   DEVMODE *pMode;

   _parc( cPrinterName, nPar1Len+1, paramList, 1 );

   pMode = __dfXppGetBin(cPrinterName);
   //_retclen(paramList, __dfXppGetBin(cPrinterName) );
   if( pMode )
      _retclen(paramList,(char*)pMode,sizeof(pMode) );
   else
      _retc(paramList,"");

   _momUnlock(hNew1);
   _momFree(hNew1);
}

/******
* Funktionsname : GetBin
* Beschreibung .: Ermittelt den aktuellen Standardpapierschacht des gewünschten Druckers
* Parameter ....: cPrinterName	Druckername
* Rückgabe .....: 0				Fehler
*				  Schachtnummer	kein Fehler
* Änderungen ...: 19 Nov 99/SB  erstellt
* Bemerkungen ..: Extern "C" muss vor der Funktion stehen, ansonsten wird die Export-
*				  tabelle der Dll falsch geschrieben!
*/
DEVMODE *__dfXppGetBin(char *cPrinterName)
{
	HANDLE hPrinter = 0;
	DWORD dwNeeded = 0, dwRet = 0;
	HGLOBAL hGlobal = NULL;
	DEVMODE *pDevMode = NULL;

	// Drucker öffnen (Zugriffsrechte werden nicht benötigt, da keine Änderungen gemacht werden)
	dwRet = OpenPrinter(cPrinterName,&hPrinter,NULL);
	if(dwRet != 0)
	{
		// Grösse der DevMode Struktur abfragen
		dwNeeded = DocumentProperties(0,hPrinter,NULL,NULL,NULL,0);
		if(dwNeeded > 0)
		{
			// Speicher für DevMode Struktur reservieren
			hGlobal = GlobalAlloc(GHND,dwNeeded);
			if(hGlobal != NULL)
			{
				// Speicher der Struktur DevMode zuweisen
				pDevMode = (DEVMODE *)GlobalLock(hGlobal);
				if(pDevMode != NULL)
				{
					// Struktur mit Werten füllen
					dwRet = DocumentProperties(0,hPrinter,NULL,pDevMode,NULL,DM_OUT_BUFFER);
					if(dwRet == IDOK)
					{
						// Aktueller Standardschacht zurückgeben

						// You can replace this value with other values from the devmode
						// structure.
						// see: http://msdn.microsoft.com/library/psdk/gdi/prntspol_8nle.htm
						// for example return(pDevmode->dmOrientation) for the paper orientation
						//return (pDevMode->dmDefaultSource);
						return (pDevMode);
					}
					else
					{
						// Reservierter Speicher für DevMode Struktur löschen
						GlobalUnlock(hGlobal);
						GlobalFree(hGlobal);
						// Drucker schliessen
						ClosePrinter(hPrinter);
						// 0 Zurückgeben
						return(0);
					}
				}
				else
				{
					GlobalFree(hGlobal);
					ClosePrinter(hPrinter);
					return(0);
				}
			}
			else
			{
				ClosePrinter(hPrinter);
				return(0);
			}
		}
		else
		{
			ClosePrinter(hPrinter);
			return(0);
		}

	}
	else
	{
		return(0);
	}
}

/******
* Funktionsname : SetBin
* Beschreibung .: Setzt den gewünschten Papierschacht als Standard des Druckers
* Parameter ....: cPrinterName	Druckername
*                 nBin			Schachtnummer
* Rückgabe .....: 0				Alles Ok
*				  Errorcode		Bei Fehler
* Änderungen ...: 11 Nov 99/SB  erstellt
* Bemerkungen ..: Extern "C" muss vor der Funktion stehen, ansonsten wird die Export-
*				  tabelle der Dll falsch geschrieben!
*/
int __dfXppSetBin(char *cPrinterName,int nBin)
{
	HGLOBAL hGlobal = NULL, hGlobalDoc = NULL;
	HANDLE hPrinter = 0;
	PRINTER_INFO_2 *pPrinter = NULL;
	DWORD dwNeeded = 0, dwRet = 0;
	PRINTER_DEFAULTS pPrinterDefaults;

	// Memory für PrinterDefaults Struktur löschen
	ZeroMemory(&pPrinterDefaults,sizeof(pPrinterDefaults));

	// Alle Zugriffsrechte für Drucker anfordern
	pPrinterDefaults.DesiredAccess = PRINTER_ALL_ACCESS;

	// Drucker öffnen
	dwRet = OpenPrinter(cPrinterName,&hPrinter,&pPrinterDefaults);
	if(dwRet != 0)
	{
		// Grösse PrinterInfo2 Struktur abfragen
        dwRet = GetPrinter(hPrinter,2,0,0,&dwNeeded);
		if( dwRet == 0 && dwNeeded > 0)
		{
			// Memory für Struktur reservieren
			hGlobal = GlobalAlloc(GHND,dwNeeded);
			if(hGlobal != NULL)
			{
				// Memory der PrinterInfo2 Struktur zuweisen
				pPrinter = (PRINTER_INFO_2 *)GlobalLock(hGlobal);
				if(pPrinter != NULL)
				{
					// Struktur mit Werten füllen
					dwRet = GetPrinter(hPrinter,2,(LPBYTE)pPrinter,dwNeeded,&dwNeeded);
					if(dwRet != 0)
					{
						// Struktur DevMode der PrinterInfo2 Struktur muss noch validiert werden
						// Dazu dient die Funktion DocumentProperties.
						// WinNt 4: Funktionierte auch ohne Validierung
						// Win 98: Validierung nötig!
						pPrinter->pDevMode = NULL;
						// Grösse der DevMode Struktur abfragen
						dwNeeded = DocumentProperties(0,hPrinter,NULL,NULL,NULL,0);
						if(dwNeeded > 0)
						{
							// Memory für Struktur reservieren
							hGlobalDoc = GlobalAlloc(GHND,dwNeeded);
							if(hGlobalDoc != NULL)
							{
								// Memory der Struktur DevMode zuweisen
								pPrinter->pDevMode = (DEVMODE *)GlobalLock(hGlobalDoc);
								if(pPrinter->pDevMode != NULL)
								{
									// Struktur mit Werten füllen
									dwRet = DocumentProperties(0,hPrinter,NULL,pPrinter->pDevMode,NULL,DM_OUT_BUFFER);
									if(dwRet != IDOK)
									{
										dwRet = GetLastError();
										GlobalUnlock(hGlobalDoc);
										GlobalFree(hGlobalDoc);
										GlobalUnlock(hGlobal);
										GlobalFree(hGlobal);
										ClosePrinter(hPrinter);
										return(dwRet);
									}
								}
								else
								{
									dwRet = GetLastError();
									GlobalFree(hGlobalDoc);
									GlobalUnlock(hGlobal);
									GlobalFree(hGlobal);
									ClosePrinter(hPrinter);
									return(dwRet);
								}
							}
							else
							{
								dwRet = GetLastError();
								GlobalUnlock(hGlobal);
								GlobalFree(hGlobal);
								ClosePrinter(hPrinter);
								return(dwRet);
							}
						}
						else
						{
							dwRet = GetLastError();
							GlobalUnlock(hGlobal);
							GlobalFree(hGlobal);
							ClosePrinter(hPrinter);
							return(dwRet);
						}

						// Druckerschacht setzen

						// You can replace this value with other values from the devmode
						// structure.
						// see: http://msdn.microsoft.com/library/psdk/gdi/prntspol_8nle.htm
						// for example: pPrinter->pDevMode->dmOrientation = 1;
						//				pPrinter->pDevMode->dmFields = DM_ORIENTATION;
						pPrinter->pDevMode->dmDefaultSource = nBin;
						// dmFields setzen
						// Nötig damit der Druckertreiber die Änderungen erkennt
						pPrinter->pDevMode->dmFields = DM_DEFAULTSOURCE;

						// Änderungen setzen
						dwRet = SetPrinter(hPrinter,2,(LPBYTE)pPrinter,(ULONG)NULL);
						if(dwRet != 0)
						{
							SendMessage(HWND_BROADCAST, WM_DEVMODECHANGE, 0L,(LPARAM)cPrinterName);
							// Falls alles Ok dann 0 zurückgeben!
							return(0);
						}
						else
						{
							// Bei Fehler:
							// Fehlercode ermitteln
							dwRet = GetLastError();
							// Memory für PrinterInfo2 Struktur löschen
							GlobalUnlock(hGlobal);
							GlobalFree(hGlobal);
							// Drucker schliessen
							ClosePrinter(hPrinter);
							// Fehlercode zurückgeben
							return(dwRet);
						}
					}
					else
					{
						dwRet = GetLastError();
						GlobalUnlock(hGlobal);
						GlobalFree(hGlobal);
						ClosePrinter(hPrinter);
						return(dwRet);
					}

				}
				else
				{
					dwRet = GetLastError();
					GlobalFree(hGlobal);
					ClosePrinter(hPrinter);
					return(dwRet);
				}
			}
			else
			{
				dwRet = GetLastError();
				ClosePrinter(hPrinter);
				return(dwRet);
			}

		}
		else
		{
			dwRet = GetLastError();
			ClosePrinter(hPrinter);
			return(dwRet);
		}
	}
	else
	{
		dwRet = GetLastError();
		return(dwRet);
	}
}
