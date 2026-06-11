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
* Pantalla de selección 1000
*--------------------------------------------------------------------*
DATA l_pernr TYPE persno.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
SELECT-OPTIONS s_pernr FOR l_pernr.
PARAMETERS p_tplid TYPE zde_contpe_tpl_id.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE text-003.
PARAMETERS p_dfrom TYPE datum.
PARAMETERS p_dto   TYPE datum.
SELECTION-SCREEN END OF BLOCK b02.

SELECTION-SCREEN COMMENT /1(80) text-002.

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
    CATCH zcx_hhr_contpe_gen_error INTO DATA(lx_error).
      MESSAGE lx_error TYPE 'E'.
  ENDTRY.
