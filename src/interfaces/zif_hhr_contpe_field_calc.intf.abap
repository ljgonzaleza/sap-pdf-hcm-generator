*&---------------------------------------------------------------------*
*& Interface ZIF_HHR_CONTPE_FIELD_CALC
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Contrato cálculo campos derivados
*& Empresa     LATAM
*&---------------------------------------------------------------------*
INTERFACE zif_hhr_contpe_field_calc
  PUBLIC.

  METHODS calculate
    IMPORTING
      pi_pernr       TYPE persno
      pi_date        TYPE datum DEFAULT sy-datum
    RETURNING
      VALUE(pe_value) TYPE string
    RAISING
      zcx_hhr_contpe_calc_error.

ENDINTERFACE.
