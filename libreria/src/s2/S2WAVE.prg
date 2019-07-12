//////////////////////////////////////////////////////////////////////
//
//  PLAYSND.PRG
//
//  Copyright:
//       Alaska Software Inc., (c) 1997-1999. All rights reserved.
//
//  Contents:
//       play system sounds via the dll interface
//
//////////////////////////////////////////////////////////////////////

#include "inkey.ch"
#include "directry.ch"
#include "dll.ch"

// flags for PlaySound
#define SND_SYNC            0
#define SND_ASYNC           1
#define SND_FILENAME        131072
#define SND_PURGE           64

// flags for MessageBeep
#define MB_ICONHAND         16
#define MB_OK               0
#define MB_DEFAULT          -1


//  IF waveOutGetNumDevs() = 0
//      MessageBeep( MB_ICONHAND)
//      Alert( "Error: No waveform output devices found!" )
//  ENDIF
//
// S2WaveStopSound()
// /* convert back to ANSI code page for PlaySound() */
// PlayWaveFile( cLookupDir + "\" + ConvToAnsiCp(aPlayField[nSelect]))

PROCEDURE S2WaveStopSound()
   /* stops waveform sound */
   DllCall("WINMM.DLL",DLL_STDCALL,"PlaySoundA",0,0,0)
   /* stops non-waveform sound */
   DllCall("WINMM.DLL",DLL_STDCALL,"PlaySoundA",0,0,SND_PURGE)
RETURN

/*
 * PlayWaveFile( cFileName )
 * This is a specialized wrapper which calls the underlaying function with
 * some fixed parameters.
 * Have a look at the SND-Flags: How to 'or' flags in Xbase++
 */
PROCEDURE S2WavePlayFile(cFilename)

    /* start to play the given file asynchronous  */
    DllCall("WINMM.DLL",DLL_STDCALL,"PlaySoundA",cFileName,0, SND_FILENAME + SND_ASYNC)

RETURN

/*
 * The MessageBeep wrapper:
 * we can use the DLLFUNCTION command because we use
 * the interface as is.
 */
DLLFUNCTION MessageBeep(nMsgType) USING STDCALL FROM "USER32.DLL"

/*
 * waveOutGetNumDevs()
 * returns the number of waveform audio output devices installed on the system
 */
DLLFUNCTION waveOutGetNumDevs() USING STDCALL FROM "WINMM.DLL"


