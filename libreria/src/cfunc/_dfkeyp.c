/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>
#include <dfkey.ch>

XPPRET XPPENTRY DFKEYPRES( XppParamList paramList ){
   int nBin = _parni( paramList, 1 );
   int iRet = 0;

   BYTE keyState[256];
   GetKeyboardState((LPBYTE)&keyState);

   switch( nBin ){
      case KEY_EITHERALT : { iRet=(keyState[VK_CONTROL ]&1);    break;}
      case KEY_EITHERCTRL: { iRet=(keyState[VK_MENU    ]&1);    break;}
      case KEY_LEFTSHIFT : { iRet=(keyState[VK_LSHIFT  ]&1);    break;}
      case KEY_RIGHTSHIFT: { iRet=(keyState[VK_RSHIFT  ]&1);    break;}
      case KEY_INSERT    : { iRet=(keyState[VK_INSERT  ]&1);    break;}
      case KEY_CAPSLOCK  : { iRet=(keyState[VK_CAPITAL ]&1);    break;}
      case KEY_NUMLOCK   : { iRet=(keyState[VK_NUMLOCK ]&1);    break;}
      case KEY_SCROLLLOCK: { iRet=(keyState[VK_SCROLL  ]&1);    break;}
      case KEY_LEFTALT   : { iRet=(keyState[VK_LMENU   ]&1);    break;}
      case KEY_LEFTCTRL  : { iRet=(keyState[VK_LCONTROL]&1);    break;}
      case KEY_RIGHTALT  : { iRet=(keyState[VK_RMENU   ]&1);    break;}
      case KEY_RIGHTCTRL : { iRet=(keyState[VK_RCONTROL]&1);    break;}
   }
   _retl( paramList, iRet );
}
