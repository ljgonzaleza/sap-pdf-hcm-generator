*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_VALIDATOR
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Validaciones de negocio generación PDF
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS validate_generation_request
      IMPORTING
        pi_pernr       TYPE persno
        pi_template_id TYPE zde_contpe_tpl_id
        pi_language    TYPE spras DEFAULT sy-langu
      RAISING
        zcx_hhr_contpe_generation_error.

    METHODS validate_template_exists
      IMPORTING
        pi_template_id TYPE zde_contpe_tpl_id
      RETURNING
        VALUE(re_valid) TYPE abap_bool.

    METHODS validate_active_version
      IMPORTING
        pi_template_id TYPE zde_contpe_tpl_id
        pi_language    TYPE spras DEFAULT sy-langu
      RETURNING
        VALUE(re_valid) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS raise_validation_error
      IMPORTING
        pi_message TYPE string
      RAISING
        zcx_hhr_contpe_generation_error.
ENDCLASS.

CLASS zcl_hhr_contpe_validator IMPLEMENTATION.

  METHOD validate_generation_request.
    IF pi_pernr IS INITIAL.
      raise_validation_error( 'PERNR requerido' ).
    ENDIF.

    IF pi_template_id IS INITIAL.
      raise_validation_error( 'TEMPLATE_ID requerido' ).
    ENDIF.

    IF validate_template_exists( pi_template_id ) = abap_false.
      raise_validation_error( |Plantilla { pi_template_id } no existe| ).
    ENDIF.

    IF validate_active_version(
         pi_template_id = pi_template_id
         pi_language    = pi_language ) = abap_false.
      raise_validation_error( |Sin versión activa para { pi_template_id }| ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_template_exists.
    SELECT SINGLE @abap_true
      FROM zhr_contpe_templates
      WHERE template_id = @pi_template_id
      INTO @re_valid.
  ENDMETHOD.

  METHOD validate_active_version.
    SELECT SINGLE @abap_true
      FROM zhr_contpe_tpl_ver
      WHERE template_id = @pi_template_id
        AND spras       = @pi_language
        AND status      = 'A'
      INTO @re_valid.
  ENDMETHOD.

  METHOD raise_validation_error.
    RAISE EXCEPTION TYPE zcx_hhr_contpe_generation_error
      EXPORTING
        error_message = pi_message.
  ENDMETHOD.

ENDCLASS.
