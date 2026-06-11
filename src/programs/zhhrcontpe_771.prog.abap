*&============================================================*
*& Report  ZHHRCONTPE_771
*&============================================================*
*& Descripción: CONTPE - Launcher Fiori generación documento PDF
*& Transacción : ZHHRTCONTPE_771
*& Fecha Creación = 11.06.2026
*& Empresa      = LATAM
*&============================================================*
REPORT zhhrcontpe_771.

*--------------------------------------------------------------------*
* Pantalla de selección 1000
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
PARAMETERS p_pernr TYPE persno.
PARAMETERS p_tplid TYPE zde_contpe_tpl_id.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN COMMENT /1(80) text-002.

*--------------------------------------------------------------------*
* Inicio de procesamiento
*--------------------------------------------------------------------*
START-OF-SELECTION.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD 'ZHHRTCONTPE_771'.
  IF sy-subrc <> 0.
    MESSAGE e001(zhr_contpe) WITH 'ZHHRTCONTPE_771'.
    LEAVE PROGRAM.
  ENDIF.

  DATA(l_params) = VALUE zcl_hhr_contpe_fiori_launcher=>ty_launch_params(
    pernr       = p_pernr
    template_id = p_tplid ).

  TRY.
      zcl_hhr_contpe_fiori_launcher=>launch_generate( pi_params = l_params ).
    CATCH zcx_hhr_contpe_gen_error INTO DATA(lx_error).
      MESSAGE lx_error TYPE 'E'.
  ENDTRY.
