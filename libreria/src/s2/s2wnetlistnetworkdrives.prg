// ritorna array con drive e mappatura di rete
// es. {{"H:", "\\srvnovell\shared"}, {"K:", "\\srv2003\shared"}}
FUNCTION S2WNetListNetworkDrives()
   LOCAL objNetwork 
   LOCAL colDrives 
   LOCAL i, max
   LOCAL aRet

   aRet := {}
   objNetwork := dfGetAX("Wscript.Network")
//   objNetwork := CreateObject("Wscript.Network")

   IF EMPTY(objNetwork)
      RETURN aRet 
   ENDIF

   colDrives := objNetwork:EnumNetworkDrives()
   max := colDrives:Count()-1

   FOR i := 0 TO max STEP 2
     AADD(aRet, {colDrives:item(i), colDrives:Item(i + 1)})
   /*
       If colDrives.Item(i + 1) = "\\server1\share" Then
           strDriveLetter = colDrives.Item(i)
           objNetwork.RemoveNetworkDrive strDriveLetter
           objNetwork.MapNetworkDrive strDriveLetter, "\\server2\share"
       End If
   */
   NEXT
RETURN aRet
