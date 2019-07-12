// da un URL ritorna array,  vedi funzione parse_url in php
// esempio 'http://username:password@hostname:port/path?arg=value#anchor'
// 1  * scheme - e.g. (http, https, file, mailto, ecc)
// 2  * host
// 3  * port
// 4  * user
// 5  * pass
// 6  * path
// 7  * query - after the question mark ?
// 8  * fragment - after the hashmark #

/* esempi da http://en.wikipedia.org/wiki/File_URI_scheme 
Linux
  file://localhost/etc/fstab
  file:///etc/fstab

Windows
  Here are some examples which may be accepted by some applications on Windows systems, 
  referring to the same file c:\WINDOWS\clock.avi

  file://localhost/c|/WINDOWS/clock.avi
  file:///c|/WINDOWS/clock.avi
  file://localhost/c:/WINDOWS/clock.avi

  Here is the correct URI as understood by the Windows Shell API:

  file:///c:/WINDOWS/clock.avi

altri
  file:////remotehost/share/dir/file.txt 
  file://localhost///remotehost/share/dir/file.txt
  file://///remotehost/share/dir/file.txt 

*/

#include "dfStd.ch"

#define URL_SCHEMA        1
#define URL_SCHEMA_SEP    2
#define URL_HOST          3
#define URL_PORT          4
#define URL_USER          5
#define URL_PASSWORD      6
#define URL_PATH          7
#define URL_QUERY         8
#define URL_FRAGMENT      9
//#define URL_FILEPATH_WIN 10

#define URL_ARR_SIZE     9

CLASS dfUrl
EXPORTED:
   VAR schema
   VAR schema_sep
   VAR host
   VAR port
   VAR user
   VAR PASSWORD
   VAR path
   VAR query 
   VAR fragment

   CLASS METHOD parseString()

   METHOD init()
   METHOD getSchema()
   METHOD toString()

   METHOD getLocalFile
   METHOD setLocalFile
ENDCLASS

METHOD dfUrl:init()
   ::schema     := ""
   ::schema_sep := ""
   ::host       := ""
   ::port       := ""
   ::user       := ""
   ::password   := ""
   ::path       := ""
   ::query      := ""
   ::fragment   := ""
RETURN self

METHOD dfUrl:getSchema()
RETURN LOWER(::schema)

METHOD dfUrl:getLocalFile()
   LOCAL ch := ""

   // calcolo il percorso al file 
   IF EMPTY(::getSchema()) 
      // se non ho file:// non faccio decodifiche strane
      ch := ::path

   ELSEIF (::getSchema() == "file")  //EMPTY(aRet[URL_SCHEMA]) .OR. 

      ch := ::path

      IF LEFT(ch, 3)=="///"
         // ä un percorso UNC con "/" iniziale es ///srvconta/shared/pippo.txt
         ch := SUBSTR(ch, 2)

      ELSEIF LEFT(ch, 2)=="//"
         // ä un percorso UNC senza "/" iniziale es //srvconta/shared/pippo.txt

      ELSE
         IF LEFT(ch, 1)=="/"
            // non ä un percorso UNC ma ha "/" iniziale es /c:/pippo.txt
            ch := SUBSTR(ch, 2)
         ENDIF

         IF SUBSTR(ch, 2, 1) == "|" 
            // sostitusco "|" con ":" es c|/file.txt -> c:/file.txt
            ch := STUFF(ch, 2, 1, ":") 
         ENDIF
      ENDIF

      ch := dfUrlDecode(ch)
   ENDIF
   ch := STRTRAN(ch, "/", "\")
RETURN ch

// imposta un percorso locale..
// i percorsi relativi NON hanno mai file://
// mentre gli assoluti hanno sempre file://
METHOD dfUrl:setLocalFile(c)
   LOCAL l:=.F.
   LOCAL ch
   LOCAL lDelFirstChar := .T. 

   // azzero tutto
   ::schema     := ""
   ::schema_sep := ""
   ::host       := ""
   ::port       := ""
   ::user       := ""
   ::password   := ""
   ::path       := ""
   ::query      := ""
   ::fragment   := ""

   IF EMPTY(dfFNameSplit(c)[1]) // se ä un percorso relativo
      // fix per far impostare sempre "file:///..." 
      // altrimenti poi in WORD non si vede l'immagine con <img src="c:/temp/pippo.jpg">
      // ma deve essere <img src="file:///c:/temp/pippo.jpg">
      ::schema := ""
      ::schema_sep := ""
   ELSE
      ::schema := "file"
      ::schema_sep := "://"
   ENDIF

   // calcolo il percorso al file 
   IF EMPTY(::getSchema()) 
      ch := c
      ch := STRTRAN(ch, "\", "/")      
      ::path := ch 

   ELSEIF   (::getSchema() == "file")  //EMPTY(aRet[URL_SCHEMA]) .OR. 

      ::path := ""
      ch := c

      ch := STRTRAN(ch, "\", "/")      

      IF SUBSTR(ch, 2, 1) == ":" 
         // sostitusco ":" con "|" es c:\file.txt -> c|\file.txt

         ::path += "/"+LEFT(ch, 1)+"|" // assegno ora per non far codificare anche il "|" 

         ch := SUBSTR(ch, 3) 

         IF LEFT(ch, 1)=="/"  // salto il primo / 
            ch := SUBSTR(ch, 2)
         ENDIF

         // simone 18/7/11
         // fix: se ä "/C|" non deve cancellare il primo "/"
         // lo faccio solo se ho ::schema_sep=="://" per cambiare il meno possibile
         // perchä non so quali casistiche potrei "rompere"
         IF ::schema_sep == "://"
            lDelFirstChar:= .F.
         ENDIF
      ENDIF

      ch := dfStr2Arr(ch, "/")

      // metto sempre un "/", ad esempio deve diventare
      // /c|/pippo.txt
      AEVAL(ch, {|x| ::path += "/"+dfUrlEncode(x)})

      IF lDelFirstChar
         ::path := SUBSTR(::path, 2)
      ENDIF
      l := .T.
   ENDIF
RETURN l


/*
FUNCTION dfUrlParse_test()
  local c

  c:="mailto:jsmith@example.com?subject=A%20Test&body=My%20idea%20is%3A%20%0A"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:="http://username:password@example.com:8042/over/there/index.dtb?type=animal;name=narwhal#nose"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file://localhost/etc/fstab"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file:///etc/fstab"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file://localhost/c|/WINDOWS/clock.avi"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file:///c|/WINDOWS/clock.avi"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file://localhost/c:/WINDOWS/clock.avi"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file:///c:/WINDOWS/clock.avi"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file:////remotehost/share/dir/file.txt"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file://localhost///remotehost/share/dir/file.txt"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file://///remotehost/share/dir/file.txt"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file://hostname/path/to/the%20file.txt"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file:///c:/path/to/the%20file.txt"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file:////remotehost/share/dir/file.txt"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))

  c:= "file://remotehost/share/dir/file.txt"
  MsgBox(c+CRLF+ VAR2CHAR(dfurlparse(c))+CRLF+dfurlarr2string(dfurlparse(c))+CRLF+VAR2CHAR(dfurlarr2string(dfurlparse(c))==c))
RETURN .T.
*/


CLASS METHOD dfUrl:parseString(cUrl)
   LOCAL nPos
   LOCAL aRet := ARRAY(URL_ARR_SIZE)
   LOCAL nSea, ch 
   LOCAL oRet

   AFILL(aRet, "")

   IF EMPTY(cUrl)
      RETURN aRet
   ENDIF

   nPos := AT(":", cUrl)
   IF nPos > 2 // se non ä c: ma ad esempio http:
      nSea := URL_SCHEMA
   ELSE
      nSea := URL_PATH
   ENDIF

   nPos := 0
   DO WHILE ++nPos <= LEN(cUrl)
      ch := DFCHAR(cUrl, nPos)

      IF nSea == URL_SCHEMA .AND. ch $ ":"

         aRet[URL_SCHEMA_SEP] := ch

         // tolgo il //
         IF SUBSTR(cUrl, nPos+1, 2)=="//"
            aRet[URL_SCHEMA_SEP] += "//"
            nPos+=2
         ENDIF

         // per default metto tutto nel PATH 
         nSea := URL_PATH

         // se http/ftp cerco user o host
         IF "-"+LOWER(aRet[URL_SCHEMA])+"-" $ "-http-https-ftp-mailto-"
            IF AT("@", cUrl, nPos) > 0
               nSea := URL_USER
            ELSE   
               nSea := URL_HOST
            ENDIF

         ELSEIF "-"+LOWER(aRet[URL_SCHEMA])+"-" $ "-file-"
            IF ! SUBSTR(cUrl, nPos+1, 1) == "/" .AND. ; // se non c'ä una "/" puï essere
               ! SUBSTR(cUrl, nPos+2, 1) $ ":|" // se ä

               // se non ho un "/" allora c'ä l'host, a meno che non ci sia un : o | 
               // esempio 
               // file://c:/WINDOWS/clock.avi
               // file://c|/WINDOWS/clock.avi

               nSea := URL_HOST
            ENDIF
         ENDIF
         ch := ""

      ELSEIF nSea == URL_USER .AND. ch $ ":@"
         IF ch == ":"
            nSea := URL_PASSWORD
         ELSE
            nSea := URL_HOST
         ENDIF
         ch := ""

      ELSEIF nSea == URL_PASSWORD .AND. ch $ "@"
         nSea := URL_HOST
         ch := ""

      ELSEIF nSea == URL_HOST .AND. ch $ ":/\?#"
         IF ch $ ":"
            nSea := URL_PORT
            ch := ""

         ELSEIF ch $ "/\"
            nSea := URL_PATH
            //ch := "" il path deve includere il "/" iniziale

         ELSEIF ch $ "?"
            nSea := URL_QUERY
            ch := ""

         ELSE //IF ch $ "#"
            nSea := URL_FRAGMENT
            ch := ""
         ENDIF

      ELSEIF nSea == URL_PORT .AND. ch $ "/\?#"
         nSea := URL_PATH
         IF ch $ "/\"
            nSea := URL_PATH
            //ch := "" il path deve includere il "/" iniziale

         ELSEIF ch $ "?"
            nSea := URL_QUERY
            ch := ""

         ELSE //IF ch $ "#"
            nSea := URL_FRAGMENT
            ch := ""
         ENDIF
         //ch := "" il path deve includere il "/" iniziale

      ELSEIF nSea == URL_PATH .AND. ch $ "?#"
         IF ch == "?"
            nSea := URL_QUERY
         ELSE //IF ch $ "#"
            nSea := URL_FRAGMENT
         ENDIF
         ch := ""

      ELSEIF nSea == URL_QUERY .AND. ch $ "#"
         nSea := URL_FRAGMENT
         ch := ""

      ENDIF

      aRet[ nSea ] += ch
   ENDDO

   oRet := dfUrl():new()
   oRet:schema     := aRet[URL_SCHEMA    ]
   oRet:schema_sep := aRet[URL_SCHEMA_SEP]
   oRet:host       := aRet[URL_HOST      ]
   oRet:port       := aRet[URL_PORT      ]
   oRet:user       := aRet[URL_USER      ]
   oRet:password   := aRet[URL_PASSWORD  ]
   oRet:path       := aRet[URL_PATH      ]
   oRet:query      := aRet[URL_QUERY     ]
   oRet:fragment   := aRet[URL_FRAGMENT  ]
RETURN oRet

// da un array aUrl compone la stringa
// senza fare conversioni, cioä bisogna usare il dfUrlEncode() 
// direttamente sul aUrl[URL_PATH])
// (funzione inversa di dfUrlParse())

METHOD dfUrl:toString()
   LOCAL cRet := ""

   IF ! EMPTY(::schema)            	
      cRet += ::schema + ::schema_sep
   ENDIF

   IF ! EMPTY(::host)
      IF ! EMPTY(::user)
         cRet += ::user
         IF ! EMPTY(::password)
            cRet += ":"+::password
         ENDIF
         cRet += "@"
      ENDIF

      cRet += ::host

      IF ! EMPTY(::port)
         cRet += ":"+::port
      ENDIF
   ENDIF

   IF ! EMPTY(::path) //.AND. ;
      //(EMPTY(aUrl[URL_SCHEMA]) .OR. "-"+LOWER(aUrl[URL_SCHEMA])+"-" $ "-http-https-ftp-file-")
      //IF ! LEFT(aUrl[URL_PATH], 1) $ "/\"
      //   cRet += "/" // aggiungo eventuale separatore dal HOST
      //ENDIF
      //cRet += "/" // aggiungo sempre separatore dal HOST (anche se vuoto) es file:///c|\pippo.txt
      cRet += ::path
   ENDIF

   IF ! EMPTY(::query)
      cRet += "?"+::query //aUrl[URL_QUERY]
   ENDIF

   IF ! EMPTY(::fragment)
      cRet += "#"+::fragment //aUrl[URL_FRAGMENT]
   ENDIF
RETURN cRet


