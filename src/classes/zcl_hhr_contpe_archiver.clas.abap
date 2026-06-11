*&---------------------------------------------------------------------*
*& Clase   ZCL_HHR_CONTPE_ARCHIVER
*&---------------------------------------------------------------------*
*& Descripción: CONTPE - Almacenamiento ArchiveLink (stub Sprint 6)
*& Empresa     LATAM
*&---------------------------------------------------------------------*
CLASS zcl_hhr_contpe_archiver DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS store_document
      IMPORTING
        pi_pdf         TYPE xstring
        pi_pernr       TYPE persno
        pi_template_id TYPE zde_contpe_tpl_id
      RETURNING
        VALUE(re_archiv_id) TYPE saeardoid
      RAISING
        zcx_hhr_contpe_archive_error.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_hhr_contpe_archiver IMPLEMENTATION.

  METHOD store_document.
    " @001 Implementación ArchiveLink pendiente Sprint 6
    RAISE EXCEPTION TYPE zcx_hhr_contpe_archive_error
      EXPORTING
        error_message = 'ArchiveLink pendiente de implementación (Sprint 6)'.
  ENDMETHOD.

ENDCLASS.
