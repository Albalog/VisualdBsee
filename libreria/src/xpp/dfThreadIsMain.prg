// torna se si sta lavorando nel thread principale dell'applicazione
FUNCTION dfThreadIsMain()
RETURN ThreadID()==1
