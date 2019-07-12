//Topic:    CASPLOCK on/off switching (2 of 2), Read 17 times
//Conf:  Xbase++ Q&A
//From:  Boris Borzic (bborzic@compuserve.com)
//Date:  Friday, April 09, 1999 07:23 AM
//Andreas,

//>i am looking for a solution (a
//>few lines of code in Xbase++)
//>to turn on or off the caps
//>lock LED.

//Here's some C code for doing this. You should be able to call both "keybd_event" and "GetKeyboardState"
//functions found in user32.dll from Xbase++.

//HTH,
//Boris Borzic

//#include <WINDOWS.H>

/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFLED( XppParamList paramList ){
//void DFLED( int nNewLed ){
   int nLed;

   OSVERSIONINFO o;
   int Success;

   BYTE keyState[256];
   GetKeyboardState((LPBYTE)&keyState);

   Success = GetVersionEx((LPOSVERSIONINFO) &o);
   o.dwPlatformId=VER_PLATFORM_WIN32_WINDOWS;
   //o.dwPlatformId=VER_PLATFORM_WIN32_NT;

   //IN CASO DI ERRORE GetLastError();

   /*
     ³ 1 ³   ScrollLock   ³
     ³ 2 ³   NumLock      ³
     ³ 4 ³   CapsLock     ³
   */

   nLed = 0;
   if( keyState[VK_NUMLOCK] & 1 )
      nLed += 2;

   if( keyState[VK_SCROLL]  & 1 )
      nLed += 1;

   if( keyState[VK_CAPITAL] & 1 )
      nLed += 4;

   if( PCOUNT(paramList)>=1 && XPP_IS_NUM(_partype(paramList,1)) ) {
      int bTest;
      INT nNewLed = _parni( paramList, 1 );

      bTest = nNewLed&4;
      if( (  bTest  && (!(keyState[VK_CAPITAL] & 1)) ) ||
          ((!bTest) &&   (keyState[VK_CAPITAL] & 1)) ) {

         if( o.dwPlatformId==VER_PLATFORM_WIN32_WINDOWS ) {
            if( keyState[VK_CAPITAL]==1 )
               keyState[VK_CAPITAL] = 0;
            else
               keyState[VK_CAPITAL] = 1;
            SetKeyboardState( keyState );
         } else if( o.dwPlatformId==VER_PLATFORM_WIN32_NT ) {
            // Simulate a key press
            keybd_event( VK_CAPITAL, 0x45, KEYEVENTF_EXTENDEDKEY | 0,0 );

            // Simulate a key release
            keybd_event( VK_CAPITAL, 0x45, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP,0);
         }
      }

      bTest = nNewLed&1;
      if( (  bTest  && (!(keyState[VK_SCROLL] & 1)) ) ||
          ((!bTest) &&   (keyState[VK_SCROLL] & 1)) ) {

         if( o.dwPlatformId==VER_PLATFORM_WIN32_WINDOWS ) {
            if( keyState[VK_SCROLL]==1 )
               keyState[VK_SCROLL] = 0;
            else
               keyState[VK_SCROLL] = 1;
            SetKeyboardState( keyState );
         } else if( o.dwPlatformId==VER_PLATFORM_WIN32_NT ) {
            // Simulate a key press
            keybd_event( VK_SCROLL, 0x45, KEYEVENTF_EXTENDEDKEY | 0,0 );

            // Simulate a key release
            keybd_event( VK_SCROLL, 0x45, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP,0);
         }
      }

      bTest = nNewLed&2;
      if( (  bTest  && (!(keyState[VK_NUMLOCK] & 1)) ) ||
          ((!bTest) &&   (keyState[VK_NUMLOCK] & 1)) ) {

         if( o.dwPlatformId==VER_PLATFORM_WIN32_WINDOWS ) {
            if( keyState[VK_NUMLOCK]==1 )
               keyState[VK_NUMLOCK] = 0;
            else
               keyState[VK_NUMLOCK] = 1;
            SetKeyboardState( keyState );
         } else if( o.dwPlatformId==VER_PLATFORM_WIN32_NT ) {
            // Simulate a key press
            keybd_event( VK_NUMLOCK, 0x45, KEYEVENTF_EXTENDEDKEY | 0,0 );

            // Simulate a key release
            keybd_event( VK_NUMLOCK, 0x45, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP,0);
         }
      }
   }

   // Non serve a nulla, ma pare che sistemi la tastiera
   GetKeyboardState((LPBYTE)&keyState);
   // Non serve a nulla, ma pare che sistemi la tastiera

   _retni( paramList, nLed );
}

/*
void main(){
 DFLED( 0 );
 DFLED( 1 );
 DFLED( 2 );
 DFLED( 4 );

}
*/
