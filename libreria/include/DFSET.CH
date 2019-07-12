/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                    Application Init Preferences                      |
   |                        Init Function Return                          |
   |                          Color Definition                            |
   |                             Button Type                              |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFSET_CH
   #define _DFSET_CH
   // Application Init

   #define AI_USERLEVEL                1
   #define AI_USERNAME                 2
   #define AI_ZOOMBOX                  3
   #define AI_ZOOMSOUND                4
   #define AI_INDEXPACK                5
   #define AI_NET                      6
   #define AI_LOCKREPEATTIME           7
   #define AI_MOUSE                    8
   #define AI_TABNAME                  9
   #define AI_TABINDEX1               10
   #define AI_TABMODIFY               11
   #define AI_GETTIMEOUT              12
   #define AI_GETWARNING              13
   #define AI_USEGETTIMEOUT           14
   #define AI_CONSOLELINES            15
   #define AI_SHADOWCOLOR             16
   #define AI_DEFAULTPRINTER          17
   #define AI_DEFAULTPORT             18
   #define AI_OBJECTOFFCOLOR          19
   #define AI_INIVERSION              20
   #define AI_CLEARSCREEN             21
   #define AI_FONTREDEFINITION        22
   #define AI_SCREENCOLOR             23
   #define AI_INIMESSAGE              24
   #define AI_ALTF4ISACTIVE           25
   #define AI_SCRSAVERACTIVE          26
   #define AI_SCRSAVERTIME            27
   #define AI_FASTMENUALT             28
   #define AI_FILEMODIFY              29
   #define AI_USRICON                 30
   #define AI_USRSTATE                31
   #define AI_FASTMENUEXIT            32
   #define AI_FASTDISPLAY             33
   #define AI_ERRORINWINDOW           34
   #define AI_GETCHECKUAR             35
   #define AI_IFNOKEYREPEATGET        36
   #define AI_GOTOWINAFTERRETURN      37
   #define AI_MENUSCREENFILL          38
   #define AI_MENUSCREENCOLOR         39
   #define AI_DISABLEKEYINDEX         40
   #define AI_FILTEROPTIMIZER         41
   #define AI_DDKEYMESSAGE            42
   #define AI_AS400INIT               43
   #define AI_FILEINSERTCB            44
   #define AI_TABLEINSERTCB           45
   #define AI_CALCULATORGET           46
   #define AI_LOGFILE                 47
   #define AI_NULLIFY_CHAR            48
   #define AI_NULLIFY_DATE            49
   #define AI_NULLIFY_LOGICAL         50
   #define AI_NULLIFY_NUMERIC         51
   #define AI_FORMCHECKESC            52
   #define AI_MAXMEM                  53
   #define AI_ENABLESEARCHKEY         54
   #define AI_DISABLEUSEMESSAGE       55
   #define AI_AUTOMATICCOMPOUND       56
   #define AI_FORTRESSINIT            57
   #define AI_AS400DISABLECLOSE       58
   #define AI_BUTDISABLEDPROMPT       59
   #define AI_BUTDISABLEDHOTKET       60
   #define AI_ENABLEUSERTRACE         61
   #define AI_WINDOWINFO              62
   #define AI_INDEXPROGRESSBAR        63
   #define AI_DISABLENOTHINGTOPRINT   64
   #define AI_WIN95INTERFACE          65
   #define AI_DATEMESSAGE             66
   #define AI_DISABLELABELPRINT       67
   #define AI_DISABLEALLCLOSE         68
   #define AI_DISABLEPRINTERSAVE      69
   #define AI_LOGMESSAGE              70
   #define AI_DISABLEMGNOPT           71
   #define AI_IDLETIME                72
   #define AI_HIDEMENUITEM            73
   #define AI_DISABLEKEYOPT           74
   #define AI_TABLECHECKCB            75
   #define AI_DISABLEREPORTFILTER     76
   #define AI_EDITCELLCB              77
   #define AI_50ROWFORM               78
   #define AI_UPDCREATEBAK            79
   #define AI_MULTILINEBUTTON         80
   #define AI_DISABLESTATISTIC        81
   #define AI_PROGRAMMINGHELP         82
   #define AI_TABLEFILTER             83
   #define AI_EXACTKEYFOUND           84
   #define AI_CRIPTKEY                85
   #define AI_EXITAPPS                86
   #define AI_EXITAPPSTIME            87
   #define AI_BUTPRESSED              88
   #define AI_EUROENABLED             89
   #define AI_EUROCHANGE              90
   #define AI_EUROCHAR                91
   #define AI_CALCULATORBTN2EURO      92
   #define AI_CALCULATORBTN2BASE      93
   #define AI_XBASEMESSAGECENTERED    94
   #define AI_PACKCODEBLOCK           95
   #define AI_XBASEREFRESH            96
   #define AI_XBASEFRAMESCROLL        97
   #define AI_REPUSEPAGELENGHT        98
   #define AI_LOGUSEDFORM             99
   #define AI_XBASEDOSCOMPATIBLE     100
   #define AI_OPENFILECB             101
   #define AI_CLOSEFILECB            102
   #define AI_ERRORCB                103
   #define AI_LOOKAUTOWIN            104
   #define AI_DBTMAXSIZE             105
   #define AI_XBASEPRNMENUNEW        106
   #define AI_CHECKMODE              107
      #define AI_CHECKMODE_ONUSE       1
      #define AI_CHECKMODE_SKIP        2
   #define AI_DOSPRINTDIRECT         108
   #define AI_NEWLABEL               109
   #define AI_FASTSEEKTIMEOUT        110
   #define AI_XBASEPRINTFONT         111
      #define AI_PRINTFONT_PRINTER     0
      #define AI_PRINTFONT_REPORT      1
      #define AI_PRINTFONT_PRN_REP     2
   #define AI_XBASECOLORMODE         112
      #define AI_COLORMODE_STD         0
      #define AI_COLORMODE_DBSEE       1
   #define AI_XBASEDDKEYMODE         113
      #define AI_DDKEYMODE_STD         0
      #define AI_DDKEYMODE_ENH         1
   #define AI_XBASEDISABLEPDFPRINT   114
   #define AI_SAVEFILTERONUSE        115
   #define AI_SAVEFILTERONPUSHAREA   116
   #define AI_DISABLEFASTSEEK        117
   #define AI_FASTSEEKVALIDKEY       118
   #define AI_XBASETOOLBARADDTOP     119
   #define AI_XBASEREPORTMANTMPFILE  120
      #define AI_REPORTMANAGER_TEMPFILE_DBF  1
      #define AI_REPORTMANAGER_TEMPFILE_XML  2
   #define AI_XBASEMAINMENUMDI       121
      #define AI_MENUMDI_DISABLED      0  // main menu mdi disabled
      #define AI_MENUMDI_ENABLED       1  // show toolbar and statusline on each form
      #define AI_MENUMDI_SHOWTOOLBAR   2  // show toolbar only on main menu, statusline on each form
      #define AI_MENUMDI_SHOWSTATUS    4  // show statusline only on main menu, toolbar on each form
   #define AI_XBASEFORMSCROLL        122
      #define AI_FORMSCROLL_DISABLED        0
      #define AI_FORMSCROLL_ENABLED         1
      #define AI_FORMSCROLL_ENABLED_ALWAYS  2
   #define AI_XBASEWAITSTYLE         123
      #define AI_WAITSTYLE_STD         0
      #define AI_WAITSTYLE_FANCY       1
      #define AI_WAITSTYLE_FANCY_AUTO  2
   #define AI_XBASEMSGSTYLE          124
      #define AI_MSGSTYLE_STD          0
      #define AI_MSGSTYLE_FANCY        1
      #define AI_MSGSTYLE_FANCY_AUTO   2
   #define AI_XBASEALERTSTYLE        125
      #define AI_ALERTSTYLE_STD        0
      #define AI_ALERTSTYLE_FANCY      1
   #define AI_XBASEALERTICONS        126
      #define AI_ALERTICONS_STD        0
      #define AI_ALERTICONS_FANCY      1
   #define AI_XBASETOOLBARSTYLE      127
      #define AI_TOOLBARSTYLE_STD      0
      #define AI_TOOLBARSTYLE_RIGHT    1
   #define AI_XBASESTATUSLINESTYLE   128
      #define AI_STATUSLINESTYLE_STD   0
      #define AI_STATUSLINESTYLE_FLAT  1
   #define AI_XBASEMULTIPAGESTYLE    129
      #define AI_MULTIPAGESTYLE_STD    0
      #define AI_MULTIPAGESTYLE_FLAT   1
   #define AI_XBASEGETSTYLE          130
   #define AI_XBASEBUTSTYLE          131
   #define AI_XBASEGRPBOXSTYLE       132
   #define AI_XBASELSBBOXSTYLE       133
   #define AI_XBASETXTBOXSTYLE       134
   #define AI_XBASECHKSTYLE          135
   #define AI_XBASERADSTYLE          136

   #define AI_XBASEGRPBOXFONT        137
   #define AI_XBASETOOLBAROPTIONS    138
      #define AI_TOOLBARRIGHT_WIDTH    1
      #define AI_TOOLBAR_HEIGHT        2

   #define AI_XBASESTDFUNCTIONS      139
      #define AI_STDFUNC_DDKEY         1
      #define AI_STDFUNC_DDWIN         2
      #define AI_STDFUNC_TBBRWNEW      3
      #define AI_STDFUNC_TBCONFIG      4
      #define AI_STDFUNC_TBEND         5
      #define AI_STDFUNC_DFSET         6
      #define AI_STDFUNC_DFARRWIN      7
      #define AI_STDFUNC_DFAUTOFORM    8
      #define AI_STDFUNC_DFNET        20

   #define AI_LOOKINSERTCB           140
   #define AI_TBSETKEYTOP            141
   #define AI_MULTIPAGE_FIND_CTRL    142
   #define AI_INDEXSTRUCTDYN         143

   #define AI_XBASEPROGRESSSTYLE     144
      #define AI_PROGRESSSTYLE_STD         0
      #define AI_PROGRESSSTYLE_STD_THREAD  1
      #define AI_PROGRESSSTYLE_FANCY       2

   #define AI_XBASEPRINTPROGRESSSTYLE 145
      #define AI_PRINTPROGRESSSTYLE_STD    0
      #define AI_PRINTPROGRESSSTYLE_FANCY  1
      #define AI_PRINTPROGRESSSTYLE_FANCY_THREAD 2

   #define AI_XBASEINDEXWAITSTYLE 146
      #define AI_INDEXWAITSTYLE_STD    0
      #define AI_INDEXWAITSTYLE_FANCY  1
      #define AI_INDEXWAITSTYLE_NONE   2

   #define AI_XBASEBRWAUTOFITCOLUMNS 147
      #define AI_BRWAUTOFITCOLUMNS_AUTO    0
      #define AI_BRWAUTOFITCOLUMNS_YES     1
      #define AI_BRWAUTOFITCOLUMNS_NO      2

   #define AI_XBASEDISABLEDGETCOPY   148
      #define AI_DISABLEDGETCOPY_NO    0
      #define AI_DISABLEDGETCOPY_YES   1

   #define AI_ERRORSAVESCREEN        149

   #define AI_TBPRNLAB_CB            150
   #define AI_TBPRNWIN_CB            151
   #define AI_TBFILESTAT_CB          152
   #define AI_EMAILFAX_CB            153

   #define AI_LEN                    153

   // Return Type

   #define RT_ARRAY                1
   #define RT_CHARACTER            2
   #define RT_LOGICAL              3
   #define RT_NUMBER               4


   // Application Color

   // Browse/Form DEFAULT Color
   #define AC_FRM_BACK             1
   #define AC_FRM_BOX              2
   #define AC_FRM_HEADER           3
   #define AC_FRM_OPTION           4
   #define AC_FRM_CURSOR           5
   #define AC_FRM_SAY              6
   #define AC_FRM_NORMALBOX        7
   #define AC_FRM_SHADOWBOX        8
   #define AC_FRM_FUNCTION         9
   #define AC_FRM_PROMPT          10
   #define AC_FRM_HOTPROMPT       11
   #define AC_FRM_GETNORMAL       12
   #define AC_FRM_GETCOMBO        13
   #define AC_FRM_COMBO           14
   #define AC_FRM_TEXFIELD        15
   #define AC_FRM_RADCHK          16

   #define AC_LSB_BACK             1
   #define AC_LSB_TOPLEFT          2
   #define AC_LSB_PROMPT           3
   #define AC_LSB_BOTTOMRIGHT      4
   #define AC_LSB_HILITE           5
   #define AC_LSB_HOTKEY           6

   // Button Color
   #define AC_BUT_NORMAL           1
   #define AC_BUT_HOTNORMAL        2
   #define AC_BUT_TNORMAL          3
   #define AC_BUT_BNORMAL          4
   #define AC_BUT_SELECTED         5
   #define AC_BUT_UNSELECTABLE     6

   // Button Type
   #define AC_BUT_SAYNORMAL        1
   #define AC_BUT_SAYSELECTED      2
   #define AC_BUT_SAYUNSELECTABLE  3
   #define AC_BUT_SAYPRESSED       4

   // WallPaper Color
   #define AC_WAL_SAY              1
   #define AC_WAL_BOX              2
   #define AC_WAL_FONT             3

   // Message Color
   #define AC_MSG_NORMALSAY        1
   #define AC_MSG_NORMALBOX        2
   #define AC_MSG_ERRORSAY         3
   #define AC_MSG_ERRORBOX         4
   #define AC_MSG_RESIDENTSAY      5
   #define AC_MSG_RESIDENTBOX      6
   #define AC_MSG_WINDOWSAY        7
   #define AC_MSG_WINDOWBOX        8

   // User Line Color
   #define AC_USR_NORMAL           1
   #define AC_USR_STATE            2
   #define AC_USR_ICON             3

   // Frame Color
   #define AC_FRA_BOX              1
   #define AC_FRA_HEADER           2
   #define AC_FRA_WALL             3
   #define AC_FRA_LINE             4

   // ddKEY Color
   #define AC_KEY_BOX              1
   #define AC_KEY_HEADER           2
   #define AC_KEY_KEYNORMAL        3
   #define AC_KEY_KEYSELECTED      4
   #define AC_KEY_SAY              5
   #define AC_KEY_GETNORMAL        6
   #define AC_KEY_GETSELECTED      7

   // dfHlp Color
   #define AC_HLP_BACK             1
   #define AC_HLP_BRWBACK          2
   #define AC_HLP_BRWBOX           3
   #define AC_HLP_BRWHEAD          4
   #define AC_HLP_OPTION           5
   #define AC_HLP_NORMAL           6
   #define AC_HLP_SELECT           7
   #define AC_HLP_HEADER           8
   #define AC_HLP_TITLE            9

   // Progress indicator
   #define AC_PI_BOX               1
   #define AC_PI_SHADOWBOX         2
   #define AC_PI_HEADER            3
   #define AC_PI_SAY               4
   #define AC_PI_PROGRESS          5

   // dfCalc
   #define AC_CALC_BOX             1
   #define AC_CALC_DISPLAYBOX      2
   #define AC_CALC_TOTAL           3
   #define AC_CALC_CHAR1           4
   #define AC_CALC_CHAR2           5
   #define AC_CALC_CHAR3           6
   #define AC_CALC_CHAR4           7
   #define AC_CALC_CHAR5           8

   // dfLogin
   #define AC_PWD_BOX              1
   #define AC_PWD_HEADER           2
   #define AC_PWD_ICON             3
   #define AC_PWD_SAY              4
   #define AC_PWD_PASSWORD         5

   // dfCalendar
   #define AC_CALC_BACK            1
   #define AC_CALC_ICON            2
   #define AC_CALC_DAY             3
   #define AC_CALC_CURRENT         4
   #define AC_CALC_MONTH           5

#endif
