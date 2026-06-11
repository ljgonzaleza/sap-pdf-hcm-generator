*&============================================================*
*& Report  ZHHRDCONTPE_001
*&============================================================*
*& Descripción: CONTPE - Carga inicial parámetros ZHR_CONTPE_CFG
*& Fecha Creación = 11.06.2026
*& Empresa      = LATAM
*&============================================================*
REPORT zhhrcontpe_001.

*--------------------------------------------------------------------*
* Tipos
*--------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_seed_config,
    param_key   TYPE zde_contpe_param_key,
    param_value TYPE string,
    description TYPE zde_contpe_description,
  END OF ty_seed_config,
  tt_seed_config TYPE STANDARD TABLE OF ty_seed_config WITH EMPTY KEY.

*--------------------------------------------------------------------*
* Datos semilla
*--------------------------------------------------------------------*
DATA(lt_seed) = VALUE tt_seed_config(
  ( param_key = 'RENDERER_TYPE'           param_value = 'ADS'               description = 'Motor PDF: ADS' )
  ( param_key = 'ADOBE_FORM_NAME'         param_value = 'ZHR_CONTPE_F_001'  description = 'Nombre Adobe Form genérico' )
  ( param_key = 'MAX_MASS_GENERATION'     param_value = '10000'             description = 'Máximo empleados generación masiva' )
  ( param_key = 'DEFAULT_SIGNATURE_ID'    param_value = 'GRRHH01'      description = 'Firmante por defecto' )
  ( param_key = 'ARCHIVELINK_DOC_CLASS'   param_value = 'Z_HR_CONTPE' description = 'Document class ArchiveLink' )
  ( param_key = 'ARCHIVELINK_OBJECT_TYPE' param_value = 'Z_PREL_PDF'   description = 'Object type ArchiveLink' )
  ( param_key = 'RETENTION_YEARS'         param_value = '7'            description = 'Años retención documentos' )
  ( param_key = 'DIGITAL_SIGN_ENABLED'    param_value = 'N'            description = 'Firma digital habilitada' )
  ( param_key = 'DIGITAL_SIGN_PROVIDER'   param_value = ''             description = 'Proveedor firma digital' ) ).

*--------------------------------------------------------------------*
* Inicio de procesamiento
*--------------------------------------------------------------------*
START-OF-SELECTION.

  DATA(lv_timestamp) = zcl_hhr_contpe_utils=>get_timestamp( ).
  DATA(lv_inserted) = 0.

  LOOP AT lt_seed ASSIGNING FIELD-SYMBOL(<ls_seed>).
    SELECT SINGLE @abap_true
      FROM zhr_contpe_cfg
      WHERE param_key = @<ls_seed>-param_key
      INTO @DATA(lv_exists).

    IF lv_exists = abap_true.
      CONTINUE.
    ENDIF.

    INSERT zhr_contpe_cfg FROM @( VALUE #(
      param_key   = <ls_seed>-param_key
      param_value = <ls_seed>-param_value
      description = <ls_seed>-description
      changed_by  = sy-uname
      changed_at  = lv_timestamp ) ).

    IF sy-subrc = 0.
      lv_inserted = lv_inserted + 1.
    ENDIF.
  ENDLOOP.

  COMMIT WORK.

  WRITE: / 'CONTPE - Configuración inicial cargada.'.
  WRITE: / 'Registros insertados:', lv_inserted.

  zcl_hhr_contpe_config=>get_instance( )->refresh_cache( ).
