//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>
#include <mapi.h>

XPPRET XPPENTRY DFMAPI( XppParamList paramList ){

 //char * fpProfileName = "Impostazioni di MS Exchange";
 //char * fpFromName    = "Matteo Baccan"              ;
 //char * fpFromEmail   = "guru@dbsee.com"             ;
 //char * fpToName      = "The guru"                   ;
 //char * fpToEmail     = "mbaccan@planetisa.com"      ;
 //char * fpSubject     = "Prova di send mail"         ;
 //char * fpMail        = "provo a scrivere qualche messaggio";

   LONG nPar1Len = _parclen( paramList, 1 );
   LONG nPar2Len = _parclen( paramList, 2 );
   LONG nPar3Len = _parclen( paramList, 3 );
   LONG nPar4Len = _parclen( paramList, 4 );
   LONG nPar5Len = _parclen( paramList, 5 );
   LONG nPar6Len = _parclen( paramList, 6 );
   LONG nPar7Len = _parclen( paramList, 7 );

   MomHandle hNew1 = _momAlloc( sizeof(char)*(nPar1Len+1) );
   MomHandle hNew2 = _momAlloc( sizeof(char)*(nPar2Len+1) );
   MomHandle hNew3 = _momAlloc( sizeof(char)*(nPar3Len+1) );
   MomHandle hNew4 = _momAlloc( sizeof(char)*(nPar4Len+1) );
   MomHandle hNew5 = _momAlloc( sizeof(char)*(nPar5Len+1) );
   MomHandle hNew6 = _momAlloc( sizeof(char)*(nPar6Len+1) );
   MomHandle hNew7 = _momAlloc( sizeof(char)*(nPar7Len+1) );

   char *fpProfileName = _momLock( hNew1 );
   char *fpFromName    = _momLock( hNew2 );
   char *fpFromEmail   = _momLock( hNew3 );
   char *fpToName      = _momLock( hNew4 );
   char *fpToEmail     = _momLock( hNew5 );
   char *fpSubject     = _momLock( hNew6 );
   char *fpMail        = _momLock( hNew7 );

   LHANDLE lhSession;
   ULONG err;

   HINSTANCE hlibMAPI = LoadLibrary("MAPI32.DLL");

   LPMAPISENDMAIL lpfnMAPISendMail = (LPMAPISENDMAIL) GetProcAddress(hlibMAPI, "MAPISendMail");

   LPMAPILOGON lpfnMAPILogon = (LPMAPILOGON) GetProcAddress(hlibMAPI, "MAPILogon");

   MapiRecipDesc sender;
   MapiRecipDesc recipient;
   MapiMessage   note;

   _parc( fpProfileName, nPar1Len+1, paramList, 1 );
   _parc( fpFromName   , nPar2Len+1, paramList, 2 );
   _parc( fpFromEmail  , nPar3Len+1, paramList, 3 );
   _parc( fpToName     , nPar4Len+1, paramList, 4 );
   _parc( fpToEmail    , nPar5Len+1, paramList, 5 );
   _parc( fpSubject    , nPar6Len+1, paramList, 6 );
   _parc( fpMail       , nPar7Len+1, paramList, 7 );

   lpfnMAPILogon( (ULONG)NULL,      // ULONG ulUIParam,
                  fpProfileName,    // LPTSTR lpszProfileName,
                  NULL,             // LPTSTR lpszPassword,
                  MAPI_NEW_SESSION, // MAPI_LOGON_UI | MAPI_NEW_SESSION,  // FLAGS flFlags,
                  0,                // ULONG ulReserved,
                  &lhSession);      // LPLHANDLE lplhSession

   sender.ulReserved   = (ULONG)0;     // ULONG ulReserved
   sender.ulRecipClass = MAPI_ORIG;    // ULONG ulRecipClass;
   sender.lpszName     = fpFromName;   // LPTSTR lpszName;
   sender.lpszAddress  = fpFromEmail;  // LPTSTR lpszAddress;
   sender.ulEIDSize    = (ULONG)0;     // ULONG ulEIDSize;
   sender.lpEntryID    = NULL;         // LPVOID lpEntryID;

   recipient.ulReserved   = 0;            // ULONG ulReserved
   recipient.ulRecipClass = MAPI_TO;      // ULONG ulRecipClass;
   recipient.lpszName     = fpToName;     // LPTSTR lpszName;
   recipient.lpszAddress  = fpToEmail;    // LPTSTR lpszAddress;
   recipient.ulEIDSize    = 0;            // ULONG ulEIDSize;
   recipient.lpEntryID    = NULL;         // LPVOID lpEntryID;

   note.ulReserved         = 0;             /* Reserved for future use (M.B. 0)       */ // reserved, must be 0                  ULONG ulReserved;
   note.lpszSubject        = fpSubject;     /* Message Subject                        */ // subject                              LPTSTR lpszSubject;
   note.lpszNoteText       = fpMail;        /* Message Text                           */ // text                                 LPTSTR lpszNoteText;
   note.lpszMessageType    = NULL;          /* Message Class                          */ // NULL = interpersonal message         LPTSTR lpszMessageType;
   note.lpszDateReceived   = NULL;          /* in YYYY/MM/DD HH:MM format             */ // no date; MAPISendMail ignores it     LPTSTR lpszDateReceived;
   note.lpszConversationID = NULL;          /* conversation thread ID                 */ // no conversation ID                   LPTSTR lpszConversationID;
   note.flFlags            = 0L;            /* unread,return receipt                  */ // no flags, MAPISendMail ignores it    FLAGS flFlags;
   note.lpOriginator       = &sender;       /* Originator descriptor                  */ // no originator, this is ignored too   lpMapiRecipDesc lpOriginator;
   note.nRecipCount        = 1;             /* Number of recipients                   */ // zero recipients                      ULONG nRecipCount;
   note.lpRecips           = &recipient;    /* Recipient descriptors                  */ // NULL recipient array                 lpMapiRecipDesc lpRecips;
   note.nFileCount         = 0;             /* # of file attachments                  */ // zero attachment                      ULONG nFileCount;
   note.lpFiles            = NULL;          /* Attachment descriptors                 */ // attachment                           lpMapiFileDesc lpFiles;

   err = lpfnMAPISendMail(
                      lhSession,   // session.
                      0L,          // ulUIParam; 0 is always valid
                      &note,       // the message being sent
                      0, //MAPI_DIALOG, // allow the user to edit the message
                      0L);         // reserved; must be 0

   _momUnlock(hNew1); _momFree(hNew1);
   _momUnlock(hNew2); _momFree(hNew2);
   _momUnlock(hNew3); _momFree(hNew3);
   _momUnlock(hNew4); _momFree(hNew4);
   _momUnlock(hNew5); _momFree(hNew5);
   _momUnlock(hNew6); _momFree(hNew6);
   _momUnlock(hNew7); _momFree(hNew7);

   _retni( paramList, err );

   FreeLibrary( hlibMAPI );
}
