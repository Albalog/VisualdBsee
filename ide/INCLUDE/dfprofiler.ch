/* +----------------------------------------------------------------------+
   |                                                                      |
   |            2000 - 2006 by Albalog Srl - Florence - Italy             |
   |                                                                      |
   |                          PROFILER interface                          |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFPROFILER_CH

   #define _DFPROFILER_CH

   #ifdef __DFPROFILER_ENABLED__
      #xtranslate prfHold(<x>) =>  _dfProfHold(<x>)
      #xtranslate prfResume(<x>) => _dfProfResume(<x>)
   #else
      #xtranslate prfHold(<x>) => 
      #xtranslate prfResume(<x>) => 
   #endif

#endif

