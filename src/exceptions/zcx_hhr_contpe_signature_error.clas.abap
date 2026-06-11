*&---------------------------------------------------------------------*
*& Clase   ZCX_HHR_CONTPE_SIGNATURE_ERROR
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Error gestión firmas
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcx_hhr_contpe_signature_error DEFINITION
  PUBLIC
  INHERITING FROM zcx_hhr_contpe_base_error
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF zhhr_contpe_signature_error,
        msgid TYPE symsgid VALUE 'ZHR_CONTPE',
        msgno TYPE symsgno VALUE '015',
        attr1 TYPE scx_attrname VALUE 'ERROR_MESSAGE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF zhhr_contpe_signature_error.

    METHODS constructor
      IMPORTING
        textid        LIKE if_t100_message=>t100key OPTIONAL
        previous      LIKE previous OPTIONAL
        error_message TYPE string OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_hhr_contpe_signature_error IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
      previous      = previous
      error_message = error_message ).

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = zhhr_contpe_signature_error.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
