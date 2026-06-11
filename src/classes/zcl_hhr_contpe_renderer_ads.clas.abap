*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_RENDERER_ADS
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Renderizado PDF vía Adobe Forms / ADS
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_renderer_ads DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_hhr_contpe_renderer.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF lc_default,
        form_name TYPE fpname VALUE 'ZHR_CONTPE_F_001',
        config_key TYPE zde_contpe_param_key VALUE 'ADOBE_FORM_NAME',
      END OF lc_default.

    METHODS get_form_name
      RETURNING
        VALUE(re_form_name) TYPE fpname.

    METHODS build_form_data
      IMPORTING
        pi_html          TYPE string
        pi_signature_img TYPE xstring OPTIONAL
        pi_logo_img      TYPE xstring OPTIONAL
        ps_metadata      TYPE zhr_contpe_s_pdf_metadata OPTIONAL
      RETURNING
        VALUE(rs_form_data) TYPE zhr_contpe_s_form_data.

    METHODS execute_fp_job
      IMPORTING
        is_form_data TYPE zhr_contpe_s_form_data
        iv_form_name TYPE fpname
      RETURNING
        VALUE(re_pdf) TYPE xstring
      RAISING
        zcx_hhr_contpe_render_error.

    METHODS raise_fp_error
      IMPORTING
        pi_message TYPE string
      RAISING
        zcx_hhr_contpe_render_error.

    METHODS raise_fp_subrc
      IMPORTING
        pi_step TYPE string
      RAISING
        zcx_hhr_contpe_render_error.
ENDCLASS.

CLASS zcl_hhr_contpe_renderer_ads IMPLEMENTATION.

  METHOD zif_hhr_contpe_renderer~render.
    DATA(ls_form_data) = build_form_data(
      pi_html          = pi_html
      pi_signature_img = pi_signature_img
      pi_logo_img      = pi_logo_img
      ps_metadata      = ps_metadata ).

    pe_pdf = execute_fp_job(
      is_form_data = ls_form_data
      iv_form_name = get_form_name( ) ).
  ENDMETHOD.

  METHOD get_form_name.
    re_form_name = lc_default-form_name.

    DATA(lv_config) = zcl_hhr_contpe_config=>get_instance( )->get_parameter( lc_default-config_key ).
    IF lv_config IS NOT INITIAL.
      re_form_name = lv_config.
    ENDIF.
  ENDMETHOD.

  METHOD build_form_data.
    rs_form_data-html_content = zcl_hhr_contpe_html_prep=>prepare_for_ads( pi_html ).
    rs_form_data-signature_img = pi_signature_img.
    rs_form_data-logo_img = pi_logo_img.

    IF ps_metadata IS NOT INITIAL.
      rs_form_data-pernr = ps_metadata-pernr.
      rs_form_data-template_id = ps_metadata-template_id.
      rs_form_data-version = ps_metadata-version.
      rs_form_data-generated_by = ps_metadata-generated_by.
      rs_form_data-document_title = ps_metadata-document_title.

      IF ps_metadata-generated_at IS NOT INITIAL.
        rs_form_data-generated_at = |{ ps_metadata-generated_at TIMESTAMP = ISO }|.
      ENDIF.
    ENDIF.

    IF rs_form_data-generated_by IS INITIAL.
      rs_form_data-generated_by = sy-uname.
    ENDIF.

    IF rs_form_data-generated_at IS INITIAL.
      rs_form_data-generated_at = zcl_hhr_contpe_utils=>format_date( sy-datum ).
    ENDIF.

    IF rs_form_data-document_title IS INITIAL AND rs_form_data-template_id IS NOT INITIAL.
      rs_form_data-document_title = rs_form_data-template_id.
    ENDIF.
  ENDMETHOD.

  METHOD execute_fp_job.
    DATA ls_output TYPE sfpoutputparams.
    DATA ls_doc TYPE sfpdocparams.
    DATA ls_form_output TYPE fpformoutput.
    DATA lv_fm_name TYPE funcname.

    ls_output-getpdf = abap_true.
    ls_output-nodialog = abap_true.
    ls_output-preview = abap_false.
    ls_output-replace = abap_true.

    ls_doc-langu = sy-langu.
    ls_doc-country = 'PE'.
    ls_doc-formname = iv_form_name.
    ls_doc-replid = sy-repid.

    TRY.
        CALL FUNCTION 'FP_JOB_OPEN'
          CHANGING
            ie_outputparams = ls_output
          EXCEPTIONS
            cancel          = 1
            usage_error     = 2
            system_error    = 3
            internal_error  = 4
            OTHERS          = 5.

        IF sy-subrc <> 0.
          raise_fp_subrc( 'FP_JOB_OPEN' ).
        ENDIF.

        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = iv_form_name
          IMPORTING
            e_funcname = lv_fm_name
          EXCEPTIONS
            not_found  = 1
            OTHERS     = 2.

        IF sy-subrc <> 0 OR lv_fm_name IS INITIAL.
          raise_fp_error( |Adobe Form { iv_form_name } no encontrado (SFP)| ).
        ENDIF.

        CALL FUNCTION lv_fm_name
          EXPORTING
            /1bcdwb/docparams  = ls_doc
            is_form_data       = is_form_data
          IMPORTING
            /1bcdwb/formoutput = ls_form_output
          EXCEPTIONS
            usage_error        = 1
            system_error       = 2
            internal_error     = 3
            OTHERS             = 4.

        IF sy-subrc <> 0.
          raise_fp_subrc( |FM { lv_fm_name }| ).
        ENDIF.

        CALL FUNCTION 'FP_JOB_CLOSE'
          EXCEPTIONS
            usage_error    = 1
            system_error   = 2
            internal_error = 3
            OTHERS         = 4.

        IF sy-subrc <> 0.
          raise_fp_subrc( 'FP_JOB_CLOSE' ).
        ENDIF.

        re_pdf = ls_form_output-pdf.

        IF re_pdf IS INITIAL.
          raise_fp_error( 'ADS retornó PDF vacío' ).
        ENDIF.

      CATCH zcx_hhr_contpe_render_error.
        RAISE.
      CATCH cx_fp_api_usage cx_fp_api_internal cx_fp_api_repository INTO DATA(lx_fp).
        raise_fp_error( lx_fp->get_text( ) ).
      CATCH cx_root INTO DATA(lx_root).
        raise_fp_error( lx_root->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD raise_fp_error.
    RAISE EXCEPTION TYPE zcx_hhr_contpe_render_error
      EXPORTING
        error_message = pi_message.
  ENDMETHOD.

  METHOD raise_fp_subrc.
    raise_fp_error( |Error ADS en { pi_step } (SY-SUBRC={ sy-subrc })| ).
  ENDMETHOD.

ENDCLASS.
