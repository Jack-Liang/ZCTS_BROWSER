*&---------------------------------------------------------------------*
*& Include          ZREP_CTS002_TRANSCOPY_SCRN
*&---------------------------------------------------------------------*

DATA gs_e070 TYPE e070.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
  "  s_trreq FOR gs_e070-trkorr ,
    s_trreqi FOR gs_e070-trkorr MATCHCODE OBJECT zshcts002_zvcts002_e070
    .

  PARAMETERS: p_copy RADIOBUTTON GROUP gr0 DEFAULT 'X'
            , p_orig RADIOBUTTON GROUP gr0.

  PARAMETERS:   rfcdest TYPE rfcdest MATCHCODE OBJECT zshcts002_destsys
              , no_dis TYPE char1 DEFAULT '' NO-DISPLAY
              .

  " see comment in TMS_TP_IMPORT / param IV_IGN_CVERS
  PARAMETERS: vers_ign TYPE zects002_vers_ignore DEFAULT 'Y'.

SELECTION-SCREEN END OF BLOCK b01.


SELECTION-SCREEN: FUNCTION KEY 1.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE t03.
  PARAMETERS: toctrans AS CHECKBOX DEFAULT 'X' USER-COMMAND uimp
            , p_impagn AS CHECKBOX DEFAULT 'X' MODIF ID mop
            , p_orgovr AS CHECKBOX DEFAULT 'X' MODIF ID mop
            , p_repovr AS CHECKBOX DEFAULT 'X' MODIF ID mop
            , p_trntyp AS CHECKBOX DEFAULT ' ' MODIF ID mop
            , p_tabcls AS CHECKBOX DEFAULT ' ' MODIF ID mop
            , p_predec AS CHECKBOX DEFAULT 'X' MODIF ID mop.
SELECTION-SCREEN END OF BLOCK b03.
