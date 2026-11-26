CLASS lhc_import DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Import
      RESULT result.

    METHODS runimport FOR MODIFY
      IMPORTING keys FOR ACTION Import~runImport
      RESULT result.
ENDCLASS.

CLASS lhc_import IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD runimport.
    READ ENTITIES OF zpl2r_import IN LOCAL MODE
      ENTITY Import
        FIELDS ( Attachment FileName ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_files).

    LOOP AT lt_files INTO DATA(ls_file).
      DATA(lo_importer) = NEW zpl2cl_template_import( ).
      lo_importer->import( EXPORTING iv_content = ls_file-Attachment
                           IMPORTING ev_success = DATA(lv_success)
                                     ev_message = DATA(lv_message) ).

      MODIFY ENTITIES OF zpl2r_import IN LOCAL MODE
        ENTITY Import
          UPDATE FIELDS ( Status Message )
          WITH VALUE #( ( %tky    = ls_file-%tky
                          Status  = COND #( WHEN lv_success = abap_true THEN 'OK' ELSE 'FOUT' )
                          Message = lv_message ) ).

      APPEND VALUE #( %tky = ls_file-%tky
                      %msg = new_message_with_text(
                               severity = COND #( WHEN lv_success = abap_true
                                                  THEN if_abap_behv_message=>severity-success
                                                  ELSE if_abap_behv_message=>severity-error )
                               text     = lv_message ) ) TO reported-import.
    ENDLOOP.

    READ ENTITIES OF zpl2r_import IN LOCAL MODE
      ENTITY Import
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

ENDCLASS.
