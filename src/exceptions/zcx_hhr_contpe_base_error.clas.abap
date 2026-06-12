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

    ALIASES t100key FOR if_t100_message~t100key.

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

    METHODS display_message.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_hhr_contpe_base_error IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).

    me->error_message = error_message.

    CLEAR me->textid.
    IF textid IS INITIAL.
      me->t100key = zhhr_contpe_base_error.
    ELSE.
      me->t100key = textid.
    ENDIF.
  ENDMETHOD.

  METHOD display_message.
    DATA: ls_key TYPE scx_t100key,
          lv_v1  TYPE string,
          lv_v2  TYPE string,
          lv_v3  TYPE string,
          lv_v4  TYPE string.

    ls_key = me->t100key.

    IF ls_key-attr1 = 'ERROR_MESSAGE'.
      lv_v1 = me->error_message.
    ENDIF.

    MESSAGE ID ls_key-msgid
            TYPE 'E'
            NUMBER ls_key-msgno
            WITH lv_v1 lv_v2 lv_v3 lv_v4.
  ENDMETHOD.

ENDCLASS.
