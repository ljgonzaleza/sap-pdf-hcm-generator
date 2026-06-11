*&============================================================*
*& Report  ZHHRCONTPE_772
*&============================================================*
*& Descripción: CONTPE - Launcher Fiori consulta documentos PDF
*& Transacción : ZHHRTCONTPE_772
*& Fecha Creación = 11.06.2026
*& Empresa      = LATAM
*&============================================================*
REPORT zhhrcontpe_772.

*--------------------------------------------------------------------*
* Parámetros de selección
*--------------------------------------------------------------------*
DATA l_pernr TYPE persno.

SELECT-OPTIONS s_pernr FOR l_pernr.
PARAMETERS p_tplid TYPE zde_contpe_tpl_id.
PARAMETERS p_dfrom TYPE datum.
PARAMETERS p_dto   TYPE datum.

*--------------------------------------------------------------------*
* Inicio de procesamiento
*--------------------------------------------------------------------*
START-OF-SELECTION.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD 'ZHHRTCONTPE_772'.
  IF sy-subrc <> 0.
    MESSAGE e001(zhr_contpe) WITH 'ZHHRTCONTPE_772'.
    LEAVE PROGRAM.
  ENDIF.

  DATA(l_params) = VALUE zcl_hhr_contpe_fiori_launcher=>ty_launch_params(
    template_id = p_tplid
    date_from   = p_dfrom
    date_to     = p_dto ).

  IF lines( s_pernr ) = 1.
    READ TABLE s_pernr INDEX 1 INTO DATA(lwa_pernr_range).
    IF lwa_pernr_range-sign = 'I' AND lwa_pernr_range-option = 'EQ'.
      l_params-pernr = lwa_pernr_range-low.
    ELSEIF lwa_pernr_range-sign = 'I' AND lwa_pernr_range-option = 'BT'.
      l_params-pernr_from = lwa_pernr_range-low.
      l_params-pernr_to   = lwa_pernr_range-high.
    ENDIF.
  ENDIF.

  TRY.
      zcl_hhr_contpe_fiori_launcher=>launch_history( pi_params = l_params ).
    CATCH zcx_hhr_contpe_generation_error INTO DATA(lx_error).
      MESSAGE lx_error TYPE 'E'.
  ENDTRY.
