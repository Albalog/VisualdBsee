#include "common.ch"
#include "dll.ch"


//
// these defines must be equal to the defines of the Win32-SDK
//

#define HKEY_CLASSES_ROOT           2147483648
#define HKEY_CURRENT_USER           2147483649
#define HKEY_LOCAL_MACHINE          2147483650
#define HKEY_USERS                  2147483651

#define KEY_QUERY_VALUE         1
#define KEY_SET_VALUE           2
#define KEY_CREATE_SUB_KEY      4
#define KEY_ENUMERATE_SUB_KEYS  8
#define KEY_NOTIFY              16
#define KEY_CREATE_LINK         32

#define KEY_WOW64_64KEY        256 // Legge (solo nei sistemi a 64bit) dall'albero delle chiavi a 64 bit, e non dall'albero WOW6432.....

// Registry value type
#define REG_NONE                     0    // No value type
#define REG_SZ                       1    // Unicode nul terminated string
#define REG_EXPAND_SZ                2    // Unicode nul terminated string
                                          // (with environment variable references)
#define REG_BINARY                   3    // Free form binary
#define REG_DWORD                    4    // 32-bit number
#define REG_DWORD_LITTLE_ENDIAN      4    // 32-bit number (same as REG_DWORD)
#define REG_DWORD_BIG_ENDIAN         5    // 32-bit number
#define REG_LINK                     6    // Symbolic Link (unicode)
#define REG_MULTI_SZ                 7    // Multiple Unicode strings
#define REG_RESOURCE_LIST               8    // Resource list in the resource map
#define REG_FULL_RESOURCE_DESCRIPTOR    9   // Resource list in the hardware description
#define REG_RESOURCE_REQUIREMENTS_LIST 10



// Create a function for every API-call
// Note: You should know the interface in detail. Pay attention to:
//       - calling  convention
//       - type of parameters
//       - number and order of parameters
//       - pass by value or by reference
// ----------------------------------------------------------------

DLLFUNCTION RegOpenKeyExA(nHkeyClass, cKeyName, reserved, access, @nKeyHandle);
                USING STDCALL FROM ADVAPI32.DLL
DLLFUNCTION RegQueryValueExA(nKeyHandle, cEntry, reserved, @valueType, @cName,@nSize);
                USING STDCALL FROM ADVAPI32.DLL
DLLFUNCTION RegCloseKey( nKeyHandle );
                USING STDCALL FROM ADVAPI32.DLL

DLLFUNCTION RegSetValueEx( nKeyHandle, cEntryName , reserved , valueType , xValue, @xxx  );
                USING STDCALL FROM ADVAPI32.DLL


// Funzione QueryRegistry per compatibilit…
FUNCTION QueryRegistry(xHKEYHandle, cKeyName, cEntryName)
RETURN dfQueryRegistry(xHKEYHandle, cKeyName, cEntryName)

FUNCTION dfQueryRegistry(xHKEYHandle, cKeyName, cEntryName, lWoW64_64)
   LOCAL cName := ""
   LOCAL nNameSize
   LOCAL nKeyHandle
   LOCAL nValueType

   DEFAULT lWoW64_64 TO .F.

   IF ! VALTYPE(xHKEYHandle) == "N"
      DO CASE
         CASE xHKEYHandle == "HKEY_CLASSES_ROOT" .OR. ;
              xHKEYHandle == "HKCR"

            xHKEYHandle := HKEY_CLASSES_ROOT

         CASE xHKEYHandle == "HKEY_CURRENT_USER" .OR. ;
              xHKEYHandle == "HKCU"
            xHKEYHandle := HKEY_CURRENT_USER

         CASE xHKEYHandle == "HKEY_LOCAL_MACHINE" .OR. ;
              xHKEYHandle == "HKLM"
            xHKEYHandle := HKEY_LOCAL_MACHINE

         CASE xHKEYHandle == "HKEY_USERS" .OR. ;
              xHKEYHandle == "HKUS"

            xHKEYHandle := HKEY_USERS
      ENDCASE
   ENDIF

   // You must assign a value to all parameters are about to pass to a
   // dll which is not Xbase++.
   // ----------------------------------------------------------------

   nKeyHandle := 0

   // Open the registry key
   // ---------------------

// Tommaso 04/03/11 - Sui sistemi operativi a 64 bit, le chiavi di registro dei programmi a 32 bit vengono scritte in un albero
//                    HKEY_LOCAL_MACHINE\Software\WOW6432node. Sia la lettura che la scrittura delle chiavi su HKEY_LOCAL_MACHINE\Software\
//                    vengono dirottate automaticamente da Windows su questo nuovo albero. Il parametro KEY_WOW64_64KEY serve per
//                    leggere sempre dall'albero a 64 bit. 
//                    Riferimento -> "Registry Redirector" "http://msdn.microsoft.com/en-us/library/aa384232(v=VS.85).aspx"

//   IF RegOpenKeyExA(xHKEYHandle, cKeyName,0,KEY_QUERY_VALUE, @nKeyHandle) = 0
   IF RegOpenKeyExA(xHKEYHandle, cKeyName,0,; 
                    IIF(lWoW64_64, KEY_QUERY_VALUE+KEY_WOW64_64KEY, KEY_QUERY_VALUE) ,; 
                    @nKeyHandle) = 0


       // Key is open
       // -----------
       nValueType  := 0
       nNameSize  := 0

       // Retrieve the length of the value
       // --------------------------------
       RegQueryValueExA(nKeyHandle, cEntryName,;
                           0, @nValueType, 0, @nNameSize)
       IF nNameSize > 0

           // Key length retrieved
           // --------------------


           // Additionally, you must preserve space for strings
           // are passed by reference. The content of these strings will
           // be changed.
           // ----------------------------------------------------------

           cName := space( nNameSize )

           // Get the value
           // -------------

           RegQueryValueExA(nKeyHandle, cEntryName,;
                            0, @nValueType, @cName, @nNameSize)

           // Key value type: <nValueType>
           // ----------------------------
           // Simone 29/11/04 aggiunta gestione 
           // del tipo DWORD e BINARY
           DO CASE
              CASE nValueType == REG_SZ
                 cName := SUBSTR( cName, 1, nNameSize-1 )

              CASE nValueType == REG_DWORD
                 cName := BIN2L( cName )

              CASE nValueType == REG_BINARY
                 //cName := cName

              CASE nValueType == REG_EXPAND_SZ
                /*  simone 29/11/04 da implementare.. vedere classe XbpReg
                 cName := SUBSTR( xRet, 1, nRet-1 )
                 DO WHILE "%" $ cName
                    nPos1 := AtNum( "%", cName, 1 )
                    nPos2 := AtNum( "%", cName, 2 )
                    IF nPos2 = 0
                       EXIT
                    ENDIF
                    cTemp := SubStr( cName, nPos1+1, nPos2-nPos1-1 )
                    IF nPos1 == 1
                       cName := GetEnv( cTemp ) + SubStr( cName, nPos2+1 )
                    ELSE
                       cName := Substr( cName, 1, nPos1-1) +  ;
                          GetEnv( cTemp ) + SubStr( cName, nPos2+1 )
                    ENDIF
                 ENDDO
                */
           ENDCASE
       ENDIF

       // Close key
       // ---------

       RegCloseKey( nKeyHandle)
   ENDIF

RETURN cName


/////////////////////////////////////////////////////////////////////////////////
//Non Funziona
/////////////////////////////////////////////////////////////////////////////////
FUNCTION dfWriteRegistry(nHKEYHandle, cKeyName, cEntryName, xValue,nValueType )
LOCAL cName := "1"
LOCAL nNameSize
LOCAL nKeyHandle
LOCAL lOK   := .F.

DEFAULT nValueType TO REG_DWORD //REG_BINARY


        xValue     := L2BIN(xValue)
        nKeyHandle := 0                                   

        IF RegOpenKeyExA (nHKEYHandle, cKeyName,  0, KEY_QUERY_VALUE +KEY_CREATE_SUB_KEY+KEY_SET_VALUE, @nKeyHandle) = 0

            lOK := RegSetValueEx(nKeyHandle, cEntryName , 0, nValueType,xValue)  == 0

            RegCloseKey( nKeyHandle)
        ENDIF
RETURN lOK
/////////////////////////////////////////////////////////////////////////////////




