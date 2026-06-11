*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_HTML_PREP
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Preparación HTML para Adobe Forms
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_html_prep DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS prepare_for_ads
      IMPORTING
        pi_html TYPE string
      RETURNING
        VALUE(re_html) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS ensure_html_wrapper
      IMPORTING
        pi_html TYPE string
      RETURNING
        VALUE(re_html) TYPE string.

    CLASS-METHODS remove_dangerous_tags
      CHANGING
        co_html TYPE string.
ENDCLASS.

CLASS zcl_hhr_contpe_html_prep IMPLEMENTATION.

  METHOD prepare_for_ads.
    re_html = pi_html.
    remove_dangerous_tags( CHANGING co_html = re_html ).
    re_html = ensure_html_wrapper( re_html ).
  ENDMETHOD.

  METHOD ensure_html_wrapper.
    DATA(lv_upper) = pi_html.
    TRANSLATE lv_upper TO UPPER CASE.

    IF lv_upper NS '<HTML'.
      re_html = |<html><body>{ pi_html }</body></html>|.
    ELSE.
      re_html = pi_html.
    ENDIF.
  ENDMETHOD.

  METHOD remove_dangerous_tags.
    REPLACE ALL OCCURRENCES OF REGEX '<script[^>]*>.*</script>'
      IN co_html WITH '' IGNORING CASE.
    REPLACE ALL OCCURRENCES OF REGEX '<style[^>]*>.*</style>'
      IN co_html WITH '' IGNORING CASE.
    REPLACE ALL OCCURRENCES OF REGEX '<iframe[^>]*>.*</iframe>'
      IN co_html WITH '' IGNORING CASE.
    REPLACE ALL OCCURRENCES OF REGEX 'on[a-z]+="[^"]*"'
      IN co_html WITH '' IGNORING CASE.
  ENDMETHOD.

ENDCLASS.
