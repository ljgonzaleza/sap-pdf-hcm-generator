*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_RENDER_FACT
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Factory motor renderizado PDF
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_render_fact DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS get_renderer
      RETURNING
        VALUE(ro_renderer) TYPE REF TO zif_hhr_contpe_renderer.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_hhr_contpe_render_fact IMPLEMENTATION.

  METHOD get_renderer.
    DATA(lv_renderer) = zcl_hhr_contpe_config=>get_instance( )->get_parameter( 'RENDERER_TYPE' ).
    IF lv_renderer IS INITIAL.
      lv_renderer = 'ADS'.
    ENDIF.

    CASE lv_renderer.
      WHEN 'ADS'.
        ro_renderer = NEW zcl_hhr_contpe_renderer_ads( ).
      WHEN OTHERS.
        ro_renderer = NEW zcl_hhr_contpe_renderer_ads( ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
