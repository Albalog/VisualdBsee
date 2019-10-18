//////////////////////////////////////////////////////////////////////
//
//  PROFILER.CH
//
//  Copyright:
//      Alaska Software, (c) 2000-2006. All rights reserved.         
//  
//  Contents:
//      Definitions for the Profiler
//   
//////////////////////////////////////////////////////////////////////

#ifndef  _PROFILER_CH          

/*
 translate defines to function names if compiled with /profile
*/
#ifdef __XPP_PROFILE__

#xtranslate prfHold(<x>) =>  _prfHold(<x>)
#xtranslate prfResume(<x>) => _prfResume(<x>)
#else
#xtranslate prfHold(<x>) => 
#xtranslate prfResume(<x>) => 
#endif

#define  _PROFILER_CH          

#endif  // #ifndef _PROFILER_CH

// * EOF *
