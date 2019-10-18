/* +----------------------------------------------------------------------+
   |                                                                      |
   |                     2000 - 2006 by Albalog s.r.l.                    |
   |                                                                      |
   |                        PDF related defines                           |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFPDF_CH
   #define _DFPDF_CH

   // Page orientation
   // ----------------

   #define PDF_VERTICAL    "P"
   #define PDF_HORIZONTAL  "L"

   // Page formats
   // ------------

   #define PDF_PAGE_LETTER         "LETTER"           //1
   #define PDF_PAGE_LEGAL          "LEGAL"            //2
   #define PDF_PAGE_LEDGER         "LEDGER"           //3
   #define PDF_PAGE_EXECUTIVE      "EXECUTIVE"        //4
   #define PDF_PAGE_A4             "A4"               //5
   #define PDF_PAGE_A3             "A3"               //6
   #define PDF_PAGE_JIS_B4         "JIS B4"           //7
   #define PDF_PAGE_JIS_B5         "JIS B5"           //8
   #define PDF_PAGE_JPOST          "JPOST"            //9
   #define PDF_PAGE_JPOSTD         "JPOSTD"           //10
   #define PDF_PAGE_COM10          "COM10"            //11
   #define PDF_PAGE_MONARCH        "MONARCH"          //12
   #define PDF_PAGE_C5             "C5"               //13
   #define PDF_PAGE_DL             "DL"               //14
   #define PDF_PAGE_B5             "B5"               //15
   #define PDF_PAGE_A5             "A5"               //16

   // Text Justify Define
   //----------------
   #define PDF_JUSTIFY_LEFT        1
   #define PDF_JUSTIFY_CENTER      2
   #define PDF_JUSTIFY_RIGHT       3
   #define PDF_JUSTIFY_EXPAND      4

   // Unita di Misura
   //----------------
   #define PDF_UM_ROW              "R"
   #define PDF_UM_DOTS             "D"
   #define PDF_UM_MM               "M"

   // Font style
   // ----------

   #define PDF_NORMAL        0
   #define PDF_BOLD          1
   #define PDF_ITALIC        2
   #define PDF_BOLDITALIC    3

   #define PDF_BOOKLEVEL     1
   #define PDF_BOOKTITLE     2
   #define PDF_BOOKPARENT    3
   #define PDF_BOOKPREV      4
   #define PDF_BOOKNEXT      5
   #define PDF_BOOKFIRST     6
   #define PDF_BOOKLAST      7
   #define PDF_BOOKCOUNT     8
   #define PDF_BOOKPAGE      9
   #define PDF_BOOKCOORD    10

   #define PDF_FONTNAME      1  // font name
   #define PDF_FONTSIZE      2  // font size
   #define PDF_LPI           3  // lines per inch
   #define PDF_PAGESIZE      4  // page size
   #define PDF_PAGEORIENT    5  // page orientation
   #define PDF_PAGEX         6
   #define PDF_PAGEY         7
   #define PDF_REPORTWIDTH   8  // report width
   #define PDF_REPORTPAGE    9  // report page
   #define PDF_REPORTLINE   10  // report line
   #define PDF_FONTNAMEPREV 11  // prev font name
   #define PDF_FONTSIZEPREV 12  // prev font size
   #define PDF_PAGEBUFFER   13  // page buffer
   #define PDF_REPORTOBJ    14  // current obj
   #define PDF_DOCLEN       15  // document length
   #define PDF_TYPE1        16  // array of type 1 fonts
   #define PDF_MARGINS      17  // recalc margins ?
   #define PDF_HEADEREDIT   18  // edit header ?
   #define PDF_NEXTOBJ      19  // next obj
   #define PDF_PDFTOP       20  // top row
   #define PDF_PDFLEFT      21  // left & right margin in mm
   #define PDF_PDFBOTTOM    22  // bottom row
   #define PDF_HANDLE       23  // handle
   #define PDF_PAGES        24  // array of pages
   #define PDF_REFS         25  // array of references
   #define PDF_BOOKMARK     26  // array of bookmarks
   #define PDF_HEADER       27  // array of headers
   #define PDF_FONTS        28  // array of report fonts
   #define PDF_IMAGES       29  // array of report images
   #define PDF_PAGEIMAGES   30  // array of current page images
   #define PDF_PAGEFONTS    31  // array of current page fonts
   #define PDF_FONTWIDTH    32  // array of fonts width's
   #define PDF_OPTIMIZE     33  // optimized ?
   #define PDF_BUFFERHANDLE 34  // if file buffer used
   #define PDF_PARAMLEN     34  // number of report elements

   #define PDF_ALIGN_LEFT    1
   #define PDF_ALIGN_CENTER  2
   #define PDF_ALIGN_RIGHT   3
   #define PDF_ALIGN_JUSTIFY 4

   #define PDF_IMAGE_WIDTH   1
   #define PDF_IMAGE_HEIGHT  2
   #define PDF_IMAGE_XRES    3
   #define PDF_IMAGE_YRES    4
   #define PDF_IMAGE_BITS    5
   #define PDF_IMAGE_FROM    6
   #define PDF_IMAGE_LENGTH  7
   #define PDF_IMAGE_SPACE   8

   #define PDF_BYTE          1
   #define PDF_ASCII         2
   #define PDF_SHORT         3
   #define PDF_LONG          4
   #define PDF_RATIONAL      5
   #define PDF_SBYTE         6
   #define PDF_UNDEFINED     7
   #define PDF_SSHORT        8
   #define PDF_SLONG         9
   #define PDF_SRATIONAL    10
   #define PDF_FLOAT        11
   #define PDF_DOUBLE       12

   #define PDF_ALICEBLUE            "F0F8FF"
   #define PDF_ANTIQUEWHITE         "FAEBD7"
   #define PDF_AQUA                 "00FFFF"
   #define PDF_AQUAMARINE           "7FFFD4"
   #define PDF_AZURE                "F0FFFF"
   #define PDF_BEIGE                "F5F5DC"
   #define PDF_BISQUE               "FFE4C4"
   #define PDF_BLACK                "000000"
   #define PDF_BLANCHEDALMOND       "FFEBCD"
   #define PDF_BLUE                 "0000FF"
   #define PDF_BLUEVIOLET           "8A2BE2"
   #define PDF_BROWN                "A52A2A"
   #define PDF_BURLYWOOD            "DEB887"
   #define PDF_CADETBLUE            "5F9EA0"
   #define PDF_CHARTREUSE           "7FFF00"
   #define PDF_CHOCOLATE            "D2691E"
   #define PDF_CORAL                "FF7F50"
   #define PDF_CORNFLOWERBLUE       "6495ED"
   #define PDF_CORNSILK             "FFF8DC"
   #define PDF_CRIMSON              "DC143C"
   #define PDF_CYAN                 "00FFFF"
   #define PDF_DARKBLUE             "00008B"
   #define PDF_DARKCYAN             "008B8B"
   #define PDF_DARKGOLDENROD        "B8860B"
   #define PDF_DARKGRAY             "A9A9A9"
   #define PDF_DARKGREEN            "006400"
   #define PDF_DARKKHAKI            "BDB76B"
   #define PDF_DARKMAGENTA          "8B008B"
   #define PDF_DARKOLIVEGREEN       "556B2F"
   #define PDF_DARKORANGE           "FF8C00"
   #define PDF_DARKORCHID           "9932CC"
   #define PDF_DARKRED              "8B0000"
   #define PDF_DARKSALMON           "E9967A"
   #define PDF_DARKSEAGREEN         "8FBC8F"
   #define PDF_DARKSLATEBLUE        "483D8B"
   #define PDF_DARKSLATEGRAY        "2F4F4F"
   #define PDF_DARKTURQUOISE        "00CED1"
   #define PDF_DARKVIOLET           "9400D3"
   #define PDF_DEEPPINK             "FF1493"
   #define PDF_DEEPSKYBLUE          "00BFFF"
   #define PDF_DIMGRAY              "696969"
   #define PDF_DODGERBLUE           "1E90FF"
   #define PDF_FIREBRICK            "B22222"
   #define PDF_FLORALWHITE          "FFFAF0"
   #define PDF_FORESTGREEN          "228B22"
   #define PDF_FUCHSIA              "FF00FF"
   #define PDF_GAINSBORO            "DCDCDC"
   #define PDF_GHOSTWHITE           "F8F8FF"
   #define PDF_GOLD                 "FFD700"
   #define PDF_GOLDENROD            "DAA520"
   #define PDF_GRAY                 "808080"
   #define PDF_GREEN                "008000"
   #define PDF_GREENYELLOW          "ADFF2F"
   #define PDF_HONEYDEW             "F0FFF0"
   #define PDF_HOTPINK              "FF69B4"
   #define PDF_INDIANRED            "CD5C5C"
   #define PDF_INDIGO               "4B0082"
   #define PDF_IVORY                "FFFFF0"
   #define PDF_KHAKI                "F0E68C"
   #define PDF_LAVENDER             "E6E6FA"
   #define PDF_LAVENDERBLUSH        "FFF0F5"
   #define PDF_LAWNGREEN            "7CFC00"
   #define PDF_LEMONCHIFFON         "FFFACD"
   #define PDF_LIGHTBLUE            "ADD8E6"
   #define PDF_LIGHTCORAL           "F08080"
   #define PDF_LIGHTCYAN            "E0FFFF"
   #define PDF_LIGHTGOLDENRODYELLOW "FAFAD2"
   #define PDF_LIGHTGREEN           "90EE90"
   #define PDF_LIGHTGREY            "D3D3D3"
   #define PDF_LIGHTPINK            "FFB6C1"
   #define PDF_LIGHTSALMON          "FFA07A"
   #define PDF_LIGHTSEAGREEN        "20B2AA"
   #define PDF_LIGHTSKYBLUE         "87CEFA"
   #define PDF_LIGHTSLATEGRAY       "778899"
   #define PDF_LIGHTSTEELBLUE       "B0C4DE"
   #define PDF_LIGHTYELLOW          "FFFFE0"
   #define PDF_LIME                 "00FF00"
   #define PDF_LIMEGREEN            "32CD32"
   #define PDF_LINEN                "FAF0E6"
   #define PDF_MAGENTA              "FF00FF"
   #define PDF_MAROON               "800000"
   #define PDF_MEDIUMAQUAMARINE     "66CDAA"
   #define PDF_MEDIUMBLUE           "0000CD"
   #define PDF_MEDIUMORCHID         "BA55D3"
   #define PDF_MEDIUMPURPLE         "9370DB"
   #define PDF_MEDIUMSEAGREEN       "3CB371"
   #define PDF_MEDIUMSLATEBLUE      "7B68EE"
   #define PDF_MEDIUMSPRINGGREEN    "00FA9A"
   #define PDF_MEDIUMTURQUOISE      "48D1CC"
   #define PDF_MEDIUMVIOLETRED      "C71585"
   #define PDF_MIDNIGHTBLUE         "191970"
   #define PDF_MINTCREAM            "F5FFFA"
   #define PDF_MISTYROSE            "FFE4E1"
   #define PDF_MOCCASIN             "FFE4B5"
   #define PDF_NAVAJOWHITE          "FFDEAD"
   #define PDF_NAVY                 "000080"
   #define PDF_OLDLACE              "FDF5E6"
   #define PDF_OLIVE                "808000"
   #define PDF_OLIVEDRAB            "6B8E23"
   #define PDF_ORANGE               "FFA500"
   #define PDF_ORANGERED            "FF4500"
   #define PDF_ORCHID               "DA70D6"
   #define PDF_PALEGOLDENROD        "EEE8AA"
   #define PDF_PALEGREEN            "98FB98"
   #define PDF_PALETURQUOISE        "AFEEEE"
   #define PDF_PALEVIOLETRED        "DB7093"
   #define PDF_PAPAYAWHIP           "FFEFD5"
   #define PDF_PEACHPUFF            "FFDAB9"
   #define PDF_PERU                 "CD853F"
   #define PDF_PINK                 "FFC0CB"
   #define PDF_PLUM                 "DDADDD"
   #define PDF_POWDERBLUE           "B0E0E6"
   #define PDF_PURPLE               "800080"
   #define PDF_RED                  "FF0000"
   #define PDF_ROSYBROWN            "BC8F8F"
   #define PDF_ROYALBLUE            "4169E1"
   #define PDF_SADDLEBROWN          "8B4513"
   #define PDF_SALMON               "FA8072"
   #define PDF_SANDYBROWN           "F4A460"
   #define PDF_SEAGREEN             "2E8B57"
   #define PDF_SEASHELL             "FFF5EE"
   #define PDF_SIENNA               "A0522D"
   #define PDF_SILVER               "C0C0C0"
   #define PDF_SKYBLUE              "87CEEB"
   #define PDF_SLATEBLUE            "6A5ACD"
   #define PDF_SLATEGRAY            "708090"
   #define PDF_SNOW                 "FFFAFA"
   #define PDF_SPRINGGREEN          "00FF7F"
   #define PDF_STEELBLUE            "4682B4"
   #define PDF_TAN                  "D2B48C"
   #define PDF_TEAL                 "008080"
   #define PDF_THISTLE              "D8BFD8"
   #define PDF_TOMATO               "FF6347"
   #define PDF_TURQUOISE            "40E0D0"
   #define PDF_VIOLET               "EE82EE"
   #define PDF_WHEAT                "F5DEB3"
   #define PDF_WHITE                "FFFFFF"
   #define PDF_WHITESMOKE           "F5F5F5"
   #define PDF_YELLOW               "FFFF00"
   #define PDF_YELLOWGREEN          "9ACD32"

#endif
