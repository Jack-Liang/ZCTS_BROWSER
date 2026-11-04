CLASS zcl_cts002_trans_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING iv_system_name TYPE stpa-sysname
                iv_request     TYPE  stpa-trkorr
                iv_vers_ignore TYPE  trparflag DEFAULT 'Y'.
    METHODS sh
      RAISING zcx_cts002_data_error.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_system_name TYPE sysysid.
    DATA mv_request TYPE  stpa-trkorr.
    DATA mv_vers_ignore TYPE  trparflag.

    METHODS ensure_in_buffer
      RAISING zcx_cts002_data_error.
ENDCLASS.



CLASS zcl_cts002_trans_imp IMPLEMENTATION.
  METHOD constructor.
    mv_system_name = iv_system_name.
    mv_request = iv_request.
    mv_vers_ignore = iv_vers_ignore.
  ENDMETHOD.

  METHOD sh.

    ensure_in_buffer( ).

    DATA lv_symandt TYPE symandt.

    """"""""""""""""""""""""""""""""""""""""""""'
    DATA lv_rc152 TYPE trparflag VALUE 'X'.
    """"""""""""""""""""""""""""""""""""""""""""'
    """"""""""""""""""""""""""""""""""""""""""""'
    DATA lv_tp_cmd_strg  TYPE    stpa-cmdstring.
    DATA lv_tp_ret_code  TYPE    stpa-retcode.
    DATA lv_tp_message   TYPE    stpa-message.
    DATA lv_tp_version   TYPE    stpa-version.
    DATA lv_tp_alog  TYPE    stpa-file.
    DATA lv_tp_slog  TYPE    stpa-file.
    DATA lv_tp_pid   TYPE    stpa-pid.
    DATA lv_tpstat_key   TYPE    stpa-timestamp.
    DATA lt_request  TYPE    tprequests.
    DATA lt_project  TYPE    zttcts002_tpproject.
    DATA lt_client   TYPE    t000_tab.
    DATA lt_stdout   TYPE    tpstdouts.
    DATA lt_logptr   TYPE    ttocs_tp_logptr.
    """"""""""""""""""""""""""""""""""""""""""""'

    lv_symandt = sy-mandt.


    CALL FUNCTION 'TMS_TP_IMPORT'
      EXPORTING
        iv_system_name     = sy-sysid
        iv_request         = mv_request
        iv_client          = lv_symandt
*       IV_CTC_UI          =
*       IV_CTC_ACTIVE      =
*       IV_UMODES          =
*       IV_TP_OPTIONS      =
        iv_ign_predec      = 'X'
        iv_ign_cvers       = mv_vers_ignore
        iv_ign_rc152       = lv_rc152
*       IV_OFFLINE         =
*       IV_FEEDBACK        =
*       IV_PRID_TEXT       =
*       IV_PRID_MIN        = 0
*       IV_PRID_MAX        = 100
*       IV_TEST_IMPORT     =
*       IV_CMD_IMPORT      =
*       IV_NO_DELIVERY     =
*       IV_OWN_REQUEST     =
*       IV_SUBSET          =
*       IV_SIMULATE        = GC_CI_SIMU_OFF
*       IV_BATCHID         =
*       IT_TRPROJECT       =
*       IT_SUCCESSOR       =
*       IT_TARFILTER       =
      IMPORTING
        ev_tp_cmd_strg     = lv_tp_cmd_strg
        ev_tp_ret_code     = lv_tp_ret_code
        ev_tp_message      = lv_tp_message
        ev_tp_version      = lv_tp_version
        ev_tp_alog         = lv_tp_alog
        ev_tp_slog         = lv_tp_slog
        ev_tp_pid          = lv_tp_pid
        ev_tpstat_key      = lv_tpstat_key
      TABLES
        tt_request         = lt_request
        tt_project         = lt_project
        tt_client          = lt_client
        tt_stdout          = lt_stdout
        tt_logptr          = lt_logptr
      EXCEPTIONS
        permission_denied  = 1
        import_not_allowed = 2
        enqueue_failed     = 3
        tp_call_failed     = 4
        tp_interface_error = 5
        tp_reported_error  = 6
        tp_reported_info   = 7
        OTHERS             = 8.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_cts002_data_error
        EXPORTING
*         textid   =
*         previous =
          descr = | { lv_tp_ret_code } { lv_tp_message }|.
      .
    ENDIF.

    IF lv_tp_ret_code > '0004'.
      RAISE EXCEPTION TYPE zcx_cts002_data_error
        EXPORTING
          descr = |Import { mv_request } failed, tp rc={ lv_tp_ret_code } { lv_tp_message } - see STMS log|.
    ENDIF.


  ENDMETHOD.


  METHOD ensure_in_buffer.

    DATA lt_tmsbuffer TYPE tmsbuffers.
    DATA lv_err       TYPE string.
    DATA lv_sysnam    TYPE tmssysnam.
    DATA lv_retcode   TYPE stpa-retcode.
    DATA ls_alert     TYPE stmscalert.

    SELECT domnam sysnam bufpos buflvl trkorr umodes impflg maxrc
        tarcli project trfunc actflg preflg nodataflg
      FROM tmsbuffer
      INTO CORRESPONDING FIELDS OF TABLE lt_tmsbuffer
      WHERE trkorr = mv_request.

    IF lt_tmsbuffer IS NOT INITIAL.
      RETURN. " request already sits in the import queue of this system
    ENDIF.

    lv_sysnam = sy-sysid.

    CALL FUNCTION 'TMS_MGR_MAINTAIN_TR_QUEUE'
      EXPORTING
        iv_command                 = 'ADDTOBUFFER'
        iv_system                  = lv_sysnam
        iv_request                 = mv_request
        iv_tarcli                  = sy-mandt
        iv_monitor                 = 'X'
      IMPORTING
        ev_tp_ret_code             = lv_retcode
        es_exception               = ls_alert
      EXCEPTIONS
        read_config_failed         = 1
        table_of_requests_is_empty = 2
        OTHERS                     = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_err.
      RAISE EXCEPTION TYPE zcx_cts002_data_error
        EXPORTING
          descr = |ADDTOBUFFER { mv_request } failed: { lv_err }|.
    ENDIF.

    IF lv_retcode > '0004'.
      RAISE EXCEPTION TYPE zcx_cts002_data_error
        EXPORTING
          descr = |ADDTOBUFFER { mv_request } failed (rc={ lv_retcode }): { ls_alert-text }|.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
