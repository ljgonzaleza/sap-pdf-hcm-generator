*&============================================================*
*& Report  ZHHRDCONTPE_002
*&============================================================*
*& Descripción: CONTPE - Carga catálogo básico ZHR_CONTPE_FMAP
*& Fecha Creación = 11.06.2026
*& Empresa      = LATAM
*&============================================================*
REPORT zhhrcontpe_002.

*--------------------------------------------------------------------*
* Tipos
*--------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_seed_fieldmap,
    placeholder    TYPE zde_contpe_placeholder,
    description      TYPE zde_contpe_description,
    origin_type      TYPE zde_contpe_origin_type,
    infty            TYPE infty,
    field_name       TYPE fieldname,
    date_logic       TYPE zde_contpe_date_logic,
    calc_class       TYPE seoclsname,
    data_type        TYPE zde_contpe_data_type,
    format_pattern   TYPE zde_contpe_format_pattern,
    uppercase        TYPE xfeld,
    default_value    TYPE string,
  END OF ty_seed_fieldmap,
  tt_seed_fieldmap TYPE STANDARD TABLE OF ty_seed_fieldmap WITH EMPTY KEY.

*--------------------------------------------------------------------*
* Datos semilla (español)
*--------------------------------------------------------------------*
DATA(lt_seed) = VALUE tt_seed_fieldmap(
  ( placeholder = 'NOMBRE'         description = 'Nombre empleado'     origin_type = 'I' infty = '0002' field_name = 'VORNA' date_logic = 'C' data_type = 'T' uppercase = 'X' )
  ( placeholder = 'APELLIDO'       description = 'Apellido empleado'   origin_type = 'I' infty = '0002' field_name = 'NACHN' date_logic = 'C' data_type = 'T' uppercase = 'X' )
  ( placeholder = 'NOMBRE_COMPLETO' description = 'Nombre completo'    origin_type = 'I' infty = '0002' field_name = 'VORNA+NACHN' date_logic = 'C' data_type = 'T' uppercase = 'X' )
  ( placeholder = 'DNI'            description = 'Documento identidad' origin_type = 'I' infty = '0002' field_name = 'PERID' date_logic = 'C' data_type = 'T' )
  ( placeholder = 'FECHA_INGRESO'  description = 'Fecha ingreso'       origin_type = 'I' infty = '0000' field_name = 'BEGDA' date_logic = 'F' data_type = 'D' format_pattern = 'DD.MM.YYYY' )
  ( placeholder = 'EDAD'           description = 'Edad empleado'       origin_type = 'C' calc_class = 'ZCL_HHR_CONTPE_CALC_EDAD' data_type = 'N' ) ).

*--------------------------------------------------------------------*
* Inicio de procesamiento
*--------------------------------------------------------------------*
START-OF-SELECTION.

  DATA(lv_timestamp) = zcl_hhr_contpe_utils=>get_timestamp( ).
  DATA(lv_inserted) = 0.
  DATA(lv_spras) = 'S'.

  LOOP AT lt_seed ASSIGNING FIELD-SYMBOL(<ls_seed>).
    SELECT SINGLE @abap_true
      FROM zhr_contpe_fmap
      WHERE placeholder = @<ls_seed>-placeholder
        AND spras       = @lv_spras
      INTO @DATA(lv_exists).

    IF lv_exists = abap_true.
      CONTINUE.
    ENDIF.

    INSERT zhr_contpe_fmap FROM VALUE #(
      placeholder    = <ls_seed>-placeholder
      spras          = lv_spras
      description    = <ls_seed>-description
      origin_type    = <ls_seed>-origin_type
      infty          = <ls_seed>-infty
      field_name     = <ls_seed>-field_name
      date_logic     = <ls_seed>-date_logic
      calc_class     = <ls_seed>-calc_class
      data_type      = <ls_seed>-data_type
      format_pattern = <ls_seed>-format_pattern
      uppercase      = <ls_seed>-uppercase
      default_value  = <ls_seed>-default_value
      created_by     = sy-uname
      created_at     = lv_timestamp
      changed_by     = sy-uname
      changed_at     = lv_timestamp ).

    IF sy-subrc = 0.
      lv_inserted = lv_inserted + 1.
    ENDIF.
  ENDLOOP.

  COMMIT WORK.

  WRITE: / 'CONTPE - Catálogo fieldmap cargado.'.
  WRITE: / 'Registros insertados:', lv_inserted.
