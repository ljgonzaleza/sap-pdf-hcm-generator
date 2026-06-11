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
* Parámetros de selección
*--------------------------------------------------------------------*
PARAMETERS p_pernr TYPE persno.
PARAMETERS p_tplid TYPE zde_contpe_tpl_id.

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
    CATCH zcx_hhr_contpe_generation_error INTO DATA(lx_error).
      MESSAGE lx_error TYPE 'E'.
  ENDTRY.
