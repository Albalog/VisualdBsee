; *** Inno Setup version 4.1.8 Italian messages ***
; Translated by Stefano Pessina (peste1@hotmail.com)
; To download user-contributed translations of this file, go to:
;   http://www.jrsoftware.org/is3rdparty.php
;
; Note: When translating this text, do not add periods (.) to the end of
; messages that didn't have them already, because on those messages Inno
; Setup adds the periods automatically (appending a period would result in
; two periods being displayed).
;
; $jrsoftware: issrc/Files/Default.isl,v 1.49 2004/01/27 00:19:21 jr Exp $

[LangOptions]
LanguageName=Italiano
LanguageID=$1040
; If the language you are translating to requires special font faces or
; sizes, uncomment any of the following entries and change them accordingly.
;DialogFontName=
;DialogFontSize=8
;WelcomeFontName=Verdana
;WelcomeFontSize=12
;TitleFontName=Arial
;TitleFontSize=29
;CopyrightFontName=Arial
;CopyrightFontSize=8

[Messages]

; *** Application titles
SetupAppTitle=Installazione
SetupWindowTitle=Installazione - %1
UninstallAppTitle=Disinstallazione
UninstallAppFullTitle=%1 Disinstallazione

; *** Misc. common
InformationTitle=Informazioni
ConfirmTitle=Conferma
ErrorTitle=Errore

; *** SetupLdr messages
SetupLdrStartupMessage=%1 sara' installato, desideri continuare?
LdrCannotCreateTemp=Non e' possibile creare il file temporaneo. Installazione interrotta
LdrCannotExecTemp=Non e' possibile eseguire il file nella cartella temporanea. Installazione interrotta

; *** Startup error messages
LastErrorMessage=%1.%n%nError %2: %3
SetupFileMissing=Il file %1 non e' presente nella cartella di installazione. Correggere il problema o provare con una diversa copia del programma.
SetupFileCorrupt=Il file di installazione e' corrotto.. Correggere il problema o provare con una diversa copia del programma.
SetupFileCorruptOrWrongVer=Il file di installazione e' corrotto o incompatibile.
NotOnThisPlatform=Questo programa non si avvia su %1.
OnlyOnThisPlatform=Questo programma e' per %1.
WinVersionTooLowError=Questo programma richiede %1 versione %2 o posteriore.
WinVersionTooHighError=Questo programma non puo' essere installato in %1 versione %2 o posteriore.
AdminPrivilegesRequired=Solo l' amministatore puo' installare il programma.
PowerUserPrivilegesRequired=Solo l' amministatore o un membro dei Power Users puo' installare il programma.
SetupAppRunningError=L'installazione ha rilevato che %1 e' in esecuzione.%n%nChiudere le istanze precedenti e premere OK per continuare oppure Cancella per uscire.
UninstallAppRunningError=La disinstallazione ha rilevato che %1 e' in esecuzione.%n%nChiudere tutte le installazioni precedenti e premere OK per continuare oppure Cancella per uscire.

; *** Misc. errors
ErrorCreatingDir=L'installazione non ha potuto creare la cartella "%1".
ErrorTooManyFilesInDir=Non e' possibile creare ulteriori files nella cartella "%1" perche' ne contiene troppi.

; *** Setup common messages
ExitSetupTitle=Esci dall'installazione
ExitSetupMessage=L'installazione non e' completa, se viene interrotta il programma non sara' installato.%n%nPuoi riprovare in un secondo momento. Vuoi uscire?
AboutSetupMenuItem=&Informazioni sull'installazione...
AboutSetupTitle=Informazioni sull'installazione
AboutSetupMessage=%1 versione %2%n%3%n%n%1 home page:%n%4
AboutSetupNote=

; *** Buttons
ButtonBack=< &Indietro
ButtonNext=&Avanti >
ButtonInstall=&Installa
ButtonOK=OK
ButtonCancel=Annulla
ButtonYes=&Si
ButtonYesToAll=Si a &Tutti
ButtonNo=&No
ButtonNoToAll=N&o a Tutti
ButtonFinish=&Fine
ButtonBrowse=&Sfoglia...
ButtonWizardBrowse=S&foglia...
ButtonNewFolder=&Nuova Cartella

; *** "Select Language" dialog messages
SelectLanguageTitle=Selezionare la lingua dell'installazione
SelectLanguageLabel=Selezionare la lingua da utilizzare durante l'installazione:

; *** Common wizard text
ClickNext=Clicca su Avanti per continuare o su Annulla per uscire dall'installazione.
BeveledLabel=
BrowseDialogTitle=Seleziona cartella
BrowseDialogLabel=Seleziona una cartella dalla seguente lista e clicca su OK.
NewFolderName=Nuova Cartella

; *** "Welcome" wizard page
WelcomeLabel1=Benvenuto nell'installazione guidata di [name]
WelcomeLabel2=Verra' ora installato [name/ver].%n%nSi raccomanda di chiudere tutte le applicazioni prima di continuare.
;%n%nAttenzione: la chiave USB NON deve essere inserita prima dell'installazione per non avere problemi con i driver di sistema.   

; *** "Password" wizard page
WizardPassword=Password
PasswordLabel1=Questa installazione e' protetta da password.
PasswordLabel3=Inserire la password e premere Avanti per continuare. Rispettare le maiuscole e minuscole.
PasswordEditLabel=&Password:
IncorrectPassword=La password non e' corretta. Riprovare.

; *** "License Agreement" wizard page
WizardLicense=Accordo di licenza
LicenseLabel=Leggere le seguenti importanti informazioni prima di continuare.
LicenseLabel3=Leggere le norme di licenza devono essere accettate prima di proseguire con l'installazione.
LicenseAccepted= &Accetto
LicenseNotAccepted= &Non accetto

; *** "Information" wizard pages
WizardInfoBefore=Informazioni
InfoBeforeLabel=Leggere le seguenti importanti informazioni prima di continuare.
InfoBeforeClickLabel=Quando sei pronto per continuare premi Avanti.
WizardInfoAfter=Informazioni
InfoAfterLabel=Leggere le seguenti importanti informazioni prima di continuare.
InfoAfterClickLabel=Quando sei pronto per continuare premi Avanti.

; *** "User Information" wizard page
WizardUserInfo=Informazioni sull'utente
UserInfoDesc=Prego inserire le proprie informazioni.
UserInfoName=&Nome utente:
UserInfoOrg=&Organizzazione:
UserInfoSerial=&Codice licenza:
UserInfoNameRequired=E' necessario inserire il nome.

; *** "Select Destination Location" wizard page
WizardSelectDir=Selezionare la cartella di destinazione.
SelectDirDesc=Dove installare [name] ?
SelectDirLabel3=L'installazione copiera' [name] nella seguente cartella.
SelectDirBrowseLabel=Per continuare, cliccare su Avanti, se si desidera selezionare una cartella differente, cliccare su Sfoglia.
DiskSpaceMBLabel=Il programma richiede almeno [mb] MB di spazio sul disco.
ToUNCPathname=L'installazione non puo' utilizzare un percorso UNC. Per installare in rete e' necessario mappare un disco di rete.
InvalidPath=Inserire un percorso completo come:%n%nC:\APP%n%nod un percorso UNC come:%n%n\\server\share
InvalidDrive=Il drive UNC non esiste o non e' accessibile.
InvalidDirName=Nome cartella di destinazione non valido.
DiskSpaceWarningTitle=Spazio sul disco non adeguato.
DiskSpaceWarning=L'installazione richiede almeno %1 KB di spazio, il drive selezionato ha solo %2 KB di spazio.%n%nContinuare?
DirNameTooLong=Il nome della cartella e' troppo lungo.
InvalidDirName=Il nome della cartella non e' valido.
BadDirName32=I nomi di cartella non possono contenere i seguenti caratteri:%n%n%1
DirExistsTitle=La cartella gia' esiste!
DirExists=La cartella%n%n%1%n%nesiste gia! Usarla per l'installazione?
DirDoesntExistTitle=La cartella non esiste.
DirDoesntExist=La cartella%n%n%1%n%nnon esiste! Creare la cartella?

; *** "Select Components" wizard page
WizardSelectComponents=Selezione componenti
SelectComponentsDesc=Quali componenti saranno installati?
SelectComponentsLabel2=Selezionare i componenti da installare, eliminare i componenti da non installare. Cliccare su Avanti una volta terminata la selezione.
FullInstallation=Completa
; if possible don't translate 'Compact' as 'Minimal' (I mean 'Minimal' in your language)
CompactInstallation=Compatta
CustomInstallation=Personalizzata
NoUninstallWarningTitle=Il componente esiste gia'.
NoUninstallWarning=L'installazione ha trovato i seguenti componenti gia' installati:%n%n%1%n%nDeselezionado questi componenti non saranno disinstallati.%n%nContinuare?
ComponentSize1=%1 KB
ComponentSize2=%1 MB
ComponentsDiskSpaceMBLabel=La versione corrente richiede almeno [mb] MB di spazio su disco.

; *** "Select Additional Tasks" wizard page
WizardSelectTasks=Operazioni aggiuntive
SelectTasksDesc=Selezionare le operazioni aggiuntive dell'installazione.
SelectTasksLabel2=Selezionare le operazioni aggiuntive da eseguire durante l'installazione di [name] e cliccare su Avanti.

; *** "Select Start Menu Folder" wizard page
WizardSelectProgramGroup=Selezionare la cartella del menu Start.
SelectStartMenuFolderDesc=Dove verranno inseriti i collegamenti del programma?
SelectStartMenuFolderLabel3=L'installazione creera' i collegamenti del programma nella seguente cartella del menu Start.
SelectStartMenuFolderBrowseLabel=Per continuare, cliccare su Avanti, se si desidera selezionare una cartella differente, cliccare su Sfoglia.
NoIconsCheck=&Non creare alcuna icona
MustEnterGroupName=Devi inserire il nome della cartella.
GroupNameTooLong=Il nome della cartella e' troppo lungo.
InvalidGroupName=Il nome della cartella non e' valido.
BadGroupName=Il nome della cartella non puo' contenere i seguenti caratteri:%n%n%1
InvalidGroupName=Il nome della cartella non e' valido.
NoProgramGroupCheck2=&Non creare una cartella nel menu Start

; *** "Ready to Install" wizard page
WizardReady=Pronto per l'installazione
ReadyLabel1=L'installazione e' pronta per copiare [name] sul tuo computer.
ReadyLabel2a=Cliccare su Installa per continuare l'installazione o su Indietro per variare i parametri precedenti.
ReadyLabel2b=Cliccare su Installa per proseguire.
ReadyMemoUserInfo=Informazioni utente:
ReadyMemoDir=Cartella di destinazione:
ReadyMemoType=Tipo di installazione:
ReadyMemoComponents=Componenti selezionati:
ReadyMemoGroup=Cartella di partenza:
ReadyMemoTasks=Operazioni aggiuntive:

; *** "Preparing to Install" wizard page
WizardPreparing=Elaborazione dell'installazione:
PreparingDesc=Il programma sta elaborando l'installazione di [name] sul tuo computer.
PreviousInstallNotCompleted=L'installazione/disinstallazione di un programma precedente non e' stata completata. Riavviare il computer per terminare l'installazione, quindi procedere nuovamente con l'installazione.
CannotContinue=L'installazione non puo' continuare. Cliccare su Annulla per terminare.

; *** "Installing" wizard page
WizardInstalling=Installazione
InstallingLabel=Attendere mentre viene installato [name] sul computer.

; *** "Setup Completed" wizard page
FinishedHeadingLabel=Termine dell'installazione guidata di [name]
FinishedLabelNoIcons=L'installazione di [name] e' stata eseguita con successo.
FinishedLabel=[name] e' stato installato con successo: l'applicazione puo' essere avviata utilizzando le icone presenti nel menu Start.
ClickFinish=Cliccare su Fine per uscire dall'installazione.
FinishedRestartLabel=Per completare l'installazione di [name] e' necessario riavviare il computer. Procedere ora?
FinishedRestartMessage=Per completare l'installazione di [name] e' necessario riavviare il computer.%n%nProcedere ora?
ShowReadmeCheck=Si, desidero visualizzare le informazioni.
YesRadio=&Si, riavvia il computer.
NoRadio=&No, riavviero' manualmente il computer.
; used for example as 'Run MyProg.exe'
RunEntryExec=Esegui %1
; used for example as 'View Readme.txt'
RunEntryShellExec=Leggi il file %1

; *** "Setup Needs the Next Disk" stuff
ChangeDiskTitle=L'installazione richiede il disco successivo.
SelectDiskLabel2=Inserire il disco %1 e selezionare OK.%n%nSe i file fossero in una  cartella diversa inserire il percorso o selezionare Sfoglia.
PathLabel=&Percorso:
FileNotInDir2=Il file "%1" non esiste in "%2". Inserire il percorso corretto.
SelectDirectoryLabel=Specificare il percorso del disco successivo.

; *** Installation phase messages
SetupAborted=L'installazione non e' stata completata.%n%nCorreggere il problema e riprovare.
EntryAbortRetryIgnore=Selezionare Riprova per per provare ancora, Ignora per continuare, Cancella per annullare l'installazione.

; *** Installation status messages
StatusCreateDirs=Creazione delle cartelle in corso...
StatusExtractFiles=Estrazione dei files in corso...
StatusCreateIcons=Creazione delle icone in corso...
StatusCreateIniEntries=Creazione delle voci INI in corso...
StatusCreateRegistryEntries=Creazione delle voci del registro in corso...
StatusRegisterFiles=Registrazione dei files in corso...
StatusSavingUninstall=Salvataggio delle informazioni di disinstallazione...
StatusRunProgram=Completamento dell'installazione in corso...
StatusRollback=Ripristino delle modifiche in corso...

; *** Misc. errors
ErrorInternal2=Errore interno: %1
ErrorFunctionFailedNoCode=%1 fallito
ErrorFunctionFailed=%1 fallito; codice %2
ErrorFunctionFailedWithMessage=%1 fallito; codice %2.%n%3
ErrorExecutingProgram=Impossibile eseguire il file:%n%1

; *** Registry errors
ErrorRegOpenKey=Errore nell'apertura della chiave di registro:%n%1\%2
ErrorRegCreateKey=Errore nella creazione della chiave di registro:%n%1\%2
ErrorRegWriteKey=Errore nella scrittura della chiave di registro:%n%1\%2

; *** INI errors
ErrorIniEntry=Errore nella creazione delle voci INI nel file "%1".

; *** File copying errors
FileAbortRetryIgnore=Cliccare su Riprova per provare nuovamente, su Ignora per saltare questo file (sconsigliato), o su Cancella per annullare l'installazione.
FileAbortRetryIgnore2=Cliccare su Riprova per provare nuovamente, su Ignora per procedere comunque (sconsigliato), o su Cancella per annullare l'installazione.
SourceIsCorrupted=Il file sorgente e' corrotto
SourceDoesntExist=Il file sorgente "%1" non esiste
ExistingFileReadOnly=Il file e' di sola lettura.%n%nRimuovere l'attributo di sola lettura e quindi cliccare su Riprova per provare nuovamente, su Ignora per saltare questo file, o su Cancella per annullare l'installazione.
ErrorReadingExistingDest=Si e' verificato un errore leggendo il file:
FileExists=Il file esiste gia'.%n%nVuoi sovrascriverlo?
ExistingFileNewer=Il file esistente e' piu' recente di quello da installare, si raccomanda di conservarlo.%n%nVuoi conservarlo?
ErrorChangingAttr=Si e' verificato un errore nel tentativo di modifica degli attributi del file:
ErrorCreatingTemp=Si e' verificato un errore durante la creazione di un file nella cartella di destinazione:
ErrorReadingSource=Si e' verificato un errore durante la lettura del file file sorgente:
ErrorCopying=Si e' verificato un errore nella copia del file:
ErrorReplacingExistingFile=Si e' verificato un errore nella sovrascrittura del file:
ErrorRestartReplace=RiavviaRimpiazza fallito:
ErrorRenamingTemp=Si e' verificato un errore rinominando un file nella cartella di destinazione:
ErrorRegisterServer=Impossibile registrare la DLL/OCX: %1
ErrorRegisterServerMissingExport=DllRegisterServer export introvabile.
ErrorRegisterTypeLib=Impossibile registrare la type library: %1

; *** Post-installation errors
ErrorOpeningReadme=Si e' verificato un errore nell'apertura del file LEGGIMI.
ErrorRestartingComputer=L'installazione non e' riuscita a riavviare il computer, procedere manualmente.

; *** Uninstaller messages
UninstallNotFound=Il file "%1" non esiste, impossibile disinstallare.
UninstallOpenError=file "%1" non puo' essere aperto, La disinstallazione viene annullata.
UninstallUnsupportedVer=Il log file di disinstallazione "%1" e' in un formato non riconosciuto, impossibile disinstallare.
UninstallUnknownEntry=Una voce non riconosciuta (%1) e' stata incontrata nella lista di disinstallazione.
ConfirmUninstall=Vuoi realmente rimuovere %1 e tutti i suoi componenti?
OnlyAdminCanUninstall=TSolo un utente con privilegi di amministratore puo' disinstallare.
UninstallStatusLabel=Attendere sino a che %1 sia disinstallato.
UninstalledAll=%1 e' stato disinstallato.
UninstalledMost=%1 e' stato disinstallato.%n%nQualche elemento non puo' essere rimosso.
UninstalledAndNeedsRestart=Per terminare la disinstallazione di %1 il computer deve esesere fatto ripartire.%n%nRipartire ora?
UninstallDataCorrupted="%1" e' corrotto. Impossibile disinstallare.

; *** Uninstallation phase messages
ConfirmDeleteSharedFileTitle=Rimuovere il file condiviso?
ConfirmDeleteSharedFile2=Il sistema indica che il file condiviso non e' piu' usato da alcun programma. Vuoi disinstallarlo?%n%nSe non si e' sicuri, lasciare il file sul computer, non produrra' alcun danno.
SharedFileNameLabel=Nome del file:
SharedFileLocationLabel=Posizione:
WizardUninstalling=Stato della disinstallazione
StatusUninstalling=Disinstallazione di %1 in corso...

[CustomMessages]
CreateDesktopIcon=Crea una icona sul &Desktop
NameAndVersion=%1 versione %2
AdditionalIcons=Icons aggiuntive:
CreateQuickLaunchIcon=Create una icona &Quick Launch
ProgramOnTheWeb=%1 sul Web
UninstallProgram=Disinstalla %1
LaunchProgram=Lancia %1
AssocFileExtension=&Associa %1 con l'estesione %2 
AssocingFileExtension=Sto associando %1 all'estesione %2...
