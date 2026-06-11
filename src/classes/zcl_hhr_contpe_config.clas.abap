*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_CONFIG
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Lectura parámetros ZHR_CONTPE_CFG
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_config DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING
        VALUE(ro_instance) TYPE REF TO zcl_hhr_contpe_config.

    METHODS get_parameter
      IMPORTING
        pi_param_key TYPE zde_contpe_param_key
      RETURNING
        VALUE(re_value) TYPE string.

    METHODS refresh_cache.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO zcl_hhr_contpe_config.

    TYPES:
      BEGIN OF ty_config_entry,
        param_key   TYPE zde_contpe_param_key,
        param_value TYPE string,
      END OF ty_config_entry,
      tt_config_entry TYPE HASHED TABLE OF ty_config_entry WITH UNIQUE KEY param_key.

    DATA mt_cache TYPE tt_config_entry.

    METHODS constructor.
    METHODS load_cache.
ENDCLASS.

CLASS zcl_hhr_contpe_config IMPLEMENTATION.

  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW zcl_hhr_contpe_config( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD constructor.
    load_cache( ).
  ENDMETHOD.

  METHOD get_parameter.
    DATA(ls_entry) = VALUE ty_config_entry( ).
    READ TABLE mt_cache INTO ls_entry WITH KEY param_key = pi_param_key.
    IF sy-subrc = 0.
      re_value = ls_entry-param_value.
    ENDIF.
  ENDMETHOD.

  METHOD refresh_cache.
    CLEAR mt_cache.
    load_cache( ).
  ENDMETHOD.

  METHOD load_cache.
    DATA lt_config TYPE STANDARD TABLE OF zhr_contpe_cfg.

    SELECT param_key
           param_value
      FROM zhr_contpe_cfg
      INTO CORRESPONDING FIELDS OF TABLE @lt_config.

    CLEAR mt_cache.
    LOOP AT lt_config ASSIGNING FIELD-SYMBOL(<ls_config>).
      INSERT VALUE #(
        param_key   = <ls_config>-param_key
        param_value = <ls_config>-param_value ) INTO TABLE mt_cache.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
