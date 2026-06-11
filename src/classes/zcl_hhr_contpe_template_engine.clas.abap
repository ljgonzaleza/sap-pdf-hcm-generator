*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_TEMPLATE_ENGINE
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Procesamiento plantillas HTML
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_template_engine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS process_template
      IMPORTING
        pi_template_id TYPE zde_contpe_tpl_id
        pi_language    TYPE spras DEFAULT sy-langu
        pt_field_values TYPE zcl_hhr_contpe_data_provider=>tt_field_value
      RETURNING
        VALUE(re_html) TYPE string
      RAISING
        zcx_hhr_contpe_template_error.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS load_active_content
      IMPORTING
        pi_template_id TYPE zde_contpe_tpl_id
        pi_language    TYPE spras
      RETURNING
        VALUE(re_content) TYPE string
      RAISING
        zcx_hhr_contpe_template_error.
ENDCLASS.

CLASS zcl_hhr_contpe_template_engine IMPLEMENTATION.

  METHOD process_template.
    re_html = load_active_content(
      pi_template_id = pi_template_id
      pi_language    = pi_language ).

    LOOP AT pt_field_values ASSIGNING FIELD-SYMBOL(<ls_value>).
      DATA(lv_pattern_brace) = '{{' && <ls_value>-placeholder && '}}'.
      DATA(lv_pattern_angle) = '&lt;&lt;' && <ls_value>-placeholder && '&gt;&gt;'.
      REPLACE ALL OCCURRENCES OF lv_pattern_brace IN re_html WITH <ls_value>-value.
      REPLACE ALL OCCURRENCES OF lv_pattern_angle IN re_html WITH <ls_value>-value.
    ENDLOOP.
  ENDMETHOD.

  METHOD load_active_content.
    SELECT SINGLE content
      FROM zhr_contpe_tver
      WHERE template_id = @pi_template_id
        AND spras       = @pi_language
        AND status      = 'A'
      INTO @re_content.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_hhr_contpe_template_error
        EXPORTING
          error_message = |Versión activa no encontrada: { pi_template_id }|.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
