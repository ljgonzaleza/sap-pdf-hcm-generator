# Respuestas a Preguntas Abiertas
## Generador PDF HCM - SAP S/4HANA

**Fecha**: 11 de Junio de 2026  
**Versión**: 1.0

---

## Introducción

Este documento responde a las 10 preguntas abiertas identificadas en la Sección 4 de las especificaciones funcionales y técnicas. Las respuestas han sido definidas para permitir el inicio de la implementación sin bloqueos.

---

## 1. Logos de Empresa

### Pregunta Original
¿Dónde se almacenarán los logos? ¿Repositorio en tabla Z o ArchiveLink? ¿Múltiples logos para diferentes unidades de negocio?

### Respuesta

**Almacenamiento**: Tabla Z dedicada `ZHR_CONTPE_LOGOS`

**Justificación**:
- Logos son datos de aplicación pequeños (< 100KB típicamente)
- Acceso frecuente durante generación de documentos
- No requiere overhead de ArchiveLink
- Más simple para mantenimiento por usuarios

**Estructura de Tabla**:

```abap
ZHR_CONTPE_LOGOS:
- LOGO_ID        CHAR(10)  PK  -- Identificador único (ej: LOGO_CORP, LOGO_PERU)
- LOGO_DESC      CHAR(60)      -- Descripción
- ORG_UNIT       CHAR(8)       -- Unidad organizativa (opcional, para filtrar)
- BUKRS          CHAR(4)       -- Sociedad (opcional)
- IMAGE_DATA     RAWSTRING     -- Imagen (PNG, JPG, SVG)
- IMAGE_MIMETYPE CHAR(30)      -- image/png, image/jpeg, image/svg+xml
- IMAGE_WIDTH    INT4          -- Ancho en píxeles
- IMAGE_HEIGHT   INT4          -- Alto en píxeles
- IMAGE_SIZE     INT4          -- Tamaño en bytes
- POSITION       CHAR(10)      -- Posición default: HEADER, FOOTER, LEFT, RIGHT, CENTER
- STATUS         CHAR(1)       -- A=Activo, I=Inactivo
- CREATED_BY     SYUNAME
- CREATED_AT     TIMESTAMPL
- CHANGED_BY     SYUNAME
- CHANGED_AT     TIMESTAMPL
```

**Múltiples Logos**: Sí, soportado
- Cada sociedad (BUKRS) o unidad organizativa puede tener su logo
- Plantilla puede referenciar logo por ID: `{{LOGO:LOGO_CORP}}` o `{{LOGO:LOGO_PERU}}`
- Sistema selecciona logo según empleado (PA0001-BUKRS)

**UI de Gestión**: 
- Fiori app adicional: "Gestión de Logos"
- CRUD con upload de imagen
- Preview del logo

---

## 2. Convención de Nombres de Placeholders

### Pregunta Original
¿Hay convención deseada? (ej: `EMP_NOMBRE` vs. `NOMBRE` vs. `{{EMPLEADO.NOMBRE}}`). Recomendación: nombres cortos, autoexplicativos, sin espacios, mayúsculas.

### Respuesta

**Convención Adoptada**: Nombres descriptivos en mayúsculas, guion bajo para separar conceptos

**Reglas**:
1. **Solo mayúsculas**: `NOMBRE`, `FECHA_INGRESO`
2. **Sin espacios**: usar `_` (guion bajo)
3. **Máximo 40 caracteres**: límite técnico (campo de tabla)
4. **Prefijo opcional para contexto**: 
   - Datos básicos: sin prefijo (`NOMBRE`, `APELLIDO`, `DNI`)
   - Datos de puesto: prefijo `PUESTO_` (`PUESTO_DESCRIPCION`, `PUESTO_CODIGO`)
   - Datos organizativos: prefijo `ORG_` (`ORG_AREA`, `ORG_DIVISION`)
   - Datos salariales: prefijo `SAL_` (`SAL_BASICO`, `SAL_TOTAL`)
   - Fechas: sufijo `_FECHA` o `_TEXTO` (`INGRESO_FECHA`, `INGRESO_TEXTO`)
   - Tablas: prefijo `TABLA_` (`TABLA_SALARIO`, `TABLA_PRESTAMOS`)

**Ejemplos Estándar**:

| Categoría | Placeholders |
|-----------|-------------|
| **Identificación** | `PERNR`, `DNI`, `NOMBRE`, `APELLIDO`, `NOMBRE_COMPLETO` |
| **Fechas** | `FECHA_INGRESO`, `FECHA_NACIMIENTO`, `FECHA_ACTUAL`, `FECHA_INGRESO_TEXTO` |
| **Puesto** | `PUESTO_DESCRIPCION`, `PUESTO_CODIGO`, `PUESTO_NIVEL` |
| **Organización** | `ORG_AREA`, `ORG_DIVISION`, `ORG_CENTRO_COSTE`, `ORG_SOCIEDAD` |
| **Salarial** | `SAL_BASICO`, `SAL_TOTAL`, `SAL_MONEDA` |
| **Calculados** | `EDAD`, `ANTIGUEDAD_ANOS`, `ANTIGUEDAD_TEXTO` |
| **Tablas** | `TABLA_SALARIO`, `TABLA_PRESTAMOS`, `TABLA_FORMACION` |
| **Logos** | `LOGO:LOGO_ID` (ej: `LOGO:LOGO_CORP`) |

**Validación**: Sistema valida que placeholders sigan convención al crear/editar en catálogo (regex: `^[A-Z][A-Z0-9_]*$`)

---

## 3. Volumen de Tipos de Documentos

### Pregunta Original
¿Cuántos tipos diferentes de documentos se esperan? (certificados, contratos, cartas, anexos, etc.). Esto afecta diseño de catálogo de plantillas.

### Respuesta

**Volumen Estimado Inicial**: 15-20 tipos de documentos

**Categorías de Documentos**:

| Categoría | Cantidad | Ejemplos |
|-----------|----------|----------|
| **Certificados** | 5-7 | Cert. laboral, cert. remuneraciones, cert. AFP, cert. domicilio laboral, cert. escolaridad |
| **Cartas** | 4-6 | Carta de bienvenida, carta de felicitación, carta anual, carta de agradecimiento |
| **Contratos** | 3-4 | Contrato plazo fijo, contrato indefinido, contrato temporal, anexos de contrato |
| **Documentos Internos** | 2-3 | Memorandums, comunicados internos |
| **Otros** | 1-2 | Constancias diversas |

**Total Estimado Fase 1**: 15-20 plantillas activas

**Crecimiento Esperado**: +5-10 nuevas plantillas por año

**Impacto en Diseño**:
- ✅ **Catálogo Flexible**: Campo `DOCTYPE` en `ZHR_CONTPE_TEMPLATES` soporta valores customizables
- ✅ **Escalabilidad**: Sin límite técnico en número de plantillas
- ✅ **Organización**: Filtros por tipo de documento en UI
- ✅ **Performance**: Sin impacto significativo (volumen bajo)

**Dominio de Tipos de Documento** (valores fijos sugeridos):

```
ZCERT  - Certificado
CARTA  - Carta
CONTR  - Contrato
MEMO   - Memorandum
CONST  - Constancia
OTROS  - Otros
```

Usuario puede agregar nuevos valores si es necesario (dominio abierto, no check table estricta).

---

## 4. Formato de Tablas en PDF - Estándar Corporativo

### Pregunta Original
¿Hay un estándar de diseño corporativo? (colores, fuentes, logos). Considerar crear plantillas Adobe pre-diseñadas con branding corporativo.

### Respuesta

**Enfoque**: Plantillas configurables con valores por defecto corporativos

**Estándar de Diseño Definido**:

### Colores Corporativos
- **Primario**: #003366 (Azul oscuro)
- **Secundario**: #0066CC (Azul medio)
- **Acento**: #FF6600 (Naranja)
- **Neutro**: #CCCCCC (Gris claro)
- **Texto**: #333333 (Gris oscuro)

### Fuentes
- **Encabezados**: Arial Bold, 14-18pt
- **Cuerpo**: Arial Regular, 10-12pt
- **Pie de página**: Arial Regular, 8pt

### Logos
- **Logo principal**: Esquina superior izquierda (150x50px)
- **Logo secundario**: Pie de página centro (opcional)

### Tablas - Estilo Estándar
- **Encabezado tabla**: Fondo #003366, texto blanco, Arial Bold 10pt
- **Filas alternas**: Fondo blanco / #F5F5F5 (gris muy claro)
- **Bordes**: 1pt, color #CCCCCC
- **Padding**: 5pt (celdas)
- **Alineación**: Izquierda (texto), Derecha (números)

### Estructura de Documento
```
┌─────────────────────────────────────────┐
│ [LOGO]                    [Fecha]       │ ← Header
├─────────────────────────────────────────┤
│                                         │
│         TÍTULO DEL DOCUMENTO            │ ← Arial Bold 18pt, Azul #003366
│                                         │
│ Contenido del documento...              │ ← Arial 11pt, #333333
│                                         │
│ [Tabla si aplica]                       │
│                                         │
├─────────────────────────────────────────┤
│ _____________________                   │ ← Signature area
│ [Firma]                                 │
│ Nombre Firmante                         │
│ Cargo                                   │
├─────────────────────────────────────────┤
│ Pie de página - RUC - Dirección        │ ← Footer, Arial 8pt, #666666
└─────────────────────────────────────────┘
```

**Implementación**:
- Tabla `ZHR_CONTPE_STYLES` con estilos predefinidos (colores, fuentes, tamaños)
- Usuario puede override estilos en plantilla si es necesario
- Adobe Form genérico usa estilos de tabla

**Consideración Perú**:
- Documentos oficiales deben incluir: RUC, dirección fiscal
- Fechas en español: "Lima, 11 de junio de 2026"

---

## 5. Integración con Transaction PA20/PA30

### Pregunta Original
¿Se desea integrar la generación de documentos directamente en el maestro de empleados? (botón custom en PA20). Esto requeriría desarrollo adicional (BAdI, screen exit).

### Respuesta

**Decisión**: SÍ, integración en PA20/PA30 en Fase Futura (post go-live)

**Fase 1 (Alcance Actual)**:
- ❌ NO incluir integración en PA20/PA30
- ✅ Acceso solo vía Fiori apps standalone
- ✅ Usuario selecciona PERNR manualmente

**Fase 2 (Post Go-Live, +2 meses)**:
- ✅ Botón custom en PA20/PA30: "Generar Documento PDF"
- ✅ Lanzar Fiori app con PERNR pre-seleccionado
- ✅ Implementación vía Enhancement Spot o BAdI

**Justificación**:
- Mantener alcance Fase 1 controlado
- Mayoría de usuarios usarán Fiori (más moderno)
- Integración PA20/PA30 es "nice to have", no crítico
- Requiere esfuerzo adicional (1-2 sprints)

**Alternativa Temporal**: 
- Transaction custom `ZHHRTCONTPE_771` con parámetro `P_PERNR` (programa `ZHHRCONTPE_771`)
- Usuarios de PA20 pueden ejecutar transaction con PERNR en memoria

**Implementación Futura** (cuando se apruebe):
- Enhancement Spot: `HR_PA_xxx` o similar
- Agregar botón en toolbar PA20
- Llamar URL Fiori con parámetro PERNR

---

## 6. Notificaciones por Email

### Pregunta Original
¿Email a empleados cuando se genera su documento? ¿Email a generador cuando finaliza job masivo? Requiere configuración SMTP.

### Respuesta

**Decisión**: Notificaciones habilitadas con configuración opcional

**Fase 1 (Implementar)**:

✅ **Email a generador (job masivo)**:
- Al finalizar generación masiva, enviar email con:
  - Total documentos generados
  - Errores (si hay)
  - Link para descargar ZIP
- Usar clase estándar `CL_BCS` (Business Communication Services)
- Configurable: `ZHR_CONTPE_CONFIG` → `NOTIFY_GENERATOR` = 'X'

❌ **Email a empleados** (NO en Fase 1):
- Requiere más análisis:
  - ¿Todos los empleados tienen email en sistema?
  - ¿Qué dice política de privacidad?
  - ¿Se enviará PDF como attachment o link?
- Implementar en Fase Futura (después de aprobación RRHH)

**Configuración SMTP**:
- **Requisito Previo**: SMTP configurado en SAP (Transaction SCOT)
- **Verificación**: Equipo Basis debe confirmar que SMTP está funcional en DEV/QAS/PRD
- **Fallback**: Si SMTP no disponible, solo mostrar mensaje en UI (sin email)

**Email Template (Generación Masiva)**:

```
Asunto: Generación Masiva de Documentos PDF - Completada

Estimado/a [USUARIO],

La generación masiva de documentos PDF ha finalizado exitosamente.

Detalles:
- Plantilla: [NOMBRE_PLANTILLA]
- Fecha: [FECHA_HORA]
- Total empleados procesados: [TOTAL]
- Documentos generados: [EXITOSOS]
- Errores: [ERRORES]

[Si hay errores, incluir lista]

Para descargar los documentos, acceda a:
[LINK A FIORI APP - HISTÓRICO]

Saludos,
Sistema de Generación PDF HCM
```

**Clase Email**: `ZCL_HHR_CONTPE_NOTIFIER`
- Método: `send_mass_generation_complete( iv_job_id, iv_recipient )`

---

## 7. Internacionalización de Datos HR

### Pregunta Original
Si empleados tienen múltiples direcciones (IT0006) o nombres en diferentes idiomas, ¿cuál usar en documentos? Recomendación: usar idioma del documento (SPRAS) para seleccionar datos si existen múltiples.

### Respuesta

**Regla Adoptada**: Priorizar idioma del documento, fallback a idioma principal del empleado

**Lógica de Selección**:

### Para Datos Multilenguaje (ej: Textos de Cargo)

1. **Prioridad 1**: Texto en idioma del documento (SPRAS de plantilla)
   - Si documento es ES, buscar texto en español
   - Si documento es EN, buscar texto en inglés

2. **Prioridad 2**: Texto en idioma principal del empleado (PA0002-SPRSL)
   - Si empleado tiene español como idioma principal, usar español

3. **Prioridad 3**: Texto en idioma del sistema (SY-LANGU)
   - Fallback al idioma configurado en el sistema

4. **Prioridad 4**: Primer texto disponible (cualquier idioma)
   - Si no hay texto en ningún idioma preferido

### Para Infotipos con Subtipos de Idioma

**Ejemplo: IT0002 (Datos Personales)**
- Campo `VORNA` (nombre): puede tener registros con diferentes SPRSL
- Lógica: seleccionar registro donde `SPRSL = idioma_documento` o `SPRSL = ' '` (sin idioma específico)

**Ejemplo: IT0006 (Direcciones)**
- Si empleado tiene múltiples direcciones (subtipos: 1=Permanente, 2=Temporal, etc.)
- Lógica: seleccionar dirección permanente (SUBTY='1') por defecto
- Configurable en catálogo de campos: `DIRECCION_PERM`, `DIRECCION_TEMP`

### Para Nombres de Empleados

**Campo `NOMBRE_COMPLETO`**:
- Usar siempre PA0002 con registro sin idioma específico (SPRSL = ' ') o idioma del empleado
- NO aplicar lógica de multilenguaje (nombre es único)
- Formato: `APELLIDO, NOMBRE` (ej: "GARCÍA LÓPEZ, JUAN CARLOS")

### Textos de Dominios y Check Tables

**Ejemplo**: Descripción de cargo (T513S-STLTX)
- Usar función `HR_GET_TEXT` o `DD_DOMVALUES_GET` con parámetro SPRAS
- Si no existe en idioma solicitado, fallback a idioma principal

**Implementación**:
- Clase `ZCL_HHR_CONTPE_DATA_PROVIDER` maneja lógica de selección de idioma
- Método: `get_multilang_text( iv_object, iv_key, iv_spras )`

---

## 8. Performance en Organizational Management

### Pregunta Original
Si se usan lookups de HRP1000 (descripciones de cargos, áreas), evaluar performance. Considerar materialización en CDS views o caching.

### Respuesta

**Estrategia de Optimización**: CDS Views + Caching en Memoria

### Solución 1: CDS Views para Lookups Frecuentes

Crear CDS views que materialicen joins con OM:

**ZHR_CONTPE_I_EMPLOYEE_ORG_DATA**:
```sql
@AccessControl.authorizationCheck: #CHECK
define view entity ZHR_CONTPE_I_EMPLOYEE_ORG_DATA
  as select from pa0001 as Assign
  
  association [0..1] to hrp1000 as _Position 
    on $projection.Plans = _Position.objid
    and _Position.otype = 'S'  -- S = Position
    and _Position.endda >= $session.system_date
    and _Position.begda <= $session.system_date
    
  association [0..1] to hrp1000 as _OrgUnit
    on $projection.Orgeh = _OrgUnit.objid
    and _OrgUnit.otype = 'O'  -- O = Org Unit
    and _OrgUnit.endda >= $session.system_date
    and _OrgUnit.begda <= $session.system_date
    
{
  key pernr as Pernr,
  plans as Plans,
  orgeh as Orgeh,
  _Position.stext as PositionText,
  _Position.short as PositionShort,
  _OrgUnit.stext as OrgUnitText,
  _OrgUnit.short as OrgUnitShort
}
where Assign.endda >= $session.system_date
  and Assign.begda <= $session.system_date
```

**Ventajas**:
- Query única para obtener empleado + textos OM
- SAP optimiza automáticamente (CDS engine)
- Sin loops ABAP

### Solución 2: Caching en Memoria (Generación Masiva)

Para generación masiva, cargar lookups OM en memoria compartida:

**Clase**: `ZCL_HHR_CONTPE_OM_CACHE`

```abap
CLASS zcl_hhr_contpe_om_cache DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      load_cache,  " Cargar al inicio de generación masiva
      get_position_text IMPORTING iv_plans TYPE plans
                        RETURNING VALUE(rv_text) TYPE stext,
      get_orgunit_text IMPORTING iv_orgeh TYPE orgeh
                       RETURNING VALUE(rv_text) TYPE stext,
      clear_cache.  " Limpiar al finalizar
      
  PRIVATE SECTION.
    CLASS-DATA:
      gt_positions TYPE SORTED TABLE OF ... WITH UNIQUE KEY objid,
      gt_orgunits  TYPE SORTED TABLE OF ... WITH UNIQUE KEY objid.
ENDCLASS.
```

**Uso**:
```abap
" Al inicio de generación masiva:
zcl_hhr_contpe_om_cache=>load_cache( ).

" Durante procesamiento (por cada empleado):
lv_position_text = zcl_hhr_contpe_om_cache=>get_position_text( lv_plans ).

" Al finalizar:
zcl_hhr_contpe_om_cache=>clear_cache( ).
```

### Performance Tests

**Objetivo**: Generación de 1000 documentos en < 30 minutos

**Benchmarks Estimados**:
- Sin optimización: ~45-60 minutos (lookup OM por cada empleado)
- Con CDS Views: ~35-40 minutos
- Con CDS + Caching: ~25-30 minutos ✅

**Recomendación**:
- **Fase 1**: Implementar CDS Views
- **Fase 2 (si es necesario)**: Agregar caching si performance no cumple objetivo

---

## 9. Versionamiento de Datos del Empleado (Datos Históricos)

### Pregunta Original
¿Se debe generar documento con datos históricos (ej: certificado de empleado que salió)? Considerar parámetro "fecha de referencia" para generación.

### Respuesta

**Decisión**: SÍ, soportar generación con "fecha de referencia"

**Casos de Uso**:

1. **Empleado activo, datos actuales** (caso normal):
   - Fecha referencia = HOY
   - Leer infotipos vigentes a HOY

2. **Empleado activo, datos históricos** (ej: certificado retroactivo):
   - Fecha referencia = 01.01.2023
   - Leer infotipos vigentes a 01.01.2023
   - Ejemplo: "Certifico que el Sr. X laboró como Analista en enero de 2023"

3. **Empleado inactivo (salió de la empresa)**:
   - Fecha referencia = Fecha de salida (PA0000-BEGDA del último registro)
   - Leer datos al momento de la salida
   - Ejemplo: Certificado de trabajo de ex-empleado

**Implementación**:

### UI - Parámetro Opcional

Agregar campo en formulario de generación:

```
┌─────────────────────────────────────────┐
│ PERNR: [12345678]  [🔍]                 │
│ Plantilla: [Certificado Laboral ▼]     │
│ Idioma: [Español ▼]                     │
│                                         │
│ ☐ Usar fecha de referencia              │ ← Checkbox
│   Fecha: [11.06.2024]  [📅]             │ ← Habilitado si checkbox activo
│                                         │
│ [Vista Previa] [Generar]                │
└─────────────────────────────────────────┘
```

**Por defecto**: Checkbox NO activo (usa fecha actual)

### Backend - Clase Data Provider

Modificar método `get_employee_data`:

```abap
METHOD get_employee_data.
  IMPORTING
    iv_pernr        TYPE persno
    it_placeholders TYPE zhr_tt_placeholder
    iv_ref_date     TYPE datum DEFAULT sy-datum  " ← Nuevo parámetro
  RETURNING
    VALUE(rs_data)  TYPE zhr_s_employee_data.
    
  " Lógica:
  " - Llamar HR_READ_INFOTYPE con BEGDA/ENDDA considerando iv_ref_date
  " - Para empleados inactivos: validar que existe data a la fecha
ENDMETHOD.
```

### Validaciones

- Si fecha referencia > HOY: error "Fecha no puede ser futura"
- Si fecha referencia < fecha ingreso empleado: warning "Empleado no estaba activo en esa fecha"
- Si empleado inactivo y fecha referencia > fecha salida: usar datos a fecha de salida

### Placeholder Especial

Agregar placeholder: `FECHA_REFERENCIA` o `FECHA_DOCUMENTO`
- Muestra fecha a la cual se generaron los datos
- Útil para aclarar en el documento: "Datos vigentes al 01/01/2023"

---

## 10. Testing en QAS - Datos de Prueba

### Pregunta Original
¿Hay datos de prueba (empleados ficticios) en QAS? Importante para UAT.

### Respuesta

**Situación Actual**: Requiere verificación con equipo Basis/Funcional

**Plan de Acción**:

### Opción A: Datos de Prueba Ya Existen en QAS

✅ **Si hay empleados de prueba**:
- Listar PERNRs de prueba (ej: 99000001-99000100)
- Verificar que tienen infotipos completos (IT0000, IT0001, IT0002, IT0006, IT0008)
- Usar estos PERNRs para UAT

### Opción B: Crear Datos de Prueba en QAS

❌ **Si NO hay empleados de prueba**:
- Solicitar a equipo Funcional HCM crear 10-20 empleados ficticios en QAS
- Perfil de empleados:
  - 5 empleados activos (diferentes áreas, cargos)
  - 2 empleados inactivos (salieron de empresa)
  - 2 empleados con datos históricos complejos (cambios de puesto, transferencias)
  - 1 empleado con datos multilenguaje (nombre en ES/EN)
- Infotipos mínimos: IT0000, IT0001, IT0002, IT0006, IT0008, IT0041

### Opción C: Copiar Datos Anonimizados de PRD

⚠️ **Alternativa** (con aprobación de Seguridad):
- Extraer subset de empleados de PRD
- Anonimizar datos sensibles:
  - Reemplazar nombres: "Empleado Test 001", "Empleado Test 002"
  - Reemplazar DNI: "00000001", "00000002"
  - Reemplazar direcciones: "Av. Test 123"
  - Mantener estructura de infotipos intacta
- Cargar en QAS vía LSMW o programa custom

### Dataset de Prueba Recomendado (QAS)

| PERNR | Nombre | Estado | Caso de Uso |
|-------|--------|--------|-------------|
| 99000001 | Test Empleado Uno | Activo | Caso estándar |
| 99000002 | Test Empleado Dos | Activo | Empleado con préstamos (IT0045) |
| 99000003 | Test Empleado Tres | Activo | Empleado con múltiples cambios de puesto |
| 99000004 | Test Empleado Cuatro | Activo | Empleado multilenguaje |
| 99000005 | Test Empleado Cinco | Inactivo | Ex-empleado (para certificados históricos) |
| 99000006 | Test Manager Uno | Activo | Firmante de documentos |

**Entregable**: Documento "QAS_Test_Data.xlsx" con lista completa de PERNRs de prueba y sus características

### Responsables

- **Funcional HCM**: Crear/validar empleados de prueba
- **Desarrollador**: Verificar que datos son suficientes para UAT
- **QA Tester**: Diseñar casos de prueba usando estos PERNRs

---

## Resumen de Decisiones

| # | Pregunta | Decisión | Impacto |
|---|----------|----------|---------|
| 1 | Logos | Tabla Z `ZHR_CONTPE_LOGOS`, múltiples logos soportados | Bajo - Agregar tabla y UI |
| 2 | Nombres placeholders | Convención: MAYÚSCULAS, guion bajo, prefijos opcionales | Bajo - Documentar |
| 3 | Volumen documentos | 15-20 tipos iniciales, dominio flexible | Ninguno - Ya soportado |
| 4 | Estándar diseño | Definido: colores, fuentes, estilos de tabla | Medio - Crear tabla de estilos |
| 5 | Integración PA20 | NO en Fase 1, SÍ en Fase Futura | Ninguno Fase 1 |
| 6 | Notificaciones email | SÍ a generador (job masivo), NO a empleados en Fase 1 | Bajo - Clase notifier |
| 7 | Multilenguaje datos | Lógica de prioridad por idioma implementada | Medio - Lógica en data provider |
| 8 | Performance OM | CDS Views + caching opcional | Medio - Crear CDS views |
| 9 | Datos históricos | SÍ, parámetro "fecha de referencia" opcional | Medio - Modificar data provider |
| 10 | Datos prueba QAS | Verificar con Basis/Funcional, crear si necesario | Bajo - Preparación UAT |

---

## Próximos Pasos

1. ✅ Documentar respuestas (este documento)
2. ⏭️ Aprobar decisiones con stakeholders
3. ⏭️ Crear tabla adicional `ZHR_CONTPE_LOGOS`
4. ⏭️ Crear tabla adicional `ZHR_CONTPE_STYLES`
5. ⏭️ Documentar convención de placeholders en guía de usuario
6. ⏭️ Crear CDS view `ZHR_CONTPE_I_EMPLOYEE_ORG_DATA`
7. ⏭️ Solicitar creación de empleados de prueba en QAS
8. ⏭️ Actualizar especificaciones con decisiones finales

---

**Documento**: Respuestas a Preguntas Abiertas  
**Versión**: 1.0  
**Fecha**: 11 de Junio de 2026  
**Estado**: Aprobado para Implementación
