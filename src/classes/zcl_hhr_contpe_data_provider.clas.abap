*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_DATA_PROVIDER
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Lectura datos empleado e infotipos
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_data_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_field_value,
        placeholder TYPE zde_contpe_placeholder,
        value       TYPE string,
      END OF ty_field_value,
      tt_field_value TYPE STANDARD TABLE OF ty_field_value WITH EMPTY KEY.

    METHODS get_field_values
      IMPORTING
        pi_pernr         TYPE persno
        pt_placeholders  TYPE zhr_contpe_tt_placeholder OPTIONAL
        pi_date          TYPE datum DEFAULT sy-datum
        pi_language      TYPE spras DEFAULT sy-langu
      RETURNING
        VALUE(rt_values) TYPE tt_field_value
      RAISING
        zcx_hhr_contpe_data_error.

    METHODS calculate_field
      IMPORTING
        pi_placeholder TYPE zde_contpe_placeholder
        pi_pernr       TYPE persno
        pi_date        TYPE datum DEFAULT sy-datum
      RETURNING
        VALUE(re_value) TYPE string
      RAISING
        zcx_hhr_contpe_data_error.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS read_fieldmap
      IMPORTING
        pi_placeholder TYPE zde_contpe_placeholder
        pi_language    TYPE spras
      RETURNING
        VALUE(rs_fieldmap) TYPE zhr_contpe_fieldmap
      RAISING
        zcx_hhr_contpe_data_error.

    METHODS resolve_infotype_value
      IMPORTING
        is_fieldmap TYPE zhr_contpe_fieldmap
        pi_pernr    TYPE persno
        pi_date     TYPE datum
      RETURNING
        VALUE(re_value) TYPE string
      RAISING
        zcx_hhr_contpe_data_error.

    METHODS format_field_value
      IMPORTING
        is_fieldmap TYPE zhr_contpe_fieldmap
        pi_raw      TYPE string
      RETURNING
        VALUE(re_value) TYPE string.
ENDCLASS.

CLASS zcl_hhr_contpe_data_provider IMPLEMENTATION.

  METHOD get_field_values.
    DATA lt_fieldmap TYPE STANDARD TABLE OF zhr_contpe_fieldmap.

    IF pt_placeholders IS SUPPLIED AND lines( pt_placeholders ) > 0.
      LOOP AT pt_placeholders ASSIGNING FIELD-SYMBOL(<ls_placeholder>).
        DATA(ls_map) = read_fieldmap(
          pi_placeholder = CONV zde_contpe_placeholder( <ls_placeholder> )
          pi_language    = pi_language ).
        INSERT VALUE #(
          placeholder = ls_map-placeholder
          value       = resolve_infotype_value(
                            is_fieldmap = ls_map
                            pi_pernr    = pi_pernr
                            pi_date     = pi_date ) ) INTO TABLE rt_values.
      ENDLOOP.
    ELSE.
      SELECT placeholder
             spras
             description
             origin_type
             infty
             subty
             field_name
             date_logic
             calc_class
             const_value
             data_type
             format_pattern
             uppercase
             default_value
        FROM zhr_contpe_fieldmap
        WHERE spras = @pi_language
        INTO CORRESPONDING FIELDS OF TABLE @lt_fieldmap.

      LOOP AT lt_fieldmap ASSIGNING FIELD-SYMBOL(<ls_map>).
        INSERT VALUE #(
          placeholder = <ls_map>-placeholder
          value       = resolve_infotype_value(
                            is_fieldmap = <ls_map>
                            pi_pernr    = pi_pernr
                            pi_date     = pi_date ) ) INTO TABLE rt_values.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_field.
    DATA(ls_fieldmap) = read_fieldmap(
      pi_placeholder = pi_placeholder
      pi_language    = sy-langu ).

    IF ls_fieldmap-origin_type <> 'C' OR ls_fieldmap-calc_class IS INITIAL.
      RAISE EXCEPTION TYPE zcx_hhr_contpe_data_error
        EXPORTING
          error_message = |Placeholder { pi_placeholder } no es calculado|.
    ENDIF.

    DATA(lo_calc) = CREATE OBJECT (ls_fieldmap-calc_class).
    re_value = lo_calc->zif_hhr_contpe_field_calc~calculate(
      pi_pernr = pi_pernr
      pi_date  = pi_date ).
  ENDMETHOD.

  METHOD read_fieldmap.
    SELECT SINGLE placeholder
                  spras
                  description
                  origin_type
                  infty
                  subty
                  field_name
                  date_logic
                  calc_class
                  const_value
                  data_type
                  format_pattern
                  uppercase
                  default_value
      FROM zhr_contpe_fieldmap
      WHERE placeholder = @pi_placeholder
        AND spras       = @pi_language
      INTO CORRESPONDING FIELDS OF @rs_fieldmap.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_hhr_contpe_data_error
        EXPORTING
          error_message = |Placeholder { pi_placeholder } no configurado|.
    ENDIF.
  ENDMETHOD.

  METHOD resolve_infotype_value.
    CASE is_fieldmap-origin_type.
      WHEN 'K'.
        re_value = is_fieldmap-const_value.
      WHEN 'C'.
        re_value = calculate_field(
          pi_placeholder = is_fieldmap-placeholder
          pi_pernr       = pi_pernr
          pi_date        = pi_date ).
      WHEN 'I'.
        IF is_fieldmap-infty = '0002'.
          SELECT SINGLE vorna nachn
            FROM pa0002
            WHERE pernr = @pi_pernr
              AND begda <= @pi_date
              AND endda >= @pi_date
            INTO (@DATA(lv_vorna), @DATA(lv_nachn)).
          IF sy-subrc = 0.
            IF is_fieldmap-field_name CS 'VORNA'.
              re_value = lv_vorna.
            ELSEIF is_fieldmap-field_name CS 'NACHN'.
              re_value = lv_nachn.
            ELSE.
              re_value = |{ lv_vorna } { lv_nachn }|.
            ENDIF.
          ENDIF.
        ELSEIF is_fieldmap-infty = '0000'.
          SELECT SINGLE begda
            FROM pa0000
            WHERE pernr = @pi_pernr
            INTO @DATA(lv_begda).
          IF sy-subrc = 0.
            re_value = zcl_hhr_contpe_utils=>format_date( lv_begda ).
          ENDIF.
        ENDIF.
      WHEN OTHERS.
        CLEAR re_value.
    ENDCASE.

    re_value = format_field_value(
      is_fieldmap = is_fieldmap
      pi_raw      = re_value ).

    IF re_value IS INITIAL AND is_fieldmap-default_value IS NOT INITIAL.
      re_value = is_fieldmap-default_value.
    ENDIF.
  ENDMETHOD.

  METHOD format_field_value.
    re_value = pi_raw.

    IF is_fieldmap-uppercase = 'X'.
      TRANSLATE re_value TO UPPER CASE.
    ENDIF.

    IF is_fieldmap-data_type = 'D' AND is_fieldmap-format_pattern IS NOT INITIAL.
      re_value = zcl_hhr_contpe_utils=>format_date(
        pi_date   = pi_raw
        pi_format = is_fieldmap-format_pattern ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
