# Prototipo Adobe Form Genérico
## Generador PDF HCM - SAP S/4HANA

**Versión**: 1.0  
**Fecha**: 11 de Junio de 2026  
**Sprint**: 5 (Prototipo técnico)

---

## Objetivo

Validar la viabilidad técnica de generar PDFs dinámicamente desde HTML usando Adobe Forms con ADS.

**Pregunta clave a responder**: ¿Puede Adobe Forms recibir HTML dinámico y renderizarlo correctamente en PDF con estilos, tablas y formato?

---

## Enfoque

### Opción A: Form con Campo HTML Interpretado
Adobe Form con un campo que interpreta HTML directamente

### Opción B: Conversión HTML → XSL-FO → Adobe Form
Convertir HTML a XSL-FO (XML Formatting Objects) antes de enviar a Adobe Form

### Opción C: Form Dinámico Generado en Runtime
Generar Adobe Form structure dinámicamente desde ABAP

**Decisión Prototipo**: Comenzar con Opción A (más simple), si no funciona, evaluar Opción B.

---

## Diseño del Prototipo

### 1. Adobe Form: ZHR_CONTPE_F_001

**Tipo**: Interactive Form (PDF-Based)

#### Interface (Importación):

```abap
TYPES: BEGIN OF ty_form_data,
         html_content   TYPE string,
         signature_img  TYPE xstring,
         logo_img       TYPE xstring,
         doc_metadata   TYPE zhrtmp_s_pdf_metadata,
       END OF ty_form_data.

PARAMETERS:
  p_data TYPE ty_form_data.
```

#### Layout (Adobe LiveCycle Designer):

```
┌─────────────────────────────────────────────────────────┐
│ [Logo Image Field]                                      │
│   Binding: p_data.logo_img                              │
│   Type: Image Field                                     │
│   Size: 150x50px, Position: 10,10                      │
├─────────────────────────────────────────────────────────┤
│ [HTML Content Field]                                    │
│   Binding: p_data.html_content                          │
│   Type: Text Field (multiline, allow rich text)        │
│   Object > Field > Allow Rich Text Format: Yes         │
│   Width: 100%, Height: Auto-expand                     │
│                                                         │
│   O usar:                                               │
│   Subform con Text Field + FormCalc para interpretar   │
│   HTML y generar contenido dinámico                    │
├─────────────────────────────────────────────────────────┤
│ [Signature Area]                                        │
│   _____________________________                         │
│   [Signature Image Field]                               │
│   Binding: p_data.signature_img                         │
│   Type: Image Field                                     │
│   Size: 200x100px, Position: center                    │
├─────────────────────────────────────────────────────────┤
│ [Footer]                                                │
│   Static text: "Documento generado el:"                │
│   Binding: p_data.doc_metadata.generated_at             │
└─────────────────────────────────────────────────────────┘
```

#### Configuración Campo HTML:

1. **Opción 1: Rich Text Field**
   - Object > Field > Allow Rich Text Format: `Yes`
   - Object > Value > Type: `User Entered (Optional)`
   - Este campo interpretará HTML básico (negrita, cursiva, párrafos)

2. **Opción 2: Subform Dinámico con Script**
   - Crear subform con script FormCalc o JavaScript
   - Script parsea HTML y crea elementos dinámicamente
   - Más complejo pero mayor control

**Decisión**: Comenzar con Opción 1 (Rich Text Field)

---

### 2. Programa ABAP de Prueba: Z_PDF_FORM_PROTOTYPE

```abap
*&---------------------------------------------------------------------*
*& Report Z_PDF_FORM_PROTOTYPE
*&---------------------------------------------------------------------*
*& Prototipo Adobe Form Genérico - HTML Dinámico
*&---------------------------------------------------------------------*
REPORT z_pdf_form_prototype.

DATA: lv_fm_name     TYPE funcname,
      ls_form_data   TYPE zhrtmp_s_form_data,
      ls_output_para TYPE sfpoutputparams,
      ls_doc_para    TYPE sfpdocparams,
      ls_form_output TYPE fpformoutput,
      lv_pdf         TYPE xstring.

" ===== HTML DE PRUEBA =====
ls_form_data-html_content = 
  '<html>' &&
  '<body>' &&
  '<h1 style="color:#003366; text-align:center;">CERTIFICADO LABORAL</h1>' &&
  '<p>La empresa <b>ACME S.A.</b>, identificada con RUC 20123456789, certifica que:</p>' &&
  '<p>El Sr(a). <b>JUAN CARLOS GARCÍA LÓPEZ</b>, identificado(a) con DNI <b>12345678</b>, ' &&
  'labora en nuestra institución desde el <b>01 de enero de 2020</b>.</p>' &&
  '<p>Actualmente se desempeña como <b>Analista de Recursos Humanos</b> ' &&
  'en el área de <b>Recursos Humanos</b>.</p>' &&
  '<br/>' &&
  '<h3>Detalle Salarial:</h3>' &&
  '<table border="1" cellpadding="5" style="border-collapse:collapse;">' &&
  '  <tr style="background-color:#003366; color:white;">' &&
  '    <th>Concepto</th>' &&
  '    <th align="right">Importe</th>' &&
  '  </tr>' &&
  '  <tr>' &&
  '    <td>Salario Básico</td>' &&
  '    <td align="right">S/ 3,500.00</td>' &&
  '  </tr>' &&
  '  <tr style="background-color:#F5F5F5;">' &&
  '    <td>Asignación Familiar</td>' &&
  '    <td align="right">S/ 102.50</td>' &&
  '  </tr>' &&
  '  <tr>' &&
  '    <td><b>Total</b></td>' &&
  '    <td align="right"><b>S/ 3,602.50</b></td>' &&
  '  </tr>' &&
  '</table>' &&
  '<br/>' &&
  '<p style="text-align:right;"><i>Lima, 11 de junio de 2026</i></p>' &&
  '</body>' &&
  '</html>'.

" ===== LOGO DE PRUEBA (base64 de imagen pequeña 1x1px PNG) =====
ls_form_data-logo_img = 
  cl_http_utility=>decode_x_base64(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==' ).

" ===== FIRMA DE PRUEBA (misma imagen placeholder) =====
ls_form_data-signature_img = ls_form_data-logo_img.

" ===== METADATA =====
ls_form_data-doc_metadata-generated_at = sy-datum.
ls_form_data-doc_metadata-generated_by = sy-uname.

" ===== GENERAR PDF =====
TRY.
    " 1. Configurar parámetros de salida
    ls_output_para-getpdf = 'X'.  " Retornar PDF
    ls_output_para-nodialog = 'X'. " Sin diálogo
    
    " 2. Abrir Form Processing
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = ls_output_para
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    " 3. Obtener nombre del función módulo generado
    CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
        i_name     = 'ZHR_CONTPE_F_001'
      IMPORTING
        e_funcname = lv_fm_name.

    " 4. Llamar función módulo (Adobe Form)
    CALL FUNCTION lv_fm_name
      EXPORTING
        /1bcdwb/docparams  = ls_doc_para
        is_form_data       = ls_form_data
      IMPORTING
        /1bcdwb/formoutput = ls_form_output
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    " 5. Cerrar Form Processing
    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.

    " 6. Extraer PDF
    lv_pdf = ls_form_output-pdf.

    " 7. Guardar PDF en servidor (para inspección)
    DATA(lv_path) = '/tmp/test_pdf_' && sy-datum && '_' && sy-uzeit && '.pdf'.
    OPEN DATASET lv_path FOR OUTPUT IN BINARY MODE.
    TRANSFER lv_pdf TO lv_path.
    CLOSE DATASET lv_path.

    WRITE: / 'PDF generado exitosamente!'.
    WRITE: / 'Tamaño:', xstrlen( lv_pdf ), 'bytes'.
    WRITE: / 'Archivo:', lv_path.
    WRITE: / ''.
    WRITE: / 'Para ver el PDF:'.
    WRITE: / '1. Transaction CG3Y (Download from Application Server)'.
    WRITE: / '2. Source file:', lv_path.
    WRITE: / '3. Target file: C:\temp\test.pdf'.
    
  CATCH cx_fp_api_usage INTO DATA(lx_usage).
    WRITE: / 'Error FP API:', lx_usage->get_text( ).
  CATCH cx_fp_api_internal INTO DATA(lx_internal).
    WRITE: / 'Error FP Internal:', lx_internal->get_text( ).
  CATCH cx_fp_api_repository INTO DATA(lx_repo).
    WRITE: / 'Error FP Repository:', lx_repo->get_text( ).
ENDTRY.
```

---

### 3. Testing del Prototipo

#### 3.1 Escenarios de Prueba

| Escenario | HTML Input | Resultado Esperado |
|-----------|------------|-------------------|
| **1. Texto Simple** | `<p>Hola mundo</p>` | Párrafo renderizado |
| **2. Formato Básico** | `<p><b>Negrita</b>, <i>Cursiva</i>, <u>Subrayado</u></p>` | Formato aplicado correctamente |
| **3. Colores** | `<p style="color:red;">Rojo</p>` | Texto en rojo |
| **4. Alineación** | `<p style="text-align:center;">Centro</p>` | Texto centrado |
| **5. Tabla Simple** | `<table><tr><td>A</td><td>B</td></tr></table>` | Tabla renderizada |
| **6. Tabla con Estilos** | Tabla con bordes, colores | Estilos aplicados |
| **7. Imagen Logo** | xstring de imagen PNG | Logo insertado |
| **8. Imagen Firma** | xstring de imagen PNG | Firma insertada |
| **9. HTML Complejo** | Documento completo (ver código prueba) | Todo renderizado correctamente |

#### 3.2 Ejecución de Pruebas

**Pasos**:
1. Crear Adobe Form `ZHR_CONTPE_F_001` en Transaction SFP
2. Activar form
3. Ejecutar report `Z_PDF_FORM_PROTOTYPE` (Transaction SE38)
4. Descargar PDF generado (Transaction CG3Y)
5. Abrir PDF y verificar:
   - ✅ Logo visible en esquina superior izquierda
   - ✅ Título centrado en azul
   - ✅ Textos con negrita renderizados correctamente
   - ✅ Tabla con bordes y colores aplicados
   - ✅ Firma visible en posición correcta
   - ✅ Metadata en footer

---

## Resultados Esperados

### ✅ Caso Exitoso (Opción 1 Funciona)

**Rich Text Field interpreta HTML correctamente**:
- Formato básico (negrita, cursiva) funciona
- Colores y alineación funcionan
- Tablas se renderizan (aunque estilos puedan ser limitados)
- Imágenes se insertan correctamente

**Conclusión**: Usar Opción 1 (Rich Text Field) para implementación

**Próximos pasos**:
- Documentar limitaciones (si hay)
- Crear función de limpieza de HTML (remover tags no soportados)
- Implementar clase `ZCL_HHR_CONTPE_RENDERER_ADS`

### ⚠️ Caso Parcial (Opción 1 con Limitaciones)

**Rich Text Field tiene limitaciones**:
- Formato básico funciona
- Algunos estilos CSS no se aplican (ej: colores de fondo en tablas)
- Tablas se renderizan pero sin bordes avanzados

**Conclusión**: Evaluar si limitaciones son aceptables

**Alternativas**:
- Simplificar HTML generado (menos estilos CSS)
- Pre-procesar HTML para convertir estilos complejos a formato soportado
- Si inaceptable → probar Opción 2 (XSL-FO)

### ❌ Caso Fallido (Opción 1 No Funciona)

**Rich Text Field NO interpreta HTML** o lo hace muy mal:
- HTML se muestra como texto plano
- Formato no se aplica

**Conclusión**: Opción 1 no es viable

**Plan B - Opción 2: HTML → XSL-FO**:

1. Implementar conversor HTML → XSL-FO en ABAP
2. Adobe Form recibe XSL-FO (XML) en lugar de HTML
3. XSL-FO es estándar soportado por Adobe

**Herramientas**:
- Clase custom `ZCL_HHR_CONTPE_HTML_TO_XSLFO_CONVERTER`
- O usar librería XSLT para transformación

**Esfuerzo adicional**: +1-2 semanas

---

## Opción 2: HTML → XSL-FO (Plan B)

### XSL-FO Básico

**HTML**:
```html
<p style="color:red;">Hola mundo</p>
```

**XSL-FO Equivalente**:
```xml
<fo:block color="red">Hola mundo</fo:block>
```

### Mapeo HTML → XSL-FO

| HTML Tag | XSL-FO |
|----------|--------|
| `<p>` | `<fo:block>` |
| `<b>` | `<fo:inline font-weight="bold">` |
| `<i>` | `<fo:inline font-style="italic">` |
| `<table>` | `<fo:table>` |
| `<tr>` | `<fo:table-row>` |
| `<td>` | `<fo:table-cell>` |
| `<img>` | `<fo:external-graphic>` |

### Implementación Conversor

```abap
CLASS zcl_hhr_contpe_html_to_xslfo_converter DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS convert
      IMPORTING
        iv_html        TYPE string
      RETURNING
        VALUE(rv_xslfo) TYPE string
      RAISING
        zcx_hhr_contpe_conversion_error.
ENDCLASS.

CLASS zcl_hhr_contpe_html_to_xslfo_converter IMPLEMENTATION.
  METHOD convert.
    " Parsear HTML (usar clase XML o regex)
    " Convertir tags HTML → XSL-FO
    " Retornar XSL-FO completo
    
    " Ejemplo simplificado:
    rv_xslfo = iv_html.
    REPLACE ALL OCCURRENCES OF '<p>' IN rv_xslfo WITH '<fo:block>'.
    REPLACE ALL OCCURRENCES OF '</p>' IN rv_xslfo WITH '</fo:block>'.
    REPLACE ALL OCCURRENCES OF '<b>' IN rv_xslfo WITH '<fo:inline font-weight="bold">'.
    REPLACE ALL OCCURRENCES OF '</b>' IN rv_xslfo WITH '</fo:inline>'.
    " ... más conversiones
    
    " Envolver en estructura XSL-FO completa
    rv_xslfo = 
      '<?xml version="1.0" encoding="UTF-8"?>' &&
      '<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">' &&
      '  <fo:layout-master-set>' &&
      '    <fo:simple-page-master master-name="A4">' &&
      '      <fo:region-body margin="2cm"/>' &&
      '    </fo:simple-page-master>' &&
      '  </fo:layout-master-set>' &&
      '  <fo:page-sequence master-reference="A4">' &&
      '    <fo:flow flow-name="xsl-region-body">' &&
      rv_xslfo &&
      '    </fo:flow>' &&
      '  </fo:page-sequence>' &&
      '</fo:root>'.
  ENDMETHOD.
ENDCLASS.
```

---

## Decisión Post-Prototipo

### Criterios de Evaluación

| Criterio | Peso | Opción 1 (Rich Text) | Opción 2 (XSL-FO) |
|----------|------|----------------------|-------------------|
| **Simplicidad** | 30% | ⭐⭐⭐⭐⭐ (muy simple) | ⭐⭐ (complejo) |
| **Soporte Estilos** | 25% | ⭐⭐⭐ (limitado) | ⭐⭐⭐⭐⭐ (completo) |
| **Esfuerzo Desarrollo** | 20% | ⭐⭐⭐⭐⭐ (mínimo) | ⭐⭐ (1-2 semanas extra) |
| **Mantenibilidad** | 15% | ⭐⭐⭐⭐ (simple) | ⭐⭐⭐ (medio) |
| **Performance** | 10% | ⭐⭐⭐⭐ (bueno) | ⭐⭐⭐ (overhead conversión) |

### Recomendación

1. **Implementar prototipo Opción 1** en Sprint 5 (1 día)
2. **Evaluar resultados** con stakeholders (mostrar PDFs generados)
3. **Si Opción 1 es suficiente** (estilos limitados pero aceptables):
   - Proceder con Opción 1
   - Documentar limitaciones
   - Simplificar HTML generado para evitar estilos no soportados
4. **Si Opción 1 NO es suficiente**:
   - Implementar conversor HTML → XSL-FO (Opción 2)
   - Agregar 1-2 semanas al cronograma

---

## Entregables del Prototipo

1. ✅ Adobe Form `ZHR_CONTPE_F_001` creado y activado
2. ✅ Report `Z_PDF_FORM_PROTOTYPE` con casos de prueba
3. ✅ 3-5 PDFs de muestra generados (diferentes escenarios)
4. ✅ Documento de evaluación (este documento con resultados)
5. ✅ Decisión documentada: Opción 1 o Opción 2
6. ✅ Si Opción 2: Especificación detallada de conversor HTML → XSL-FO

---

## Cronograma Prototipo

| Tarea | Duración | Responsable |
|-------|----------|-------------|
| Crear Adobe Form genérico | 2 horas | Dev ABAP |
| Crear report de prueba | 2 horas | Dev ABAP |
| Ejecutar pruebas (9 escenarios) | 1 hora | Dev ABAP |
| Generar PDFs de muestra | 30 min | Dev ABAP |
| Evaluar resultados | 1 hora | Dev ABAP + Arquitecto |
| Documentar decisión | 30 min | Arquitecto |

**Total**: 1 día (7 horas)

---

## Conclusión

Este prototipo es **crítico** para validar la viabilidad técnica del approach de HTML dinámico. Los resultados determinarán:
- Si el cronograma se mantiene (Opción 1)
- Si necesitamos agregar 1-2 semanas (Opción 2)
- Si hay un problema fundamental que requiere rediseño

**Ejecutar prototipo en Sprint 5 (semana 5) antes de implementar clase `ZCL_HHR_CONTPE_RENDERER_ADS`.**

---

**Documento**: Prototipo Adobe Form Genérico  
**Versión**: 1.0  
**Estado**: Diseño Aprobado  
**Próxima Revisión**: Post-ejecución de prototipo (Sprint 5)
