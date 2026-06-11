*&============================================================*
*& Report  ZHHRDCONTPE_003
*&============================================================*
*& Descripción: CONTPE - Prototipo Adobe Form ZHR_CONTPE_F_001
*& Fecha Creación = 11.06.2026
*& Empresa      = LATAM
*&============================================================*
*& Prerrequisito: crear y activar form ZHR_CONTPE_F_001 en SFP
*& Interface import: IS_FORM_DATA TYPE ZHR_CONTPE_S_FORM
*&============================================================*
REPORT zhhrcontpe_003.

*--------------------------------------------------------------------*
* Pantalla de selección 1000
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
PARAMETERS p_down AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN COMMENT /1(80) text-002.
SELECTION-SCREEN COMMENT /2(80) text-003.

*--------------------------------------------------------------------*
* Inicio de procesamiento
*--------------------------------------------------------------------*
START-OF-SELECTION.

  DATA(ls_metadata) = VALUE zhr_contpe_s_pdf(
    pernr          = '00000001'
    template_id    = 'CERT01'
    version        = '0001'
    document_title = 'Certificado Laboral - Prototipo'
    generated_by   = sy-uname
    generated_at   = zcl_hhr_contpe_utils=>get_timestamp( ) ).

  DATA(lv_html) =
    '<h1 style="color:#003366; text-align:center;">CERTIFICADO LABORAL</h1>' &&
    '<p>La empresa <b>ACME S.A.</b> certifica que:</p>' &&
    '<p>El Sr(a). <b>JUAN CARLOS GARCÍA LÓPEZ</b>, identificado(a) con DNI <b>12345678</b>, ' &&
    'labora en nuestra institución desde el <b>01.01.2020</b>.</p>' &&
    '<table border="1" cellpadding="5" style="border-collapse:collapse;">' &&
    '<tr style="background-color:#003366; color:white;">' &&
    '<th>Concepto</th><th align="right">Importe</th></tr>' &&
    '<tr><td>Salario Básico</td><td align="right">S/ 3,500.00</td></tr>' &&
    '<tr><td><b>Total</b></td><td align="right"><b>S/ 3,500.00</b></td></tr>' &&
    '</table>'.

  DATA(lv_logo) = cl_http_utility=>decode_x_base64(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==' ).

  TRY.
      DATA(lo_renderer) = NEW zcl_hhr_contpe_renderer_ads( ).
      DATA(lv_pdf) = lo_renderer->zif_hhr_contpe_renderer~render(
        pi_html          = lv_html
        pi_signature_img = lv_logo
        pi_logo_img      = lv_logo
        ps_metadata      = ls_metadata ).

      DATA(lv_pdf_size) = xstrlen( lv_pdf ).
      MESSAGE s042(zhr_contpe) WITH lv_pdf_size.

      IF p_down = abap_true.
        DATA(lv_filename) = |CONTPE_TEST_{ sy-datum }_{ sy-uzeit }.pdf|.
        DATA(lt_binary) = zcl_hhr_contpe_utils=>xstring_to_binary( lv_pdf ).

        cl_gui_frontend_services=>gui_download(
          EXPORTING
            filename                = lv_filename
            filetype                = 'BIN'
          CHANGING
            data_tab                = lt_binary
          EXCEPTIONS
            file_write_error        = 1
            no_batch                = 2
            gui_refuse_filetransfer = 3
            invalid_type            = 4
            no_authority            = 5
            unknown_error           = 6
            header_not_allowed      = 7
            separator_not_allowed   = 8
            filesize_not_allowed    = 9
            dp_error_create         = 10
            OTHERS                  = 11 ).

        IF sy-subrc = 0.
          MESSAGE s043(zhr_contpe) WITH lv_filename.
        ELSE.
          MESSAGE s044(zhr_contpe).
        ENDIF.
      ENDIF.

    CATCH zcx_hhr_contpe_render_error INTO DATA(lx_render).
      MESSAGE lx_render TYPE 'E'.
      RETURN.
  ENDTRY.
