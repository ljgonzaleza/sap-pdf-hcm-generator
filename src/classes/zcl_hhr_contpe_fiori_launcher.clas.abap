*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_FIORI_LAUNCHER
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Navegación apps Fiori generador PDF HCM
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_fiori_launcher DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_launch_params,
        pernr        TYPE persno,
        pernr_from   TYPE persno,
        pernr_to     TYPE persno,
        template_id  TYPE zde_contpe_tpl_id,
        date_from    TYPE datum,
        date_to      TYPE datum,
      END OF ty_launch_params.

    CLASS-METHODS launch_templates
      IMPORTING
        pi_params TYPE ty_launch_params OPTIONAL
      RAISING
        zcx_hhr_contpe_gen_error.

    CLASS-METHODS launch_generate
      IMPORTING
        pi_params TYPE ty_launch_params OPTIONAL
      RAISING
        zcx_hhr_contpe_gen_error.

    CLASS-METHODS launch_history
      IMPORTING
        pi_params TYPE ty_launch_params OPTIONAL
      RAISING
        zcx_hhr_contpe_gen_error.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF lc_semantic,
        template_obj TYPE string VALUE 'ZCONTPEPdfTemplate',
        document_obj TYPE string VALUE 'ZCONTPEPdfDocument',
      END OF lc_semantic,
      BEGIN OF lc_action,
        manage         TYPE string VALUE 'manage',
        generate       TYPE string VALUE 'generate',
        displayhistory TYPE string VALUE 'displayHistory',
      END OF lc_action,
      lc_flp_path TYPE string VALUE '/sap/bc/ui2/flp'.

    CLASS-METHODS get_launchpad_base_url
      RETURNING
        VALUE(re_base_url) TYPE string.

    CLASS-METHODS build_fiori_url
      IMPORTING
        pi_semantic_object TYPE string
        pi_semantic_action TYPE string
        pi_params          TYPE ty_launch_params OPTIONAL
      RETURNING
        VALUE(re_url)      TYPE string.

    CLASS-METHODS navigate_to_url
      IMPORTING
        pi_url TYPE string
      RAISING
        zcx_hhr_contpe_gen_error.

ENDCLASS.

CLASS zcl_hhr_contpe_fiori_launcher IMPLEMENTATION.

  METHOD launch_templates.
    DATA(l_url) = build_fiori_url(
      pi_semantic_object = lc_semantic-template_obj
      pi_semantic_action = lc_action-manage
      pi_params          = pi_params ).

    navigate_to_url( pi_url = l_url ).
  ENDMETHOD.

  METHOD launch_generate.
    DATA(l_url) = build_fiori_url(
      pi_semantic_object = lc_semantic-document_obj
      pi_semantic_action = lc_action-generate
      pi_params          = pi_params ).

    navigate_to_url( pi_url = l_url ).
  ENDMETHOD.

  METHOD launch_history.
    DATA(l_url) = build_fiori_url(
      pi_semantic_object = lc_semantic-document_obj
      pi_semantic_action = lc_action-displayhistory
      pi_params          = pi_params ).

    navigate_to_url( pi_url = l_url ).
  ENDMETHOD.

  METHOD get_launchpad_base_url.
    DATA(lv_cfg_url) = zcl_hhr_contpe_config=>get_instance( )->get_parameter( 'FIORI_LAUNCHPAD_URL' ).

    IF lv_cfg_url IS NOT INITIAL.
      IF lv_cfg_url CS lc_flp_path.
        re_base_url = lv_cfg_url.
      ELSE.
        re_base_url = |{ lv_cfg_url }{ lc_flp_path }?sap-client={ sy-mandt }&sap-language={ sy-langu }|.
      ENDIF.
      RETURN.
    ENDIF.

    DATA(lv_host) = zcl_hhr_contpe_config=>get_instance( )->get_parameter( 'FIORI_LAUNCHPAD_HOST' ).
    IF lv_host IS INITIAL.
      lv_host = sy-host.
    ENDIF.

    DATA(lv_port) = zcl_hhr_contpe_config=>get_instance( )->get_parameter( 'FIORI_LAUNCHPAD_PORT' ).
    DATA(lv_https) = zcl_hhr_contpe_config=>get_instance( )->get_parameter( 'FIORI_LAUNCHPAD_HTTPS' ).
    DATA(lv_proto) = COND string( WHEN lv_https = 'X' OR lv_https = 'TRUE' THEN 'https' ELSE 'http' ).

    IF lv_port IS INITIAL.
      lv_port = COND string( WHEN lv_proto = 'https' THEN '44300' ELSE '8000' ).
    ENDIF.

    re_base_url = |{ lv_proto }://{ lv_host }:{ lv_port }{ lc_flp_path }?sap-client={ sy-mandt }&sap-language={ sy-langu }|.
  ENDMETHOD.

  METHOD build_fiori_url.
    DATA(lv_intent) = |#{ pi_semantic_object }-{ pi_semantic_action }|.
    DATA(lv_query) = ``.

    IF pi_params-pernr IS NOT INITIAL.
        lv_query = |{ lv_query }{ COND string( WHEN lv_query IS INITIAL THEN '' ELSE '&' ) }PERNR={ pi_params-pernr ALPHA = OUT }|.
      ENDIF.

      IF pi_params-template_id IS NOT INITIAL.
        lv_query = |{ lv_query }{ COND string( WHEN lv_query IS INITIAL THEN '' ELSE '&' ) }TEMPLATE_ID={ pi_params-template_id }|.
      ENDIF.

      IF pi_params-pernr_from IS NOT INITIAL.
        lv_query = |{ lv_query }{ COND string( WHEN lv_query IS INITIAL THEN '' ELSE '&' ) }PERNR_FROM={ pi_params-pernr_from ALPHA = OUT }|.
      ENDIF.

      IF pi_params-pernr_to IS NOT INITIAL.
        lv_query = |{ lv_query }{ COND string( WHEN lv_query IS INITIAL THEN '' ELSE '&' ) }PERNR_TO={ pi_params-pernr_to ALPHA = OUT }|.
      ENDIF.

      IF pi_params-date_from IS NOT INITIAL.
        lv_query = |{ lv_query }{ COND string( WHEN lv_query IS INITIAL THEN '' ELSE '&' ) }DATE_FROM={ pi_params-date_from }|.
      ENDIF.

    IF pi_params-date_to IS NOT INITIAL.
      lv_query = |{ lv_query }{ COND string( WHEN lv_query IS INITIAL THEN '' ELSE '&' ) }DATE_TO={ pi_params-date_to }|.
    ENDIF.

    IF lv_query IS NOT INITIAL.
      lv_intent = |{ lv_intent }?{ lv_query }|.
    ENDIF.

    re_url = |{ get_launchpad_base_url( ) }{ lv_intent }|.
  ENDMETHOD.

  METHOD navigate_to_url.
    CALL FUNCTION 'CALL_BROWSER'
      EXPORTING
        url = pi_url
      EXCEPTIONS
        OTHERS = 1.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_hhr_contpe_gen_error
        EXPORTING
          textid = zcx_hhr_contpe_gen_error=>zhhr_contpe_fiori_nav_error.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
