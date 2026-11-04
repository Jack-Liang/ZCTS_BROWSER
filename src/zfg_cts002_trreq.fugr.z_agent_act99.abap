FUNCTION Z_AGENT_ACT99.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(IV_OBJECT1) TYPE  DWINACTIV-OBJECT OPTIONAL
*"     VALUE(IV_NAME1) TYPE  DWINACTIV-OBJ_NAME OPTIONAL
*"     VALUE(IV_OBJECT2) TYPE  DWINACTIV-OBJECT OPTIONAL
*"     VALUE(IV_NAME2) TYPE  DWINACTIV-OBJ_NAME OPTIONAL
*"  EXPORTING
*"     VALUE(EV_ERROR) TYPE  STRING
*"     VALUE(EV_SUBRC) TYPE  I
*"----------------------------------------------------------------------
  DATA lt_objects TYPE STANDARD TABLE OF dwinactiv.
  DATA ls_obj TYPE dwinactiv.
  IF iv_object1 IS NOT INITIAL.
    ls_obj-object = iv_object1.
    ls_obj-obj_name = iv_name1.
    APPEND ls_obj TO lt_objects.
  ENDIF.
  IF iv_object2 IS NOT INITIAL.
    ls_obj-object = iv_object2.
    ls_obj-obj_name = iv_name2.
    APPEND ls_obj TO lt_objects.
  ENDIF.
  CALL FUNCTION 'RS_WORKING_OBJECT_ACTIVATE'
    TABLES
      objects = lt_objects
    EXCEPTIONS
      exe_check_only = 1
      execution_error = 2
      OTHERS = 3.
  ev_subrc = sy-subrc.
  IF sy-subrc <> 0.
    ev_error = |activation failed rc={ sy-subrc }|.
  ENDIF.
ENDFUNCTION.
