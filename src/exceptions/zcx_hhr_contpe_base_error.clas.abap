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

    ALIASES msg_type FOR if_t100_dyn_msg~msg_type.

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
    DATA if_t100_dyn_msg~msg_type TYPE symsgty VALUE 'E'.
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

  METHOD if_t100_dyn_msg~get_text.
    DATA(lv_msgv1) TYPE string.
    DATA(lv_msgv2) TYPE string.
    DATA(lv_msgv3) TYPE string.
    DATA(lv_msgv4) TYPE string.

    IF if_t100_message~t100key-attr1 IS NOT INITIAL.
      ASSIGN me->( if_t100_message~t100key-attr1 ) TO FIELD-SYMBOL(<attr1>).
      IF sy-subrc = 0.
        lv_msgv1 = |{ <attr1> }|.
      ENDIF.
    ENDIF.

    IF if_t100_message~t100key-attr2 IS NOT INITIAL.
      ASSIGN me->( if_t100_message~t100key-attr2 ) TO FIELD-SYMBOL(<attr2>).
      IF sy-subrc = 0.
        lv_msgv2 = |{ <attr2> }|.
      ENDIF.
    ENDIF.

    IF if_t100_message~t100key-attr3 IS NOT INITIAL.
      ASSIGN me->( if_t100_message~t100key-attr3 ) TO FIELD-SYMBOL(<attr3>).
      IF sy-subrc = 0.
        lv_msgv3 = |{ <attr3> }|.
      ENDIF.
    ENDIF.

    IF if_t100_message~t100key-attr4 IS NOT INITIAL.
      ASSIGN me->( if_t100_message~t100key-attr4 ) TO FIELD-SYMBOL(<attr4>).
      IF sy-subrc = 0.
        lv_msgv4 = |{ <attr4> }|.
      ENDIF.
    ENDIF.

    MESSAGE ID if_t100_message~t100key-msgid
            TYPE if_t100_dyn_msg~msg_type
            NUMBER if_t100_message~t100key-msgno
            WITH lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4
            INTO rv_text.
  ENDMETHOD.

  METHOD if_t100_dyn_msg~get_longtext.
    rv_text = if_t100_dyn_msg~get_text( ).
  ENDMETHOD.

ENDCLASS.
