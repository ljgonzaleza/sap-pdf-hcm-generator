*&============================================================*
*& Report  ZHHRCONTPE_770
*&============================================================*
*& Descripción: CONTPE - Launcher Fiori mantenimiento plantillas
*& Transacción : ZHHRTCONTPE_770
*& Fecha Creación = 11.06.2026
*& Empresa      = LATAM
*&============================================================*
REPORT zhhrcontpe_770.

*--------------------------------------------------------------------*
* Pantalla de selección 1000
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
PARAMETERS p_tplid TYPE zde_contpe_tpl_id.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN COMMENT /1(80) text-002.

*--------------------------------------------------------------------*
* Inicio de procesamiento
*--------------------------------------------------------------------*
START-OF-SELECTION.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD 'ZHHRTCONTPE_770'.
  IF sy-subrc <> 0.
    MESSAGE e001(zhr_contpe) WITH 'ZHHRTCONTPE_770'.
    LEAVE PROGRAM.
  ENDIF.

  DATA(l_params) = VALUE zcl_hhr_contpe_fiori_launcher=>ty_launch_params(
    template_id = p_tplid ).

  TRY.
      zcl_hhr_contpe_fiori_launcher=>launch_templates( pi_params = l_params ).
    CATCH zcx_hhr_contpe_gen_error INTO DATA(lx_error).
      lx_error->display_message( ).
      LEAVE PROGRAM.
  ENDTRY.
