/*

   Registry-Klassenbibliothek für Xbase++
=======================================================
   Registry class for Xbase++

(C) Thomas Braun Softwareentwicklung
    Hindenburgstr. 69
    D-72336 Balingen
    GERMANY

    e-mail   : tb@software-braun.de
    Homepage : http://www.software-braun.de

Feel free to use the source below in any project you
like as long as you keep the above copyright note.

The most current version of this class can be found on
my homepage.

Any comments and enhancements are always welcome.

If you have any questions regarding this source feel free
to contact me via e-mail.

---------------------------------------------------------------------------------------
CHANGE HISTORY (sorry german guys, only in english ;-) :

30.09.2001 Extended RegOpenKeyEx to support Windows NT / 2000 access right settings
           for registry keys. Versions before this change allways tried to open the
           registry key with maximum access rights which is not possible under NT
           for "regular" users but only for users with administrator privilege.

23.09.2001 Two new defines and some helpful functions from Scott McNay (see reghelp.prg)

02.10.1999 New iVar cSaveStringTypeAs
           New ACCESS/ASSIGN SaveStringType

29.08.1999 Fixed a weird "duplicate variable declaration" error with Xbase++ SL2 1.20.204

21.08.1999 removed a left over "Return lSuccess" in xbpReg:DelKey()
           Fixed bug in :Init() method with SET EXACT ON. Init is now saving
           the current EXACT-state and restoring it when finished. (Thanks to
           Ken Levitt for this)


18.04.1999 Added Section "CHANGE HISTORY"
           New iVar cReadBinaryTypeAs
           New ACCESS/ASSIGN ReadBinType
           New Method ::ValueList() for retrieving a 2-dim array that contains all
                                    value names - value pairs. (so now you can query if
                                    a value already exists)
           several minor bugfixes regarding the useage under WindowsNT
           (thanks to Axel Zimelka for this one and Johan Droskie for some
            other comments)

*/


#include "common.ch"
#include "dll.ch"
#include "regclass.ch"
#include "set.ch"


/*
 Registry Klasse, verwaltet Informationen und stellt Zugriffsfunktionen für einen
 bestimmten RegistryKey bereit. Dieser muß in der Init-Funktion angegeben werden.

 Die Manipulationsmethoden erlauben es dann, Werte und weitere Key´s hinzu-
 zufügen / zu löschen / abzufragen usw.
 =================================================================================
 Registry class, contains information and accessfunctions for a single
 registry key. The name of the key must be set with the init method.

 The manipulation methods then allow to add/delete keys and values

*/
CLASS XbpReg

   HIDDEN:
      METHOD RegOpenKeyEx, RegCreateKeyEx, RegQueryInfoKey, RegCloseKey
      METHOD RegEnumKeyEx, RegEnumValue
      VAR nHKey                     // numerical handle from regclass.ch for the root key
      VAR cKey                      // Name of Subkey to open
      VAR nKeyHandle                // Handle to currently open key
      VAR lStatus                   // State of Key´s (see comment in the init method)
      VAR nCallSuccess              // return value of all Reg...DLL functions
      VAR nDllHandle                // DLL handle
      VAR xValue                    // general purpose iVar
      VAR cClass
      VAR nClass
      VAR nSubKeys
      VAR nMaxSubKeyLen
      VAR nMaxClassLen
      VAR nValues
      VAR nMaxValueNameLen
      VAR nMaxValueLen
      VAR nSecurityDescriptor
      VAR cLastWriteTime
      VAR nLastWriteTime
      VAR cReadBinaryTypeAs         // Datatype to be retrieved from REG_BINARY registry entry
      VAR cSaveStringTypeAs         // Datatype to be saved to registry

   EXPORTED:
      METHOD Init, Create
      METHOD NewKey, DelKey
      METHOD GetValue, SetValue, DelValue
      METHOD KeyList, MoveUp, MoveDown
      METHOD ValueList

      ACCESS ASSIGN METHOD Standard
      ACCESS ASSIGN METHOD ReadBinType     // get/set ::cReadBinaryTypeAs
      ACCESS ASSIGN METHOD SaveStringType  // get/set ::cSaveStringTypeAs
      ACCESS METHOD Status
      ACCESS METHOD KeyName

ENDCLASS

/*
   Init-Methode. Ermitteln, welcher Root-Key benötigt wird und diesen in ::nHKey
   eintragen.

   Subkey ermitteln und diesen in ::cKey eintragen

   Die Memberfunktion ::Status() gibt einen logischen Wert zurück der angibt,
   ob der Key bereits in der Registry angelegt ist (.T.) oder nicht (.F.)

   Wird lCreate auf .T. (default = .F.) gesetzt und existiert der Key noch nicht,
   so wird er neu angelegt. Anderenfalls muß er mittels der Methode ::create()
   erzeugt werden.

=======================================================================================

   Init method. First determine the needed root key which is then stored in ::nHKey

   Determine subkey name and store into ::cKey

   The member function ::Status() returns a logical value that states if the key already
   exists in the registry (.T.) or not (.F.)

   If lCreate is set to .T. (default = .F.) and the key does not exist, it is
   created in the init method.

   Otherwise it has to be created via the :create() method.

*/
METHOD XbpReg:Init( cRegKey, lCreate, lReInit )
   LOCAL nPos := 0
   /*
      Turning EXACT off, otherwise some string compares will fail...
      ======================
      EXACT auf "OFF" schalten, weil sonst einige String-Vergleiche weiter
      unten scheitern...
   */
   LOCAL lSetExact := SET( _SET_EXACT , .F. )

   DEFAULT cRegKey TO ""
   DEFAULT lCreate TO .F.
   DEFAULT lReInit TO .F.

   ::lStatus             := .F.
   ::nDllHandle          := 0
   ::cClass              := ""
   ::nClass              := 0
   ::nSubKeys            := 0
   ::nMaxSubKeyLen       := 0
   ::nMaxClassLen        := 0
   ::nValues             := 0
   ::nMaxValueNameLen    := 0
   ::nMaxValueLen        := 0
   ::nSecurityDescriptor := 0
   ::cLastWriteTime      := ""
   ::nLastWriteTime      := 0

   // Keep setting when doing :MoveUp / :MoveDown
   If ! lReInit
      ::cReadBinaryTypeAs   := "A"                  // Read Binary data into an array
      ::cSaveStringTypeAs   := "C"                  // Save Binary data into an array
   EndIF

   If ! EMPTY( cRegKey )
      If cRegKey = "\"                           // remove backslash
         cRegKey := SUBSTR( cRegKey, 2 )
      EndIF

      nPos := AT( "\", cRegKey )                 // det. name of subkey

      DO CASE
         CASE cRegKey = "HKEY_LOCAL_MACHINE"
            ::nHKey := HKEY_LOCAL_MACHINE

         CASE cRegKey = "HKEY_CLASSES_ROOT"
            ::nHKey := HKEY_CLASSES_ROOT

         CASE cRegKey = "HKEY_USERS"
            ::nHKey := HKEY_USERS

         CASE cRegKey = "HKEY_CURRENT_USER"
            ::nHKey := HKEY_CURRENT_USER

         CASE cRegKey = "HKEY_CURRENT_CONFIG"
            ::nHKey := HKEY_CURRENT_CONFIG

         CASE cRegKey = "HKEY_DYN_DATA"
            ::nHKey := HKEY_DYN_DATA

         OTHERWISE
            ::nHKey := HKEY_NO_KEY

      ENDCASE

      If ::nHKey # HKEY_NO_KEY                   // if root key exists

         If nPos # 0
            ::cKey := SUBSTR( cRegKey, nPos + 1 )
         Else
            ::cKey := ""
         ENDIF

         ::RegOpenKeyEx( ::cKey, KEY_QUERY_VALUE )                // open key

         If ::nCallSuccess = ERROR_SUCCESS
            ::lStatus := .T.
         ELSE
            If lCreate
               ::RegCreateKeyEx( ::cKey )
               IF ::nCallSuccess = ERROR_SUCCESS
                  ::lStatus := .T.
               EndIF
            EndIF
         EndIF

         ::RegCloseKey()

      EndIF
   EndIF

   SET( _SET_EXACT , lSetExact )

RETURN self

/*

   Registry Key erzeugen, hat nur eine Bedeutung, wenn der Key noch nicht existiert
   d.H. ::Status() == .F.

   Create muß nicht aufgerufen werden, wenn der Key existiert oder die init Methode
   mit lCreate == .T. aufgerufen wurde.

===================================

   Create registry key. Only works if the key does not exist (::Status() = .F.)

   Create is not needed if the Key exists or you call the init method with
   lCreate == .T.

*/
METHOD XbpReg:Create

   If ::lStatus == .F.  .AND. ::nHKey # HKEY_NO_KEY

      ::RegOpenKeyEx( ::cKey, KEY_CREATE_SUB_KEY )               // open registry key

      If ::nCallSuccess = ERROR_SUCCESS
         ::lStatus := .T.
      ELSE
         ::RegCreateKeyEx( ::cKey )
         IF ::nCallSuccess = ERROR_SUCCESS
            ::lStatus := .T.
         EndIF
      EndIF

      ::RegCloseKey()                        // close registry key

   EndIF

RETURN self

/*
   Registry Key öffnen

================================

   Open registry key

*/
METHOD XbpReg:RegOpenKeyEx( cSubKey, nAccess )
   LOCAL nNewKeyHandle := 0

   DEFAULT nAccess TO KEY_ALL_ACCESS

   ::nCallSuccess := 1  // 1 = no success; 0 = success
   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   If ::nhKey # HKEY_NO_KEY
      ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegOpenKeyExA", ::nhKey,;
                               cSubKey, 0, nAccess , @nNewKeyHandle )

      If ::nCallSuccess = ERROR_SUCCESS
         ::nKeyHandle := nNewKeyHandle
         ::RegQueryInfoKey()
      EndIF

   EndIF

RETURN ::nCallSuccess

/*
   Registry-Schlüssel schließen

=======================================

   Close registry key

*/
METHOD XbpReg:RegCloseKey

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegCloseKey", ::nKeyHandle )
   If ::nCallSuccess = ERROR_SUCCESS
      ::nKeyHandle := HKEY_NO_KEY
   EndIF

   If ::nDllHandle # 0
      DllUnload( ::nDllHandle )
      ::nDllHandle := 0
   EndIF

RETURN ::nCallSuccess

/*
   Neuen Registry Key erzeugen

=============================================

   Create new key

*/
METHOD XbpReg:RegCreateKeyEx( cSubKey )
   LOCAL nNewKeyHandle := 0, nDisposition := 0
   ::nCallSuccess := 1  // 1 = no success; 0 = success

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegCreateKeyExA", ::nHKey,;
                              cSubKey, 0, "", REG_OPTION_NON_VOLATILE, ;
                              KEY_ALL_ACCESS , 0, @nNewKeyHandle, @nDisposition )

   If ::nCallSuccess = ERROR_SUCCESS
      ::nKeyHandle := nNewKeyHandle
      ::RegQueryInfoKey()
      ::RegCloseKey()
   EndIF

RETURN ::nCallSuccess


/*
   Neuen Subkey unterhalb des existierenden anlegen

========================================================

   Create subkey below existing key

*/
METHOD XbpReg:NewKey( cSubKey, lKeepOld )
   LOCAL cOldKey := ::KeyName(), lSuccess

   DEFAULT cSubKey  TO ""
   DEFAULT lKeepOld TO .T.

   If ! EMPTY( cSubkey )
      ::Init( cOldKey + "\" + cSubKey, .T., .T. )
      If ! ::lStatus
         ::Init( cOldKey,,.T. )
      Else
         lSuccess := .T.
         If lKeepOld
            ::Init( cOldKey,,.T. )
         EndIF
      Endif
   EndIF

RETURN lSuccess

/*
   Subkey unterhalb des existierenden löschen

============================================================

   Delete subkey (including all contained values and subkeys)

*/
METHOD XbpReg:DelKey( cSubKey )
   LOCAL lRet := .F.

   ::nCallSuccess := 1  // 1 = no success; 0 = success

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::RegOpenKeyEx( ::cKey, KEY_ALL_ACCESS )
   If ::nCallSuccess = ERROR_SUCCESS
      ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegDeleteKeyA", ::nKeyHandle,;
                                 cSubKey )

      lRet := ::nCallSuccess = ERROR_SUCCESS

   ENDIF
   ::RegCloseKey()

RETURN lRet

/*
   Informationen über Registry Key ermitteln und in den vorgesehenen iVar´s
   ablegen.

====================================================================================

   Gather information about registry key

*/
METHOD XbpReg:RegQueryInfoKey
   LOCAL lpClass := "", lpcbClass := 0, lpReserved := 0, lpcSubKeys := 0
   LOCAL lpcbMaxSubKeyLen := 0, lpcbMaxClassLen := 0
   LOCAL lpcValues := 0, lpcbMaxValueNameLen := 0, lpcbMaxValueLen := 0
   LOCAL lpcbSecurityDescriptor := 0, lpftLastWriteTime := "        "

   ::nCallSuccess := 1  // 1 = no success; 0 = success

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegQueryInfoKeyA", ::nKeyHandle,;
                              @lpClass,;
                              @lpcbClass,;
                              lpReserved,;
                              @lpcSubKeys,;
                              @lpcbMaxSubKeyLen,;
                              @lpcbMaxClassLen,;
                              @lpcValues,;
                              @lpcbMaxValueNameLen,;
                              @lpcbMaxValueLen,;
                              @lpcbSecurityDescriptor,;
                              @lpftLastWriteTime )

   If ::nCallSuccess = ERROR_SUCCESS
      ::cClass              := lpClass
      ::nClass              := lpcbClass
      ::nSubKeys            := lpcSubKeys
      ::nMaxSubKeyLen       := lpcbMaxSubKeyLen
      ::nMaxClassLen        := lpcbMaxClassLen
      ::nValues             := lpcValues
      ::nMaxValueNameLen    := lpcbMaxValueNameLen
      ::nMaxValueLen        := lpcbMaxValueLen

      // the following is only valid under WIN/NT
      ::nSecurityDescriptor := lpcbSecurityDescriptor
      ::cLastWriteTime      := lpftLastWriteTime
      ::nLastWriteTime      := Bin2U( SUBSTR( ::cLastWriteTime, 1, 4 ) ) +;
                                 Bin2U( SUBSTR( ::cLastWriteTime, 5, 4 ) ) * 2^32
   EndIF

RETURN ::nCallSuccess

/*
   Subkeys aus der Registry enumerieren (Aufzählen)
   Hilfsmethode, vorher muß der Registry-Key mit ::RegOpenKeyEx geöffnet
   worden sein.

=================================================================================

   Enumerate subkeys, key has to be opened before with ::RegOpenKeyEX

*/
METHOD xbpReg:RegEnumKeyEx( nIndex )
   LOCAL cBuffer := SPACE( ::nMaxSubKeyLen + 1 )
   LOCAL nBufLen := ::nMaxSubKeyLen + 1
   LOCAL lpftLastWriteTime := "        "

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegEnumKeyExA", ::nKeyHandle,;
                              nIndex, @cBuffer, @nBufLen, 0, 0, 0, @lpftLastWriteTime )

   If ::nCallSuccess = ERROR_SUCCESS
      ::cLastWriteTime      := lpftLastWriteTime
      ::nLastWriteTime      := Bin2U( SUBSTR( ::cLastWriteTime, 1, 4 ) ) +;
                                 Bin2U( SUBSTR( ::cLastWriteTime, 5, 4 ) ) * 2^32
   EndIF

RETURN TRIM(cBuffer)

/*
   Values aus der Registry enumerieren (Aufzählen)
   Hilfsmethode, vorher muß der Registry-Key mit ::RegOpenKeyEx geöffnet
   worden sein.

=================================================================================

   Enumerate values, key has to be opened before with ::RegOpenKeyEx

*/
METHOD xbpReg:RegEnumValue( nIndex, lWithValue )
   LOCAL cBuffer1 := SPACE( ::nMaxValueNameLen + 1 )
   LOCAL nBufLen1 := ::nMaxValueNameLen + 1
   LOCAL cBuffer2 := SPACE( ::nMaxValueLen + 1 )
   LOCAL nBufLen2 := ::nMaxValueLen + 1
   LOCAL nType    := 0
   LOCAL lpftLastWriteTime := "        "
   LOCAL aRet := {}
   LOCAL bError

   DEFAULT lWithValue TO .T.

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::xValue := NIL
   ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegEnumValueA", ::nKeyHandle,;
                              nIndex, @cBuffer1, @nBufLen1, 0, @nType, @cBuffer2, @nBufLen2 )

   If ::nCallSuccess = ERROR_SUCCESS
      AADD( aRet, TRIM(SUBSTR(cBuffer1,1,nBufLen1)) )

      If lWithValue
         DO CASE
            CASE nType == REG_SZ
               ::xValue := SUBSTR( cBuffer2, 1, nBufLen2-1 )

            CASE nType == REG_DWORD
               ::xValue := BIN2L( cBuffer2 )

            CASE nType == REG_BINARY
               DO CASE
                  CASE ::cReadBinaryTypeAs = "A"
                     ::xValue := Bin2Var( cBuffer2 )

                  CASE ::cReadBinaryTypeAs = "C"
                     ::xValue := cBuffer2

                  CASE ::cReadBinaryTypeAs = "N"
                     ::xValue := BIN2L( cBuffer2 )
               EndCASE

         ENDCASE
      EndIF

      AADD( aRet, ::xValue )

   ENDIF

RETURN aRet


/*
   Wert aus Registry-Schlüssel auslesen

======================================================

   Get a named value

*/
METHOD XbpReg:GetValue( cName )
   LOCAL xRet := SPACE(::nMaxValueLen), nRet := ::nMaxValueLen
   LOCAL nType := 0
   LOCAL cTemp, nPos1, nPos2

   ::nCallSuccess := 1  // 1 = no success; 0 = success

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::xValue := NIL

   ::RegOpenKeyEx( ::cKey, KEY_READ )
   If ::nCallSuccess = ERROR_SUCCESS

      ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegQueryValueExA", ::nKeyHandle,;
                                 @cName, 0, @nType , @xRet, @nRet )

      If ::nCallSuccess = ERROR_SUCCESS
         DO CASE
            CASE nType == REG_SZ
               ::xValue := SUBSTR( xRet, 1, nRet-1 )

            CASE nType == REG_DWORD
               ::xValue := BIN2L( xRet )

            CASE nType == REG_BINARY
               DO CASE
                  CASE ::cReadBinaryTypeAs = "A"
                     ::xValue := Bin2Var( xRet )

                  CASE ::cReadBinaryTypeAs = "C"
                     ::xValue := xRet

                  CASE ::cReadBinaryTypeAs = "N"
                     ::xValue := BIN2L( xRet )
               EndCASE

            CASE nType == REG_EXPAND_SZ
               ::xValue := SUBSTR( xRet, 1, nRet-1 )
               DO WHILE "%" $ ::xValue
                  nPos1 := AtNum( "%", ::xValue, 1 )
                  nPos2 := AtNum( "%", ::xValue, 2 )
                  IF nPos2 = 0
                     EXIT
                  ENDIF
                  cTemp := SubStr( ::xValue, nPos1+1, nPos2-nPos1-1 )
                  IF nPos1 == 1
                     ::xValue := GetEnv( cTemp ) + SubStr( ::xValue, nPos2+1 )
                  ELSE
                     ::xValue := Substr( ::xValue, 1, nPos1-1) +  ;
                        GetEnv( cTemp ) + SubStr( ::xValue, nPos2+1 )
                  ENDIF
               ENDDO
         ENDCASE
      Endif
   ENDIF
   ::RegCloseKey()

RETURN ::xValue

/*
   Wert in Registry-Value ablegen, bzw. Value neu erzeugen

===================================================================

   Write/create a named value
*/
METHOD XbpReg:SetValue( cName, xValue )
   LOCAL nLen := 0, nType := REG_NONE

   ::nCallSuccess := 1  // 1 = no success; 0 = success

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   DO CASE
      CASE VALTYPE( xValue ) = "C"
         DO CASE
            CASE ::cSaveStringTypeAs = "C"      // Save string as string (default)
               nLen  := LEN(xValue) + 1
               nType := REG_SZ

            CASE ::cSaveStringTypeAs = "B"      // Save string as binary value
               nLen   := LEN( xValue )
               nType  := REG_BINARY
         ENDCASE

      CASE VALTYPE( xValue ) = "N"
         nLen  := 4
         xValue := L2BIN( xValue )
         nType := REG_DWORD

      CASE VALTYPE( xValue ) = "A"
         xValue := Var2Bin( xValue )
         nLen   := LEN( xValue )
         nType  := REG_BINARY

   ENDCASE

   ::RegOpenKeyEx( ::cKey, KEY_WRITE )
   If ::nCallSuccess = ERROR_SUCCESS
      ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegSetValueExA", ::nKeyHandle,;
                                 @cName, 0, nType , @xValue, nLen )

      If ::nCallSuccess = ERROR_SUCCESS
      EndIF
   ENDIF
   ::RegCloseKey()

RETURN ::nCallSuccess

/*
   Value löschen

========================================

   Delete value

*/
METHOD XbpReg:DelValue( cName )
   LOCAL lRet := .F.

   ::nCallSuccess := 1  // 1 = no success; 0 = success

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::RegOpenKeyEx( ::cKey, KEY_ALL_ACCESS )
   If ::nCallSuccess = ERROR_SUCCESS

      ::nCallSuccess := DllCall( ::nDllHandle, DLL_STDCALL, "RegDeleteValueA", ::nKeyHandle,;
                                 @cName )

      lRet :=  ::nCallSuccess = ERROR_SUCCESS

   ENDIF
   ::RegCloseKey()

RETURN lRet


/*
   "Standard"-Wert des Registry-Key´s abfragen oder setzen, als Beispiel siehe
   \HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\TimeZones

==================================================================================

   Get/Set "standard" value of the registry key for example see
   \HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\TimeZones

*/
METHOD XbpReg:Standard( xValue )

   If xValue # NIL
      ::SetValue( "", xValue )
   Endif

RETURN ::GetValue( "" )

/*
   ACCESS/ASSIGN stellt den xBase++ Datentyp ein, der beim Lesen von bin„ren Daten
   aus der Registry verwendet werden soll. Standard ist "A" = Array, d.H.
   Daten mit dem Attribut REG_BINARY werden mit BIN2VAR in ein Array umgewandelt.

   Erlaubte Werte :   "C" = šbernahme in eine String-Variable
                      "A" = šbernahme in ein Array via BIN2VAR()
                      "N" = šbernahme in eine numerische Variable via BIN2L()

   (!!! Arrays werden generell mit VAR2BIN gespeichert !!!)
==================================================================================

   ACCESS/ASSIGN to get/set the Xbase++ datatype that should be used when reading
   binary data from the registry. The standard value is "A" so that data with the
   REG_BINARY type attribute gets transferred into an array via BIN2VAR.

   Allowed values are "C" = retrieve as string
                      "A" = retrieve into an array via BIN2VAR()
                      "N" = retrieve into a numeric variable via BIN2L()

   (Arrays are always stored as REG_BINARY into the registry via VAR2BIN when
    using ::SetValue())

*/
METHOD XbpReg:ReadBinType( xValue )

   If xValue # NIL
      If VALTYPE(xValue) = "C"
         ::cReadBinaryTypeAs := xValue
      Endif
   Endif

RETURN ::cReadBinaryTypeAs

/*
   ACCESS/ASSIGN stellt den Registry-Datentyp ein, der beim Schreiben von String-
   Daten in die Registry verwendet werden soll. Standard ist REG_SZ = String

   Erlaubte Werte :   "C" = Speichern als REG_SZ     = String
                      "B" = Speichern als REG_BINARY = Bin„r-Wert

   (!!! Arrays werden generell als REG_BINARY mit VAR2BIN gespeichert !!!)
==================================================================================

   ACCESS/ASSIGN to get/set the registry datatype that should be used when writing
   string type Xbase++ data to the registry. The standard value is "C" so strings will
   be saved as REG_SZ = zero terminated strings

   Allowed values are "C" = save as REG_SZ
                      "B" = save as REG_BINARY

   (Arrays are always stored into the registry as REG_BINARY via VAR2BIN when using
    ::SetValue())

*/
METHOD XbpReg:SaveStringType( xValue )

   If xValue # NIL
      If VALTYPE(xValue) = "C"
         ::cSaveStringTypeAs := xValue
      Endif
   Endif

RETURN ::cSaveStringTypeAs

/*
   Status des Objekts abfragen, .F. wenn der Key
   noch nicht existiert

================================================

   Get object status, .F. if key does not exist

*/
METHOD XbpReg:Status
RETURN ::lStatus


/*
   Vollständigen Namen des Registry-Keys zurückliefern

====================================================================

   Return complete registry key "path"

*/
METHOD XbpReg:KeyName
   LOCAL cRet := "\"

      DO CASE
         CASE ::nHKey = HKEY_LOCAL_MACHINE
            cRet += "HKEY_LOCAL_MACHINE"

         CASE ::nHKey = HKEY_CLASSES_ROOT
            cRet += "HKEY_CLASSES_ROOT"

         CASE ::nHKey = HKEY_USERS
            cRet += "HKEY_USERS"

         CASE ::nHKey = HKEY_CURRENT_USER
            cRet += "HKEY_CURRENT_USER"

      ENDCASE

      cRet += IIF( ! EMPTY(::cKey), "\" + ::cKey, "" )

RETURN cRet



/*
   Liste aller Subkeys als Array zurückgeben
   Verwendet ::RegEnumKeyEx()

==================================================

   List all subkeys (returns an array)
   Uses ::RegEnumKeyEx()

*/
METHOD XbpReg:KeyList
   LOCAL nIndex, aRet := {}, cEnumKey

   ::nCallSuccess := 1  // 1 = no success; 0 = success

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::RegOpenKeyEx( ::cKey, KEY_READ )                // Key öffnen, Fehlercode steht in ::nCallSuccess
   If ::nCallSuccess = ERROR_SUCCESS

      nIndex := ::nSubKeys

      DO WHILE nIndex >= 0

         If ! EMPTY( cEnumKey := ::RegEnumKeyEx( nIndex ) )
            AADD( aRet, cEnumKey )
         EndIF

         nIndex--
      EndDO

   ENDIF
   ::RegCloseKey()

   If LEN( aRet ) # 0
      aRet := ASORT( aRet,,, {|c1,c2| UPPER(c1) < UPPER(c2) } )
   EndIF

RETURN aRet

/*
   Liste aller Values des Keys als 2-dimensionales Array zurückgeben
   Wird lWithValues auf .F. gesetzt ist das zweite Arrayelement jeweils NIL,
   es werden also nur die ValueNamen, nit jedoch der Wert selbst ermittelt.
   Vorgabewert ist .T. = Werte ermitteln

   Verwendet ::RegEnumValue()

==================================================

   List all values (returns an 2-dimensional array)
   Set lWithValues to .F. if you only need the value names, not the value itself
   Default is .T.

   Uses ::RegEnumValue()

*/
METHOD XbpReg:ValueList( lWithValues )
   LOCAL nIndex, aRet := {}, aEnumVal

   DEFAULT lWithValues TO .T.

   ::nCallSuccess := 1  // 1 = no success; 0 = success

   If ::nDllHandle = 0
      ::nDllHandle := DllLoad( "ADVAPI32.DLL" )
   EndIF

   ::RegOpenKeyEx( ::cKey, KEY_READ )                // Key öffnen, Fehlercode steht in ::nCallSuccess
   If ::nCallSuccess = ERROR_SUCCESS

      nIndex := ::nValues
      If nIndex # 0
         ::RegEnumValue( 0 )
      EndIF

      DO WHILE nIndex >= 0

         If LEN( aEnumVal := ::RegEnumValue( nIndex, lWithValues ) ) # 0
            AADD( aRet, aEnumVal )
         EndIF

         nIndex--
      EndDO

   ENDIF
   ::RegCloseKey()

   If LEN( aRet ) # 0
      aRet := ASORT( aRet,,, {|c1,c2| UPPER(c1[1]) < UPPER(c2[1]) } )
   EndIF

RETURN aRet

/*
   Eine Ebene höher in der Schlüsselhierarchie
   (ähnlich dem DOS-Kommando CD..)

=====================================================

   Move one level up in the key hierarchy
   (similar to the dos command CD..)

*/
METHOD xbpReg:MoveUp
   LOCAL cNewKey, nPos, lSuccess := .F.

   nPos := RAT( "\", ::KeyName() )

   If nPos > 1
      cNewKey := LEFT( ::KeyName, nPos-1)
      ::Init( cNewKey,,.T. )
      lSuccess := ::lStatus
   EndIF

RETURN lSuccess

/*
   Eine Ebene tiefer in der Schlüsselhierarchie

===========================================================

   Move down one level

*/
METHOD xbpReg:MoveDown( cSubkey )
   LOCAL cOldKey := ::KeyName(), lSuccess := .F.

   DEFAULT cSubKey TO ""
   If ! EMPTY( cSubkey )
      ::Init( cOldKey + "\" + cSubKey,,.T. )
      If ! ::lStatus
         ::Init( cOldKey,,.T. )
      Else
         lSuccess := .T.
      Endif
   EndIF

RETURN lSuccess

// Da aggiungere a regclass2
* --------------------------------------------------------------------------

STATIC FUNCTION ATNUM(L_SHORT,L_LONG,L_CNT,STARTER)
*           // FIND Nth APPEARANCE OF A SUB-STRING
LOCAL POS, CNT2, NUM
IF PCount() > 3  .OR.  L_CNT < 0
   Return -1          // Features not implemented in this code
ENDIF
POS  := 1
CNT2 := 0
DO WHILE .T.
   NUM := At(L_SHORT,SubStr(L_LONG,POS))
   IF NUM == 0
      RETURN 0
   ENDIF
   CNT2++
   IF CNT2 == L_CNT
      RETURN POS + NUM - 1
   ELSE
      POS := POS + NUM
   ENDIF
ENDDO
RETURN 0         // Will not get here, but functions must end with return

