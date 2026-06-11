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
* Parámetros de selección
*--------------------------------------------------------------------*
PARAMETERS p_tplid TYPE zde_contpe_tpl_id.

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
      MESSAGE lx_error TYPE 'E'.
  ENDTRY.
