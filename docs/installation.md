# Guía de Instalación
## Generador PDF HCM - SAP S/4HANA

**Versión**: 1.0  
**Fecha**: 11 de Junio de 2026

---

## Pre-requisitos

### Sistema SAP

- SAP S/4HANA 2023 o superior
- Adobe Document Services (ADS) configurado y licenciado
- SAP ArchiveLink configurado con Content Server
- SAP Gateway activado
- Fiori Launchpad configurado

### Verificación de Pre-requisitos

#### 1. Verificar ADS

```abap
" Transaction: FP_CHECK_DESTINATION_SERV
" O ejecutar report: FP_CHECK_DESTINATION_SERVICE
```

**Resultado esperado**: Estado verde, conexión exitosa a ADS

#### 2. Verificar ArchiveLink

```abap
" Transaction: OAC0 (Configuración ArchiveLink)
" Verificar que existe Content Server configurado
```

#### 3. Verificar Gateway

```abap
" Transaction: /IWFND/MAINT_SERVICE
" Verificar que Gateway está activo
```

---

## Instalación

### Paso 1: Importar Código vía abapGit

#### 1.1 Instalar abapGit (si no está instalado)

1. Ir a Transaction SE38
2. Ejecutar report `ZABAPGIT_STANDALONE`
3. Si no existe, instalarlo desde: https://docs.abapgit.org/

#### 1.2 Clonar Repositorio

1. Ejecutar `ZABAPGIT`
2. Click en "New Online"
3. Ingresar URL del repositorio: `https://github.com/[org]/sap-pdf-hcm-generator`
4. Package: `ZHR_CONTPE`
5. Folder logic: `PREFIX`
6. Click "Create Package"
7. Click "Pull"
8. Seleccionar todos los objetos
9. Click "Import"

**Tiempo estimado**: 5-10 minutos

#### 1.3 Verificar Importación

Transaction SE80 → Buscar package `ZHR_CONTPE`

**Objetos esperados**:
- 8 tablas Z (ZHR_CONTPE_*)
- 11 clases principales (ZCL_HHR_CONTPE_*)
- 2 interfaces (ZIF_HHR_CONTPE_*)
- 7 clases de excepción (ZCX_HHR_CONTPE_*)
- 8 CDS views (ZHR_CONTPE_I_*, ZHR_CONTPE_C_*)
- 5 servicios OData (ZUI_HHR_CONTPE_*_O4)
- 1 Adobe Form (ZHR_CONTPE_F_001)
- Elementos de datos y dominios

---

### Paso 2: Configurar ArchiveLink

#### 2.1 Crear Document Class

Transaction: `OAC2`

1. Click "Create"
2. Document class: `Z_HR_CONTPE`
3. Description: "Documentos PDF HCM"
4. Class type: `Document class for archiving`
5. Retention period: `2557` días (7 años)
6. Storage system: seleccionar Content Server configurado
7. Guardar

#### 2.2 Crear Object Type

Transaction: `OAC3`

1. SAP Object Type: `Z_PREL_PDF`
2. Description: "PDF Documentos Personal"
3. Link Table: `TOA01`
4. Document class: `Z_HR_CONTPE`
5. Technical name: `Z_PREL_PDF`
6. Guardar

#### 2.3 Vincular a PA (Personal)

Transaction: `OAOR`

1. Business Object: `PREL`
2. Object Type: `Z_PREL_PDF`
3. Document class: `Z_HR_CONTPE`
4. Activar vínculo
5. Guardar

---

### Paso 3: Activar Servicios OData

Transaction: `/IWFND/MAINT_SERVICE`

#### 3.1 Registrar Servicios

Para cada servicio:
- `ZUI_HHR_CONTPE_TPL_O4`
- `ZUI_HHR_CONTPE_FMAP_O4`
- `ZUI_HHR_CONTPE_SIG_O4`
- `ZUI_HHR_CONTPE_HIST_O4`
- `ZUI_HHR_CONTPE_GEN_O4`

**Pasos**:
1. Click "Add Service"
2. System Alias: `LOCAL`
3. Technical Service Name: [nombre del servicio]
4. Click "Get Services"
5. Seleccionar servicio
6. Package Assignment: `ZHR_CONTPE`
7. Click "Add Selected Services"
8. Confirmar
9. Click "Register"

**Tiempo estimado**: 15-20 minutos (todos los servicios)

#### 3.2 Verificar Servicios

Transaction: `/IWFND/GW_CLIENT`

1. Ingresar Service: `/sap/opu/odata4/sap/zui_hhr_contpe_tpl_o4/srvd/sap/zui_hhr_contpe_tpl_o4/0001/Templates`
2. Method: `GET`
3. Click "Execute"
4. **Resultado esperado**: HTTP 200, lista vacía (aún no hay templates)

---

### Paso 4: Cargar Datos Iniciales

#### 4.1 Configuración (ZHR_CONTPE_CONFIG)

Transaction: `SE16` → Tabla `ZHR_CONTPE_CONFIG`

Click "Create" y cargar:

| PARAM_KEY | PARAM_VALUE | DESCRIPTION |
|-----------|-------------|-------------|
| RENDERER_TYPE | ADS | Motor PDF: ADS, NATIVE, EXTERNAL |
| MAX_MASS_GENERATION | 10000 | Máximo empleados por generación masiva |
| DEFAULT_SIGNATURE_ID | | Firmante por defecto (dejar vacío inicialmente) |
| ARCHIVELINK_DOC_CLASS | Z_HR_CONTPE | Document class ArchiveLink |
| ARCHIVELINK_OBJECT_TYPE | Z_PREL_PDF | Object type ArchiveLink |
| RETENTION_YEARS | 7 | Años retención documentos |
| DIGITAL_SIGN_ENABLED | N | Firma digital habilitada: Y/N |
| NOTIFY_GENERATOR | X | Notificar por email a generador |

**Alternativa**: Ejecutar report `Z_PDF_INIT_CONFIG` (carga automática)

#### 4.2 Campos Básicos (ZHR_CONTPE_FIELDMAP)

Ejecutar report: `Z_PDF_INIT_FIELDMAP`

Este report carga placeholders básicos:
- PERNR, DNI, NOMBRE, APELLIDO, NOMBRE_COMPLETO
- FECHA_INGRESO, FECHA_NACIMIENTO, EDAD, ANTIGUEDAD_ANOS
- PUESTO_DESCRIPCION, ORG_AREA, ORG_DIVISION
- SAL_BASICO, SAL_MONEDA

**Tiempo estimado**: 1-2 minutos

---

### Paso 5: Desplegar Apps Fiori

#### 5.1 Pre-requisitos

- Node.js 16+ instalado
- npm 8+
- SAP Fiori Tools (VS Code extension)
- Cloud Connector configurado (si aplica)

#### 5.2 Build y Deploy

Para cada app en `fiori-apps/`:

```bash
cd fiori-apps/zhr_contpe_template_list
npm install
npm run build
npm run deploy
```

**Apps a desplegar**:
1. `zhr_contpe_template_list` (Gestión de Plantillas)
2. `zhr_contpe_template_editor` (Editor de Plantilla)
3. `zhr_contpe_fieldmap_list` (Catálogo de Campos)
4. `zhr_contpe_generate_doc` (Generación de Documentos)
5. `zhr_contpe_doc_history` (Histórico)
6. `zhr_contpe_signatures` (Gestión de Firmas)

**Tiempo estimado**: 10-15 minutos por app

#### 5.3 Configurar Fiori Launchpad

Transaction: `/UI2/FLPD_CUST`

1. Crear Catalog: `Z_PDF_HCM`
2. Crear Group: `Generador PDF HCM`
3. Agregar Tiles para cada app (acceso alternativo a las transacciones):
   - Gestión de Plantillas → transacción `ZHHRTCONTPE_770`
   - Generar Documentos → transacción `ZHHRTCONTPE_771`
   - Histórico de Documentos → transacción `ZHHRTCONTPE_772`
   - Catálogo de Campos (desde mantenimiento o tile secundario)
   - Gestión de Firmas (desde mantenimiento o tile secundario)

4. Asignar Catalog al rol `Z_HR_CONTPE_FULL` (o roles segregados: `Z_HR_CONTPE_ADMIN`, `Z_HR_CONTPE_OPERATOR`)

---

### Paso 6: Configurar Autorizaciones

#### 6.1 Crear Role

Transaction: `PFCG`

1. Role: `Z_HR_CONTPE_GENERATOR`
2. Description: "Generador PDF HCM - Usuario RRHH"

**Autorizaciones**:

```
S_TCODE:
  TCD: ZHHRTCONTPE_770, ZHHRTCONTPE_771, ZHHRTCONTPE_772

S_SERVICE:
  SRV_NAME: ZUI_HHR_CONTPE_*
  
/IWFND/RT_GW_USER:
  Acceso a Gateway

S_WFAR_OBJ:
  OBJECTTYPE: Z_HR_CONTPE
  ACTVT: 01, 02, 03 (Crear, Modificar, Visualizar)

S_RFC:
  RFC_NAME: ARCHIV* (funciones de ArchiveLink)
  ACTVT: 16 (Ejecutar)
```

#### 6.2 Asignar Role a Usuarios

Transaction: `SU01`

1. Seleccionar usuario RRHH
2. Tab "Roles"
3. Agregar role `Z_HR_CONTPE_GENERATOR`
4. Generar perfil
5. Guardar

---

### Paso 7: Testing de Instalación

#### 7.1 Test ArchiveLink

1. Transaction: `SE38`
2. Crear programa de prueba:

```abap
REPORT z_test_archivelink.

DATA: lv_archiv_id TYPE archiv_id,
      lv_pdf       TYPE xstring.

" Crear PDF de prueba
lv_pdf = cl_bcs_convert=>string_to_xstring( '<html><body>Test</body></html>' ).

" Almacenar
TRY.
    DATA(lo_archiver) = NEW zcl_hhr_contpe_archiver( ).
    lv_archiv_id = lo_archiver->store_document(
      iv_pdf         = lv_pdf
      iv_pernr       = '00000001'
      iv_document_id = 1
      is_metadata    = VALUE #( )
    ).
    WRITE: / 'Almacenamiento exitoso, ARCHIV_ID:', lv_archiv_id.
  CATCH zcx_hhr_contpe_archive_error INTO DATA(lx_error).
    WRITE: / 'Error:', lx_error->get_text( ).
ENDTRY.
```

**Resultado esperado**: "Almacenamiento exitoso"

#### 7.2 Test Servicios OData

Transaction: `/IWFND/GW_CLIENT`

Probar cada servicio:
1. Templates: `GET /Templates`
2. FieldMap: `GET /FieldMappings`
3. Signatures: `GET /Signatures`

**Resultado esperado**: HTTP 200

#### 7.3 Test Fiori Apps

1. Acceder a Fiori Launchpad
2. Verificar que aparecen los 6 tiles del grupo "Generador PDF HCM"
3. Abrir cada app y verificar que carga sin errores

---

## Post-Instalación

### Crear Plantilla de Prueba

1. Acceder a Fiori app "Gestión de Plantillas"
2. Click "Crear Nueva"
3. Código: `TEST01`
4. Descripción: "Plantilla de Prueba"
5. Tipo: `CERT` (Certificado)
6. Idioma: Español
7. Contenido:

```html
<h1>CERTIFICADO DE PRUEBA</h1>
<p>El empleado {{NOMBRE_COMPLETO}} con DNI {{DNI}} labora en nuestra empresa desde el {{FECHA_INGRESO}}.</p>
<p>Fecha: {{FECHA_ACTUAL}}</p>
```

8. Guardar como Borrador
9. Click "Validar" → debe mostrar "OK" (todos los placeholders existen)
10. Click "Activar Plantilla"

### Generar Documento de Prueba

1. Acceder a Fiori app "Generar Documentos"
2. PERNR: Ingresar empleado de prueba
3. Plantilla: `TEST01 - Plantilla de Prueba`
4. Click "Vista Previa"
5. Verificar que PDF se genera correctamente
6. Click "Generar Definitivo"
7. Verificar mensaje de éxito

### Verificar en Histórico

1. Acceder a Fiori app "Histórico de Documentos"
2. Filtrar por PERNR del empleado de prueba
3. Debe aparecer documento generado
4. Click "Ver PDF"
5. Verificar que se recupera desde ArchiveLink

---

## Troubleshooting

### Error: "ADS not available"

**Solución**:
1. Transaction: `FP_CHECK_DESTINATION_SERV`
2. Verificar que servicio ADS está activo
3. Si no, contactar equipo Basis para activarlo

### Error: "ArchiveLink document class not found"

**Solución**:
1. Verificar Transaction `OAC2` → Document class `Z_HR_CONTPE` existe
2. Si no, repetir Paso 2.1

### Error: "OData service not found"

**Solución**:
1. Transaction: `/IWFND/MAINT_SERVICE`
2. Verificar que servicios están registrados
3. Si no, repetir Paso 3.1

### Error: "Placeholder no encontrado"

**Solución**:
1. Ejecutar report `Z_PDF_INIT_FIELDMAP` para cargar campos básicos
2. O crear placeholder manualmente en app "Catálogo de Campos"

### Fiori apps no cargan

**Solución**:
1. Verificar Gateway activo: Transaction `/IWFND/ERROR_LOG`
2. Verificar que servicios OData están publicados
3. Verificar que usuario tiene role `Z_HR_CONTPE_GENERATOR`
4. Clear browser cache

---

## Siguiente Pasos

Después de instalación exitosa:

1. ✅ **Capacitación de Usuarios**: Programar sesión de capacitación para usuarios RRHH (2-3 horas)
2. ✅ **Crear Plantillas Productivas**: Trabajar con RRHH para crear plantillas reales (certificados, cartas, contratos)
3. ✅ **Configurar Firmantes**: Cargar imágenes de firmas en "Gestión de Firmas"
4. ✅ **Configurar Logos**: Cargar logos corporativos
5. ✅ **Testing UAT**: Realizar pruebas de aceptación con usuarios finales

---

## Soporte

**Equipo de Desarrollo**:
- Líder Técnico: [Nombre] - [email]
- Desarrollador ABAP: [Nombre] - [email]
- Desarrollador Fiori: [Nombre] - [email]

**Equipo Basis**:
- Basis Lead: [Nombre] - [email]

**Incidentes**: Abrir ticket en [Sistema de Tickets]

---

**Documento**: Guía de Instalación  
**Versión**: 1.0  
**Última Actualización**: 11 de Junio de 2026
