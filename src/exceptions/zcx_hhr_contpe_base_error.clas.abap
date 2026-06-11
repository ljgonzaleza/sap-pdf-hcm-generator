*&---------------------------------------------------------------------*
*& Clase   ZCX_HHR_CONTPE_BASE_ERROR
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Excepción base generador PDF HCM
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcx_hhr_contpe_base_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.
    INTERFACES if_t100_dyn_msg.

    CONSTANTS:
      BEGIN OF zhhr_contpe_base_error,
        msgid TYPE symsgid VALUE 'ZHR_CONTPE',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'ERROR_MESSAGE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF zhhr_contpe_base_error.

    DATA error_message TYPE string READ-ONLY.

    METHODS constructor
      IMPORTING
        textid        LIKE if_t100_message=>t100key OPTIONAL
        previous      LIKE previous OPTIONAL
        error_message TYPE string OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_hhr_contpe_base_error IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).

    me->error_message = error_message.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = zhhr_contpe_base_error.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
