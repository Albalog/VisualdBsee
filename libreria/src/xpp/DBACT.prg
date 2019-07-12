// Function/Procedure Prototype Table  -  Last Update: 08/10/98 @ 16.12.45
// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
// Return Value         Function/Arguments
// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
// Void                 PROCEDURE dbActSet(nKey)
// nKsc                 FUNCTION dbAct2Ksc(cAct)
// cMsg                 FUNCTION dbAct2Mne(cAct)
// cRet                 FUNCTION dbKsc2Act(mp1)

#include "Appevent.ch"
#include "dfStd.ch"
#include "dfXBase.ch"

#define ACTION_NOT_VALID "-~~"
#define ACTION_MOUSE     "mou"

MEMVAR ACT, SA, A, EnvId, SubId

// NOTA: le azioni tsi, tai, uai (per la selezione colonna TAG)
//       sono su tasti diversi:
//
//       tsi CTRL-barra     -> CTRL-asterisco
//       uai CTRL-Slash     -> CTRL-meno
//       tai CTRL-BackSlash -> CTRL-pió
//
// Aggiunti xbeK_CTRL_SH_TAB e Cst non definiti in xbase/dbsee

/*
  1=hom,Home
  2=Cra,Ctrl-Fr.Destra
  3=pgd,Pag.gió
  4=rar,Fr.Destra
  5=uar,Fr.só
  6=end,Fine
  7=ecr,Canc
  8=bks,BackSpace
  9=tab,Tab
 10=
 13=ret,Invio
 18=pgu,Pag.só
 19=lar,Fr.sin.
 22=anr,Ins
 23=Cen,Ctrl-Fine
 24=dar,Fr.gió
 26=Cla,Ctrl-Fr.sin.
 28=hlp,F1
 29=Cho,Ctrl-Home
 32=mcr,Barra
127=Cbs,Ctrl-BackSpace
257=Aes,Alt-Esc
270=Abs,Alt-BackSpace
271=Stb,Shift-Tab

282=A_ä,Alt-ä
283=A_+,Alt-+
334=A_+,Alt-+
284=Art,Alt-Invio
286=A_a,Alt-A
287=A_s,Alt-S
288=A_d,Alt-D
289=A_f,Alt-F
290=A_g,Alt-G
291=A_h,Alt-H
292=A_j,Alt-J
293=A_k,Alt-K
294=A_l,Alt-L
295=A_ï,Alt-ï
296=A_Ö,Alt-Ö
297=A_\,Alt-Backslash
299=A_ó,Alt-ó
300=A_z,Alt-Z
301=A_x,Alt-X
302=A_c,Alt-C
303=A_v,Alt-V
304=A_b,Alt-B
305=A_n,Alt-N
306=A_m,Alt-M
307=A_,,Alt-,
308=A_.,Alt-.
309=A_-,Alt--
330=A_-,Alt--
386=A_',Alt-'
387=A_ç,Alt-ç
389=f11,F11
390=f12,F12
391=S11,Shift-F11
392=S12,Shift-F12
393=C11,Ctrl-F11
394=C12,Ctrl-F12
395=A11,Alt-F11
396=A12,Alt-F12
397=Cua,Ctrl-Fr.só
401=Cda,Ctrl-Fr.gió
402=Cin,Ctrl-Ins
403=Cde,Ctrl-Canc
404=Ctb,Ctrl-Tab
405=tai,Ctrl-Slash
407=Aho,Alt-Home
408=Aua,Alt-Fr.só
409=Apu,Alt-Pag.só
411=Ala,Alt-Fr.sin.
413=Ara,Alt-Fr.Destra
415=Aen,Alt-Fine
416=Ada,Alt-Fr.gió
417=Apd,Alt-Pag.gió
418=Ain,Alt-Ins
419=Ade,Alt-Canc
421=Atb,Alt-Tab
506=C_f,Ctrl-F
512=C_l,Ctrl-L
516=C_p,Ctrl-P
520=C_t,Ctrl-T
528=uai,Ctrl-Backslash
532=tsi,Ctrl-Barra
632=smp,Alt-Barra
707=
722=Sin,Shift-Ins
786=A_?,Alt-?
921=Ast,Alt-Shift-Tab

aggiunto CTRL-SHIFT-TAB
*/

STATIC aKeyTable := { { 43                  , "skn", "+" } , ;
                      { 45                  , "skp", "-" } , ;
                      { 60                  , "usl", "<" } , ;
                      { 62                  , "usr", ">" } , ;
                      { xbeK_UP             , "uar", "Fr. só" } , ;
                      { xbeK_DOWN           , "dar", "Fr. gió" } , ;
                      { xbeK_LEFT           , "lar", "Fr. sin." } , ;
                      { xbeK_RIGHT          , "rar", "Fr. destra" } , ;
                      { xbeK_HOME           , "hom", "Home" } , ;
                      { xbeK_END            , "end", "Fine" } , ;
                      { xbeK_PGUP           , "pgu", "Pag. só" } , ;
                      { xbeK_PGDN           , "pgd", "Pag. gió" } , ;
                      { xbeK_CTRL_UP        , "Cua", "Ctrl-Fr.só" } , ;
                      { xbeK_CTRL_DOWN      , "Cda", "Ctrl-Fr.gió" } , ;
                      { xbeK_CTRL_LEFT      , "Cla", "Ctrl-Fr. sin" } , ;
                      { xbeK_CTRL_RIGHT     , "Cra", "Ctrl-Fr. destra" } , ;
                      { xbeK_CTRL_HOME      , "Cho", "Ctrl-Home" } , ;
                      { xbeK_CTRL_END       , "Cen", "Ctrl-Fine"} , ;
                      { xbeK_CTRL_PGUP      , "Cpu", "Ctrl-Pag.só" } , ;
                      { xbeK_CTRL_PGDN      , "Cpd", "Ctrl-Pag.gió" } , ;
                      { xbeK_ALT_UP         , "Aua", "Alt-Fr.só" } , ;
                      { xbeK_ALT_DOWN       , "Ada", "Alt-Fr.gió" } , ;
                      { xbeK_ALT_LEFT       , "Ala", "Alt-Fr.sin." } , ;
                      { xbeK_ALT_RIGHT      , "Ara", "Alt-Fr.Destra" } , ;
                      { xbeK_ALT_HOME       , "Aho", "Alt-Home" } , ;
                      { xbeK_ALT_END        , "Aen", "Alt-Fine" } , ;
                      { xbeK_ALT_PGUP       , "Apu", "Alt-Pag.só" } , ;
                      { xbeK_ALT_PGDN       , "Apd", "Alt-Pag.gió" } , ;
                      { xbeK_SH_UP          , "   ", "" } , ;
                      { xbeK_SH_DOWN        , "   ", "" } , ;
                      { xbeK_SH_LEFT        , "Sla", "Shift-Fr. sin." } , ;
                      { xbeK_SH_RIGHT       , "Sra", "Shift-Fr. destra" } , ;
                      { xbeK_SH_HOME        , "Sho", "Shift-Home" } , ;
                      { xbeK_SH_END         , "Sen", "Shift-Fine" } , ;
                      { xbeK_SH_PGUP        , "   ", "" } , ;
                      { xbeK_SH_PGDN        , "   ", "" } , ;
                      { xbeK_SH_CTRL_UP     , "   ", "" } , ;
                      { xbeK_SH_CTRL_DOWN   , "   ", "" } , ;
                      { xbeK_SH_CTRL_LEFT   , "   ", "" } , ;
                      { xbeK_SH_CTRL_RIGHT  , "   ", "" } , ;
                      { xbeK_SH_CTRL_HOME   , "   ", "" } , ;
                      { xbeK_SH_CTRL_END    , "   ", "" } , ;
                      { xbeK_SH_CTRL_PGUP   , "   ", "" } , ;
                      { xbeK_SH_CTRL_PGDN   , "   ", "" } , ;
                      { xbeK_ENTER          , "ret", "Invio" } , ;
                      { xbeK_RETURN         , "ret", "Invio" } , ;
                      { xbeK_SPACE          , "mcr", "Barra" } , ;
                      { xbeK_ESC            , "esc", "Esc"        } , ;
                      { xbeK_CTRL_ENTER     , "Crt", "Ctrl-Invio" } , ;
                      { xbeK_CTRL_RETURN    , "Crt", "Ctrl-Invio" } , ;
                      { xbeK_CTRL_RET       , "Crt", "Ctrl-Invio" } , ;
                      { xbeK_ALT_ENTER      , "   ", "" } , ;
                      { xbeK_ALT_RETURN     , "   ", "" } , ;
                      { xbeK_ALT_EQUALS     , "   ", "" } , ;
                      { xbeK_P_ALT_ENTER    , "   ", "" } , ;
                      { xbeK_P_CTRL_5       , "   ", "" } , ;
                      { xbeK_P_CTRL_SLASH   , "   ", "" } , ;
                      { xbeK_P_CTRL_ASTERISK, "tsi", "Ctrl-*" } , ;
                      { xbeK_P_CTRL_MINUS   , "uai", "Ctrl-meno" } , ;
                      { xbeK_P_CTRL_PLUS    , "tai", "Ctrl-pió" } , ;
                      { xbeK_P_ALT_5        , "   ", "" } , ;
                      { xbeK_P_ALT_SLASH    , "   ", "" } , ;
                      { xbeK_P_ALT_ASTERISK , "   ", "" } , ;
                      { xbeK_P_ALT_MINUS    , "   ", "" } , ;
                      { xbeK_P_ALT_PLUS     , "   ", "" } , ;
                      { xbeK_INS            , "anr", "Ins" } , ;
                      { xbeK_DEL            , "ecr", "Del" } , ;
                      { xbeK_BS             , "bks", "BackSpace" } , ;
                      { xbeK_TAB            , "tab", "Tab"       } , ;
                      { xbeK_SH_TAB         , "Stb", "Shift-Tab" } , ;
                      { xbeK_CTRL_TAB       , "Ctb", "Ctrl-Tab"  } , ;
                      { xbeK_CTRL_INS       , "Cin", "Ctrl-Ins"  } , ;
                      { xbeK_CTRL_DEL       , "Cde", "Ctrl-Canc" } , ;
                      { xbeK_CTRL_BS        , "Cbs", "Ctrl-BackSpace" } , ;
                      { xbeK_ALT_INS        , "Ain", "Alt-Ins" } , ;
                      { xbeK_ALT_DEL        , "Ade", "Alt-Canc" } , ;
                      { xbeK_ALT_BS         , "Abs", "Alt-BackSpace" } , ;
                      { xbeK_SH_INS         , "Sin", "Shift-Ins" } , ;
                      { xbeK_SH_DEL         , "Sde", "Shift-Canc" } , ;
                      { xbeK_SH_BS          , "   ", "" } , ;
                      { xbeK_CTRL_A         , "C_a", "Ctrl-A" } , ;
                      { xbeK_CTRL_B         , "C_b", "Ctrl-B" } , ;
                      { xbeK_CTRL_C         , "C_c", "Ctrl-C" } , ;
                      { xbeK_CTRL_D         , "C_d", "Ctrl-D" } , ;
                      { xbeK_CTRL_E         , "C_e", "Ctrl-E" } , ;
                      { xbeK_CTRL_F         , "C_f", "Ctrl-F" } , ;
                      { xbeK_CTRL_G         , "C_g", "Ctrl-G" } , ;
                      { xbeK_CTRL_H         , "C_h", "Ctrl-H" } , ;
                      { xbeK_CTRL_I         , "C_i", "Ctrl-I" } , ;
                      { xbeK_CTRL_J         , "C_j", "Ctrl-J" } , ;
                      { xbeK_CTRL_K         , "C_k", "Ctrl-K" } , ;
                      { xbeK_CTRL_L         , "C_l", "Ctrl-L" } , ;
                      { xbeK_CTRL_M         , "C_m", "Ctrl-M" } , ;
                      { xbeK_CTRL_N         , "C_n", "Ctrl-N" } , ;
                      { xbeK_CTRL_O         , "C_o", "Ctrl-O" } , ;
                      { xbeK_CTRL_P         , "C_p", "Ctrl-P" } , ;
                      { xbeK_CTRL_Q         , "C_q", "Ctrl-Q" } , ;
                      { xbeK_CTRL_R         , "C_r", "Ctrl-R" } , ;
                      { xbeK_CTRL_S         , "C_s", "Ctrl-S" } , ;
                      { xbeK_CTRL_T         , "C_t", "Ctrl-T" } , ;
                      { xbeK_CTRL_U         , "C_u", "Ctrl-U" } , ;
                      { xbeK_CTRL_V         , "C_v", "Ctrl-V" } , ;
                      { xbeK_CTRL_W         , "C_w", "Ctrl-W" } , ;
                      { xbeK_CTRL_X         , "C_x", "Ctrl-X" } , ;
                      { xbeK_CTRL_Y         , "C_y", "Ctrl-Y" } , ;
                      { xbeK_CTRL_Z         , "C_z", "Ctrl-Z" } , ;
                      { xbeK_ALT_A          , "A_a", "Alt-A" } , ;
                      { xbeK_ALT_B          , "A_b", "Alt-B" } , ;
                      { xbeK_ALT_C          , "A_c", "Alt-C" } , ;
                      { xbeK_ALT_D          , "A_d", "Alt-D" } , ;
                      { xbeK_ALT_E          , "A_e", "Alt-E" } , ;
                      { xbeK_ALT_F          , "A_f", "Alt-F" } , ;
                      { xbeK_ALT_G          , "A_g", "Alt-G" } , ;
                      { xbeK_ALT_H          , "A_h", "Alt-H" } , ;
                      { xbeK_ALT_I          , "A_i", "Alt-I" } , ;
                      { xbeK_ALT_J          , "A_j", "Alt-J" } , ;
                      { xbeK_ALT_K          , "A_k", "Alt-K" } , ;
                      { xbeK_ALT_L          , "A_l", "Alt-L" } , ;
                      { xbeK_ALT_M          , "A_m", "Alt-M" } , ;
                      { xbeK_ALT_N          , "A_n", "Alt-N" } , ;
                      { xbeK_ALT_O          , "A_o", "Alt-O" } , ;
                      { xbeK_ALT_P          , "A_p", "Alt-P" } , ;
                      { xbeK_ALT_Q          , "A_q", "Alt-Q" } , ;
                      { xbeK_ALT_R          , "A_r", "Alt-R" } , ;
                      { xbeK_ALT_S          , "A_s", "Alt-S" } , ;
                      { xbeK_ALT_T          , "A_t", "Alt-T" } , ;
                      { xbeK_ALT_U          , "A_u", "Alt-U" } , ;
                      { xbeK_ALT_V          , "A_v", "Alt-V" } , ;
                      { xbeK_ALT_W          , "A_w", "Alt-W" } , ;
                      { xbeK_ALT_X          , "A_x", "Alt-X" } , ;
                      { xbeK_ALT_Y          , "A_y", "Alt-Y" } , ;
                      { xbeK_ALT_Z          , "A_z", "Alt-Z" } , ;
                      { xbeK_ALT_1          , "A_1", "Alt-1" } , ;
                      { xbeK_ALT_2          , "A_2", "Alt-2" } , ;
                      { xbeK_ALT_3          , "A_3", "Alt-3" } , ;
                      { xbeK_ALT_4          , "A_4", "Alt-4" } , ;
                      { xbeK_ALT_5          , "A_5", "Alt-5" } , ;
                      { xbeK_ALT_6          , "A_6", "Alt-6" } , ;
                      { xbeK_ALT_7          , "A_7", "Alt-7" } , ;
                      { xbeK_ALT_8          , "A_8", "Alt-8" } , ;
                      { xbeK_ALT_9          , "A_9", "Alt-9" } , ;
                      { xbeK_ALT_0          , "A_0", "Alt-0" } , ;
                      { xbeK_F1             , "hlp", "F1" } , ;
                      { xbeK_F2             , "qdr", "F2" } , ;
                      { xbeK_F3             , "add", "F3" } , ;
                      { xbeK_F4             , "mod", "F4" } , ;
                      { xbeK_F5             , "f05", "F5" } , ;
                      { xbeK_F6             , "del", "F6" } , ;
                      { xbeK_F7             , "win", "F7" } , ;
                      { xbeK_F8             , "wis", "F8" } , ;
                      { xbeK_F9             , "new", "F9" } , ;
                      { xbeK_F10            , "wri", "F10" } , ;
                      { xbeK_F11            , "f11", "F11" } , ;
                      { xbeK_F12            , "f12", "F12" } , ;
                      { xbeK_CTRL_F1        , "C01", "Ctrl-F1"  } , ;
                      { xbeK_CTRL_F2        , "C02", "Ctrl-F2"  } , ;
                      { xbeK_CTRL_F3        , "C03", "Ctrl-F3"  } , ;
                      { xbeK_CTRL_F4        , "C04", "Ctrl-F4"  } , ;
                      { xbeK_CTRL_F5        , "C05", "Ctrl-F5"  } , ;
                      { xbeK_CTRL_F6        , "C06", "Ctrl-F6"  } , ;
                      { xbeK_CTRL_F7        , "C07", "Ctrl-F7"  } , ;
                      { xbeK_CTRL_F8        , "C08", "Ctrl-F8"  } , ;
                      { xbeK_CTRL_F9        , "C09", "Ctrl-F9"  } , ;
                      { xbeK_CTRL_F10       , "doc", "Ctrl-F10" } , ;
                      { xbeK_CTRL_F11       , "C11", "Ctrl-F11" } , ;
                      { xbeK_CTRL_F12       , "C12", "Ctrl-F12" } , ;
                      { xbeK_ALT_F1         , "A01", "Alt-F1"} , ;
                      { xbeK_ALT_F2         , "A02", "Alt-F2"} , ;
                      { xbeK_ALT_F3         , "A03", "Alt-F3"} , ;
                      { xbeK_ALT_F4         , "A04", "Alt-F4"} , ;
                      { xbeK_ALT_F5         , "A05", "Alt-F5"} , ;
                      { xbeK_ALT_F6         , "A06", "Alt-F6"} , ;
                      { xbeK_ALT_F7         , "A07", "Alt-F7"} , ;
                      { xbeK_ALT_F8         , "A08", "Alt-F8"} , ;
                      { xbeK_ALT_F9         , "A09", "Alt-F9"} , ;
                      { xbeK_ALT_F10        , "sho", "Alt-F10"} , ;
                      { xbeK_ALT_F11        , "A11", "Alt-F11"} , ;
                      { xbeK_ALT_F12        , "A12", "Alt-F12"} , ;
                      { xbeK_SH_F1          , "ush", "Shift-F1"}  , ;
                      { xbeK_SH_F2          , "S02", "Shift-F2"}  , ;
                      { xbeK_SH_F3          , "S03", "Shift-F3"}  , ;
                      { xbeK_SH_F4          , "S04", "Shift-F4"}  , ;
                      { xbeK_SH_F5          , "S05", "Shift-F5"}  , ;
                      { xbeK_SH_F6          , "S06", "Shift-F6"}  , ;
                      { xbeK_SH_F7          , "S07", "Shift-F7"}  , ;
                      { xbeK_SH_F8          , "S08", "Shift-F8"}  , ;
                      { xbeK_SH_F9          , "S09", "Shift-F9"}  , ;
                      { xbeK_SH_F10         , "S10", "Shift-F10"} , ;
                      { xbeK_SH_F11         , "S11", "Shift-F11"} , ;
                      { xbeK_SH_F12         , "S12", "Shift-F12"} , ;
                      { xbeK_ALT_AE         , "   ", "" } , ;
                      { xbeK_ALT_OE         , "   ", "" } , ;
                      { xbeK_ALT_UE         , "   ", "" } , ;
                      { xbeK_ALT_SZ         , "   ", "" } , ;
                      { xbeK_CTRL_SH_TAB    , "Cst", "Ctrl-Shift-Tab" }, ;
                      { 327900              , "A_\", "Alt-Backslash"  }, ;   //Non ä definita in base
                      { EVENT_MOUSE_DOWN    , ACTION_MOUSE, "Click Mouse" } }


FUNCTION dbGetKeyTable()
RETURN aKeyTable

FUNCTION dbKsc2Act(mp1)
   LOCAL cRet := "   "
   LOCAL nPos := ASCAN(aKeyTable, {|x| x[1]== mp1 })

   IF nPos > 0
      cRet := aKeyTable[nPos][2]

      IF ! dbActState(cRet)
         cRet := ACTION_NOT_VALID
      ENDIF

   ELSEIF mp1 >= 0 .AND. mp1 <= 255
      cRet := "-"+CHR(mp1)+LOWER(CHR(mp1))
   ENDIF

RETURN cRet

FUNCTION dbAct2Ksc(cAct)
   LOCAL nPos := 0
   LOCAL nKsc := 0

   IF ! dbActState(cAct)
      cAct := ACTION_NOT_VALID
   ENDIF

   nPos := ASCAN(aKeyTable, {|x| x[2]==cAct })
   IF nPos > 0
      nKsc := aKeyTable[nPos][1]
   ENDIF
RETURN nKsc

FUNCTION dbAct2Mne(cAct)
   LOCAL nPos := 0
   LOCAL cMsg := ""

   IF ! dbActState(cAct)
      cAct := ACTION_NOT_VALID
   ENDIF

   nPos := ASCAN(aKeyTable, {|x| x[2]==cAct })
   IF nPos > 0
      cMsg := aKeyTable[nPos][3]
   ENDIF
RETURN cMsg



PROCEDURE dbActSet(nKey)
   A := nKey

   IF nKey >= 0 .AND. nKey <= 255
      SA := LOWER( CHR(nKey) )
   ELSE
      SA := ""
   ENDIF

   ACT := dbKsc2Act(nKey)

RETURN

FUNCTION dbActState(cAct, lState)
   STATIC aNotValid := {}
   LOCAL lRet := .F.
   LOCAL nPos := ASCAN(aNotValid, cAct)

   lRet := nPos == 0

   IF VALTYPE(lState) == "L"
      IF lState .AND. ! lRet
         DFAERASE(aNotValid, nPos)
      ELSEIF ! lState .AND. lRet
         AADD(aNotValid, cAct)
      ENDIF
   ENDIF

RETURN lRet


