*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_UTILS
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Utilidades formateo y conversiones
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS format_date
      IMPORTING
        pi_date     TYPE datum
        pi_format   TYPE zde_contpe_format_pattern DEFAULT 'DD.MM.YYYY'
        pi_language TYPE spras DEFAULT sy-langu
      RETURNING
        VALUE(re_text) TYPE string.

    CLASS-METHODS format_amount
      IMPORTING
        pi_amount   TYPE p LENGTH 15 DECIMALS 2
        pi_currency TYPE waers
        pi_format   TYPE zde_contpe_format_pattern OPTIONAL
      RETURNING
        VALUE(re_text) TYPE string.

    CLASS-METHODS calculate_hash
      IMPORTING
        pi_pdf TYPE xstring
      RETURNING
        VALUE(re_hash) TYPE zde_contpe_pdf_hash.

    CLASS-METHODS xstring_to_binary
      IMPORTING
        pi_xstring TYPE xstring
      RETURNING
        VALUE(rt_binary) TYPE solix_tab.

    CLASS-METHODS binary_to_xstring
      IMPORTING
        it_binary TYPE solix_tab
      RETURNING
        VALUE(re_xstring) TYPE xstring.

    CLASS-METHODS get_timestamp
      RETURNING
        VALUE(re_timestamp) TYPE timestampl.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_hhr_contpe_utils IMPLEMENTATION.

  METHOD format_date.
    IF pi_date IS INITIAL.
      RETURN.
    ENDIF.

    CASE pi_format.
      WHEN 'DD.MM.YYYY'.
        re_text = |{ pi_date+6(2) }.{ pi_date+4(2) }.{ pi_date(4) }|.
      WHEN 'YYYY-MM-DD'.
        re_text = |{ pi_date(4) }-{ pi_date+4(2) }-{ pi_date+6(2) }|.
      WHEN OTHERS.
        WRITE pi_date TO re_text.
    ENDCASE.
  ENDMETHOD.

  METHOD format_amount.
    DATA lv_amount TYPE char20.

    WRITE pi_amount TO lv_amount CURRENCY pi_currency.
    re_text = lv_amount.
  ENDMETHOD.

  METHOD calculate_hash.
    TRY.
        re_hash = cl_abap_hmac=>calculate_hash_for_raw(
          if_algorithm = if_abap_hmac=>co_sha256
          if_data      = pi_pdf ).
      CATCH cx_root.
        CLEAR re_hash.
    ENDTRY.
  ENDMETHOD.

  METHOD xstring_to_binary.
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = pi_xstring
      IMPORTING
        output_length = DATA(lv_length)
      TABLES
        binary_tab    = rt_binary
      EXCEPTIONS
        failed        = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      CLEAR rt_binary.
    ENDIF.
  ENDMETHOD.

  METHOD binary_to_xstring.
    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length  = lines( it_binary ) * 255
      IMPORTING
        buffer        = re_xstring
      TABLES
        binary_tab    = it_binary
      EXCEPTIONS
        failed        = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      CLEAR re_xstring.
    ENDIF.
  ENDMETHOD.

  METHOD get_timestamp.
    GET TIME STAMP FIELD re_timestamp.
  ENDMETHOD.

ENDCLASS.
