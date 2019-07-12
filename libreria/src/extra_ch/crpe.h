/*
** File:    CRPE.h
**
** Authors: Seagate Software, Inc.
** Date:    13 Nov 91
** Purpose: This file presents the API to the Seagate Crystal Reports
**          Print Engine DLL.
**
** Copyright (c) 1991-2000  Seagate Software, Inc.
*/

#if !defined (CRPE_H)
#define CRPE_H

// Set 1-byte structure alignment
#if defined (__BORLANDC__)               // Borland C/C++
  #pragma option -a-
    #pragma comment (lib, "crpe32.lib")    // Point to Borland Lib File
#elif defined (_MSC_VER)                 // Microsoft Visual C++
  #if _MSC_VER >= 900                    // MSVC 2.x and later
    #pragma pack (push)
    #pragma comment (lib, "crpe32m.lib") // Point to Microsoft Lib File
  #endif
  #pragma pack (1)
#endif

#if defined (__cplusplus)
extern "C"
{
#endif

/*********************************************/
// CRPE error code
/*********************************************/
#define PE_ERR_NOERROR                      0

#define PE_ERR_NOTENOUGHMEMORY              500
#define PE_ERR_INVALIDJOBNO                 501
#define PE_ERR_INVALIDHANDLE                502
#define PE_ERR_STRINGTOOLONG                503
#define PE_ERR_NOSUCHREPORT                 504
#define PE_ERR_NODESTINATION                505
#define PE_ERR_BADFILENUMBER                506
#define PE_ERR_BADFILENAME                  507
#define PE_ERR_BADFIELDNUMBER               508
#define PE_ERR_BADFIELDNAME                 509
#define PE_ERR_BADFORMULANAME               510
#define PE_ERR_BADSORTDIRECTION             511
#define PE_ERR_ENGINENOTOPEN                512
#define PE_ERR_INVALIDPRINTER               513
#define PE_ERR_PRINTFILEEXISTS              514
#define PE_ERR_BADFORMULATEXT               515
#define PE_ERR_BADGROUPSECTION              516
#define PE_ERR_ENGINEBUSY                   517
#define PE_ERR_BADSECTION                   518
#define PE_ERR_NOPRINTWINDOW                519
#define PE_ERR_JOBALREADYSTARTED            520
#define PE_ERR_BADSUMMARYFIELD              521
#define PE_ERR_NOTENOUGHSYSRES              522
#define PE_ERR_BADGROUPCONDITION            523
#define PE_ERR_JOBBUSY                      524
#define PE_ERR_BADREPORTFILE                525
#define PE_ERR_NODEFAULTPRINTER             526
#define PE_ERR_SQLSERVERERROR               527
#define PE_ERR_BADLINENUMBER                528
#define PE_ERR_DISKFULL                     529
#define PE_ERR_FILEERROR                    530
#define PE_ERR_INCORRECTPASSWORD            531
#define PE_ERR_BADDATABASEDLL               532
#define PE_ERR_BADDATABASEFILE              533
#define PE_ERR_ERRORINDATABASEDLL           534
#define PE_ERR_DATABASESESSION              535
#define PE_ERR_DATABASELOGON                536
#define PE_ERR_DATABASELOCATION             537
#define PE_ERR_BADSTRUCTSIZE                538
#define PE_ERR_BADDATE                      539
#define PE_ERR_BADEXPORTDLL                 540
#define PE_ERR_ERRORINEXPORTDLL             541
#define PE_ERR_PREVATFIRSTPAGE              542
#define PE_ERR_NEXTATLASTPAGE               543
#define PE_ERR_CANNOTACCESSREPORT           544
#define PE_ERR_USERCANCELLED                545
#define PE_ERR_OLE2NOTLOADED                546
#define PE_ERR_BADCROSSTABGROUP             547
#define PE_ERR_NOCTSUMMARIZEDFIELD          548
#define PE_ERR_DESTINATIONNOTEXPORT         549
#define PE_ERR_INVALIDPAGENUMBER            550
#define PE_ERR_NOTSTOREDPROCEDURE           552
#define PE_ERR_INVALIDPARAMETER             553
#define PE_ERR_GRAPHNOTFOUND                554
#define PE_ERR_INVALIDGRAPHTYPE             555
#define PE_ERR_INVALIDGRAPHDATA             556
#define PE_ERR_CANNOTMOVEGRAPH              557
#define PE_ERR_INVALIDGRAPHTEXT             558
#define PE_ERR_INVALIDGRAPHOPT              559
#define PE_ERR_BADSECTIONHEIGHT             560
#define PE_ERR_BADVALUETYPE                 561
#define PE_ERR_INVALIDSUBREPORTNAME         562
#define PE_ERR_NOPARENTWINDOW               564 // dialog parent window
#define PE_ERR_INVALIDZOOMFACTOR            565 // zoom factor
#define PE_ERR_PAGESIZEOVERFLOW             567
#define PE_ERR_LOWSYSTEMRESOURCES           568
#define PE_ERR_BADGROUPNUMBER               570
#define PE_ERR_INVALIDOBJECTFORMATNAME      571
#define PE_ERR_INVALIDNEGATIVEVALUE         572
#define PE_ERR_INVALIDMEMORYPOINTER         573
#define PE_ERR_INVALIDOBJECTTYPE            574
#define PE_ERR_INVALIDGRAPHDATATYPE         577
#define PE_ERR_INVALIDSUBREPORTLINKNUMBER   582
#define PE_ERR_SUBREPORTLINKEXIST           583
#define PE_ERR_BADROWCOLVALUE               584
#define PE_ERR_INVALIDSUMMARYNUMBER         585
#define PE_ERR_INVALIDGRAPHDATAFIELDNUMBER  586
#define PE_ERR_INVALIDSUBREPORTNUMBER       587
#define PE_ERR_INVALIDFIELDSCOPE            588
#define PE_ERR_FIELDINUSE                   590
#define PE_ERR_INVALIDPARAMETERNUMBER       594
#define PE_ERR_INVALIDPAGEMARGINS           595
#define PE_ERR_REPORTONSECUREQUERY          596
#define PE_ERR_CANNOTOPENSECUREQUERY        597
#define PE_ERR_INVALIDSECTIONNUMBER         598
#define PE_ERR_SQLSERVERNOTOPENED           599
#define PE_ERR_TABLENAMEEXIST               606
#define PE_ERR_INVALIDCURSOR                607
#define PE_ERR_FIRSTPASSNOTFINISHED         608
#define PE_ERR_CREATEDATASOURCE             609
#define PE_ERR_CREATEDRILLDOWNPARAMETERS    610
#define PE_ERR_CHECKFORDATASOURCECHANGES    613
#define PE_ERR_STARTBACKGROUNDPROCESSING    614
#define PE_ERR_SQLSERVERINUSE               619
#define PE_ERR_GROUPSORTFIELDNOTSET         620
#define PE_ERR_CANNOTSETSAVESUMMARIES       621
#define PE_ERR_LOADOLAPDATABASEMANAGER      622
#define PE_ERR_OPENOLAPCUBE                 623
#define PE_ERR_READOLAPCUBEDATA             624
#define PE_ERR_CANNOTSAVEQUERY              626
#define PE_ERR_CANNOTREADQUERYDATA          627
#define PE_ERR_MAINREPORTFIELDLINKED        629
#define PE_ERR_INVALIDMAPPINGTYPEVALUE      630
#define PE_ERR_HITTESTFAILED                636
#define PE_ERR_BADSQLEXPRESSIONNAME         637 // no SQL expression by the specified *name* exists in this report.
#define PE_ERR_BADSQLEXPRESSIONNUMBER       638 // no SQL expression by the specified *number* exists in this report.
#define PE_ERR_BADSQLEXPRESSIONTEXT         639 // not a valid SQL expression
#define PE_ERR_INVALIDDEFAULTVALUEINDEX     641 // invalid index for default value of a parameter.
#define PE_ERR_NOMINMAXVALUE                642 // the specified PE_PF_* type does not have min/max values.
#define PE_ERR_INCONSISTANTTYPES            643 // if both min and max values are specified in PESetParameterMinMaxValue,
                                                // the value types for the min and max must be the same.

#define PE_ERR_CANNOTLINKTABLES             645
#define PE_ERR_CREATEROUTER                 646

#define PE_ERR_INVALIDFIELDINDEX            647
#define PE_ERR_INVALIDGRAPHTITLETYPE        648
#define PE_ERR_INVALIDGRAPHTITLEFONTTYPE    649

#define PE_ERR_PARAMTYPEDIFFERENT           650 // the type used in a add/set value API for a
                                                // parameter differs with it's existing type.
#define PE_ERR_INCONSISTANTRANGETYPES       651 // the value type for both start & end range
                                                // values must be the same.
#define PE_ERR_RANGEORDISCRETE              652 // an operation was attempted on a discrete parameter that is
                                                // only legal for range parameters or vice versa.

#define PE_ERR_NOTMAINREPORT                654 // an operation was attempted that is disallowed for subreports.

#define PE_ERR_INVALIDCURRENTVALUEINDEX     655 // invalid index for current value of a parameter.
#define PE_ERR_LINKEDPARAMVALUE             656 // operation illegal on linked parameter.

#define PE_ERR_INVALIDPARAMETERRANGEINFO    672 // Invalid PE_RI_* combination.
#define PE_ERR_INVALIDSORTMETHODINDEX       674 // Invalid sort method index.

#define PE_ERR_INVALIDGRAPHSUBTYPE          675 // Invalid PE_GST_* or 
                                                // PE_GST_* does not match PE_GT_* or 
                                                // PE_GST_* current graph type.
#define PE_ERR_BADGRAPHOPTIONINFO           676 // one of the members of PEGraphOptionInfo is out of range.
#define PE_ERR_BADGRAPHAXISINFO             677 // one of the members of PEGraphAxisInfo is out of range.

#define PE_ERR_NOTEXTERNALSUBREPORT         680 // the subreport is not imported.
#define PE_ERR_INVALIDPARAMETERVALUE        687
#define PE_ERR_INVALIDFORMULASYNTAXTYPE     688 // specified formula syntax not in PE_FST_*
#define PE_ERR_INVALIDCROPVALUE             689
#define PE_ERR_INVALIDCOLLATIONVALUE        690
#define PE_ERR_STARTPAGEGREATERSTOPPAGE     691
#define PE_ERR_INVALIDEXPORTFORMAT		    692

#define PE_ERR_READONLYPARAMETEROPTION      700 // This parameter option is read only and cannot be changed.
#define PE_ERR_MINGREATERTHANMAX            702 // The minimum cannot be greater than the maximum
#define PE_ERR_INVALIDSTARTPAGE             703 // Specified start page is greater than the last page on the report.

#define PE_ERR_OTHERERROR                   997
#define PE_ERR_INTERNALERROR                998 // programming error
#define PE_ERR_NOTIMPLEMENTED               999


/*************************************/
// unchanged constant
/*************************************/
#define PE_UNCHANGED       -1
#define PE_UNCHANGED_COLOR (COLORREF) -2
#define PE_NO_COLOR  (unsigned long) 0xffffffffL

#if defined (_WINDLL)
	#define CRPE_API /* __declspec(dllexport) */ WINAPI
#else
	#define CRPE_API WINAPI
#endif

/**********************************/
// Open and close print engine
/***********************************/
BOOL CRPE_API PEOpenEngine (void);
void CRPE_API PECloseEngine (void);
BOOL CRPE_API PECanCloseEngine (void);

/*************************************/
// Get version info
/*************************************/
#define PE_GV_DLL     100
#define PE_GV_ENGINE  200

short CRPE_API PEGetVersion (short versionRequested);

/*********************************************/
// the version number of the .rpt file format
/********************************************/

typedef struct PEVersionInfo
{
    WORD StructSize;  // initialize to PE_SIZEOF_VERSION_INFO
    WORD major;
    WORD minor;
    char letter;
} PEVersionInfo;
#define PE_SIZEOF_VERSION_INFO (sizeof(PEVersionInfo))

BOOL CRPE_API PEGetReportVersion( short printJob, 
                                  PEVersionInfo FAR* pVersionInfo );

/*************************************************************************/
// Open, print and close report (used when no changes needed to report)
/*************************************************************************/
short CRPE_API PEPrintReport (const char FAR *reportFilePath,
                              BOOL toDefaultPrinter,
                              BOOL toWindow,
                              const char FAR *title,
                              int left,
                              int top,
                              int width,
                              int height,
                              DWORD style,
                              HWND parentWindow);


#define PE_RPTOPT_CVTDATETIMETOSTR  0
#define PE_RPTOPT_CVTDATETIMETODATE 1
#define PE_RPTOPT_KEEPDATETIMETYPE  2

//Following are the valid values for promptMode
#define PE_RPTOPT_PROMPT_NONE 0
#define PE_RPTOPT_PROMPT_NORMAL 1
#define PE_RPTOPT_PROMPT_ALWAYS 2

/*******************************************/
// report options
/********************************************/
typedef struct PEReportOptions
{
    WORD StructSize;  // initialize to PE_SIZEOF_REPORT_OPTIONS
    short saveDataWithReport;  // BOOL value, except use PE_UNCHANGED for no change
    short saveSummariesWithReport;  // BOOL value, except use PE_UNCHANGED for no change
    short useIndexForSpeed;    // BOOL value, except use PE_UNCHANGED for no change
    short translateDOSStrings; // BOOL value, except use PE_UNCHANGED for no change
    short translateDOSMemos;   // BOOL value, except use PE_UNCHANGED for no change
    short convertDateTimeType; // a PE_RPTOPT_ value, except use PE_UNCHANGED for no change
    short convertNullFieldToDefault; // BOOL value, except use PE_UNCHANGED for no change
    short morePrintEngineErrorMessages;// BOOL value, except use PE_UNCHANGED for no change
    short caseInsensitiveSQLData; // BOOL value, except use PE_UNCHANGED for no change
    short verifyOnEveryPrint;     // BOOL value, except use PE_UNCHAGED for no change
    short zoomMode;                //  a PE_ZOOM_ constant, except use PE_UNCHANGED for no change
    short hasGroupTree;           // BOOL value, except use PE_UNCHANGED for no change
    short dontGenerateDataForHiddenObjects; // BOOL value, except use PE_UNCHANGED for no change
    short performGroupingOnServer;           // BOOL value, except use PE_UNCHANGED for no change
	short doAsyncQuery; // BOOL value, except use PE_UNCHANGED for no change
    short promptMode; // PE_RPTOPT_PROMPT_NONE, PE_RPTOPT_PROMPT_NORMAL, PE_RPTOPT_PROMPT_ALWAYS, use PE_UNCHANGED for no change
    short selectDistinctRecords; // BOOL value, except use PE_UNCHANGED for no change
    short alwaysSortLocally; // BOOL value, except use PE_UNCHANGED for no change
    short isReadOnly; // BOOL value,  a read-only attribute.  PESetReportOptions simply ignore it
    short canSelectDistinctRecords; // BOOL value,  a read-only attribute.  PESetReportOptions simply ignore it
}PEReportOptions;
#define PE_SIZEOF_REPORT_OPTIONS (sizeof(PEReportOptions))

BOOL CRPE_API PEGetReportOptions (short printJob,
                                  PEReportOptions FAR * reportOptions);
BOOL CRPE_API PESetReportOptions (short printJob,
                                  PEReportOptions FAR * reportOptions);

/***************************************************/
// print job
/***************************************************/
 
short CRPE_API PEOpenPrintJob (const char FAR *reportFilePath);

BOOL CRPE_API PEClosePrintJob (short printJob);

BOOL CRPE_API PEStartPrintJob (short printJob,
                               BOOL waitUntilDone);
void CRPE_API PECancelPrintJob (short printJob);

// open and close subreport
short CRPE_API PEOpenSubreport (short parentJob,
                                const char FAR *subreportName);
BOOL CRPE_API PECloseSubreport (short printJob);

// Print job status
// ----------------

BOOL CRPE_API PEIsPrintJobFinished (short printJob);

#define PE_JOBNOTSTARTED 1
#define PE_JOBINPROGRESS 2
#define PE_JOBCOMPLETED  3
#define PE_JOBFAILED     4  // an error occurred
#define PE_JOBCANCELLED  5  // by user
#define PE_JOBHALTED     6  // too many records or too much time

typedef struct PEJobInfo
{
    WORD StructSize;    // initialize to PE_SIZEOF_JOB_INFO

    DWORD NumRecordsRead,
          NumRecordsSelected,
          NumRecordsPrinted;
    WORD  DisplayPageN, // the page being displayed in window
          LatestPageN,  // the page being generated
          StartPageN;   // user opted, default to 1
    BOOL  printEnded;   // full report print completed?
}PEJobInfo;
#define PE_SIZEOF_JOB_INFO (sizeof (PEJobInfo))

short CRPE_API PEGetJobStatus (short printJob,
                               PEJobInfo FAR *jobInfo);


/***************************************/
// Controlling dialogs
/***************************************/
BOOL CRPE_API PESetDialogParentWindow (short printJob,
                                       HWND parentWindow);

BOOL CRPE_API PEEnableProgressDialog (short printJob,
                                      BOOL enable);

/***********************************************/
// Controlling Parameter Field Prompting Dialog
/***********************************************/

// Set boolean to indicate whether CRPE is allowed to prompt for parameter values
// during printing.

BOOL CRPE_API PEGetAllowPromptDialog(short printJob);
BOOL CRPE_API PESetAllowPromptDialog(short printJob, BOOL showPromptDialog);


/*******************************************/
// Print job error codes and messages
/******************************************/

short CRPE_API PEGetErrorCode (short printJob);
BOOL  CRPE_API PEGetErrorText (short printJob,
                               HANDLE FAR *textHandle,
                               short  FAR *textLength);

BOOL  CRPE_API PEGetHandleString (HANDLE textHandle,
                                  char FAR *buffer,
                                  short bufferLength);

/*************************************/
// Getting and setting the print date
/*************************************/
BOOL CRPE_API PEGetPrintDate (short printJob,
                              short FAR *year,
                              short FAR *month,
                              short FAR *day);

BOOL CRPE_API PESetPrintDate (short printJob,
                              short year,
                              short month,
                              short day);


/********************************************/
// Area, section and group operations
/********************************************/
#define PE_ALLSECTIONS           0

// A macro to create section codes:
// (This representation allows up to 25 groups and 40 sections of a given
// type, although Crystal Reports itself has no such limitations.)
#define PE_SECTION_CODE(sectionType,groupN,sectionN) \
    (((sectionType) * 1000) + ((groupN) % 25) + (((sectionN) % 40) * 25))

// A macro to create area codes:
#define PE_AREA_CODE(sectionType,groupN) \
    PE_SECTION_CODE (sectionType, groupN, 0)

// Section types:
#define PE_SECT_PAGE_HEADER      2
#define PE_SECT_PAGE_FOOTER      7
#define PE_SECT_REPORT_HEADER    1
#define PE_SECT_REPORT_FOOTER    8
#define PE_SECT_GROUP_HEADER     3
#define PE_SECT_GROUP_FOOTER     5
#define PE_SECT_DETAIL           4

// Macros to decode section and area codes:
#define PE_SECTION_TYPE(sectionCode) ((sectionCode) / 1000)
#define PE_GROUP_N(sectionCode)      ((sectionCode) % 25)
#define PE_SECTION_N(sectionCode)    (((sectionCode) / 25) % 40)

// The old section constants redefined in terms of the new:
// (Note that PE_GRANDTOTALSECTION and PE_SUMMARYSECTION both map
// to PE_SECT_REPORT_FOOTER.)
#define PE_HEADERSECTION      PE_SECTION_CODE (PE_SECT_PAGE_HEADER,   0, 0)
#define PE_FOOTERSECTION      PE_SECTION_CODE (PE_SECT_PAGE_FOOTER,   0, 0)
#define PE_TITLESECTION       PE_SECTION_CODE (PE_SECT_REPORT_HEADER, 0, 0)
#define PE_SUMMARYSECTION     PE_SECTION_CODE (PE_SECT_REPORT_FOOTER, 0, 0)
#define PE_GROUPHEADER        PE_SECTION_CODE (PE_SECT_GROUP_HEADER,  0, 0)
#define PE_GROUPFOOTER        PE_SECTION_CODE (PE_SECT_GROUP_FOOTER,  0, 0)
#define PE_DETAILSECTION      PE_SECTION_CODE (PE_SECT_DETAIL,        0, 0)
#define PE_GRANDTOTALSECTION  PE_SUMMARYSECTION

// Controlling group conditions (i.e. group breaks)
#define PE_SF_MAX_NAME_LENGTH 50

#define PE_SF_DESCENDING 0
#define PE_SF_ASCENDING  1
#define PE_SF_ORIGINAL   2 // only for group condition
#define PE_SF_SPECIFIED  3 // only for group condition


// use PE_ANYCHANGE for all field types except Date
#define PE_GC_ANYCHANGE    0

// use these constants for Date and DateTime fields
#define PE_GC_DAILY        0
#define PE_GC_WEEKLY       1
#define PE_GC_BIWEEKLY     2
#define PE_GC_SEMIMONTHLY  3
#define PE_GC_MONTHLY      4
#define PE_GC_QUARTERLY    5
#define PE_GC_SEMIANNUALLY 6
#define PE_GC_ANNUALLY     7

// use these constants for Time  and DateTime fields
#define PE_GC_BYSECOND     8
#define PE_GC_BYMINUTE     9
#define PE_GC_BYHOUR       10
#define PE_GC_BYAMPM       11

// use these constants for Boolean fields
#define PE_GC_TOYES        1
#define PE_GC_TONO         2
#define PE_GC_EVERYYES     3
#define PE_GC_EVERYNO      4
#define PE_GC_NEXTISYES    5
#define PE_GC_NEXTISNO     6

BOOL CRPE_API PESetGroupCondition (short printJob,
                                   short sectionCode,
                                   const char FAR *conditionField, // formula form
                                   short condition,       // a PE_GC_ constant
                                   short sortDirection);  // a PE_SF_ constant

short CRPE_API PEGetNGroups (short printJob);  // return -1 if failed.


// for PEGetGroupCondition, condition encodes both
// the condition and the type of the condition field
#define PE_GC_CONDITIONMASK   0x00FF
#define PE_GC_TYPEMASK        0x0F00

#define PE_GC_TYPEOTHER       0x0000
#define PE_GC_TYPEDATE        0x0200
#define PE_GC_TYPEBOOLEAN     0x0400
#define PE_GC_TYPETIME        0x0800

BOOL CRPE_API PEGetGroupCondition (short printJob,
                                   short sectionCode,
                                   HANDLE FAR *conditionFieldHandle,
                                   short  FAR *conditionFieldLength,
                                   short  FAR *condition,
                                   short  FAR *sortDirection);

#define PE_FIELD_NAME_LEN 512

#define PE_GO_TBN_ALL_GROUPS_UNSORTED   0
#define PE_GO_TBN_ALL_GROUPS_SORTED     1
#define PE_GO_TBN_TOP_N_GROUPS          2
#define PE_GO_TBN_BOTTOM_N_GROUPS       3

typedef struct PEGroupOptions
{ 
    WORD StructSize;
    // when setting, pass a PE_GC_ constant, or PE_UNCHANGED for no change.
    // when getting, use PE_GC_TYPEMASK and PE_GC_CONDITIONMASK to
    // decode the condition.
    short condition;
    char fieldName [PE_FIELD_NAME_LEN]; // formula form, or empty for no change.
    short sortDirection;                // a PE_SF_ const, or PE_UNCHANGED for no change.
    short repeatGroupHeader;            // BOOL value, or PE_UNCHANGED for no change.
    short keepGroupTogether;            // BOOL value, or PE_UNCHANGED for no change.
    short topOrBottomNGroups;           // a PE_GO_TBN_ constant, or PE_UNCHANGED for no change.
    char topOrBottomNSortFieldName [PE_FIELD_NAME_LEN]; // formula form, or empty for no change.
    short nTopOrBottomGroups;           // the number of groups to keep, 0 for all, or PE_UNCHANGED for no change.
    short discardOtherGroups;           // BOOL value, or PE_UNCHANGED for no change.
    short   ignored;                                // for 4 byte alignment. ignored.
    short   hierarchicalSorting;                    // Boolean or PE_UNCHANGED
    char    instanceIDField [PE_FIELD_NAME_LEN];    // for hierarchical grouping
    char    parentIDField [PE_FIELD_NAME_LEN];      // for hierarchical grouping
    long    groupIndent;                            // twips
}
    PEGroupOptions;
#define PE_SIZEOF_GROUP_OPTIONS (sizeof (PEGroupOptions))

BOOL CRPE_API PEGetGroupOptions(short printJob,
                                short groupN,
                                PEGroupOptions FAR * groupOptions);
BOOL CRPE_API PESetGroupOptions(short printJob,
                                short groupN,
                                PEGroupOptions FAR * groupOptions);

//Get number of sections
short CRPE_API PEGetNSections (short printJob); // return -1 if failed
short CRPE_API PEGetNSectionsInArea(short printJob, short areaCode); // return -1 if failed

short CRPE_API PEGetSectionCode (short printJob,  // return 0 if failed
                                 short sectionN); // range within the number from PEGetNSections

// Setting section/area height

// This is the replacement API Call for PEGetMinimumSectionHeight which is obsolete.
// The obsolete API will still work for older applications, but use this for all new development
BOOL CRPE_API PEGetSectionHeight(short printJob,
                                 short sectionCode,
                                 short FAR * height); // Twips

// This is the replacement API Call for PESetMinimumSectionHeight which is obsolete.
// The obsolete API will still work for older applications, but use this for all new development
BOOL CRPE_API PESetSectionHeight (short printJob,
                                  short sectionCode,
                                  short height); // twips

// area or section format.
typedef struct PESectionOptions // For area options, too.
{
    WORD StructSize;            // initialize to PE_SIZEOF_SECTION_OPTIONS

    short visible,              // BOOL values, except use PE_UNCHANGED
          newPageBefore,        // to preserve the existing settings
          newPageAfter,
          keepTogether,
          suppressBlankSection,
          resetPageNAfter,
          printAtBottomOfPage;
    COLORREF backgroundColor;   // Use PE_UNCHANGED_COLOR to preserve the
                                // existing color. only for section format
    short underlaySection;      // BOOL values, except use PE_UNCHANGED
    short showArea;             // to preserve the existing settings
    short freeFormPlacement;
    short reserveMinimumPageFooter; // BOOLEAN or PE_UNCHANGED; Sets the size of the Page Footer *area*
                                    // to the size of the largest Page Footer *section*. Used with
                                    // PEGetAreaFormat/PESetAreaFormat; ignored when used with
                                    // PEGetSectionFormat/PESetSectionFormat.
}PESectionOptions;
#define PE_SIZEOF_SECTION_OPTIONS (sizeof (PESectionOptions))

BOOL CRPE_API PESetSectionFormat (short printJob,
                                  short sectionCode,
                                  PESectionOptions FAR *options);

BOOL CRPE_API PEGetSectionFormat (short printJob,
                                  short sectionCode,
                                  PESectionOptions FAR *options);

BOOL CRPE_API PESetAreaFormat (short printJob,
                               short areaCode,
                               PESectionOptions FAR *options);

BOOL CRPE_API PEGetAreaFormat (short printJob,
                               short areaCode,
                               PESectionOptions FAR *options);

// Setting font and color info
#define PE_FIELDS    0x0001
#define PE_TEXT      0x0002

BOOL CRPE_API PESetFont (short printJob,
                         short sectionCode,
                         short scopeCode,     // PE_FIELDS or PE_TEXT
                         const char FAR *faceName,  // 0 for no change
                         short fontFamily,    // FF_DONTCARE for no change
                         short fontPitch,     // DEFAULT_PITCH for no change
                         short charSet,       // DEFAULT_CHARSET for no change
                         short pointSize,     // 0 for no change
                         short isItalic,      // PE_UNCHANGED for no change
                         short isUnderlined,  // ditto
                         short isStruckOut,   // ditto
                         short weight);       // 0 for no change


// Subreport object
short CRPE_API PEGetNSubreportsInSection (short printJob,
                                          short sectionCode);

DWORD CRPE_API PEGetNthSubreportInSection (short printJob,
                                           short sectionCode,
                                           short subreportN);

#define PE_SUBREPORT_NAME_LEN 128
// PE_SRI_ONOPENJOB: Reimport the subreport when opening the main report.
// PE_SRI_ONFUNCTIONCALL: Reimport the subreport when the api is called.
#define PE_SRI_UNDEFINED     -1
#define PE_SRI_ONOPENJOB      0
#define PE_SRI_ONFUNCTIONCALL 1

typedef struct PESubreportInfo
{
    WORD StructSize;            // Initialize to PE_SIZEOF_SUBREPORT_INFO.

    // Strings are null-terminated.
    char name [PE_SUBREPORT_NAME_LEN];

    // number of links
    short NLinks;
    // subreport placement.
    short isOnDemand;    // TRUE if the subreport is on demand subreport.
    
    short external;         // 1: the subreport is imported; 0: otherwise.
    short reimportOption;   // PE_SRI_ONOPENJOB or PE_SRI_ONFUNCTIONCALL
                            // This value is ignored if the subreport is
                            // not imported (value of external is 0).
}PESubreportInfo;
#define PE_SIZEOF_SUBREPORT_INFO (sizeof (PESubreportInfo))

BOOL CRPE_API PEGetSubreportInfo (short printJob,
                                  DWORD subreportHandle,
                                  PESubreportInfo FAR *subreportInfo);

BOOL CRPE_API PEReimportSubreport(short printJob,
                                  DWORD subreportHandle,
                                  BOOL FAR * linkChanged,
                                  BOOL FAR * reimported);

/* *************************************** */
/*        GRAPHING                         */
/* *************************************** */
//graph type

#define PE_GT_BARCHART              0
#define PE_GT_LINECHART             1
#define PE_GT_AREACHART             2
#define PE_GT_PIECHART              3
#define PE_GT_DOUGHNUTCHART         4
#define PE_GT_THREEDRISERCHART      5
#define PE_GT_THREEDSURFACECHART    6
#define PE_GT_SCATTERCHART          7
#define PE_GT_RADARCHART            8
#define PE_GT_BUBBLECHART           9
#define PE_GT_STOCKCHART            10
#define PE_GT_USERDEFINEDCHART      50      // <----|__ for PEGetGraphTypeInfo only - 
#define PE_GT_UNKNOWNTYPECHART      100     // <----|   do not use in PESetGraphTypeInfo.


// graph subtype
// bar charts
#define PE_GST_SIDEBYSIDEBARCHART                   0
#define PE_GST_STACKEDBARCHART                      1
#define PE_GST_PERCENTBARCHART                      2
#define PE_GST_FAKED3DSIDEBYSIDEBARCHART            3
#define PE_GST_FAKED3DSTACKEDBARCHART               4
#define PE_GST_FAKED3DPERCENTBARCHART               5
                                                    
// line charts                                      
#define PE_GST_REGULARLINECHART                     10
#define PE_GST_STACKEDLINECHART                     11
#define PE_GST_PERCENTAGELINECHART                  12
#define PE_GST_LINECHARTWITHMARKERS                 13
#define PE_GST_STACKEDLINECHARTWITHMARKERS          14
#define PE_GST_PERCENTAGELINECHARTWITHMARKERS       15
                                                    
//area charts                                       
#define PE_GST_ABSOLUTEAREACHART                    20
#define PE_GST_STACKEDAREACHART                     21
#define PE_GST_PERCENTAREACHART                     22
#define PE_GST_FAKED3DABSOLUTEAREACHART             23
#define PE_GST_FAKED3DSTACKEDAREACHART              24
#define PE_GST_FAKED3DPERCENTAREACHART              25
                                                    
// pie charts                                       
#define PE_GST_REGULARPIECHART                      30
#define PE_GST_FAKED3DREGULARPIECHART               31
#define PE_GST_MULTIPLEPIECHART                     32
#define PE_GST_MULTIPLEPROPORTIONALPIECHART         33
                                                    
// doughnut charts                                  
#define PE_GST_REGULARDOUGHNUTCHART                 40
#define PE_GST_MULTIPLEDOUGHNUTCHART                41
#define PE_GST_MULTIPLEPROPORTIONALDOUGHNUTCHART    42

// 3D riser charts
#define PE_GST_THREEDREGULARCHART                   50
#define PE_GST_THREEDPYRAMIDCHART                   51
#define PE_GST_THREEDOCTAGONCHART                   52
#define PE_GST_THREEDCUTCORNERSCHART                53
	                                                
// 3D surface charts                                
#define PE_GST_THREEDSURFACEREGULARCHART            60
#define PE_GST_THREEDSURFACEWITHSIDESCHART          61
#define PE_GST_THREEDSURFACEHONEYCOMBCHART          62
                                                    
// scatter charts                                   
#define PE_GST_XYSCATTERCHART                       70
#define PE_GST_XYSCATTERDUALAXISCHART               71
#define PE_GST_XYSCATTERWITHLABELSCHART             72
#define PE_GST_XYSCATTERDUALAXISWITHLABELSCHART     73
                                                    
// radar charts                                     
#define PE_GST_REGULARRADARCHART                    80
#define PE_GST_STACKEDRADARCHART                    81
#define PE_GST_RADARDUALAXISCHART                   82
                                                    
// bubble charts                                    
#define PE_GST_REGULARBUBBLECHART                   90
#define PE_GST_DUALAXISBUBBLECHART                  91
                                                    
// stocked charts                                   
#define PE_GST_HIGHLOWCHART                         100
#define PE_GST_HIGHLOWOPENCLOSECHART                101

#define PE_GST_UNKNOWNSUBTYPECHART                  1000

typedef struct PEGraphTypeInfo
{
    WORD StructSize;
    short graphType;      // PE_GT_*, PE_UNCHANGED for no change
    short graphSubtype;   // PE_GST_*, PE_UNCHANGED for no change

} PEGraphTypeInfo;

#define PE_SIZEOF_GRAPH_TYPE_INFO (sizeof (PEGraphTypeInfo))

BOOL CRPE_API PEGetGraphTypeInfo(short printJob, 
                                 short sectionN, 
                                 short graphN, 
                                 PEGraphTypeInfo FAR * graphTypeInfo);

BOOL CRPE_API PESetGraphTypeInfo(short printJob, 
                                 short sectionN, 
                                 short graphN, 
                                 PEGraphTypeInfo FAR * graphTypeInfo);


//graph text

// graph text
#define PE_GTT_TITLE            0
#define PE_GTT_SUBTITLE         1
#define PE_GTT_FOOTNOTE         2
#define PE_GTT_SERIESTITLE      3
#define PE_GTT_GROUPSTITLE      4
#define PE_GTT_XAXISTITLE       5
#define PE_GTT_YAXISTITLE       6
#define PE_GTT_ZAXISTITLE       7


// graph text fonts
#define PE_GTF_TITLEFONT        0
#define PE_GTF_SUBTITLEFONT     1
#define PE_GTF_FOOTNOTEFONT     2
#define PE_GTF_GROUPSTITLEFONT  3
#define PE_GTF_DATATITLEFONT    4
#define PE_GTF_LEGENDFONT       5
#define PE_GTF_GROUPLABELSFONT  6
#define PE_GTF_DATALABELSFONT   7

#define PE_FACE_NAME_LEN 64
typedef struct PEFontColorInfo
{
    WORD StructSize;
    char faceName[PE_FACE_NAME_LEN]; // empty string for no change
    short fontFamily; // FF_DONTCARE for no change
    short fontPitch;  // DEFAULT_PITCH for no change
    short charSet;   // DEFAULT_CHARSET for no change
    short pointSize;  // 0 for no change
    short isItalic;   // BOOL value, except use PE_UNCHANGED for no change.
    short isUnderlined; // BOOL value, except use PE_UNCHANGED for no change.
    short isStruckOut;  // BOOL value, except use PE_UNCHANGED for no change.
    short weight;       // 0 for no change
    COLORREF color;     // PE_UNCHANGED_COLOR for no change.
    short twipSize;     // Font size in twips, 0 for no change.
                        // Use one of pointSize or twipSize. If both pointSize and twipSize
                        // are non-zero, twipSize will be used and pointSize will be ignored.
}PEFontColorInfo;
#define PE_SIZEOF_FONT_COLOR_INFO (sizeof(PEFontColorInfo))

BOOL CRPE_API PEGetGraphTextInfo(short printJob, 
                                 short sectionN, 
                                 short graphN, 
                                 WORD titleType,     //PE_GTT_*
                                 HANDLE FAR * title, 
                                 short FAR * titleLength);

BOOL CRPE_API PESetGraphTextInfo(short printJob, 
                                 short sectionN, 
                                 short graphN, 
                                 WORD titleType, 
                                 LPCSTR title);

//enable/disable graph default titles
BOOL CRPE_API PESetGraphTextDefaultOption (short printJob,
                                    short sectionN, 
                                    short graphN, 
                                    WORD titleType,     //PE_GTT_*
                                    BOOL useDefault);

BOOL CRPE_API PEGetGraphTextDefaultOption (short printJob,
                                    short sectionN, 
                                    short graphN, 
                                    WORD titleType,     //PE_GTT_*
                                    BOOL FAR * useDefault);

//graph font
BOOL CRPE_API PEGetGraphFontInfo(short printJob, 
                                 short sectionN, 
                                 short graphN, 
                                 WORD titleFontType,  //PE_GTF_
                                 PEFontColorInfo FAR * fontColourInfo);

BOOL CRPE_API PESetGraphFontInfo(short printJob, 
                                 short sectionN, 
                                 short graphN, 
                                 WORD titleFontType,  //PE_GTF_
                                 PEFontColorInfo FAR * fontColourInfo);

// graph options
#define PE_GLP_PLACEUPPERRIGHT      0
#define PE_GLP_PLACEBOTTOMCENTER    1
#define PE_GLP_PLACETOPCENTER       2
#define PE_GLP_PLACERIGHT           3
#define PE_GLP_PLACELEFT            4
#define PE_GLP_PLACECUSTOM          5   // for PEGetGraphOptionInfo, do not use
                                        // in PESetGraphOptionInfo.

//legend layout
#define PE_GLL_PERCENTAGE           0
#define PE_GLL_AMOUNT               1
#define PE_GLL_CUSTOM               2   // for PEGetGraphOptionInfo, do not use
                                        // in PESetGraphOptionInfo.
// bar sizes
#define PE_GBS_MINIMUMBARSIZE       0
#define PE_GBS_SMALLBARSIZE         1
#define PE_GBS_AVERAGEBARSIZE       2
#define PE_GBS_LARGEBARSIZE         3
#define PE_GBS_MAXIMUMBARSIZE       4

// pie sizes
#define PE_GPS_MINIMUMPIESIZE       64
#define PE_GPS_SMALLPIESIZE         48
#define PE_GPS_AVERAGEPIESIZE       32
#define PE_GPS_LARGEPIESIZE         16
#define PE_GPS_MAXIMUMPIESIZE       0

// detached pie slice
#define PE_GDPS_NODETACHMENT        0
#define PE_GDPS_SMALLESTSLICE       1
#define PE_GDPS_LARGESTSLICE        2

// marker sizes
#define PE_GMS_SMALLMARKERS         0
#define PE_GMS_MEDIUMSMALLMARKERS   1
#define PE_GMS_MEDIUMMARKERS        2
#define PE_GMS_MEDIUMLARGEMARKERS   3
#define PE_GMS_LARGEMARKERS         4

// marker shapes
#define PE_GMSP_RECTANGLESHAPE      1
#define PE_GMSP_CIRCLESHAPE         4
#define PE_GMSP_DIAMONDSHAPE        5
#define PE_GMSP_TRIANGLESHAPE       8

// chart color
#define PE_GCR_COLORCHART           0
#define PE_GCR_BLACKANDWHITECHART   1

// chart data points
#define PE_GDP_NONE                 0
#define PE_GDP_SHOWLABEL            1
#define PE_GDP_SHOWVALUE            2

// number formats
#define PE_GNF_NODECIMAL            0
#define PE_GNF_ONEDECIMAL           1
#define PE_GNF_TWODECIMAL           2
#define PE_GNF_CURRENCYNODECIMAL    3
#define PE_GNF_CURRENCYTWODECIMAL   4
#define PE_GNF_PERCENTNODECIMAL     5
#define PE_GNF_PERCENTONEDECIMAL    6
#define PE_GNF_PERCENTTWODECIMAL    7

// viewing angles
#define PE_GVA_STANDARDVIEW         1
#define PE_GVA_TALLVIEW             2
#define PE_GVA_TOPVIEW              3
#define PE_GVA_DISTORTEDVIEW        4
#define PE_GVA_SHORTVIEW            5
#define PE_GVA_GROUPEYEVIEW         6
#define PE_GVA_GROUPEMPHASISVIEW    7
#define PE_GVA_FEWSERIESVIEW        8
#define PE_GVA_FEWGROUPSVIEW        9
#define PE_GVA_DISTORTEDSTDVIEW     10
#define PE_GVA_THICKGROUPSVIEW      11
#define PE_GVA_SHORTERVIEW          12
#define PE_GVA_THICKSERIESVIEW      13
#define PE_GVA_THICKSTDVIEW         14
#define PE_GVA_BIRDSEYEVIEW         15
#define PE_GVA_MAXVIEW              16

typedef struct PEGraphOptionInfo
{
    WORD StructSize;

    short graphColour; // PE_GCR_*, PE_UNCHANGED for no change
	
    short showLegend; //BOOL, PE_UNCHANGED for no change
    short legendPosition; //PE_GLP_*, if showLegend == 0, means no legend 

// pie charts and doughut charts
    short pieSize; // PE_GPS_*, PE_UNCHANGED for no change
    short detachedPieSlice; // PE_GDPS_*, PE_UNCHANGED for no change

// bar chart
    short barSize; // PE_GBS_*, PE_UNCHANGED for no change
    short verticalBars; //BOOL, PE_UNCHANGED for no change

// markers (used for line and bar charts)
    short markerSize; // PE_GMS_*, PE_UNCHANGED for no change
    short markerShape; // PE_GMSP_*, PE_UNCHANGED for no change

//data points
    short dataPoints; // PE_GDP_*, PE_UNCHANGED for no change    
    short dataValueNumberFormat; //PE_GNF_*, PE_UNCHANGED for no change
	
// 3d
    short viewingAngle; //PE_GVA_*, PE_UNCHANGED for no change

    short legendLayout;     //PE_GLL_*
} PEGraphOptionInfo;

#define PE_SIZEOF_GRAPH_OPTION_INFO (sizeof (PEGraphOptionInfo))

BOOL CRPE_API PEGetGraphOptionInfo(short printJob, 
                                   short sectionN, 
                                   short graphN, 
                                   PEGraphOptionInfo FAR * graphOptionInfo);

BOOL CRPE_API PESetGraphOptionInfo(short printJob, 
                                   short sectionN, 
                                   short graphN,
                                   PEGraphOptionInfo FAR * graphOptionInfo);

//graph axes
#define PE_GGT_NOGRIDLINES              0
#define PE_GGT_MINORGRIDLINES           1
#define PE_GGT_MAJORGRIDLINES           2
#define PE_GGT_MAJORANDMINORGRIDLINES   3

//axis division method
#define PE_ADM_AUTOMATIC                0
#define PE_ADM_MANUAL                   1

typedef struct PEGraphAxisInfo
{
    WORD StructSize;

    short groupAxisGridLine; // PE_GGT_*, PE_UNCHANGED for no change
    short dataAxisYGridLine; // PE_GGT_*, PE_UNCHANGED for no change
    short dataAxisY2GridLine; // PE_GGT_*, PE_UNCHANGED for no change
    short seriesAxisGridline; // PE_GGT_*, PE_UNCHANGED for no change

    double dataAxisYMinValue;
    double dataAxisYMaxValue;
    double dataAxisY2MinValue;
    double dataAxisY2MaxValue;
    double seriesAxisMinValue;
    double seriesAxisMaxValue;

    short dataAxisYNumberFormat; //PE_GNF_*, PE_UNCHANGED for no change
    short dataAxisY2NumberFormat; //PE_GNF_*, PE_UNCHANGED for no change
    short seriesAxisNumberFormat; //PE_GNF_*, PE_UNCHANGED for no change

    short dataAxisYAutoRange; // BOOL, PE_UNCHANGED for no change
    short dataAxisY2AutoRange; //BOOL, PE_UNCHANGED for no change
    short seriesAxisAutoRange; //BOOL, PE_UNCHANGED for no change

    short dataAxisYAutomaticDivision; // PE_ADM_* or PE_UNCHANGED for no change
    short dataAxisY2AutomaticDivision; // PE_ADM_* or PE_UNCHANED for no change
    short seriesAxisAutomaticDivision; // PE_ADM_* or PE_UNCHANED for no change

    long dataAxisYManualDivision;  //if dataAxisYAutomaticDivision is PE_ADM_AUTOMATIC, this field is ignored
    long dataAxisY2ManualDivision; //if dataAxisY2AutomaticDivision is PE_ADM_AUTOMATIC, this field is ignored
    long seriesAxisManualDivision; //if seriesAxisAutomaticDivision is PE_ADM_AUTOMATIC, this field is ignored

    short dataAxisYAutoScale;       //BOOL, PE_UNCHANGED for no change
    short dataAxisY2AutoScale;      //BOOL, PE_UNCHANGED for no change
    short seriesAxisAutoScale;      //BOOL, PE_UNCHANGED for no change
}  PEGraphAxisInfo;

#define PE_SIZEOF_GRAPH_AXIS_INFO (sizeof (PEGraphAxisInfo))

BOOL CRPE_API PEGetGraphAxisInfo(short printJob, 
                                 short sectionN, 
                                 short graphN, 
                                 PEGraphAxisInfo FAR * graphAxisInfo);

BOOL CRPE_API PESetGraphAxisInfo(short printJob, 
                                 short sectionN, 
                                 short graphN, 
                                 PEGraphAxisInfo FAR * graphAxisInfo);


/*******************************************/
// formula operations
/********************************************/
short CRPE_API PEGetNFormulas (short printJob);

BOOL CRPE_API PEGetNthFormula (short printJob,
                               short formulaN,
                               HANDLE FAR *nameHandle,
                               short FAR *nameLength,
                               HANDLE FAR *textHandle,
                               short FAR *textLength);

BOOL CRPE_API PEGetFormula (short printJob,
                            const char FAR *formulaName,
                            HANDLE FAR *textHandle,
                            short FAR *textLength);

BOOL CRPE_API PESetFormula (short printJob,
                            const char FAR *formulaName,
                            const char FAR *formulaString);

// Format formula name
// Old naming convention
#define SECTION_VISIBILITY               58
#define NEW_PAGE_BEFORE                  60
#define NEW_PAGE_AFTER                   61
#define KEEP_SECTION_TOGETHER            62
#define SUPPRESS_BLANK_SECTION           63
#define RESET_PAGE_N_AFTER               64
#define PRINT_AT_BOTTOM_OF_PAGE          65
#define UNDERLAY_SECTION                 66
#define SECTION_BACK_COLOUR              67

// New naming convention
#define PE_FFN_AREASECTION_VISIBILITY           58  // area & section format
#define PE_FFN_SECTION_VISIBILITY               58  // section format
#define PE_FFN_SHOW_AREA                        59  // area format
#define PE_FFN_NEW_PAGE_BEFORE                  60  // area & section format
#define PE_FFN_NEW_PAGE_AFTER                   61  // area & section format
#define PE_FFN_KEEP_TOGETHER                    62  // area & section format
#define PE_FFN_SUPPRESS_BLANK_SECTION           63  // section format
#define PE_FFN_RESET_PAGE_N_AFTER               64  // area & section format
#define PE_FFN_PRINT_AT_BOTTOM_OF_PAGE          65  // area & section format
#define PE_FFN_UNDERLAY_SECTION                 66  // section format
#define PE_FFN_SECTION_BACK_COLOUR              67  // section format
#define PE_FFN_SECTION_BACK_COLOR               67  // section format

BOOL CRPE_API PEGetAreaFormatFormula (short printJob,
                                      short areaCode,
                                      short formulaName, // an area PE_FFN_ constant
                                      HANDLE FAR *textHandle,
                                      short FAR *textLength);

BOOL CRPE_API PESetAreaFormatFormula (short printJob,
                                      short areaCode,
                                      short formulaName, // an area PE_FFN_ constant
                                      const char FAR *formulaString);

BOOL CRPE_API PEGetSectionFormatFormula (short printJob,
                                         short sectionCode,
                                         short formulaName, // a section PE_FFN_ constant
                                         HANDLE FAR *textHandle,
                                         short FAR *textLength);

BOOL CRPE_API PESetSectionFormatFormula (short printJob,
                                         short sectionCode,
                                         short formulaName, // a section PE_FFN_ constant
                                         const char FAR *formulaString);

BOOL CRPE_API PECheckFormula (short printJob,
                              const char FAR *formulaName);

BOOL CRPE_API PEGetSelectionFormula (short printJob,
                                     HANDLE FAR *textHandle,
                                     short FAR *textLength);

BOOL CRPE_API PESetSelectionFormula (short printJob,
                                     const char FAR *formulaString);

BOOL CRPE_API PECheckSelectionFormula (short printJob);

BOOL CRPE_API PEGetGroupSelectionFormula (short printJob,
                                          HANDLE FAR *textHandle,
                                          short FAR *textLength);

BOOL CRPE_API PESetGroupSelectionFormula (short printJob,
                                          const char FAR *formulaString);

BOOL CRPE_API PECheckGroupSelectionFormula (short printJob);

/* ************************************ */
/*          SQL Expressions             */
/* ************************************ */
short CRPE_API PEGetNSQLExpressions (short printJob);

BOOL CRPE_API PEGetNthSQLExpression (short printJob,
                                    short expressionN,
                                    HANDLE FAR *nameHandle,
                                    short FAR *nameLength,
                                    HANDLE FAR *textHandle,
                                    short FAR *textLength);

BOOL CRPE_API PEGetSQLExpression (short printJob,
                                    const char FAR *expressionName,
                                    HANDLE FAR *textHandle,
                                    short FAR *textLength);

BOOL CRPE_API PESetSQLExpression (short printJob,
                                    const char FAR *expressionName,
                                    const char FAR *expressionString);

BOOL CRPE_API PECheckSQLExpression (short printJob,
                                    const char FAR *expressionName);

/********************************************************************************/
// NOTE : Stored Procedures
//
// The previous Stored Procedure API Calls PEGetNParams, PEGetNthParam,
// PEGetNthParamInfo and PESetNthParam have been made obsolete.  Older 
// applications that used these API Calls will still work as before, but for new 
// development please use the new Parameter API calls below, 
//
// The Stored Procedure Parameters have now been unified with the Parameter 
// Fields.
//
// The replacements for these calls are as follows : 
//		PEGetNParams		= PEGetNParameterFields
//		PEGetNthParam		= PEGetNthParameterField
//		PEGetNthParamInfo	= PEGetParameterValueInfo
//		PESetNthParam		= PESetNthParameterField
//
// NOTE : To tell if a Parameter Field is a Stored Procedure, use the 
//		  PEGetNthParameterType or PEGetNthParameterField API Calls
//
// If you wish to SET a parameter to NULL then set the CurrentValue to CRWNULL.
// The CRWNULL is of Type String and is independant of the datatype of the 
// parameter.
//
/********************************************************************************/

/****************************************/
// Parameter field operation
/****************************************/
#define PE_WORD_LEN           2
#define PE_PF_REPORT_NAME_LEN 128
#define PE_PF_NAME_LEN        256
#define PE_PF_PROMPT_LEN      256
#define PE_PF_VALUE_LEN       256
#define PE_PF_EDITMASK_LEN    256

#define PE_PF_NUMBER          0
#define PE_PF_CURRENCY        1
#define PE_PF_BOOLEAN         2
#define PE_PF_DATE            3
#define PE_PF_STRING          4
#define PE_PF_DATETIME        5
#define PE_PF_TIME            6

typedef struct PEParameterFieldInfo
{
    // Initialize to PE_SIZEOF_PARAMETER_FIELD_INFO.
    WORD StructSize;

    // PE_PF_ constant
    WORD ValueType;

    // Indicate the default value is set in PEParameterFieldInfo.
    WORD DefaultValueSet;

    // Indicate the current value is set in PEParameterFieldInfo.
    WORD CurrentValueSet;

    // All strings are null-terminated.
    char Name [PE_PF_NAME_LEN];
    char Prompt [PE_PF_PROMPT_LEN];

    // Could be Number, Currency, Boolean, Date, DateTime, Time, or String
    char DefaultValue [PE_PF_VALUE_LEN];
    char CurrentValue [PE_PF_VALUE_LEN];

    // name of report where the field belongs, only used in
    // PEGetNthParameterField and PENewParameterField
    char ReportName [PE_PF_REPORT_NAME_LEN];

    // returns false if parameter is linked, not in use, or has current value set
    WORD needsCurrentValue; 

    //for String values this will be TRUE if the string is limited on length, for 
	//other types it will be TRUE if the parameter is limited by a range
    WORD isLimited;

    //For string fields, these are the minimum/maximum length of the string.
    //For numeric fields, they are the minimum/maximum numeric value.
    //For other fields, use PEGetParameterMinMaxValue
    double MinSize;
    double MaxSize;

    //An edit mask that restricts what may be entered for string parameters.
    char EditMask [PE_PF_EDITMASK_LEN];

    //  return true if it is essbase sub var
    WORD isHidden;
}PEParameterFieldInfo;

#define PE_SIZEOF_PARAMETER_FIELD_INFO (sizeof (PEParameterFieldInfo))

short CRPE_API PEGetNParameterFields (short printJob);

BOOL CRPE_API PEGetNthParameterField (short printJob,
                                      short parameterN,
                                      PEParameterFieldInfo FAR *parameterInfo);

BOOL CRPE_API PESetNthParameterField (short printJob,
                                      short parameterN,
                                      PEParameterFieldInfo FAR *parameterInfo);

// define value type
#define PE_VI_NUMBER       0
#define PE_VI_CURRENCY     1
#define PE_VI_BOOLEAN      2
#define PE_VI_DATE         3
#define PE_VI_STRING       4
#define PE_VI_DATETIME     5
#define PE_VI_TIME         6
#define PE_VI_INTEGER      7
#define PE_VI_COLOR        8
#define PE_VI_CHAR         9
#define PE_VI_LONG		   10
#define PE_VI_NOVALUE      100

#define PE_VI_STRING_LEN 256

typedef struct PEValueInfo
{
    WORD StructSize;
    WORD valueType; // a PE_VI_ constant
    double viNumber;
    double viCurrency;
    BOOL viBoolean;
    char viString[PE_VI_STRING_LEN];
    short viDate[3]; // year, month, day
    short viDateTime[6]; // year, month, day, hour, minute, second
    short viTime[3];  // hour, minute, second
    COLORREF viColor;
    short viInteger;
    char viC; //BYTE
	char ignored; // for 4 byte alignment. ignored.
	long viLong;
} PEValueInfo;

#define PE_SIZEOF_VALUE_INFO (sizeof (PEValueInfo))
 
// Converting parameterInfo default value or current value into value info
// pass default vaule or current value in PEParameterFieldInfo into these two functions. 
BOOL CRPE_API PEConvertPFInfoToVInfo(void FAR * value, short valueType, PEValueInfo FAR * valueInfo);
BOOL CRPE_API PEConvertVInfoToPFInfo(PEValueInfo FAR * valueInfo, WORD FAR * valueType, void FAR * value);

// Default values for Parameter fields.
// ////////////////////////////////////
// If return value is -1 then an error has occurred.
short CRPE_API PEGetNParameterDefaultValues (short printJob, 
                                             const char FAR * parameterFieldName, 
                                             const char FAR * reportName);

BOOL  CRPE_API PEGetNthParameterDefaultValue (short printJob, 
                                              const char FAR * parameterFieldName, 
                                              const char FAR * reportName, 
                                              short index, 
                                              PEValueInfo FAR * valueInfo);

BOOL  CRPE_API PESetNthParameterDefaultValue (short printJob, 
                                              const char FAR * parameterFieldName, 
                                              const char FAR * reportName, 
                                              short index, PEValueInfo FAR * valueInfo);

BOOL  CRPE_API PEAddParameterDefaultValue (short printJob, 
                                           const char FAR * parameterFieldName, 
                                           const char FAR * reportName, 
                                           PEValueInfo FAR * valueInfo);

BOOL  CRPE_API PEDeleteNthParameterDefaultValue (short printJob, 
                                                 const char FAR * parameterFieldName, 
                                                 const char FAR * reportName, 
                                                 short index);

// Min/Max values for Parameter fields.
// ////////////////////////////////////
BOOL  CRPE_API PEGetParameterMinMaxValue (short printJob, 
                                          const char FAR * parameterFieldName,
                                          const char FAR * reportName,
                                          PEValueInfo FAR * valueMin, // Set to NULL to retrieve MAX only; must be non-NULL if valueMax is NULL.
                                          PEValueInfo FAR * valueMax  // Set to NULL to retrieve MIN only; must be non-NULL if valueMin is NULL.
                                          );
BOOL  CRPE_API PESetParameterMinMaxValue (short printJob, 
                                          const char FAR * parameterFieldName,
                                          const char FAR * reportName,
                                          PEValueInfo FAR * valueMin, // Set to NULL to set MAX only; must be non-NULL if valueMax is NULL.
                                          PEValueInfo FAR * valueMax  // Set to NULL to set MIN only; must be non-NULL if valueMin is NULL.
                                                                        // If both valueInfo and valueMax are non-NULL then
                                                                        // valueMin->valueType MUST BE THE SAME AS valueMax->valueType.
                                                                        // If different, PE_ERR_INCONSISTANTTYPES is returned.
                                          );
// Pick list options in Parameter fields.
// //////////////////////////////////////
BOOL CRPE_API PEGetNthParameterValueDescription (short printJob, const char FAR * parameterFieldName,
                                                 const char FAR * reportName, short index, HANDLE FAR * valueDesc,
                                                 short FAR *valueDescLength);
BOOL CRPE_API PESetNthParameterValueDescription (short printJob, const char FAR * parameterFieldName,
                                                 const char FAR * reportName, short index, char FAR * valueDesc);

// constants for sortMethod in PEParameterPickListOption struct
#define PE_OR_NO_SORT                   0
#define PE_OR_ALPHANUMERIC_ASCENDING    1
#define PE_OR_ALPHANUMERIC_DESCENDING   2
#define PE_OR_NUMERIC_ASCENDING         3
#define PE_OR_NUMERIC_DESCENDING        4

typedef struct PEParameterPickListOption
{
    WORD  StructSize;       // initialize to PE_SIZEOF_PICK_LIST_OPTION
    short showDescOnly;     // boolean value or PE_UNCHANGED
    short sortMethod;       // enum type const, PE_UNCHANGED for no change
    short sortBasedOnDesc;  // boolean value or PE_UNCHANGED
} PEParameterPickListOption;
#define PE_SIZEOF_PICK_LIST_OPTION (sizeof (PEParameterPickListOption))

BOOL CRPE_API PEGetParameterPickListOption (short printJob, const char FAR * parameterFieldName,
                                            const char FAR * reportName, PEParameterPickListOption FAR * pickListOption);
BOOL CRPE_API PESetParameterPickListOption (short printJob, const char FAR * parameterFieldName,
                                            const char FAR * reportName, PEParameterPickListOption FAR * pickListOption);

// Parameter current values
///////////////////////////
// parameter field origin
#define PE_PO_REPORT         0
#define PE_PO_STOREDPROC     1
#define PE_PO_QUERY          2

// range info
#define PE_RI_INCLUDEUPPERBOUND 1
#define PE_RI_INCLUDELOWERBOUND 2
#define PE_RI_NOUPPERBOUND      4
#define PE_RI_NOLOWERBOUND      8

#define PE_DR_HASRANGE              0
#define PE_DR_HASDISCRETE           1
#define PE_DR_HASDISCRETEANDRANGE   2

typedef struct PEParameterValueInfo {
    WORD StructSize;
    short isNullable;               // Boolean value or PE_UNCHANGED for no change.
    short disallowEditing;          // Boolean value or PE_UNCHANGED for no change.
    short allowMultipleValues;      // Boolean value or PE_UNCHANGED for no change.
    short hasDiscreteValues;        // int value or PE_UNCHANGED for no change.
                                    // 0 means has ranges, 1 means has discrete values
                                    // 2 means has discrete and ranged values
    short partOfGroup;              // Boolean value or PE_UNCHANGED for no change.
    short groupNum;                 // a group number or PE_UNCHANGED for no change.
    short mutuallyExclusiveGroup;   // Boolean value or PE_UNCHANGED for no change.
} PEParameterValueInfo;
#define PE_SIZEOF_PARAMETER_VALUE_INFO (sizeof (PEParameterValueInfo))

BOOL CRPE_API PEGetParameterValueInfo (short printJob, 
                                       const char FAR * parameterFieldName, 
                                       const char FAR * reportName, 
                                       PEParameterValueInfo FAR * valueInfo);

BOOL CRPE_API PESetParameterValueInfo (short printJob, 
                                       const char FAR * parameterFieldName,
                                       const char FAR * reportName, 
                                       PEParameterValueInfo FAR * valueInfo);

// If return value is -1 then an error has occurred.
short CRPE_API PEGetNParameterCurrentValues (short printJob, 
                                                      const char FAR * parameterFieldName, 
                                                      const char FAR * reportName);

BOOL CRPE_API PEGetNthParameterCurrentValue (short printJob, 
                                             const char FAR * parameterFieldName,
                                             const char FAR * reportName,
                                             short index,
                                             PEValueInfo FAR * currentValue);

BOOL CRPE_API PEAddParameterCurrentValue (short printJob, 
                                          const char FAR * parameterFieldName,
                                          const char FAR * reportName, 
                                          PEValueInfo FAR * currentValue);

// If return value is -1 then an error has occurred.
short CRPE_API PEGetNParameterCurrentRanges (short printJob, 
                                                      const char FAR * parameterFieldName, 
                                                      const char FAR * reportName);

BOOL CRPE_API PEGetNthParameterCurrentRange (short printJob, 
                                             const char FAR * parameterFieldName,
                                             const char FAR * reportName,
                                             short index,
                                             PEValueInfo FAR * rangeStart, 
                                             PEValueInfo FAR * rangeEnd,
											 short FAR * rangeInfo     // one or more PE_RI_* constants.
											);
										 

BOOL CRPE_API PEAddParameterCurrentRange (short printJob, 
                                          const char FAR * parameterFieldName,
                                          const char FAR * reportName,
                                          PEValueInfo FAR * rangeStart, 
                                          PEValueInfo FAR * rangeEnd,
										  short rangeInfo     // one or more PE_RI_* constants.
										 );

short CRPE_API PEGetNthParameterType (short printJob, short index); // returns PE_PO_* or -1 if index is invalid.

BOOL  CRPE_API PEClearParameterCurrentValuesAndRanges (short printJob, 
                                                       const char FAR * parameterFieldName, 
                                                       const char FAR * reportName);


/**********************************************/
// Adding, controlling sort order and group sort order
/**********************************************/

short CRPE_API PEGetNSortFields (short printJob);

BOOL CRPE_API PEGetNthSortField (short printJob,
                                 short sortFieldN,
                                 HANDLE FAR *nameHandle,
                                 short  FAR *nameLength,
                                 short  FAR *direction);

BOOL CRPE_API PESetNthSortField (short printJob,
                                 short sortFieldN,
                                 const char FAR *name, // formula form
                                 short direction);  // a PE_SF_ constant

BOOL CRPE_API PEDeleteNthSortField (short printJob,
                                    short sortFieldN);

short CRPE_API PEGetNGroupSortFields (short printJob);

BOOL CRPE_API PEGetNthGroupSortField (short printJob,
                                      short sortFieldN,
                                      HANDLE FAR *nameHandle,
                                      short  FAR *nameLength,
                                      short  FAR *direction); // a PE_SF_ constant

BOOL CRPE_API PESetNthGroupSortField (short printJob,
                                      short sortFieldN,
                                      const char FAR *name,
                                      short direction);

BOOL CRPE_API PEDeleteNthGroupSortField (short printJob,
                                         short sortFieldN);

/********************************************/
// Controlling databases
/********************************************/

// The following functions allow retrieving and updating database info
// in an opened report, so that a report can be printed using different
// session, server, database, user and/or table location settings.  Any
// changes made to the report via these functions are not permanent, and
// only last as long as the report is open.
//
// The following database functions (except for PELogOnServer and
// PELogOffServer) must be called after PEOpenPrintJob and before
// PEStartPrintJob.

// The function PEGetNTables is called to fetch the number of tables in
// the report.  This includes all PC databases (e.g. Paradox, xBase)
// as well as SQL databases (e.g. SQL Server, Oracle, Netware).

short CRPE_API PEGetNTables (short printJob);


// The function PEGetNthTableType allows the application to determine the
// type of each table.  The application can test DBType (equal to
// PE_DT_STANDARD or PE_DT_SQL), or test the database DLL name used to
// create the report.  DLL names have the following naming convention:
//     - PDB*.DLL for standard (non-SQL) databases,
//     - PDS*.DLL for SQL databases.
//
// In the case of ODBC (PDSODBC.DLL) the DescriptiveName includes the
// ODBC data source name.

#define PE_WORD_LEN          2
#define PE_DLL_NAME_LEN      64
#define PE_FULL_NAME_LEN     256

#define PE_DT_STANDARD               1
#define PE_DT_SQL                    2
#define PE_DT_SQL_STORED_PROCEDURE   3

typedef struct PETableType
{
    // Initialize to PE_SIZEOF_TABLE_TYPE.
    WORD StructSize;

    // All strings are null-terminated.
    char DLLName [PE_DLL_NAME_LEN];
    char DescriptiveName [PE_FULL_NAME_LEN];

    WORD DBType;
}PETableType;
#define PE_SIZEOF_TABLE_TYPE (sizeof (PETableType))


BOOL  CRPE_API PEGetNthTableType (short printJob,
                                  short tableN,
                                  PETableType FAR *tableType);


// The functions PEGetNthTableSessionInfo and PESetNthTableSessionInfo
// are only used when connecting to MS Access databases (which require a
// session to be opened first)

#define PE_LONGPTR_LEN       4
#define PE_SESS_USERID_LEN   128
#define PE_SESS_PASSWORD_LEN 128

typedef struct PESessionInfo
{
    // Initialize to PE_SIZEOF_SESSION_INFO.
    WORD StructSize;

    // All strings are null-terminated.
    char UserID [PE_SESS_PASSWORD_LEN];

    // Password is undefined when getting information from report.
    char Password [PE_SESS_PASSWORD_LEN];

    // SessionHandle is undefined when getting information from report.
    // When setting information, if it is = 0 the UserID and Password
    // settings are used, otherwise the SessionHandle is used.
    DWORD SessionHandle;
}
    PESessionInfo;
#define PE_SIZEOF_SESSION_INFO (sizeof (PESessionInfo))


BOOL  CRPE_API PEGetNthTableSessionInfo (short printJob,
                                         short tableN,
                                         PESessionInfo FAR *sessionInfo);
BOOL  CRPE_API PESetNthTableSessionInfo (short printJob,
                                         short tableN,
                                         PESessionInfo FAR *sessionInfo,
                                         BOOL propagateAcrossTables);


// Logging on is performed when printing the report, but the correct
// log on information must first be set using PESetNthTableLogOnInfo.
// Only the password is required, but the server, database, and
// user names may optionally be overriden as well.
//
// If the parameter propagateAcrossTables is TRUE, the new log on info
// is also applied to any other tables in this report that had the
// same original server and database names as this table.  If FALSE
// only this table is updated.
//
// Logging off is performed automatically when the print job is closed

#define PE_SERVERNAME_LEN    128
#define PE_DATABASENAME_LEN  128
#define PE_USERID_LEN        128
#define PE_PASSWORD_LEN      128

typedef struct PELogOnInfo
{
    // Initialize to PE_SIZEOF_LOGON_INFO.
    WORD StructSize;

    // For any of the following values an empty string ("") means to use
    // the value already set in the report.  To override a value in the
    // report use a non-empty string (e.g. "Server A").  All strings are
    // null-terminated.
    //
    // For Netware SQL, pass the dictionary path name in ServerName and
    // data path name in DatabaseName.
    char ServerName [PE_SERVERNAME_LEN];
    char DatabaseName [PE_DATABASENAME_LEN];
    char UserID [PE_USERID_LEN];

    // Password is undefined when getting information from report.
    char Password [PE_PASSWORD_LEN];
}PELogOnInfo;
#define PE_SIZEOF_LOGON_INFO (sizeof (PELogOnInfo))

BOOL  CRPE_API PEGetNthTableLogOnInfo (short printJob,
                                       short tableN,
                                       PELogOnInfo FAR *logOnInfo);
BOOL  CRPE_API PESetNthTableLogOnInfo (short printJob,
                                       short tableN,
                                       PELogOnInfo FAR *logOnInfo,
                                       BOOL propagateAcrossTables);


// A table's location is fetched and set using PEGetNthTableLocation and
// PESetNthTableLocation.  This name is database-dependent, and must be
// formatted correctly for the expected database.  For example:
//     - Paradox: "c:\crw\ORDERS.DB"
//     - SQL Server: "publications.dbo.authors"

#define PE_TABLE_LOCATION_LEN      256
#define PE_CONNECTION_BUFFER_LEN   512

typedef struct PETableLocation
{
    // Initialize to PE_SIZEOF_TABLE_LOCATION.
    WORD StructSize;

    // String is null-terminated.
    char Location [PE_TABLE_LOCATION_LEN];
    char SubLocation[PE_TABLE_LOCATION_LEN];
    char ConnectBuffer[PE_CONNECTION_BUFFER_LEN];    //Connection Info for attached tables
}PETableLocation;
#define PE_SIZEOF_TABLE_LOCATION (sizeof (PETableLocation))

BOOL  CRPE_API PEGetNthTableLocation (short printJob,
                                      short tableN,
                                      PETableLocation FAR *location);
BOOL  CRPE_API PESetNthTableLocation (short printJob,
                                      short tableN,
                                      PETableLocation FAR *location);
// Table Private Info

typedef struct PETablePrivateInfo
{
    WORD StructSize;  // initialize to PE_SIZEOF_TABLE_PRIVATE_INFO
    WORD nBytes;
    DWORD tag;
    BYTE FAR * dataPtr;
} PETablePrivateInfo;
#define PE_SIZEOF_TABLE_PRIVATE_INFO (sizeof(PETablePrivateInfo))


BOOL CRPE_API PEGetNthTablePrivateInfo (short printJob,
                                        short tableN,
                                        PETablePrivateInfo FAR *privateInfo);

BOOL CRPE_API PESetNthTablePrivateInfo (short printJob,
                                        short tableN,
                                        PETablePrivateInfo FAR *privateInfo);


// The function PETestNthTableConnectivity tests whether a database
// table's settings are valid and ready to be reported on.  It returns
// true if the database session, log on, and location info is all
// correct.
//
// This is useful, for example, in prompting the user and testing a
// server password before printing begins.
//
// This function may require a significant amount of time to complete,
// since it will first open a user session (if required), then log onto
// the database server (if required), and then open the appropriate
// database table (to test that it exists).  It does not read any data,
// and closes the table immediately once successful.  Logging off is
// performed when the print job is closed.
//
// If it fails in any of these steps, the error code set indicates
// which database info needs to be updated using functions above:
//    - If it is unable to begin a session, PE_ERR_DATABASESESSION is set,
//      and the application should update with PESetNthTableSessionInfo.
//    - If it is unable to log onto a server, PE_ERR_DATABASELOGON is set,
//      and the application should update with PESetNthTableLogOnInfo.
//    - If it is unable open the table, PE_ERR_DATABASELOCATION is set,
//      and the application should update with PESetNthTableLocation.

BOOL  CRPE_API PETestNthTableConnectivity (short printJob,
                                           short tableN);


// PELogOnServer and PELogOffServer can be called at any time to log on
// and off of a database server.  These functions are not required if
// function PESetNthTableLogOnInfo above was already used to set the
// password for a table.
//
// These functions require a database DLL name, which can be retrieved
// using PEGetNthTableType above.
//
// This function can also be used for non-SQL tables, such as password-
// protected Paradox tables.  Call this function to set the password
// for the Paradox DLL before beginning printing.
//
// Note: When printing using PEStartPrintJob the ServerName passed in
// PELogOnServer must agree exactly with the server name stored in the
// report.  If this is not true use PESetNthTableLogOnInfo to perform
// logging on instead.

BOOL CRPE_API PELogOnServer (const char FAR *dllName,
                             PELogOnInfo FAR *logOnInfo);
BOOL CRPE_API PELogOffServer (const char FAR *dllName,
                              PELogOnInfo FAR *logOnInfo);

BOOL CRPE_API PELogOnSQLServerWithPrivateInfo (const char FAR *dllName,
                                               void FAR *privateInfo);


/***************************************/
// Overriding SQL query in report
/***************************************/
//
// PEGetSQLQuery () returns the same query as appears in the Show SQL Query
// dialog in CRW, in syntax specific to the database driver you are using.
//
// PESetSQLQuery () is mostly useful for reports with SQL queries that
// were explicitly edited in the Show SQL Query dialog in CRW, i.e. those
// reports that needed database-specific selection criteria or joins.
// (Otherwise it is usually best to continue using function calls such as
// PESetSelectionFormula () and let CRW build the SQL query automatically.)
//
// PESetSQLQuery () has the same restrictions as editing in the Show SQL
// Query dialog; in particular that changes are accepted in the FROM and
// WHERE clauses but ignored in the SELECT list of fields.

BOOL CRPE_API PEGetSQLQuery (short printJob,
                             HANDLE FAR *textHandle,
                             short  FAR *textLength);

BOOL CRPE_API PESetSQLQuery (short printJob,
                             const char FAR *queryString);

BOOL CRPE_API PEVerifyDatabase(short printJob);
// constants returned from PECheckNthTableDifferences, can be any
// combination of the following:
#define PE_TCD_OKAY                          0x00000000
#define PE_TCD_DATABASENOTFOUND              0x00000001
#define PE_TCD_SERVERNOTFOUND                0x00000002
#define PE_TCD_SERVERNOTOPENED               0x00000004
#define PE_TCD_ALIASCHANGED                  0x00000008
#define PE_TCD_INDEXESCHANGED                0x00000010
#define PE_TCD_DRIVERCHANGED                 0x00000020
#define PE_TCD_DICTIONARYCHANGED             0x00000040
#define PE_TCD_FILETYPECHANGED               0x00000080
#define PE_TCD_RECORDSIZECHANGED             0x00000100
#define PE_TCD_ACCESSCHANGED                 0x00000200
#define PE_TCD_PARAMETERSCHANGED             0x00000400
#define PE_TCD_LOCATIONCHANGED               0x00000800
#define PE_TCD_DATABASEOTHER                 0x00001000
#define PE_TCD_NUMFIELDSCHANGED              0x00010000
#define PE_TCD_FIELDOTHER                    0x00020000
#define PE_TCD_FIELDNAMECHANGED              0x00040000
#define PE_TCD_FIELDDESCCHANGED              0x00080000
#define PE_TCD_FIELDTYPECHANGED              0x00100000
#define PE_TCD_FIELDSIZECHANGED              0x00200000
#define PE_TCD_NATIVEFIELDTYPECHANGED        0x00400000
#define PE_TCD_NATIVEFIELDOFFSETCHANGED      0x00800000
#define PE_TCD_NATIVEFIELDSIZECHANGED        0x01000000
#define PE_TCD_FIELDDECPLACESCHANGED         0x02000000

typedef struct PETableDifferenceInfo
{
    WORD StructSize;
    DWORD tableDifferences;                 // any combination of PE_TCD_*
    DWORD reserved1;                        // reserved - do not use
    DWORD reserved2;                        // reserved - do not use
} PETableDifferenceInfo;

#define PE_SIZEOF_TABLE_DIFFERENCE_INFO (sizeof (PETableDifferenceInfo))

// Not implemented for reports based on dictionary returns PE_ERR_NOTIMPLEMENTED
BOOL CRPE_API PECheckNthTableDifferences (short printJob, short tableN, PETableDifferenceInfo FAR *tabledifferenceinfo);

/*******************************/
// Saved data
/*******************************/
//
// Use PEHasSavedData() to find out if a report currently has saved data
// associated with it.  This may or may not be TRUE when a print job is
// first opened from a report file.  Since data is saved during a print,
// this will always be TRUE immediately after a report is printed.
//
// Use PEDiscardSavedData() to release the saved data associated with a
// report.  The next time the report is printed, it will get current data
// from the database.
//
// The default behavior is for a report to use its saved data, rather than
// refresh its data from the database when printing a report.

BOOL CRPE_API PEHasSavedData (short printJob,
                              BOOL FAR *hasSavedData);
BOOL CRPE_API PEDiscardSavedData (short printJob);

/*************************/
// Report title
/*************************/

BOOL CRPE_API PEGetReportTitle (short printJob,
                                HANDLE FAR *titleHandle,
                                short  FAR *titleLength);
BOOL CRPE_API PESetReportTitle (short printJob,
                                const char FAR *title);


/*************************************/
// Controlling print to window
/*************************************/

BOOL CRPE_API PEOutputToWindow (short printJob,
                                const char FAR *title,
                                int left,
                                int top,
                                int width,
                                int height,
                                DWORD style,
                                HWND parentWindow);

typedef struct PEWindowOptions
{
    WORD StructSize;                // initialize to PE_SIZEOF_WINDOW_OPTIONS

    short hasGroupTree;             // BOOL value, except use PE_UNCHANGED for no change
    short canDrillDown;             // BOOL value, except use PE_UNCHANGED for no change
    short hasNavigationControls;    // BOOL value, except use PE_UNCHANGED for no change
    short hasCancelButton;          // BOOL value, except use PE_UNCHANGED for no change
    short hasPrintButton;           // BOOL value, except use PE_UNCHANGED for no change
    short hasExportButton;          // BOOL value, except use PE_UNCHANGED for no change
    short hasZoomControl;           // BOOL value, except use PE_UNCHANGED for no change
    short hasCloseButton;           // BOOL value, except use PE_UNCHANGED for no change
    short hasProgressControls;      // BOOL value, except use PE_UNCHANGED for no change
    short hasSearchButton;          // BOOL value, except use PE_UNCHANGED for no change
    short hasPrintSetupButton;      // BOOL value, except use PE_UNCHANGED for no change
    short hasRefreshButton;         // BOOL value, except use PE_UNCHANGED for no change
    short showToolbarTips;          // BOOL value, except use PE_UNCHANGED for no change
                                    //      default is TRUE (*Show* tooltips on toolbar)
    short showDocumentTips;         // BOOL value, except use PE_UNCHANGED for no change
                                    //      default is FALSE (*Hide* tooltips on document)
    short hasLaunchButton;          // Launch Seagate Analysis button on toolbar.
                                    // BOOL value, except use PE_UNCHANGED for no change
                                    //      default is FALSE
}
    PEWindowOptions;

#define PE_SIZEOF_WINDOW_OPTIONS (sizeof (PEWindowOptions))

BOOL CRPE_API PESetWindowOptions (short printJob,
                                  PEWindowOptions FAR *options);

BOOL CRPE_API PEGetWindowOptions (short printJob,
                                  PEWindowOptions FAR *options);

HWND CRPE_API PEGetWindowHandle (short printJob);

void CRPE_API PECloseWindow (short printJob);


/***********************************/
// Controlling printed pages
/*************************************/

BOOL CRPE_API PEShowNextPage (short printJob);
BOOL CRPE_API PEShowFirstPage (short printJob);
BOOL CRPE_API PEShowPreviousPage (short printJob);
BOOL CRPE_API PEShowLastPage (short printJob);
short CRPE_API PEGetNPages (short printJob);
BOOL CRPE_API PEShowNthPage (short printJob,
                             short pageN); // start from 1

#define PE_ZOOM_FULL_SIZE           0
#define PE_ZOOM_SIZE_FIT_ONE_SIDE   1
#define PE_ZOOM_SIZE_FIT_BOTH_SIDES 2

BOOL CRPE_API PEZoomPreviewWindow (short printJob,
                                   short level); // a percent from 25 to 400
                                                 // or a PE_ZOOM_ constant

/*************************************************************/
// Controlling print window when print control buttons hidden
/*************************************************************/

BOOL CRPE_API PEShowPrintControls (short printJob,
                                   BOOL showPrintControls);
BOOL CRPE_API PEPrintControlsShowing (short printJob,
                                      BOOL FAR *controlsShowing);

BOOL CRPE_API PEPrintWindow (short printJob,
                             BOOL waitUntilDone);

BOOL CRPE_API PEExportPrintWindow (short printJob,
                                   BOOL toMail,
                                   BOOL waitUntilDone);

BOOL CRPE_API PENextPrintWindowMagnification (short printJob);


/********************************/
// Changing printer selection
/********************************/
BOOL CRPE_API PESelectPrinter (short printJob,
                               const char FAR *driverName,
                               const char FAR *printerName,
                               const char FAR *portName,
                               DEVMODEA FAR *mode
                               );

BOOL CRPE_API PEGetSelectedPrinter (short printJob,
                                    HANDLE  FAR *driverHandle,
                                    short   FAR *driverLength,
                                    HANDLE  FAR *printerHandle,
                                    short   FAR *printerLength,
                                    HANDLE  FAR *portHandle,
                                    short   FAR *portLength,
                                    DEVMODEA FAR * FAR *mode
                                    );
BOOL CRPE_API PEFreeDevMode (short printJob, DEVMODEA FAR * mode);


/*********************************/
// Controlling print to printer
/*********************************/

BOOL CRPE_API PEOutputToPrinter (short printJob,
                                 short nCopies);

BOOL CRPE_API PESetNDetailCopies (short printJob,
                                  short nDetailCopies);

BOOL CRPE_API PEGetNDetailCopies (short printJob,
                                  short FAR *nDetailCopies);

// Extension to PESetPrintOptions function: If the 2nd parameter
// (pointer to PEPrintOptions) is set to 0 (null) the function prompts
// the user for these options.
//
// With this change, you can get the behaviour of the print-to-printer
// button in the print window by calling PESetPrintOptions with a
// null pointer and then calling PEPrintWindow.

#define PE_MAXPAGEN  65535

#define PE_FILE_PATH_LEN     512

#define PE_UNCOLLATED       0
#define PE_COLLATED         1
#define PE_DEFAULTCOLLATION 2

typedef struct PEPrintOptions
{
    WORD StructSize;            // initialize to PE_SIZEOF_PRINT_OPTIONS

    // page and copy numbers are 1-origin
    // use 0 to preserve the existing settings
    unsigned short startPageN,
                   stopPageN;

    unsigned short nReportCopies;
    unsigned short collation;

    char outputFileName[PE_FILE_PATH_LEN];
}
    PEPrintOptions;
#define PE_SIZEOF_PRINT_OPTIONS (sizeof (PEPrintOptions))

BOOL CRPE_API PESetPrintOptions (short printJob,
                                 PEPrintOptions FAR *options);

BOOL CRPE_API PEGetPrintOptions (short printJob,
                                 PEPrintOptions FAR *options);

/************************/
// Controlling print to file and export
/************************/

typedef struct PEExportOptions
{
    WORD StructSize;               // initialize to PE_SIZEOF_EXPORT_OPTIONS

    char formatDLLName [PE_DLL_NAME_LEN];
    DWORD formatType;
    void FAR *formatOptions;
    char destinationDLLName [PE_DLL_NAME_LEN];
    DWORD destinationType;
    void FAR *destinationOptions;
    WORD nFormatOptionsBytes;      // Set by 'PEGetExportOptions'
                                   // ignored by 'PEExportTo'.
    WORD nDestinationOptionsBytes; // Set by 'PEGetExportOptions'
                                   // ignored by 'PEExportTo'.
}
    PEExportOptions;
#define PE_SIZEOF_EXPORT_OPTIONS (sizeof (PEExportOptions))

BOOL CRPE_API PEGetExportOptions (short printJob,
                                  PEExportOptions FAR *options);

BOOL CRPE_API PEExportTo (short printJob,
                          PEExportOptions FAR *options);


/************************/
// Setting page margins
/************************/

#define PE_SM_DEFAULT  (short)0x8000

BOOL CRPE_API PESetMargins (short printJob,
                            short left,
                            short right,
                            short top,
                            short bottom);

BOOL CRPE_API PEGetMargins (short printJob,
                            short FAR *left,
                            short FAR *right,
                            short FAR *top,
                            short FAR *bottom);



#define PE_SI_APPLICATION_NAME_LEN  128
#define PE_SI_TITLE_LEN 128
#define PE_SI_SUBJECT_LEN 128
#define PE_SI_AUTHOR_LEN 128
#define PE_SI_KEYWORDS_LEN 128
#define PE_SI_COMMENTS_LEN 512
#define PE_SI_REPORT_TEMPLATE_LEN 128

typedef struct PEReportSummaryInfo
{
    WORD StructSize;
    char applicationName[PE_SI_APPLICATION_NAME_LEN]; // read only.
    char title[PE_SI_TITLE_LEN];
    char subject[PE_SI_SUBJECT_LEN];
    char author[PE_SI_AUTHOR_LEN];
    char keywords[PE_SI_KEYWORDS_LEN];
    char comments[PE_SI_COMMENTS_LEN];
    char reportTemplate[PE_SI_REPORT_TEMPLATE_LEN];
    short savePreviewPicture; // BOOL PE_UNCHANGED for no change
} PEReportSummaryInfo;

#define PE_SIZEOF_REPORT_SUMMARY_INFO (sizeof(PEReportSummaryInfo))
BOOL CRPE_API PEGetReportSummaryInfo(short printJob, PEReportSummaryInfo FAR * summaryInfo);
BOOL CRPE_API PESetReportSummaryInfo(short printJob, PEReportSummaryInfo FAR * summaryInfo);


/************************************************/
// Event support
/***************************************************/
// event ID
#define PE_CLOSE_PRINT_WINDOW_EVENT           1
#define PE_ACTIVATE_PRINT_WINDOW_EVENT        2
#define PE_DEACTIVATE_PRINT_WINDOW_EVENT      3
#define PE_PRINT_BUTTON_CLICKED_EVENT         4
#define PE_EXPORT_BUTTON_CLICKED_EVENT        5
#define PE_ZOOM_LEVEL_CHANGING_EVENT          6
#define PE_FIRST_PAGE_BUTTON_CLICKED_EVENT    7
#define PE_PREVIOUS_PAGE_BUTTON_CLICKED_EVENT 8
#define PE_NEXT_PAGE_BUTTON_CLICKED_EVENT     9
#define PE_LAST_PAGE_BUTTON_CLICKED_EVENT     10
#define PE_CANCEL_BUTTON_CLICKED_EVENT        11
#define PE_CLOSE_BUTTON_CLICKED_EVENT         12
#define PE_SEARCH_BUTTON_CLICKED_EVENT        13
#define PE_GROUP_TREE_BUTTON_CLICKED_EVENT    14
#define PE_PRINT_SETUP_BUTTON_CLICKED_EVENT   15
#define PE_REFRESH_BUTTON_CLICKED_EVENT       16
#define PE_SHOW_GROUP_EVENT                   17
#define PE_DRILL_ON_GROUP_EVENT               18 // include drill on graph
#define PE_DRILL_ON_DETAIL_EVENT              19
#define PE_READING_RECORDS_EVENT              20
#define PE_START_EVENT                        21
#define PE_STOP_EVENT                         22
#define PE_MAPPING_FIELD_EVENT                23
#define PE_RIGHT_CLICK_EVENT                  24 // right mouse click
#define PE_LEFT_CLICK_EVENT                   25 // left mouse click
#define PE_MIDDLE_CLICK_EVENT                 26 // middle mouse click
#define PE_DRILL_ON_HYPERLINK_EVENT           27
#define PE_LAUNCH_SEAGATE_ANALYSIS_EVENT      28

// job destination
#define PE_TO_NOWHERE                   0
#define	PE_TO_WINDOW                    1
#define PE_TO_PRINTER                   2
#define PE_TO_EXPORT                    3
#define PE_FROM_QUERY                   4

// mouse click action
#define PE_MOUSE_NOTSUPPORTED   0
#define PE_MOUSE_DOWN           1
#define PE_MOUSE_UP             2
#define PE_MOUSE_DOUBLE_CLICK   3

// mouse click flags (virtual key state-masks)
#define PE_CF_NONE       0x0000
#define PE_CF_LBUTTON    0x0001
#define PE_CF_RBUTTON    0x0002
#define PE_CF_SHIFTKEY   0x0004
#define PE_CF_CONTROLKEY 0x0008
#define PE_CF_MBUTTON    0x0010

// for PE_*_CLICK_EVENT
typedef struct PEMouseClickEventInfo
{
        WORD StructSize;
        long windowHandle;
        UINT clickAction;           // one of PE_MOUSE_*
        UINT clickFlags;            // any combination of PE_CF_*
        int xOffset;                // x-coordinate of mouse click in pixels
        int yOffset;                // y-coordinate of mouse click in pixels
        PEValueInfo fieldValue;     // value of object at click point if it is a field
                                    // object, excluding MEMO and BLOB fields,
                                    // else valueType element = PE_VI_NOVALUE.
        DWORD objectHandle;         // the design view object
        short sectionCode;          // section in which click occurred.
} PEMouseClickEventInfo;
#define PE_SIZEOF_MOUSE_CLICK_EVENT_INFO (sizeof(PEMouseClickEventInfo))

// for PE_START_EVENT
typedef struct PEStartEventInfo
{
	WORD StructSize;
	WORD destination; 	// a job destination constant.
} PEStartEventInfo;
#define PE_SIZEOF_START_EVENT_INFO (sizeof(PEStartEventInfo))

// for PE_STOP_EVENT
typedef struct PEStopEventInfo
{
	WORD StructSize;
	WORD destination; 	// a job destination constant.
	WORD jobStatus; 	// a PE_JOB constant 
} PEStopEventInfo;
#define PE_SIZEOF_STOP_EVENT_INFO (sizeof(PEStopEventInfo))

// for PE_READING_RECORDS_EVENT
typedef struct PEReadingRecordsEventInfo
{
	WORD StructSize;
	short cancelled;        // BOOL value. 
	long recordsRead;
	long recordsSelected;
	short done;		// BOOL value.
} PEReadingRecordsEventInfo;

#define PE_SIZEOF_READING_RECORDS_EVENT_INFO (sizeof(PEReadingRecordsEventInfo))

// use this structure for 
// PE_CLOSE_PRINT_WINDOW_EVENT
// PE_PRINT_BUTTON_CLICKED_EVENT
// PE_EXPORT_BUTTON_CLICKED_EVENT
// PE_FIRST_PAGE_BUTTON_CLICKED_EVENT
// PE_PREVIOUS_PAGE_BUTTON_CLICKED_EVENT
// PE_NEXT_PAGE_BUTTON_CLICKED_EVENT
// PE_LAST_PAGE_BUTTON_CLICKED_EVENT
// PE_CANCEL_BUTTON_CLICKED_EVENT
// PE_PRINT_SETUP_BUTTON_CLICKED_EVENT
// PE_REFRESH_BUTTON_CLICKED_EVENT
// PE_ACTIVATE_PRINT_WINDOW_EVENT
// PE_DEACTIVATE_PRINT_WINDOW_EVENT
typedef struct PEGeneralPrintWindowEventInfo
{
	WORD StructSize;
	WORD ignored; // for 4 byte alignment. ignore.
	long windowHandle; // HWND
} PEGeneralPrintWindowEventInfo;

#define PE_SIZEOF_GENERAL_PRINT_WINDOW_EVENT_INFO (sizeof(PEGeneralPrintWindowEventInfo))

// for PE_ZOOM_CONTROL_SELECTED_EVENT
typedef struct PEZoomLevelChangingEventInfo
{
	WORD StructSize;
	WORD zoomLevel;
	long windowHandle;
} PEZoomLevelChaningEventInfo;

#define PE_SIZEOF_ZOOM_LEVEL_CHANGING_EVENT_INFO (sizeof (PEZoomLevelChangingEventInfo))

// for PE_CLOSE_BUTTON_CLICKED_EVENT
typedef struct PECloseButtonClickedEventInfo
{
	WORD StructSize;
	WORD viewIndex; // which view is going to be closed. start from zero.
	long windowHandle; // frame window handle the button is on.
} PECloseButtonClickedEventInfo;
#define PE_SIZEOF_CLOSE_BUTTON_CLICKED_EVENT_INFO (sizeof(PECloseButtonClickedEventInfo))

//for PE_SEARCH_BUTTON_CLICKED_EVENT
#define PE_SEARCH_STRING_LEN   128
typedef struct PESearchButtonClickedEventInfo
{
	long windowHandle;
	char searchString[PE_SEARCH_STRING_LEN];
	WORD StructSize;
} PESearchButtonClickedEventInfo;
#define PE_SIZEOF_SEARCH_BUTTON_CLICKED_EVENT_INFO (sizeof(PESearchButtonClickedEventInfo))

//for PE_GROUPTREE_BUTTON_CLICKED_EVENT
typedef struct PEGroupTreeButtonClickedEventInfo
{
	WORD StructSize;
	short visible; // BOOL value. current state of the group tree button
	long windowHandle;
}PEGroupTreeButtonClickedEventInfo;

#define PE_SIZEOF_GROUP_TREE_BUTTON_CLICKED_EVENT_INFO (sizeof(PEGroupTreeButtonClickedEventInfo))

//for PE_SHOW_GROUP_EVENT
typedef struct PEShowGroupEventInfo
{
	WORD StructSize;
	WORD groupLevel;
	long windowHandle;
	char **groupList;	// points to an array of group names.
						// memory pointed by group list is freed after calling the call back function.
} PEShowGroupEventInfo;
#define PE_SIZEOF_SHOW_GROUP_EVENT_INFO (sizeof(PEShowGroupEventInfo))

//For PE_DRILL_ON_GROUP_EVENT
#define PE_DE_ON_GROUP       0
#define PE_DE_ON_GROUPTREE   1
#define PE_DE_ON_GRAPH       2
#define PE_DE_ON_MAP         3
#define PE_DE_ON_SUBREPORT   4

typedef struct PEDrillOnGroupEventInfo
{
	WORD StructSize;
	WORD drillType; // a PE_DE_ constant
	long windowHandle;
	char **groupList;	// points to an array of group names for drillOnGroup, drillOnGroupTree, drillOnGraph, drillOnMap
						// points to an array with one element, the subreport name, for drillOnSubreport.
						// memory pointed by group list is freed after calling the call back function.
	WORD groupLevel;
}PEDrillOnGroupEventInfo;
#define PE_SIZEOF_DRILL_ON_GROUP_EVENT_INFO (sizeof(PEDrillOnGroupEventInfo))

// for PE_DRILL_ON_DETAIL_EVENT
typedef struct PEFieldValueInfo
{
	WORD StructSize;
	WORD ignored; // for 4 byte alignment. ignore.
	char fieldName[PE_FIELD_NAME_LEN];
	PEValueInfo fieldValue;
} PEFieldValueInfo;
#define PE_SIZEOF_FIELD_VALUE_INFO (sizeof(PEFieldValueInfo))

typedef struct PEDrillOnDetailEventInfo
{
	WORD StructSize;
	short selectedFieldIndex; // -1 if no field selected
	long windowHandle;
	// points to an array of PEFieldValueInfo. memory pointed by fieldValueList is freed after calling the call
	// back function.
	struct PEFieldValueInfo ** fieldValueList;
	short nFieldValue; // number of field value in fieldValueList
} PEDrillOnDetailEventInfo;
#define PE_SIZEOF_DRILL_ON_DETAIL_EVENT_INFO (sizeof(PEDrillOnDetailEventInfo))

/* -------------------------------------------------------------------------*/

#define PE_TABLE_NAME_LEN 128
#define PE_DATABASE_FIELD_NAME_LEN  128

// Field value type
#define PE_FVT_INT8SFIELD            1
#define PE_FVT_INT8UFIELD            2
#define PE_FVT_INT16SFIELD           3
#define PE_FVT_INT16UFIELD           4
#define PE_FVT_INT32SFIELD           5
#define PE_FVT_INT32UFIELD           6
#define PE_FVT_NUMBERFIELD           7
#define PE_FVT_CURRENCYFIELD         8
#define PE_FVT_BOOLEANFIELD          9
#define PE_FVT_DATEFIELD             10
#define PE_FVT_TIMEFIELD             11
#define PE_FVT_STRINGFIELD           12
#define PE_FVT_TRANSIENTMEMOFIELD    13
#define PE_FVT_PERSISTENTMEMOFIELD   14
#define PE_FVT_BLOBFIELD             15
#define PE_FVT_DATETIMEFIELD         16
#define PE_FVT_BITMAPFIELD           17
#define PE_FVT_ICONFIELD             18
#define PE_FVT_PICTUREFIELD          19
#define PE_FVT_OLEFIELD              20
#define PE_FVT_GRAPHFIELD            21
#define PE_FVT_UNKNOWNFIELD          22

// Field mapping types
#define PE_FM_AUTO_FLD_MAP          0   //Automatic field name mapping
                                        //NOTE : unmapped report fields will be removed
#define PE_FM_CRPE_PROMPT_FLD_MAP   1   //CRPE provides dialog box to map field manually
#define PE_FM_EVENT_DEFINED_FLD_MAP 2   //CRPE provides list of field in report and new database
                                        //User needs to activate the PE_MAPPING_FIELD_EVENT
                                        //and define a callback function

BOOL CRPE_API PESetFieldMappingType(short printJob,
                                    WORD mappingType  //use PE_FM_ constant
                                    );   

BOOL CRPE_API PEGetFieldMappingType(short printJob,
                                    WORD FAR * mappingType //use PE_FM_ constant
                                    );

typedef struct PEReportFieldMappingInfo
{
    WORD StructSize;
    WORD valueType; // a PE_FVT_constant
    char tableAliasName[PE_TABLE_NAME_LEN];
    char databaseFieldName[PE_DATABASE_FIELD_NAME_LEN];
    int mappingTo;   //mapped fields are assigned to the index of a field
                      //in array PEFieldMappingEventInfo->databaseFields
                      //unmapped fields are assigned to -1
} PEReportFieldMappingInfo;
#define PE_SIZEOF_REPORT_FIELDMAPPING_INFO (sizeof(PEReportFieldMappingInfo))

typedef struct PEFieldMappingEventInfo
{
    WORD StructSize;

   PEReportFieldMappingInfo ** reportFields; //An array of pointers to the fields in the report.
                                            //User need to modify the 'mappingTo' of
                                            //each new mapped field by assigning the value
                                            //of the index of a field in the array
                                            //databaseFields.
   WORD nReportFields;                      //Size of array reportFields

   PEReportFieldMappingInfo ** databaseFields; //An array of pointers to the fields in the new database file
   WORD nDatabaseFields;                    //Size of array databaseField
} PEFieldMappingEventInfo;
#define PE_SIZEOF_FIELDMAPPING_EVENT_INFO (sizeof(PEFieldMappingEventInfo))

typedef struct PEHyperlinkEventInfo
{
    WORD StructSize;
    WORD ignored;               // for 4 byte alignment. ignore.
    long windowHandle;          // HWND
    char FAR *hyperlinkText;    // points to the hyperlink text associated with the object.
                                // memory pointed by hyperlinkText is freed after calling the callback function.
} PEHyperlinkEventInfo;

#define PE_SIZEOF_HYPERLINKEVENTINFO (sizeof (PEHyperlinkEventInfo))

typedef struct PELaunchSeagateAnalysisEventInfo
{
    WORD StructSize;
    WORD ignored;               // for 4 byte alignment. ignore.
    long windowHandle;          // HWND
    char FAR *pathFile;         // points to the path and filename of the temporary report.
                                // memory pointed by pathFile is freed after calling the callback function.
} PELaunchSeagateAnalysisEventInfo;

#define PE_SIZEOF_LAUNCH_SEAGATE_ANALYSIS_EVENT_INFO (sizeof (PELaunchSeagateAnalysisEventInfo))

// All events are disabled by default
// use PEEnableEvent to enable events.
typedef struct PEEnableEventInfo
{
	WORD StructSize;
	short startStopEvent; // BOOL value, PE_UNCHANGED for no change
	short readingRecordEvent; // BOOL value, PE_UNCHANGED for no change
	short printWindowButtonEvent; // BOOL value, PE_UNCHANGED for no change
	short drillEvent; // BOOL value, PE_UNCHANGED for no change
	short closePrintWindowEvent; // BOOL value, PE_UNCHANGED for no change
	short activatePrintWindowEvent; // BOOL value, PE_UNCHANGED for no change
	short fieldMappingEvent; // BOOL value, PE_UNCHANGED for no change.
	short mouseClickEvent; // BOOL value, PE_UNCHANGED for no change.
    short hyperlinkEvent;   // BOOL value, PE_UNCHANGED for no change.
    short launchSeagateAnalysisEvent;   // BOOL value, PE_UNCHANGED for no change.
} PEEnableEventInfo;

#define PE_SIZEOF_ENABLE_EVENT_INFO (sizeof(PEEnableEventInfo))

BOOL CRPE_API PEEnableEvent(short printJob, PEEnableEventInfo FAR * enableEventInfo);
BOOL CRPE_API PEGetEnableEventInfo(short printJob, PEEnableEventInfo FAR * enableEventInfo);

// Set callback function
BOOL CRPE_API PESetEventCallback(short printJob,
                                 BOOL ( CALLBACK * callbackProc )(short eventID, void *param, void *userData),
								 void *userData);
/* -------------------------------------------------------------------------*/

// all are window standard cursors except PE_TC_MAGNIFY_CURSOR.
// PE_TC_SIZEALL_CURSOR, PE_TC_NO_CURSOR, PE_TC_APPSTARTING_CURSOR
// and PE_TC_HELP_CURSOR are not supported in 16bit. 
// PE_TC_SIZE_CURSOR and PE_TC_ICON_CURSOR are obsolete for 32bit
// use PE_TC_SIZEALL_CURSOR and PE_TC_ARROW_CURSOR instead.

#define PE_TC_DEFAULT_CURSOR     0 // CRPE set default cursor to be PE_TC_ARRAOW_CURSOR
#define PE_TC_ARROW_CURSOR       1 
#define PE_TC_CROSS_CURSOR       2
#define PE_TC_IBEAM_CURSOR       3
#define PE_TC_UPARROW_CURSOR     4
#define PE_TC_SIZEALL_CURSOR     5 
#define PE_TC_SIZENWSE_CURSOR    6
#define PE_TC_SIZENESW_CURSOR    7
#define PE_TC_SIZEWE_CURSOR      8
#define PE_TC_SIZENS_CURSOR      9
#define PE_TC_NO_CURSOR          10
#define PE_TC_WAIT_CURSOR        11
#define PE_TC_APPSTARTING_CURSOR 12
#define PE_TC_HELP_CURSOR        13
#define PE_TC_SIZE_CURSOR        14 // for 16bit
#define PE_TC_ICON_CURSOR        15 // for 16bit

 // CRPE specific cursors
#define PE_TC_BACKGROUND_PROCESS_CURSOR 94
#define PE_TC_GRAB_HAND_CURSOR          95
#define PE_TC_ZOOM_IN_CURSOR            96
#define PE_TC_REPORT_SECTION_CURSOR     97
#define PE_TC_HAND_CURSOR               98
#define PE_TC_MAGNIFY_CURSOR     99 // CRPE specific cusor

typedef struct PETrackCursorInfo
{
	WORD StructSize;
	short groupAreaCursor; // a PE_TC constant. PE_UNCHANGED for no change.
	short groupAreaFieldCursor; // a PE_TC constant. PE_UNCHAGNED for no change.
	short detailAreaCursor;  // a PE_TC constant. PE_UNCHANGED for no change
	short detailAreaFieldCursor; // a PE_TC constant. PE_UNCHANGED for no change
	short graphCursor;			// a PE_TC constant. PE_UNCHANGED for no change.
	long groupAreaCursorHandle; // reserved
	long groupAreaFieldCursorHandle; // reserved
	long detailAreaCursorHandle; // reserved
	long detailAreaFieldCursorHandle; // reserved
	long graphCursorHandle; // reserved
    short ondemandSubreportCursor;  // Cursor to show over on-demand subreports when
                                    // drilldown for the window is enabled;
                                    // default is PE_TC_MAGNIFY_CURSOR.
    short hyperlinkCursor;          // Cursor to show over report object that has hyperlink text;
                                    // default is PE_TC_HAND_CURSOR.
} PETrackCursorInfo;
#define PE_SIZEOF_TRACK_CURSOR_INFO  (sizeof(PETrackCursorInfo))

// set tracking cursor
BOOL CRPE_API PESetTrackCursorInfo(short printJob,
							       PETrackCursorInfo FAR * cursorInfo);
BOOL CRPE_API PEGetTrackCursorInfo(short printJob,
							       PETrackCursorInfo FAR * cursorInfo);


/* ******************************* */
/* Report Alerting                 */
/* ******************************* */

typedef struct PEReportAlertInfo
{
    WORD StructSize;    // initialized to be PE_SIZEOF_REPORT_ALERT_INFO
    short nameLength;
    HANDLE name;        // NOTE: must release HANDLEs even not using them
    short isEnabled;    // TRUE if alert is enabled, else FALSE
    short alertConditionLength;
    HANDLE alertConditionFormula;
    DWORD nTriggeredInstances;  // the number of times the alert was triggered
    short alertMessageLength;
    short defaultAlertMessageLength;
    HANDLE alertMessageFormula;
    HANDLE defaultAlertMessage;
} PEReportAlertInfo;
#define PE_SIZEOF_REPORT_ALERT_INFO (sizeof (PEReportAlertInfo))

typedef struct PEAlertInstanceInfo
{
    WORD StructSize;    // initialized to be PE_SIZEOF_ALERT_INSTANCE_INFO
    short alertMessageLength;
    HANDLE alertMessage;
} PEAlertInstanceInfo;
#define PE_SIZEOF_ALERT_INSTANCE_INFO (sizeof (PEAlertInstanceInfo))

short CRPE_API PEGetNReportAlerts (short printJob);  // return -1 if failed.

BOOL CRPE_API PEGetNthReportAlert (short printJob,
                                   short alertN,
                                   PEReportAlertInfo FAR * reportAlertInfo);

BOOL CRPE_API PEGetNthAlertInstanceInfo (short printJob,
                                         short alertN,
                                         DWORD instanceN,
                                         PEAlertInstanceInfo FAR * alertInstanceInfo);

BOOL CRPE_API PESetNthAlertConditionFormula (short printJob,
                                             short alertN,
                                             const char FAR *formula);

BOOL CRPE_API PESetNthAlertMessageFormula (short printJob,
                                           short alertN,
                                           const char FAR *formula);

BOOL CRPE_API PESetNthAlertDefaultMessage (short printJob,
                                           short alertN,
                                           const char FAR *text);

BOOL CRPE_API PEEnableNthAlert (short printJob,
                                short alertN,
                                BOOL enabled);

/* ******************************* */
/* Formula Syntax                  */
/* ******************************* */

#define PE_FS_SIZE      2

#define PE_FST_CRYSTAL   0
#define PE_FST_BASIC     1

typedef struct PEFormulaSyntax
{
    WORD StructSize;
    short formulaSyntax [PE_FS_SIZE];           // PE_FST_* or PE_UNCHANGED.
} PEFormulaSyntax;

#define PE_SIZEOF_FORMULA_SYNTAX (sizeof (PEFormulaSyntax))

// PESetFormulaSyntax
// Use this API to set the syntax to use in the next (and all successive)
// formula API call(s).
// Set one of PE_FST_* into formulaSyntax[0];
// formulaSyntax[1] is reserved for internal use.
// ***Default Behaviour: If any Formula API is called before calling
//                       PESetFormulaSyntax then PE_FST_CRYSTAL is assumed.
/////////////////////////////////////////////////////////////////////////
BOOL CRPE_API PESetFormulaSyntax (short printJob, PEFormulaSyntax FAR *formulaSyntax);

// PEGetFormulaSyntax
// Indicates the syntax used by the formula addressed in the last formula API call.
// The syntax type is returned in formulaSyntax[0];
// formulaSyntax[1] is reserved for internal use.
// ***Default Behaviour: If this API is called before any Formula API is called
//                       then the values returned will be PE_UNCHANGED.
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
BOOL CRPE_API PEGetFormulaSyntax (short printJob, PEFormulaSyntax FAR *formulaSyntax);

// for 4.x version
#define PE_ALLLINES  -1

#if defined (__cplusplus)
}
#endif

// Reset structure alignment
#if defined (__BORLANDC__)
  #pragma option -a.
#elif defined (_MSC_VER)
  #if _MSC_VER >= 900
    #pragma pack (pop)
  #else
    #pragma pack ()
  #endif
#endif

#endif // CRPE_H
