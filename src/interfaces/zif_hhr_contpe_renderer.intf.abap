*&---------------------------------------------------------------------*
*& Interface ZIF_HHR_CONTPE_RENDERER
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Contrato motor renderizado PDF
*& Empresa     LATAM
*&---------------------------------------------------------------------*
INTERFACE zif_hhr_contpe_renderer
  PUBLIC.

  METHODS render
    IMPORTING
      pi_html          TYPE string
      pi_signature_img TYPE xstring OPTIONAL
      pi_logo_img      TYPE xstring OPTIONAL
      ps_metadata      TYPE zhr_contpe_s_pdf_metadata OPTIONAL
    RETURNING
      VALUE(pe_pdf)    TYPE xstring
    RAISING
      zcx_hhr_contpe_render_error.

ENDINTERFACE.
