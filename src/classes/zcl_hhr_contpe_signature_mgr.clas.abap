*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_SIGNATURE_MGR
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Gestión imágenes de firma
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_signature_mgr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS get_signature_image
      IMPORTING
        pi_signature_id TYPE zde_contpe_signature_id
      RETURNING
        VALUE(re_image) TYPE xstring
      RAISING
        zcx_hhr_contpe_signature_error.

    METHODS validate_signature
      IMPORTING
        pi_signature_id TYPE zde_contpe_signature_id
      RETURNING
        VALUE(re_valid) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_hhr_contpe_signature_mgr IMPLEMENTATION.

  METHOD get_signature_image.
    SELECT SINGLE image_data
      FROM zhr_contpe_sign
      WHERE signature_id = @pi_signature_id
        AND status       = 'A'
      INTO @re_image.

    IF sy-subrc <> 0 OR re_image IS INITIAL.
      RAISE EXCEPTION TYPE zcx_hhr_contpe_signature_error
        EXPORTING
          error_message = |Firma { pi_signature_id } no disponible|.
    ENDIF.
  ENDMETHOD.

  METHOD validate_signature.
    SELECT SINGLE @abap_true
      FROM zhr_contpe_sign
      WHERE signature_id = @pi_signature_id
        AND status       = 'A'
      INTO @re_valid.
  ENDMETHOD.

ENDCLASS.
