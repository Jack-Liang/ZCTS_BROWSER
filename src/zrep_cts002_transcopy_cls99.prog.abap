*&---------------------------------------------------------------------*
*& Include          ZREP_CTS002_TRANSCOPY_CLS99
*&---------------------------------------------------------------------*

CLASS lcl_app DEFINITION.

  PUBLIC SECTION.
    METHODS constructor.
    METHODS init_texts.
    METHODS start_of_sel.
    METHODS at_sel_screen.
    METHODS at_sel_screen_output.
    METHODS end_of_sel.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA ms_scr TYPE ts_screen.
    METHODS fill_from_screen.
    METHODS output_end.
    METHODS fill_toolbar_func1.

ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    fill_toolbar_func1( ).
  ENDMETHOD.

  METHOD init_texts.
    %_p_impagn_%_app_%-text = '再次导入传输请求'.
    %_p_orgovr_%_app_%-text = '覆盖原件'.
    %_p_repovr_%_app_%-text = '覆盖未确认修复中的对象'.
    %_p_trntyp_%_app_%-text = '忽略无效传输类型'.
    %_p_tabcls_%_app_%-text = '忽略无效表类'.
    %_p_predec_%_app_%-text = '跳过前导关系'.
    t03 = '导入选项'.
  ENDMETHOD.

  METHOD start_of_sel.

    DATA lx TYPE REF TO cx_root.

    DATA lv_res TYPE string.
    TRY .
        fill_from_screen( ).
        lv_res = NEW lcl_toc( ms_scr )->sh( ).
        MESSAGE |TOC finished: { lv_res }| TYPE 'S'.
      CATCH cx_root INTO lx.
        DATA lv_txt TYPE string.
        TRY.
            lv_txt = CAST zcx_cts002_data_error( lx )->descr.
          CATCH cx_root.
            lv_txt = lx->get_text( ).
        ENDTRY.
        MESSAGE |TOC failed: { lv_txt }| TYPE 'S'.
    ENDTRY.

  ENDMETHOD.

  METHOD end_of_sel.
    " output_end( ).
  ENDMETHOD.

  METHOD output_end.
    MESSAGE s000(cl) WITH '...something is done...'.
  ENDMETHOD.

  METHOD fill_from_screen.

    "    ms_scr-s_trreq = s_trreq[].
    ms_scr-s_trreqi = s_trreqi[].
*    ms_scr-remote = remote.
    ms_scr-rfcdest = rfcdest.
    ms_scr-version_ignore = vers_ign.
    ms_scr-toctrans = toctrans.
    ms_scr-imp_again = p_impagn.
    ms_scr-ign_orig = p_orgovr.
    ms_scr-ign_repair = p_repovr.
    ms_scr-ign_transtype = p_trntyp.
    ms_scr-ign_tabletype = p_tabcls.
    ms_scr-ign_predec = p_predec.


  ENDMETHOD.

  METHOD at_sel_screen.

    CASE sscrfields-ucomm.
      WHEN'FC01'.
        NEW lcl_open_ext_obj( )->open_view( 'ZTCTS002_DESTSYS' ).
      WHEN 'FC02'.
        " no action
    ENDCASE.

  ENDMETHOD.

  METHOD at_sel_screen_output.
    LOOP AT SCREEN.
      IF screen-name = 'RFCDEST'.
        screen-required = '2'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD fill_toolbar_func1.
    sscrfields-functxt_01 = 'TargetSys (ZTCTS002_DESTSYS)'.
  ENDMETHOD.
ENDCLASS.
