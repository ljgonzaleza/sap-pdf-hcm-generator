*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_CALC_EDAD
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Calculadora edad empleado
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_calc_edad DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_hhr_contpe_field_calc.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_hhr_contpe_calc_edad IMPLEMENTATION.

  METHOD zif_hhr_contpe_field_calc~calculate.
    SELECT SINGLE gbdat
      FROM pa0002
      WHERE pernr = @pi_pernr
        AND begda <= @pi_date
        AND endda >= @pi_date
      INTO @DATA(lv_birth).

    IF sy-subrc <> 0 OR lv_birth IS INITIAL.
      RAISE EXCEPTION TYPE zcx_hhr_contpe_calc_error
        EXPORTING
          error_message = 'Fecha nacimiento no disponible'.
    ENDIF.

    DATA(lv_years) = pi_date(4) - lv_birth(4).
    IF pi_date+4(4) < lv_birth+4(4).
      lv_years = lv_years - 1.
    ENDIF.

    pe_value = |{ lv_years }|.
  ENDMETHOD.

ENDCLASS.
