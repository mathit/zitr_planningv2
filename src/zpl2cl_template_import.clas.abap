"! <p class="shorttext synchronized">Import van sjabloon, docenten en lokalen uit Excel</p>
"! Leest een XLSX-bestand (tabbladen Template, Module, Item, Teacher, Room)
"! en maakt via EML docenten, lokalen en een sjabloon met blokken,
"! onderdelen en ondersteunende docenten aan.
"! De methode voert GEEN commit uit: de aanroeper (RAP-actie of
"! console-app) is verantwoordelijk voor COMMIT ENTITIES.
CLASS zpl2cl_template_import DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_template,
        template_key  TYPE string,
        template_name TYPE string,
        description   TYPE string,
        is_active     TYPE string,
      END OF ty_template,
      tt_template TYPE STANDARD TABLE OF ty_template WITH EMPTY KEY,

      BEGIN OF ty_module,
        template_key     TYPE string,
        module_key       TYPE string,
        module_name      TYPE string,
        sequence         TYPE string,
        track            TYPE string,
        duration_days    TYPE string,
        anchor_day       TYPE string,
        prerequisite_key TYPE string,
        is_swappable     TYPE string,
      END OF ty_module,
      tt_module TYPE STANDARD TABLE OF ty_module WITH EMPTY KEY,

      BEGIN OF ty_item,
        module_key       TYPE string,
        title            TYPE string,
        day_offset       TYPE string,
        time_from        TYPE string,
        time_to          TYPE string,
        item_type        TYPE string,
        location         TYPE string,
        lead_teacher     TYPE string,
        room_type        TYPE string,
        support_teachers TYPE string,
      END OF ty_item,
      tt_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY,

      BEGIN OF ty_teacher,
        short_name  TYPE string,
        full_name   TYPE string,
        discipline  TYPE string,
        email       TYPE string,
        is_external TYPE string,
        is_active   TYPE string,
      END OF ty_teacher,
      tt_teacher TYPE STANDARD TABLE OF ty_teacher WITH EMPTY KEY,

      BEGIN OF ty_room,
        room_name  TYPE string,
        capacity   TYPE string,
        room_email TYPE string,
        is_active  TYPE string,
      END OF ty_room,
      tt_room TYPE STANDARD TABLE OF ty_room WITH EMPTY KEY.

    "! Importeert het Excel-bestand. Geeft een samenvatting of foutmelding terug.
    METHODS import
      IMPORTING iv_content TYPE xstring
      EXPORTING ev_success TYPE abap_bool
                ev_message TYPE string.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_key_uuid,
        key  TYPE string,
        uuid TYPE sysuuid_x16,
      END OF ty_key_uuid,
      tt_key_uuid TYPE HASHED TABLE OF ty_key_uuid WITH UNIQUE KEY key.

    DATA mt_teacher_uuid TYPE tt_key_uuid.

    METHODS read_sheet
      IMPORTING io_document TYPE REF TO if_xco_xlsx_ra_document
                iv_sheet    TYPE string
                iv_last_col TYPE string
                ir_data     TYPE REF TO data.

    METHODS import_teachers
      IMPORTING it_teacher TYPE tt_teacher
      RETURNING VALUE(rv_count) TYPE i.

    METHODS import_rooms
      IMPORTING it_room TYPE tt_room
      RETURNING VALUE(rv_count) TYPE i.

    METHODS import_template
      IMPORTING is_template TYPE ty_template
                it_module   TYPE tt_module
                it_item     TYPE tt_item
      EXPORTING ev_success  TYPE abap_bool
                ev_message  TYPE string.

    METHODS teacher_uuid
      IMPORTING iv_short_name  TYPE string
      RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.

    CLASS-METHODS to_bool
      IMPORTING iv_value       TYPE string
      RETURNING VALUE(rv_bool) TYPE abap_boolean.

    CLASS-METHODS to_int
      IMPORTING iv_value      TYPE string
      RETURNING VALUE(rv_int) TYPE i.

    CLASS-METHODS to_time
      IMPORTING iv_value       TYPE string
      RETURNING VALUE(rv_time) TYPE t.

ENDCLASS.



CLASS zpl2cl_template_import IMPLEMENTATION.

  METHOD import.
    DATA lt_template TYPE tt_template.
    DATA lt_module   TYPE tt_module.
    DATA lt_item     TYPE tt_item.
    DATA lt_teacher  TYPE tt_teacher.
    DATA lt_room     TYPE tt_room.

    ev_success = abap_false.
    CLEAR ev_message.

    IF iv_content IS INITIAL.
      ev_message = `Er is geen bestand geüpload.`.
      RETURN.
    ENDIF.

    TRY.
        DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( iv_content )->read_access( ).

        read_sheet( io_document = lo_document iv_sheet = `Template` iv_last_col = `D` ir_data = REF #( lt_template ) ).
        read_sheet( io_document = lo_document iv_sheet = `Module`   iv_last_col = `I` ir_data = REF #( lt_module ) ).
        read_sheet( io_document = lo_document iv_sheet = `Item`     iv_last_col = `J` ir_data = REF #( lt_item ) ).
        read_sheet( io_document = lo_document iv_sheet = `Teacher`  iv_last_col = `F` ir_data = REF #( lt_teacher ) ).
        read_sheet( io_document = lo_document iv_sheet = `Room`     iv_last_col = `D` ir_data = REF #( lt_room ) ).
      CATCH cx_root INTO DATA(lx_read).
        ev_message = |Excel-bestand kon niet worden gelezen: { lx_read->get_text( ) }|.
        RETURN.
    ENDTRY.

    DELETE lt_template WHERE template_key IS INITIAL.
    DELETE lt_module   WHERE module_key IS INITIAL.
    DELETE lt_item     WHERE module_key IS INITIAL.
    DELETE lt_teacher  WHERE short_name IS INITIAL.
    DELETE lt_room     WHERE room_name IS INITIAL.

    IF lt_template IS INITIAL.
      ev_message = `Tabblad Template bevat geen sjabloon.`.
      RETURN.
    ENDIF.

    DATA(lv_new_teachers) = import_teachers( lt_teacher ).
    DATA(lv_new_rooms)    = import_rooms( lt_room ).

    DATA(lv_summary) = |Docenten nieuw: { lv_new_teachers }, lokalen nieuw: { lv_new_rooms }.|.

    LOOP AT lt_template INTO DATA(ls_template).
      import_template( EXPORTING is_template = ls_template
                                 it_module   = VALUE #( FOR m IN lt_module WHERE ( template_key = ls_template-template_key ) ( m ) )
                                 it_item     = lt_item
                       IMPORTING ev_success  = DATA(lv_ok)
                                 ev_message  = DATA(lv_msg) ).
      lv_summary = |{ lv_summary } { lv_msg }|.
      IF lv_ok = abap_false.
        ev_message = lv_summary.
        RETURN.
      ENDIF.
    ENDLOOP.

    ev_success = abap_true.
    ev_message = lv_summary.
  ENDMETHOD.


  METHOD read_sheet.
    DATA(lo_sheet) = io_document->get_workbook( )->worksheet->for_name( CONV #( iv_sheet ) ).
    IF lo_sheet->exists( ) = abap_false.
      RETURN.
    ENDIF.

    DATA(lo_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
      )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( CONV #( `A` ) )
      )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( CONV #( iv_last_col ) )
      )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
      )->get_pattern( ).

    lo_sheet->select( lo_pattern
      )->row_stream(
      )->operation->write_to( ir_data
      )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
      )->if_xco_xlsx_ra_operation~execute( ).
  ENDMETHOD.


  METHOD import_teachers.
    DATA lt_create TYPE TABLE FOR CREATE zpl2r_teacher\\Teacher.

    SELECT ShortName, UUID FROM zpl2r_teacher INTO TABLE @DATA(lt_existing).
    LOOP AT lt_existing INTO DATA(ls_existing).
      INSERT VALUE #( key = to_upper( condense( CONV string( ls_existing-ShortName ) ) ) uuid = ls_existing-UUID ) INTO TABLE mt_teacher_uuid.
    ENDLOOP.

    LOOP AT it_teacher INTO DATA(ls_teacher).
      DATA(lv_key) = to_upper( condense( ls_teacher-short_name ) ).
      IF line_exists( mt_teacher_uuid[ key = lv_key ] ) OR line_exists( lt_create[ %cid = lv_key ] ).
        CONTINUE.
      ENDIF.
      APPEND VALUE #( %cid       = lv_key
                      ShortName  = condense( ls_teacher-short_name )
                      FullName   = ls_teacher-full_name
                      Discipline = ls_teacher-discipline
                      Email      = ls_teacher-email
                      IsExternal = to_bool( ls_teacher-is_external )
                      IsActive   = to_bool( ls_teacher-is_active ) ) TO lt_create.
    ENDLOOP.

    IF lt_create IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zpl2r_teacher
      ENTITY Teacher
        CREATE FIELDS ( ShortName FullName Discipline Email IsExternal IsActive )
        WITH lt_create
      MAPPED DATA(ls_mapped).

    LOOP AT ls_mapped-teacher INTO DATA(ls_map).
      INSERT VALUE #( key = ls_map-%cid uuid = ls_map-UUID ) INTO TABLE mt_teacher_uuid.
    ENDLOOP.
    rv_count = lines( ls_mapped-teacher ).
  ENDMETHOD.


  METHOD import_rooms.
    DATA lt_create TYPE TABLE FOR CREATE zpl2r_room\\Room.

    SELECT RoomName FROM zpl2r_room INTO TABLE @DATA(lt_existing).

    LOOP AT it_room INTO DATA(ls_room).
      DATA(lv_name) = condense( ls_room-room_name ).
      IF line_exists( lt_existing[ RoomName = lv_name ] ) OR line_exists( lt_create[ RoomName = lv_name ] ).
        CONTINUE.
      ENDIF.
      APPEND VALUE #( %cid      = |R{ sy-tabix }|
                      RoomName  = lv_name
                      Capacity  = to_int( ls_room-capacity )
                      RoomEmail = ls_room-room_email
                      IsActive  = to_bool( ls_room-is_active ) ) TO lt_create.
    ENDLOOP.

    IF lt_create IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zpl2r_room
      ENTITY Room
        CREATE FIELDS ( RoomName Capacity RoomEmail IsActive )
        WITH lt_create
      MAPPED DATA(ls_mapped).

    rv_count = lines( ls_mapped-room ).
  ENDMETHOD.


  METHOD import_template.
    DATA lt_template TYPE TABLE FOR CREATE zpl2r_template000\\Template.
    DATA lt_module   TYPE TABLE FOR CREATE zpl2r_template000\\Template\_TemplateModule.
    DATA lt_item     TYPE TABLE FOR CREATE zpl2r_template000\\TemplateModule\_TemplateItem.
    DATA lt_teacher  TYPE TABLE FOR CREATE zpl2r_template000\\TemplateItem\_TemplateItemTeacher.
    DATA lt_prereq   TYPE TABLE FOR UPDATE zpl2r_template000\\TemplateModule.

    ev_success = abap_false.
    DATA(lv_name) = condense( is_template-template_name ).

    SELECT SINGLE @abap_true FROM zpl2r_template000
      WHERE TemplateName = @lv_name
      INTO @DATA(lv_exists).
    IF lv_exists = abap_true.
      ev_message = |Sjabloon "{ lv_name }" bestaat al en is niet opnieuw geïmporteerd.|.
      RETURN.
    ENDIF.

    DATA(lv_tpl_cid) = |TPL_{ is_template-template_key }|.
    APPEND VALUE #( %cid         = lv_tpl_cid
                    TemplateName = lv_name
                    Description  = is_template-description
                    IsActive     = to_bool( is_template-is_active ) ) TO lt_template.

    " Blokken (modules, workshops, vaste blokken)
    APPEND VALUE #( %cid_ref = lv_tpl_cid ) TO lt_module ASSIGNING FIELD-SYMBOL(<ls_module_cba>).
    LOOP AT it_module INTO DATA(ls_module).
      APPEND VALUE #( %cid         = |MOD_{ ls_module-module_key }|
                      ModuleName   = ls_module-module_name
                      Sequence     = to_int( ls_module-sequence )
                      Track        = ls_module-track
                      DurationDays = to_int( ls_module-duration_days )
                      AnchorDay    = to_int( ls_module-anchor_day )
                      IsSwappable  = to_bool( ls_module-is_swappable ) ) TO <ls_module_cba>-%target.
    ENDLOOP.

    " Onderdelen en ondersteunende docenten
    LOOP AT it_item INTO DATA(ls_item).
      DATA(lv_item_index) = sy-tabix.
      IF NOT line_exists( it_module[ module_key = ls_item-module_key ] ).
        CONTINUE.
      ENDIF.
      DATA(lv_mod_cid)  = |MOD_{ ls_item-module_key }|.
      DATA(lv_item_cid) = |ITM_{ lv_item_index }|.

      READ TABLE lt_item ASSIGNING FIELD-SYMBOL(<ls_item_cba>) WITH KEY %cid_ref = lv_mod_cid.
      IF sy-subrc <> 0.
        APPEND VALUE #( %cid_ref = lv_mod_cid ) TO lt_item ASSIGNING <ls_item_cba>.
      ENDIF.
      APPEND VALUE #( %cid            = lv_item_cid
                      Title           = ls_item-title
                      DayOffset       = to_int( ls_item-day_offset )
                      TimeFrom        = to_time( ls_item-time_from )
                      TimeTo          = to_time( ls_item-time_to )
                      ItemType        = ls_item-item_type
                      Location        = ls_item-location
                      LeadTeacherUUID = teacher_uuid( ls_item-lead_teacher )
                      RoomType        = ls_item-room_type ) TO <ls_item_cba>-%target.

      IF ls_item-support_teachers IS NOT INITIAL.
        SPLIT ls_item-support_teachers AT `;` INTO TABLE DATA(lt_support).
        APPEND VALUE #( %cid_ref = lv_item_cid ) TO lt_teacher ASSIGNING FIELD-SYMBOL(<ls_teacher_cba>).
        LOOP AT lt_support INTO DATA(lv_support).
          DATA(lv_uuid) = teacher_uuid( lv_support ).
          IF lv_uuid IS NOT INITIAL.
            APPEND VALUE #( %cid        = |{ lv_item_cid }_T{ sy-tabix }|
                            TeacherUUID = lv_uuid ) TO <ls_teacher_cba>-%target.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zpl2r_template000
      ENTITY Template
        CREATE FIELDS ( TemplateName Description IsActive ) WITH lt_template
        CREATE BY \_TemplateModule
          FIELDS ( ModuleName Sequence Track DurationDays AnchorDay IsSwappable ) WITH lt_module
      ENTITY TemplateModule
        CREATE BY \_TemplateItem
          FIELDS ( Title DayOffset TimeFrom TimeTo ItemType Location LeadTeacherUUID RoomType ) WITH lt_item
      ENTITY TemplateItem
        CREATE BY \_TemplateItemTeacher
          FIELDS ( TeacherUUID ) WITH lt_teacher
      MAPPED DATA(ls_mapped)
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed IS NOT INITIAL.
      ev_message = |Sjabloon "{ lv_name }" kon niet worden aangemaakt.|.
      LOOP AT ls_reported-template INTO DATA(ls_rep) WHERE %msg IS BOUND.
        ev_message = |{ ev_message } { ls_rep-%msg->if_message~get_text( ) }|.
        EXIT.
      ENDLOOP.
      RETURN.
    ENDIF.

    " Voorgaande blokken koppelen nu de UUID's bekend zijn
    LOOP AT it_module INTO ls_module WHERE prerequisite_key IS NOT INITIAL.
      DATA(lv_cid) = |MOD_{ ls_module-module_key }|.
      DATA(lv_pre_cid) = |MOD_{ ls_module-prerequisite_key }|.
      READ TABLE ls_mapped-templatemodule INTO DATA(ls_mod_map) WITH KEY %cid = lv_cid.
      CHECK sy-subrc = 0.
      READ TABLE ls_mapped-templatemodule INTO DATA(ls_pre_map) WITH KEY %cid = lv_pre_cid.
      CHECK sy-subrc = 0.
      APPEND VALUE #( UUID = ls_mod_map-UUID PrerequisiteModuleUUID = ls_pre_map-UUID ) TO lt_prereq.
    ENDLOOP.

    IF lt_prereq IS NOT INITIAL.
      MODIFY ENTITIES OF zpl2r_template000
        ENTITY TemplateModule
          UPDATE FIELDS ( PrerequisiteModuleUUID ) WITH lt_prereq.
    ENDIF.

    ev_success = abap_true.
    ev_message = |Sjabloon "{ lv_name }" aangemaakt met { lines( ls_mapped-templatemodule ) } blokken en { lines( ls_mapped-templateitem ) } onderdelen.|.
  ENDMETHOD.


  METHOD teacher_uuid.
    DATA(lv_key) = to_upper( condense( iv_short_name ) ).
    IF lv_key IS INITIAL.
      RETURN.
    ENDIF.
    rv_uuid = VALUE #( mt_teacher_uuid[ key = lv_key ]-uuid OPTIONAL ).
  ENDMETHOD.


  METHOD to_bool.
    rv_bool = xsdbool( to_upper( condense( iv_value ) ) = `X` OR to_upper( condense( iv_value ) ) = `TRUE` ).
  ENDMETHOD.


  METHOD to_int.
    DATA(lv_value) = condense( iv_value ).
    IF lv_value IS INITIAL OR lv_value CN '0123456789'.
      RETURN.
    ENDIF.
    rv_int = CONV i( lv_value ).
  ENDMETHOD.


  METHOD to_time.
    DATA(lv_value) = replace( val = condense( iv_value ) sub = `:` with = `` occ = 0 ).
    IF strlen( lv_value ) = 3.
      lv_value = |0{ lv_value }|.
    ENDIF.
    IF strlen( lv_value ) <> 4 OR lv_value CN '0123456789'.
      RETURN.
    ENDIF.
    rv_time = |{ lv_value }00|.
  ENDMETHOD.

ENDCLASS.
