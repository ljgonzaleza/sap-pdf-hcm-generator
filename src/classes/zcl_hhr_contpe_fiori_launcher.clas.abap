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
        pi_params TYPE ty_launch_params OPTIONAL.

    CLASS-METHODS launch_generate
      IMPORTING
        pi_params TYPE ty_launch_params OPTIONAL.

    CLASS-METHODS launch_history
      IMPORTING
        pi_params TYPE ty_launch_params OPTIONAL.

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
      END OF lc_action.

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

  METHOD build_fiori_url.
    re_url = |#SemanticObject={ pi_semantic_object };SemanticAction={ pi_semantic_action }|.

    IF pi_params-pernr IS NOT INITIAL.
      re_url = |{ re_url }?PERNR={ pi_params-pernr ALPHA = OUT }|.
    ENDIF.

    IF pi_params-template_id IS NOT INITIAL.
      re_url = |{ re_url }{ COND string( WHEN pi_params-pernr IS INITIAL THEN '?' ELSE '&' ) }TEMPLATE_ID={ pi_params-template_id }|.
    ENDIF.

    IF pi_params-pernr_from IS NOT INITIAL.
      re_url = |{ re_url }{ COND string( WHEN re_url CA '?' THEN '&' ELSE '?' ) }PERNR_FROM={ pi_params-pernr_from ALPHA = OUT }|.
    ENDIF.

    IF pi_params-pernr_to IS NOT INITIAL.
      re_url = |{ re_url }&PERNR_TO={ pi_params-pernr_to ALPHA = OUT }|.
    ENDIF.

    IF pi_params-date_from IS NOT INITIAL.
      re_url = |{ re_url }&DATE_FROM={ pi_params-date_from }|.
    ENDIF.

    IF pi_params-date_to IS NOT INITIAL.
      re_url = |{ re_url }&DATE_TO={ pi_params-date_to }|.
    ENDIF.
  ENDMETHOD.

  METHOD navigate_to_url.
    DATA(l_url) = pi_url.

    CALL METHOD cl_gui_frontend_services=>execute
      EXPORTING
        document = l_url
      EXCEPTIONS
        cntl_error         = 1
        error_no_gui       = 2
        bad_parameter      = 3
        file_not_found     = 4
        pathname_not_found = 5
        unknown_error      = 6
        OTHERS             = 7.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_hhr_contpe_gen_error
        EXPORTING
          textid = zcx_hhr_contpe_gen_error=>zhhr_contpe_fiori_nav_error.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
