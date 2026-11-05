FUNCTION z_cts002_file_upload.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(IV_FILENAME) TYPE  EPSF-EPSFILNAM
*"     VALUE(IV_SUBDIR) TYPE  EPSF-EPSSUBDIR
*"     VALUE(IV_TOTAL_LEN) TYPE  I
*"     VALUE(IT_DATA) TYPE  SOLIX_TAB
*"  EXPORTING
*"     VALUE(EV_ERROR) TYPE  STRING
*"     VALUE(EV_BYTES) TYPE  I
*"----------------------------------------------------------------------
  DATA lv_path TYPE c LENGTH 60.
  DATA lv_full TYPE string.
  DATA lv_msg TYPE c LENGTH 100.
  DATA ls_x TYPE solix.
  DATA lv_len TYPE i.
  DATA lv_wlen TYPE i.
  CALL 'C_SAPGPARAM' ID 'NAME' FIELD 'DIR_TRANS'
    ID 'VALUE' FIELD lv_path.
  CONCATENATE lv_path iv_subdir iv_filename
    INTO lv_full SEPARATED BY '/'.
  OPEN DATASET lv_full FOR OUTPUT IN BINARY MODE
    MESSAGE lv_msg.
  IF sy-subrc <> 0.
    ev_error = |OPEN failed: { lv_msg }|.
    RETURN.
  ENDIF.
  LOOP AT it_data INTO ls_x.
    IF lv_len >= iv_total_len.
      EXIT.
    ENDIF.
    lv_wlen = iv_total_len - lv_len.
    IF lv_wlen > 255.
      lv_wlen = 255.
    ENDIF.
    TRANSFER ls_x-line(lv_wlen) TO lv_full.
    lv_len = lv_len + lv_wlen.
  ENDLOOP.
  CLOSE DATASET lv_full.
  ev_bytes = lv_len.
  IF lv_len <> iv_total_len.
    ev_error = |Wrote { lv_len } of { iv_total_len } bytes|.
  ENDIF.
ENDFUNCTION.
