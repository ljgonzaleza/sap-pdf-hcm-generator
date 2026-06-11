*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_GENERATOR
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Orquestador generación documentos PDF HCM
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS generate_document
      IMPORTING
        pi_pernr         TYPE persno
        pi_template_id   TYPE zde_contpe_tpl_id
        pi_language      TYPE spras DEFAULT sy-langu
        pi_signature_id  TYPE zde_contpe_signature_id OPTIONAL
        pi_ref_date      TYPE datum DEFAULT sy-datum
        pi_preview       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(pe_pdf)    TYPE xstring
      RAISING
        zcx_hhr_contpe_generation_error.

    METHODS generate_mass
      IMPORTING
        pt_pernr_list    TYPE zhr_contpe_tt_pernr
        pi_template_id   TYPE zde_contpe_tpl_id
        pi_language      TYPE spras DEFAULT sy-langu
        pi_signature_id  TYPE zde_contpe_signature_id OPTIONAL
        pi_background    TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(pe_job_id) TYPE zde_contpe_job_id
      RAISING
        zcx_hhr_contpe_generation_error.

    METHODS get_document_history
      IMPORTING
        pi_pernr         TYPE persno OPTIONAL
        pi_date_from     TYPE datum OPTIONAL
        pi_date_to       TYPE datum OPTIONAL
        pi_template_id   TYPE zde_contpe_tpl_id OPTIONAL
      RETURNING
        VALUE(pt_docs)   TYPE zhr_contpe_tt_doc_log.

    METHODS retrieve_document
      IMPORTING
        pi_document_id TYPE zde_contpe_document_id
      RETURNING
        VALUE(pe_pdf)  TYPE xstring
      RAISING
        zcx_hhr_contpe_not_found.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA go_template_engine TYPE REF TO zcl_hhr_contpe_template_engine.
    DATA go_data_provider TYPE REF TO zcl_hhr_contpe_data_provider.
    DATA go_renderer_factory TYPE REF TO zcl_hhr_contpe_renderer_factory.
    DATA go_archiver TYPE REF TO zcl_hhr_contpe_archiver.
    DATA go_validator TYPE REF TO zcl_hhr_contpe_validator.
    DATA go_signature_mgr TYPE REF TO zcl_hhr_contpe_signature_mgr.
    DATA mv_initialized TYPE abap_bool.

    METHODS initialize.
    METHODS validate_inputs
      IMPORTING
        pi_pernr        TYPE persno
        pi_template_id  TYPE zde_contpe_tpl_id
        pi_language     TYPE spras
      RAISING
        zcx_hhr_contpe_generation_error.

    METHODS wrap_exception
      IMPORTING
        ix_error TYPE REF TO zcx_hhr_contpe_base_error
      RAISING
        zcx_hhr_contpe_generation_error.

ENDCLASS.

CLASS zcl_hhr_contpe_generator IMPLEMENTATION.

  METHOD generate_document.
    initialize( ).

    validate_inputs(
      pi_pernr       = pi_pernr
      pi_template_id = pi_template_id
      pi_language    = pi_language ).

    TRY.
        DATA(lt_values) = go_data_provider->get_field_values(
          pi_pernr    = pi_pernr
          pi_date     = pi_ref_date
          pi_language = pi_language ).

        DATA(lv_html) = go_template_engine->process_template(
          pi_template_id  = pi_template_id
          pi_language     = pi_language
          pt_field_values = lt_values ).

        DATA(lv_signature_img) = VALUE xstring( ).
        IF pi_signature_id IS NOT INITIAL.
          lv_signature_img = go_signature_mgr->get_signature_image( pi_signature_id ).
        ENDIF.

        DATA(ls_metadata) = VALUE zhr_contpe_s_pdf_metadata(
          pernr          = pi_pernr
          template_id    = pi_template_id
          spras          = pi_language
          generated_by   = sy-uname
          generated_at   = zcl_hhr_contpe_utils=>get_timestamp( ) ).

        pe_pdf = go_renderer_factory->get_renderer( )->render(
          pi_html          = lv_html
          pi_signature_img = lv_signature_img
          ps_metadata      = ls_metadata ).

        IF pi_preview = abap_true.
          RETURN.
        ENDIF.

        DATA(lv_archiv_id) = go_archiver->store_document(
          pi_pdf         = pe_pdf
          pi_pernr       = pi_pernr
          pi_template_id = pi_template_id ).

      CATCH zcx_hhr_contpe_base_error INTO DATA(lx_error).
        wrap_exception( lx_error ).
    ENDTRY.
  ENDMETHOD.

  METHOD generate_mass.
    initialize( ).

    IF lines( pt_pernr_list ) = 0.
      RAISE EXCEPTION TYPE zcx_hhr_contpe_generation_error
        EXPORTING
          error_message = 'Lista de empleados vacía'.
    ENDIF.

    pe_job_id = |{ sy-datum }{ sy-uzeit }|.

    LOOP AT pt_pernr_list ASSIGNING FIELD-SYMBOL(<lv_pernr>).
      TRY.
          generate_document(
            pi_pernr       = <lv_pernr>
            pi_template_id = pi_template_id
            pi_language    = pi_language
            pi_signature_id = pi_signature_id
            pi_preview     = abap_false ).
        CATCH zcx_hhr_contpe_generation_error.
          CONTINUE.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_document_history.
    SELECT document_id
           pernr
           template_id
           version
           spras
           signature_id
           archiv_id
           pdf_hash
           generated_by
           generated_at
           job_id
           status
           error_msg
      FROM zhr_contpe_doc_log
      WHERE ( @pi_pernr IS INITIAL OR pernr = @pi_pernr )
        AND ( @pi_template_id IS INITIAL OR template_id = @pi_template_id )
      INTO CORRESPONDING FIELDS OF TABLE @pt_docs.
  ENDMETHOD.

  METHOD retrieve_document.
    SELECT SINGLE archiv_id
      FROM zhr_contpe_doc_log
      WHERE document_id = @pi_document_id
      INTO @DATA(lv_archiv_id).

    IF sy-subrc <> 0 OR lv_archiv_id IS INITIAL.
      RAISE EXCEPTION TYPE zcx_hhr_contpe_not_found
        EXPORTING
          error_message = |Documento { pi_document_id } no encontrado|.
    ENDIF.

    " @001 Recuperación ArchiveLink pendiente Sprint 6
    RAISE EXCEPTION TYPE zcx_hhr_contpe_not_found
      EXPORTING
        error_message = 'Recuperación ArchiveLink pendiente (Sprint 6)'.
  ENDMETHOD.

  METHOD initialize.
    IF mv_initialized = abap_true.
      RETURN.
    ENDIF.

    go_template_engine   = NEW zcl_hhr_contpe_template_engine( ).
    go_data_provider     = NEW zcl_hhr_contpe_data_provider( ).
    go_renderer_factory  = NEW zcl_hhr_contpe_renderer_factory( ).
    go_archiver          = NEW zcl_hhr_contpe_archiver( ).
    go_validator         = NEW zcl_hhr_contpe_validator( ).
    go_signature_mgr     = NEW zcl_hhr_contpe_signature_mgr( ).
    mv_initialized       = abap_true.
  ENDMETHOD.

  METHOD validate_inputs.
    go_validator->validate_generation_request(
      pi_pernr       = pi_pernr
      pi_template_id = pi_template_id
      pi_language    = pi_language ).
  ENDMETHOD.

  METHOD wrap_exception.
    RAISE EXCEPTION TYPE zcx_hhr_contpe_generation_error
      EXPORTING
        error_message = ix_error->error_message
        previous      = ix_error.
  ENDMETHOD.

ENDCLASS.
