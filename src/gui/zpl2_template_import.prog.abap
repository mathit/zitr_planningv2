*&---------------------------------------------------------------------*
*& Report ZPL2_TEMPLATE_IMPORT
*&---------------------------------------------------------------------*
*& Importeert een sjabloon (met blokken, onderdelen en docenten),
*& docenten en lokalen uit een Excel-bestand (XLSX) in de planning
*& ZITR_PLANNING_V2. Het bestand wordt van de pc geupload en via
*& ZPL2CL_TEMPLATE_IMPORT (XCO_CP_XLSX + EML) verwerkt.
*&
*& Tabbladen: Template, Module, Item, Teacher, Room (zie Toelichting
*& in het voorbeeldbestand Sjabloon_import_SAP_College.xlsx).
*&---------------------------------------------------------------------*
REPORT zpl2_template_import.

PARAMETERS p_file TYPE localfile LOWER CASE OBLIGATORY.
PARAMETERS p_test AS CHECKBOX DEFAULT abap_true.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  DATA lt_files  TYPE filetable.
  DATA lv_rc     TYPE i.
  DATA lv_action TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title            = 'Excel-bestand voor import kiezen'
      file_filter             = 'Excel (*.xlsx)|*.xlsx'
      multiselection          = abap_false
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
      user_action             = lv_action
    EXCEPTIONS
      OTHERS                  = 1 ).
  IF sy-subrc = 0 AND lv_action = cl_gui_frontend_services=>action_ok AND lt_files IS NOT INITIAL.
    p_file = lt_files[ 1 ]-filename.
  ENDIF.

START-OF-SELECTION.
  DATA lt_bin    TYPE solix_tab.
  DATA lv_length TYPE i.

  cl_gui_frontend_services=>gui_upload(
    EXPORTING
      filename                = CONV string( p_file )
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_length
    CHANGING
      data_tab                = lt_bin
    EXCEPTIONS
      OTHERS                  = 1 ).
  IF sy-subrc <> 0.
    MESSAGE |Bestand { p_file } kon niet worden geladen.| TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DATA(lv_content) = cl_bcs_convert=>solix_to_xstring( it_solix = lt_bin
                                                       iv_size  = lv_length ).

  DATA(lo_importer) = NEW zpl2cl_template_import( ).
  lo_importer->import( EXPORTING iv_content = lv_content
                       IMPORTING ev_success = DATA(lv_success)
                                 ev_message = DATA(lv_message) ).

  IF lv_success = abap_true AND p_test = abap_false.
    COMMIT ENTITIES.
    IF sy-subrc <> 0.
      ROLLBACK ENTITIES.
      lv_success = abap_false.
      lv_message = |Opslaan mislukt, er is niets geimporteerd. { lv_message }|.
    ENDIF.
  ELSE.
    ROLLBACK ENTITIES.
  ENDIF.

  WRITE: / 'Import sjabloon uit Excel' COLOR COL_HEADING.
  ULINE.
  WRITE: / 'Bestand:', p_file.
  IF p_test = abap_true.
    WRITE: / 'Testrun: er is niets opgeslagen.' COLOR COL_TOTAL.
  ENDIF.
  IF lv_success = abap_true.
    WRITE: / 'Resultaat: OK' COLOR COL_POSITIVE.
  ELSE.
    WRITE: / 'Resultaat: FOUT' COLOR COL_NEGATIVE.
  ENDIF.
  SKIP.

  " Melding over meerdere regels tonen
  DATA(lv_rest) = lv_message.
  DATA lv_line TYPE c LENGTH 100.
  WHILE lv_rest IS NOT INITIAL.
    lv_line = lv_rest.
    WRITE: / lv_line.
    IF strlen( lv_rest ) > 100.
      lv_rest = substring( val = lv_rest off = 100 ).
    ELSE.
      CLEAR lv_rest.
    ENDIF.
  ENDWHILE.
