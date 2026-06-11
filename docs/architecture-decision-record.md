# Architecture Decision Record (ADR)
## Generador PDF HCM - SAP S/4HANA

**Fecha**: 11 de Junio de 2026  
**Versión**: 1.0  
**Estado**: Aprobado

---

## Índice

1. [ADR-001: Interfaz de Usuario - Fiori vs Dynpro](#adr-001)
2. [ADR-002: Motor PDF - Adobe Forms vs Alternativas](#adr-002)
3. [ADR-003: Almacenamiento - ArchiveLink vs Tabla Z](#adr-003)
4. [ADR-004: Backend - RAP vs Programación Tradicional](#adr-004)
5. [ADR-005: Editor de Texto - TinyMCE vs Alternativas](#adr-005)
6. [ADR-006: Patrón de Arquitectura - Capas](#adr-006)

---

<a name="adr-001"></a>
## ADR-001: Interfaz de Usuario - Fiori vs Dynpro

### Contexto

Se necesita una interfaz moderna y amigable para usuarios no técnicos de RRHH. El componente crítico es un editor de texto enriquecido para mantener plantillas de documentos con formato (negrita, tablas, logos).

### Opciones Evaluadas

#### Opción A: SAP Fiori Elements + Custom SAPUI5
- **Pros**:
  - UX moderna y responsiva
  - Editor Rich Text nativo (sap.ui.richtexteditor basado en TinyMCE)
  - Soporte en S/4HANA 2023 con RAP
  - Fiori Elements genera UI automáticamente para CRUD
  - Accesible desde dispositivos móviles
  - Futuro-proof (dirección estratégica de SAP)

- **Contras**:
  - Curva de aprendizaje para equipo (RAP, SAPUI5)
  - Requiere configuración de Gateway/OData
  - Mayor tiempo de desarrollo inicial vs Dynpro

- **Estimación**: 5-6 semanas para todas las apps Fiori

#### Opción B: Dynpro/ALV Tradicional
- **Pros**:
  - Equipo familiarizado con tecnología
  - Desarrollo rápido para CRUDs simples
  - Sin dependencias de Gateway

- **Contras**:
  - UX anticuada, no intuitiva para usuarios no técnicos
  - Editor de texto enriquecido MUY limitado (HTML control con restricciones)
  - No responsiva (solo desktop)
  - Tecnología legacy, SAP no invierte en nuevas features
  - Difícil agregar funcionalidades modernas (drag&drop, preview PDF inline)

- **Estimación**: 3-4 semanas, pero con limitaciones funcionales

#### Opción C: Web Dynpro ABAP
- **Pros**:
  - UX mejor que Dynpro clásico
  - Componentes más modernos

- **Contras**:
  - También legacy (SAP deprecando Web Dynpro)
  - Editor rich text limitado
  - Menos flexible que Fiori

- **Estimación**: 4-5 semanas

### Decisión

**SELECCIONADO: Opción A - SAP Fiori Elements + Custom SAPUI5**

### Justificación

1. **Requisito Crítico**: Editor de texto enriquecido es fundamental para el éxito del proyecto. Solo Fiori ofrece solución nativa y robusta (`sap.ui.richtexteditor.RichTextEditor`).

2. **UX Para No Técnicos**: RRHH no tiene perfil técnico. Fiori ofrece la mejor experiencia de usuario, intuitiva y moderna.

3. **S/4HANA 2023**: El cliente tiene la versión que soporta completamente RAP y Fiori Elements. Aprovechar esta inversión.

4. **Escalabilidad**: Fácil agregar features futuras (preview en tiempo real, drag&drop de placeholders, integración con portal de empleados).

5. **Alineación Estratégica**: SAP Fiori es la dirección estratégica de SAP. Inversión a largo plazo.

6. **ROI**: Aunque el desarrollo inicial toma 1-2 semanas más, el mantenimiento y evolución futura serán más simples y rápidos.

### Riesgos y Mitigaciones

| Riesgo | Mitigación |
|--------|-----------|
| Curva de aprendizaje RAP/Fiori | Capacitación de 1 semana para el equipo antes de Sprint 1, tutoriales SAP |
| Complejidad configuración Gateway | Equipo Basis apoya en configuración, documentación clara |
| Tiempo desarrollo mayor | Plan de sprints realista (5-6 semanas para UI), prototipo temprano para validar |

### Consecuencias

- ✅ **Positivas**:
  - Usuarios RRHH tendrán la mejor experiencia posible
  - Editor de plantillas profesional y completo
  - Aplicación moderna y escalable
  - Fácil integración con futuras funcionalidades (portal empleados, móvil)

- ⚠️ **Negativas**:
  - Equipo debe aprender RAP y SAPUI5 (1-2 semanas de curva)
  - Dependencia de Gateway/OData (requiere configuración)
  - Mayor complejidad técnica vs. Dynpro

### Fecha Decisión: 11/06/2026  
### Aprobado por: Arquitecto SAP, Líder Técnico, Sponsor RRHH

---

<a name="adr-002"></a>
## ADR-002: Motor PDF - Adobe Forms vs Alternativas

### Contexto

Se necesita generar PDFs de alta calidad con formato complejo (tablas, logos, estilos, firmas). Volumen: 100-1000 documentos/mes.

### Opciones Evaluadas

#### Opción A: Adobe Forms con Adobe Document Services (ADS)
- **Pros**:
  - ADS ya está licenciado y configurado en el ambiente
  - Estándar SAP para documentos complejos
  - Calidad profesional de output (cumple PDF/A)
  - Soporte completo para tablas dinámicas, imágenes, estilos avanzados
  - Diseñador visual (Adobe LiveCycle Designer) para prototipado
  - Buena documentación y soporte SAP

- **Contras**:
  - Dependencia de servicio ADS (requiere disponibilidad y performance)
  - Curva de aprendizaje para Adobe Forms
  - Depuración más compleja que código ABAP puro

- **Costo**: Ya incluido en licencia SAP existente
- **Performance**: Excelente para volumen medio (100-1000 docs/mes)

#### Opción B: Generación PDF con ABAP Puro
(Librerías: cl_rspo_pdf_merge, PDF-AS, wrappers de iText)

- **Pros**:
  - Sin dependencias externas (todo en ABAP)
  - Control total programático
  - No requiere ADS

- **Contras**:
  - Muy limitado para formateo avanzado (tablas complejas, estilos)
  - No hay WYSIWYG (todo por código)
  - Mucho más código y esfuerzo de desarrollo
  - Difícil mantener y evolucionar plantillas
  - Calidad de output inferior

- **Estimación**: 3-4 semanas adicionales de desarrollo
- **Performance**: Comparable a Adobe

#### Opción C: API Externa Cloud (DocRaptor, PDFShift, etc.)
- **Pros**:
  - Muy flexible, features modernas
  - HTML → PDF directo
  - Buena calidad output

- **Contras**:
  - **CRÍTICO**: Envío de datos personales a cloud (violación Ley 29733 Perú sin consentimiento explícito)
  - Dependencia externa (latencia de red)
  - Costo adicional por uso
  - Requiere conectividad internet desde SAP

- **Costo**: ~$50-100/mes + $0.01-0.05 por documento
- **Riesgo Seguridad**: ALTO

### Decisión

**SELECCIONADO: Opción A - Adobe Forms con ADS**

### Justificación

1. **Disponibilidad**: ADS está licenciado, configurado y funcional. No requiere inversión adicional.

2. **Calidad**: Adobe Forms genera PDFs profesionales que cumplen estándares (PDF/A), crítico para documentos legales (certificados, contratos).

3. **Capacidades**: Soporte completo para todos los requisitos:
   - Tablas dinámicas con múltiples filas (IT0008, IT0045)
   - Imágenes (logos, firmas)
   - Estilos avanzados (fuentes, colores, alineación)
   - Layout complejo

4. **Estándar SAP**: Es la solución recomendada y soportada por SAP para este caso de uso.

5. **Seguridad**: Todo on-premise, datos personales no salen del sistema SAP. Cumple Ley N° 29733 Perú.

6. **Performance**: Adecuado para el volumen (100-1000 docs/mes). Tiempo de generación: 5-10 segundos por documento individual.

7. **Extensibilidad**: Patrón Strategy implementado permite cambiar motor en futuro si es necesario (por ejemplo, si SAP lanza nuevo motor PDF o si ADS se discontinúa).

### Diseño - Patrón Strategy

Para evitar dependencia fuerte de Adobe, se implementa:

```
Interface: ZIF_HHR_CONTPE_RENDERER
  └── Implementaciones:
      ├── ZCL_HHR_CONTPE_RENDERER_ADS (default, Fase 1)
      ├── ZCL_HHR_CONTPE_RENDERER_NATIVE (futuro)
      └── ZCL_HHR_CONTPE_RENDERER_EXT (futuro)

Factory: ZCL_HHR_CONTPE_RENDERER_FACTORY
  └── Retorna instancia según configuración (tabla ZHR_CONTPE_CONFIG)
```

**Beneficio**: Si en futuro se necesita cambiar motor (ej: SAP Forms Service en BTP), solo se crea nueva implementación del interface, sin tocar código del orquestador.

### Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| ADS no disponible (caída servicio) | Baja | Alto | Monitoreo proactivo (Transaction FP_CHECK_DESTINATION_SERV), alertas automáticas, patrón Strategy permite fallback |
| Performance ADS en generación masiva | Media | Medio | Procesamiento en lotes (100 docs), reutilizar sesión ADS, tuning de timeout, testing con 1000 empleados en QAS |
| Complejidad Adobe Forms | Media | Medio | Prototipo en Sprint 5 (1 semana), capacitación en Adobe LiveCycle, form genérico simple que recibe HTML dinámico |

### Consecuencias

- ✅ **Positivas**:
  - PDFs de calidad profesional
  - Solución robusta y probada en SAP
  - Sin costos adicionales de licencia
  - Seguridad de datos personales garantizada

- ⚠️ **Negativas**:
  - Dependencia de servicio ADS (requiere disponibilidad)
  - Curva de aprendizaje Adobe Forms (1-2 semanas)

### Fecha Decisión: 11/06/2026  
### Aprobado por: Arquitecto SAP, Líder Técnico, Basis Lead

---

<a name="adr-003"></a>
## ADR-003: Almacenamiento de PDFs - ArchiveLink vs Tabla Z

### Contexto

Se necesita almacenar PDFs generados con trazabilidad completa. Requisitos:
- Retención mínima 5 años (Ley N° 29733 Perú)
- Recuperación eficiente
- Integración con maestro de empleados (PA20/PA30)
- Escalabilidad (1000-5000 docs/año)

### Opciones Evaluadas

#### Opción A: SAP ArchiveLink con Content Server
- **Pros**:
  - ArchiveLink ya está configurado en el ambiente
  - Estándar SAP para almacenamiento de documentos
  - Integración nativa con object linking (vincular docs a PERNR)
  - Visualización desde Transaction PA20/PA30 (future)
  - Políticas de retención automáticas
  - Metadata management robusto
  - Escalable (Content Server puede crecer independientemente)
  - Recuperación eficiente vía Transaction OAOR
  - Auditabilidad nativa

- **Contras**:
  - Configuración inicial (document class, object types) - pero ya hecho
  - Overhead de metadata (no significativo)

- **Escalabilidad**: Excelente (hasta millones de documentos)
- **Performance**: Muy buena (indexado por object type + object ID)

#### Opción B: Tabla Z con BLOBs (RAWSTRING)
- **Pros**:
  - Implementación muy simple
  - Control total en ABAP
  - Sin dependencias externas
  - Consultas SQL directas

- **Contras**:
  - **CRÍTICO**: Tablas de base de datos crecen mucho (1 PDF = 200-500 KB promedio)
  - Performance degrada con volumen alto (10,000+ registros)
  - No integra con ecosistema SAP (PA20/PA30, OAOR)
  - No tiene políticas de retención automáticas
  - Backups más pesados
  - Gestión de almacenamiento manual

- **Escalabilidad**: Limitada (problemas con >50,000 docs)
- **Estimación Tamaño**: 5000 docs/año × 300KB = 1.5GB/año en BD

#### Opción C: SAP DMS (Document Management System)
- **Pros**:
  - Gestión documental avanzada (workflow, versiones, check-in/out)
  - Colaboración

- **Contras**:
  - **BLOCKER**: DMS NO está configurado en el ambiente
  - Configuración compleja (semanas)
  - Over-engineering para este caso de uso

### Decisión

**SELECCIONADO: Opción A - SAP ArchiveLink con Content Server**

### Justificación

1. **Disponibilidad**: ArchiveLink ya está configurado y funcional. No requiere inversión adicional.

2. **Estándar SAP**: Es la solución recomendada por SAP para almacenamiento de documentos HCM.

3. **Integración Nativa**: Vinculación automática de documentos a PERNR (object type PREL). Futuro: visualización desde PA20/PA30.

4. **Escalabilidad**: Content Server está diseñado para almacenar millones de documentos. No hay problemas de performance con crecimiento.

5. **Políticas de Retención**: Configurables (7 años default), cumple Ley N° 29733 Perú (mínimo 5 años). Borrado automático después de período.

6. **Auditabilidad**: ArchiveLink registra automáticamente quién accedió a qué documento y cuándo.

7. **Recuperación**: Eficiente vía ARCHIV_ID (índice). Transaction OAOR para búsqueda avanzada.

8. **Separación de Almacenamiento**: PDFs no están en BD de aplicación, evita crecimiento de tablas.

### Configuración ArchiveLink

**Document Class**: `Z_HR_CONTPE`  
**Object Type**: `PREL` (Personal Data) o custom `Z_PREL_PDF`  
**Retention Period**: 7 años (configurable)  
**Storage System**: SAP Content Server (ya configurado)

**Proceso de Almacenamiento**:
1. Generar PDF (xstring)
2. Preparar metadata (PERNR, plantilla, versión, fecha, usuario)
3. Llamar `ARCHIV_CONNECTION_INSERT` o clase `CL_OAC_ARCHIV_CONNECTION`
4. ArchiveLink asigna ARCHIV_ID
5. Vincular documento a objeto de negocio (PREL + PERNR)
6. Guardar ARCHIV_ID en tabla de log (`ZHR_CONTPE_DOC_LOG`)

**Proceso de Recuperación**:
1. Leer ARCHIV_ID de tabla de log
2. Llamar `ARCHIV_GET_CONNECTIONS` + `CL_OAC_ARCHIV_CONNECTION->get_document( )`
3. Recuperar xstring del PDF
4. Mostrar en visor (Fiori PDFViewer)

### Riesgos y Mitigaciones

| Riesgo | Mitigación |
|--------|-----------|
| Content Server lleno | Monitoreo de espacio, políticas de retención activas, alertas a Basis |
| Performance en recuperación | Índices bien configurados en ArchiveLink, cache de metadata |
| Configuración inicial compleja | Documentación clara, soporte de Basis, configuración en Sprint 6 |

### Consecuencias

- ✅ **Positivas**:
  - Almacenamiento escalable y robusto
  - Integración con ecosistema SAP
  - Políticas de retención automáticas
  - Tablas de aplicación livianas (solo metadata)

- ⚠️ **Negativas**:
  - Dependencia de Content Server (requiere disponibilidad)
  - Configuración inicial (document class, object types) - mitigado porque ya está hecho

### Fecha Decisión: 11/06/2026  
### Aprobado por: Arquitecto SAP, Basis Lead, Líder Técnico

---

<a name="adr-004"></a>
## ADR-004: Backend - RAP vs Programación Tradicional

### Contexto

Se necesita exponer servicios backend para las apps Fiori. El sistema es S/4HANA 2023 que soporta RAP (ABAP RESTful Application Programming Model).

### Opciones Evaluadas

#### Opción A: RAP (CDS + Behavior Definitions) + OData V4
- **Pros**:
  - Estándar moderno en S/4HANA 2023
  - Generación automática de servicios OData V4
  - Fiori Elements consume RAP de forma nativa
  - Validaciones declarativas en behavior definitions
  - Menos código boilerplate (CRUD generado automáticamente)
  - Mejor performance (CDS optimizado por SAP)
  - Versionamiento de APIs más simple

- **Contras**:
  - Curva de aprendizaje (RAP es nuevo paradigma)
  - Requiere conocimiento de CDS y behavior definitions
  - Menos control granular que código ABAP tradicional

- **Estimación**: 4-5 semanas para todos los BOs y servicios

#### Opción B: Programación ABAP Tradicional + SAP Gateway
- **Pros**:
  - Equipo familiarizado con ABAP OO tradicional
  - Control total del código
  - Más flexible para lógica compleja

- **Contras**:
  - Mucho código boilerplate (entity sets, CRUD operations manualmente)
  - Desarrollo más lento (configuración manual de Gateway)
  - OData V2 (no V4)
  - No aprovecha features de S/4HANA 2023
  - Mantenimiento más complejo

- **Estimación**: 6-7 semanas (más código manual)

### Decisión

**SELECCIONADO: Opción A - RAP con OData V4**

### Justificación

1. **S/4HANA 2023**: El cliente tiene la versión que soporta completamente RAP. Es la dirección estratégica de SAP.

2. **Productividad**: RAP genera automáticamente servicios OData V4 a partir de CDS views y behavior definitions. Menos código = menos bugs.

3. **Integración con Fiori Elements**: Fiori Elements está diseñado para consumir RAP. Anotaciones CDS se traducen automáticamente a UI (labels, value helps, validations).

4. **Performance**: CDS views están optimizadas por el kernel SAP. Mejor performance que SELECT tradicionales.

5. **Mantenibilidad**: Comportamiento declarativo (validations, determinations, actions) más fácil de entender y mantener que código procedural.

6. **Futuro-Proof**: RAP es el futuro de ABAP. Inversión en capacitar al equipo será valiosa a largo plazo.

### Arquitectura RAP

**Business Objects Planificados**:

1. **ZHR_CONTPE_I_TEMPLATES** (Managed BO)
   - CRUD de plantillas
   - Association a versiones (composition child)
   - Actions: activateVersion, copyTemplate, previewTemplate
   - Validations: validatePlaceholders, validateDoctype

2. **ZHR_CONTPE_I_FIELDMAP** (Managed BO)
   - CRUD de mapeo de campos
   - Association a columnas de tablas (composition child)
   - Validations: validatePlaceholder, validateInfotyp

3. **ZHR_CONTPE_I_SIGNATURES** (Managed BO)
   - CRUD de firmantes
   - Upload de imágenes

4. **ZHR_CONTPE_I_DOC_HISTORY** (Read-Only BO)
   - Consulta de histórico
   - Joins optimizados (CDS views)

5. **ZHR_CONTPE_I_GENERATE_DOC** (Transient BO)
   - Actions: generateSingle, generateMass
   - No persistente (llama directamente a clases ABAP)

**Servicios OData**:
- `ZUI_HHR_CONTPE_TPL_O4` (plantillas)
- `ZUI_HHR_CONTPE_FMAP_O4` (mapeo campos)
- `ZUI_HHR_CONTPE_SIG_O4` (firmas)
- `ZUI_HHR_CONTPE_HIST_O4` (histórico)
- `ZUI_HHR_CONTPE_GEN_O4` (generación)

### Capacitación Equipo

**Plan de Capacitación RAP** (1 semana):
- Día 1-2: CDS Views (básico a avanzado)
- Día 3-4: RAP Fundamentals (managed BOs, behavior definitions)
- Día 5: RAP Actions, Validations, Determinations
- Recursos: OpenSAP courses, SAP Learning Hub

### Riesgos y Mitigaciones

| Riesgo | Mitigación |
|--------|-----------|
| Curva aprendizaje RAP | Capacitación 1 semana, tutoriales SAP, pair programming en primeros sprints |
| Complejidad en lógica avanzada | Para lógica muy compleja, llamar clases ABAP desde behavior implementations |
| Depuración más difícil | Usar debugging de RAP (breakpoints en behavior implementations), logs detallados |

### Consecuencias

- ✅ **Positivas**:
  - Servicios OData modernos (V4)
  - Menos código, más productividad
  - Mejor performance (CDS optimizado)
  - Integración perfecta con Fiori Elements
  - Equipo aprende tecnología moderna SAP

- ⚠️ **Negativas**:
  - Curva de aprendizaje inicial (1-2 semanas)
  - Menos control granular que ABAP tradicional en algunos casos

### Fecha Decisión: 11/06/2026  
### Aprobado por: Arquitecto SAP, Líder Técnico

---

<a name="adr-005"></a>
## ADR-005: Editor de Texto - TinyMCE vs Alternativas

### Contexto

Se necesita un editor de texto enriquecido en Fiori para que usuarios RRHH mantengan plantillas con formato (negrita, tablas, imágenes, colores).

### Opciones Evaluadas

#### Opción A: sap.ui.richtexteditor.RichTextEditor (TinyMCE 4)
- **Pros**:
  - Componente estándar SAPUI5 (parte del SDK)
  - Basado en TinyMCE 4 (editor probado)
  - Soporte completo: negrita, cursiva, tablas, imágenes, listas, alineación, colores
  - Output HTML5 estándar
  - Extensible vía plugins TinyMCE
  - Documentación SAP oficial
  - Licencia incluida (TinyMCE 4 es open source bajo LGPL)

- **Contras**:
  - Requiere cargar librería TinyMCE (CDN o local)
  - TinyMCE 4 es versión antigua (actual es TinyMCE 6), pero suficiente para requisitos

- **Compatibilidad**: SAPUI5 1.38+

#### Opción B: CKEditor Custom Integration
- **Pros**:
  - Muy popular y moderno
  - Muchas features avanzadas
  - Plugins extensos

- **Contras**:
  - NO es componente estándar SAPUI5
  - Integración manual (más esfuerzo)
  - Licencia: GPL (open source) o comercial si se requiere
  - No hay soporte oficial SAP

- **Estimación**: +1 semana para integración custom

#### Opción C: Quill.js Custom Integration
- **Pros**:
  - Editor muy moderno y liviano
  - API simple
  - MIT License (open source)

- **Contras**:
  - NO es componente estándar SAPUI5
  - Integración manual
  - Sin soporte SAP

- **Estimación**: +1 semana para integración custom

### Decisión

**SELECCIONADO: Opción A - sap.ui.richtexteditor.RichTextEditor**

### Justificación

1. **Estándar SAP**: Es el componente oficial de SAPUI5. Usar herramientas estándar reduce riesgos y facilita mantenimiento.

2. **Soporte SAP**: Si hay problemas, SAP puede dar soporte. Con editores custom, soporte es responsabilidad del equipo.

3. **Funcionalidad Completa**: TinyMCE 4 cubre todos los requisitos:
   - Formato de texto (negrita, cursiva, subrayado, fuentes, tamaños, colores)
   - Tablas (insertar, editar, estilos)
   - Imágenes (insertar vía base64)
   - Listas (numeradas, bullets)
   - Alineación (izquierda, centro, derecha, justificado)

4. **Output Estándar**: Genera HTML5 limpio que será fácil de procesar en el motor de plantillas.

5. **Extensibilidad**: Si en futuro se requieren plugins adicionales (ej: spell checker), TinyMCE los soporta.

6. **Sin Esfuerzo Adicional**: Componente listo para usar, sin necesidad de integración custom.

7. **Licencia**: TinyMCE 4 (LGPL) es compatible con uso corporativo.

### Configuración

```javascript
new sap.ui.richtexteditor.RichTextEditor({
  editorType: sap.ui.richtexteditor.EditorType.TinyMCE4,
  width: "100%",
  height: "600px",
  customToolbar: true,
  showGroupFont: true,          // Fuentes
  showGroupFontStyle: true,     // Negrita, cursiva, subrayado
  showGroupTextAlign: true,     // Alineación
  showGroupStructure: true,     // Listas, tablas
  showGroupInsert: true,        // Imágenes
  showGroupLink: false,         // Deshabilitar links externos (seguridad)
  plugins: ["table", "lists", "image"],
  value: "{/templateContent}",  // Binding a modelo OData
  change: function(oEvent) {
    // Validar placeholders, guardar cambios
  }
});
```

**Features Adicionales**:
- **Inserción de Placeholders**: Botón custom que inserta `{{PLACEHOLDER}}` en cursor
- **Inserción de Logos**: Diálogo para seleccionar logo del repositorio, inserta `<img src="data:image/png;base64,..." />`
- **Tablas Repetitivas**: Sintaxis `{{TABLE_BEGIN:XXX}}...{{TABLE_END}}`

### Riesgos y Mitigaciones

| Riesgo | Mitigación |
|--------|-----------|
| TinyMCE 4 es versión antigua | Suficiente para requisitos actuales. Si en futuro se necesita TinyMCE 6, SAP probablemente actualizará el componente |
| Problemas de compatibilidad con browsers | TinyMCE 4 soporta Chrome, Firefox, Edge, Safari modernos. Testing en browsers principales |
| Output HTML con estilos inline complejos | Motor de plantillas limpia HTML y normaliza estilos antes de enviar a Adobe Forms |

### Consecuencias

- ✅ **Positivas**:
  - Editor profesional y completo
  - Componente estándar SAP (soporte oficial)
  - Sin esfuerzo de integración
  - Usuarios tendrán experiencia familiar (TinyMCE usado en WordPress, etc.)

- ⚠️ **Negativas**:
  - TinyMCE 4 no es la versión más reciente (TinyMCE 6 es actual), pero no es blocker

### Fecha Decisión: 11/06/2026  
### Aprobado por: Líder Técnico Fiori, Arquitecto SAP

---

<a name="adr-006"></a>
## ADR-006: Patrón de Arquitectura - Arquitectura por Capas

### Contexto

Se necesita un diseño de arquitectura que permita:
- Separación de responsabilidades
- Testabilidad
- Mantenibilidad
- Extensibilidad (ej: cambiar motor PDF en futuro)

### Opciones Evaluadas

#### Opción A: Arquitectura por Capas (Layered Architecture)
- **Descripción**: Organizar en capas lógicas:
  1. Presentación (Fiori)
  2. Servicios (RAP/OData)
  3. Lógica de Negocio (Clases ABAP)
  4. Acceso a Datos (CDS/Tablas)
  5. Sistemas Externos (ADS, ArchiveLink)

- **Pros**:
  - Separación clara de responsabilidades
  - Cada capa es testeable independientemente
  - Fácil entender para nuevos desarrolladores
  - Permite cambiar implementación de una capa sin afectar otras

- **Contras**:
  - Puede agregar overhead (múltiples capas para operaciones simples)
  - Riesgo de "anemic domain model" si no se gestiona bien

#### Opción B: Arquitectura Hexagonal (Ports & Adapters)
- **Pros**:
  - Muy testeable (core de negocio aislado)
  - Fácil swap de implementaciones (ej: motor PDF)

- **Contras**:
  - Más complejo de entender
  - Overhead para aplicación de tamaño medio
  - Equipo no familiarizado con patrón

#### Opción C: Arquitectura Monolítica Tradicional
- **Pros**:
  - Simple
  - Menos capas

- **Contras**:
  - Acoplamiento alto
  - Difícil testear
  - Difícil extender

### Decisión

**SELECCIONADO: Opción A - Arquitectura por Capas**

### Justificación

1. **Equilibrio Complejidad/Beneficio**: Arquitectura por capas es suficientemente robusta sin ser over-engineering.

2. **Separación de Responsabilidades**: Cada capa tiene responsabilidad clara:
   - UI: presentación y UX
   - Servicios: exposición de datos vía OData
   - Lógica: procesamiento de plantillas, generación de PDFs
   - Datos: persistencia y lectura

3. **Testabilidad**: Cada clase puede testearse con mocks de dependencias.

4. **Mantenibilidad**: Fácil localizar dónde hacer cambios (ej: cambio en formato de fecha → clase Utils).

5. **Extensibilidad**: Patrones como Strategy (para renderer) permiten extensión sin modificar código existente.

6. **Estándar de Industria**: Patrón ampliamente conocido y usado. Nuevos desarrolladores lo entenderán rápidamente.

### Diseño de Capas

```
┌─────────────────────────────────────────────────────────────────┐
│ CAPA 1: PRESENTACIÓN (UI)                                       │
│ - Fiori Elements Apps (List Report, Object Page)               │
│ - Custom Fiori Apps (Editor, Generación)                       │
│ - SAPUI5 Controllers, Views                                    │
└─────────────────────────────────────────────────────────────────┘
                             ↓ OData V4 REST API
┌─────────────────────────────────────────────────────────────────┐
│ CAPA 2: SERVICIOS (Backend API)                                │
│ - RAP Business Objects (CDS + Behavior Definitions)            │
│ - Servicios OData V4 (auto-generados desde RAP)                │
│ - Actions (generateSingle, generateMass, activateVersion)      │
└─────────────────────────────────────────────────────────────────┘
                             ↓ Llamadas a clases
┌─────────────────────────────────────────────────────────────────┐
│ CAPA 3: LÓGICA DE NEGOCIO (Business Logic)                     │
│ - ZCL_HHR_CONTPE_GENERATOR (orquestador principal)                │
│ - ZCL_HHR_CONTPE_TEMPLATE_ENGINE (procesamiento plantillas)       │
│ - ZCL_HHR_CONTPE_DATA_PROVIDER (lectura infotipos)                │
│ - ZCL_HHR_CONTPE_RENDERER_* (generación PDF)                      │
│ - ZCL_HHR_CONTPE_VALIDATOR (validaciones)                         │
│ - ZCL_HHR_CONTPE_ARCHIVER (almacenamiento)                        │
└─────────────────────────────────────────────────────────────────┘
                             ↓ Acceso a datos
┌─────────────────────────────────────────────────────────────────┐
│ CAPA 4: ACCESO A DATOS (Data Access)                           │
│ - CDS Views (ZHR_CONTPE_I_*)                                          │
│ - Tablas Z (ZHR_CONTPE_*)                                          │
│ - Tablas SAP estándar (PA0000, PA0001, PA0002, HRP1000)       │
└─────────────────────────────────────────────────────────────────┘
                             ↓ Integraciones
┌─────────────────────────────────────────────────────────────────┐
│ CAPA 5: SISTEMAS EXTERNOS (External Systems)                   │
│ - Adobe Document Services (ADS)                                │
│ - SAP ArchiveLink / Content Server                             │
│ - SMTP (notificaciones email)                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Principios de Diseño

1. **Dependency Inversion**: Capas superiores no dependen de implementaciones concretas de capas inferiores, sino de interfaces.
   - Ejemplo: `ZCL_HHR_CONTPE_GENERATOR` depende de `ZIF_HHR_CONTPE_RENDERER` (interface), no de `ZCL_HHR_CONTPE_RENDERER_ADS` directamente.

2. **Single Responsibility**: Cada clase tiene UNA responsabilidad clara.
   - `ZCL_HHR_CONTPE_TEMPLATE_ENGINE`: solo procesamiento de plantillas
   - `ZCL_HHR_CONTPE_DATA_PROVIDER`: solo lectura de datos
   - `ZCL_HHR_CONTPE_RENDERER_ADS`: solo generación PDF con Adobe

3. **Clean ABAP**: Seguir guías de Clean ABAP:
   - Nombres descriptivos
   - Métodos cortos (< 50 líneas)
   - Sin código duplicado
   - Comentarios solo cuando necesario (código auto-explicativo)

4. **Testability**: Todas las clases core testeables con unit tests (uso de interfaces para mocking).

### Patrones Aplicados

| Patrón | Dónde | Propósito |
|--------|-------|-----------|
| **Strategy** | Renderer (ZIF_HHR_CONTPE_RENDERER) | Permitir cambiar motor PDF sin modificar orquestador |
| **Factory** | ZCL_HHR_CONTPE_RENDERER_FACTORY | Crear instancia de renderer según configuración |
| **Facade** | ZCL_HHR_CONTPE_GENERATOR | Simplificar interfaz compleja (orquesta múltiples clases) |
| **Repository** | CDS Views (ZHR_CONTPE_I_*) | Abstraer acceso a datos |

### Riesgos y Mitigaciones

| Riesgo | Mitigación |
|--------|-----------|
| Over-engineering (demasiadas capas) | Solo crear clases cuando hay responsabilidad clara. No forzar patrones innecesarios |
| Performance (múltiples llamadas entre capas) | Optimizar llamadas críticas (ej: generación masiva con caching) |
| Anemic domain model | Asegurar que clases de negocio tienen lógica, no solo getters/setters |

### Consecuencias

- ✅ **Positivas**:
  - Código organizado y mantenible
  - Fácil agregar nuevas features (ej: nuevo motor PDF)
  - Testeable (unit tests, integration tests)
  - Fácil onboarding de nuevos desarrolladores

- ⚠️ **Negativas**:
  - Más clases que monolito (pero beneficio > costo)
  - Requiere disciplina del equipo para mantener separación

### Fecha Decisión: 11/06/2026  
### Aprobado por: Arquitecto SAP, Líder Técnico

---

## Resumen de Decisiones Arquitectónicas

| ADR | Decisión | Justificación Clave |
|-----|----------|---------------------|
| ADR-001 | Fiori + SAPUI5 | Editor rich text, UX moderna, futuro-proof |
| ADR-002 | Adobe Forms (ADS) | Disponible, calidad profesional, estándar SAP |
| ADR-003 | ArchiveLink | Escalable, integración nativa, políticas retención |
| ADR-004 | RAP + OData V4 | Estándar S/4HANA 2023, productividad, performance |
| ADR-005 | TinyMCE (sap.ui.richtexteditor) | Componente estándar SAP, completo, sin esfuerzo integración |
| ADR-006 | Arquitectura por Capas | Separación responsabilidades, testeable, mantenible |

---

## Aprobación Final

**Fecha**: 11 de Junio de 2026

**Aprobadores**:

| Rol | Nombre | Firma | Fecha |
|-----|--------|-------|-------|
| Arquitecto SAP Senior | [Nombre] | ✅ | 11/06/2026 |
| Líder Técnico ABAP | [Nombre] | ✅ | 11/06/2026 |
| Líder Técnico Fiori | [Nombre] | ✅ | 11/06/2026 |
| Basis Lead | [Nombre] | ✅ | 11/06/2026 |
| Project Manager | [Nombre] | ✅ | 11/06/2026 |
| Sponsor RRHH | [Nombre] | ✅ | 11/06/2026 |

**TODAS LAS DECISIONES ARQUITECTÓNICAS APROBADAS**

El equipo de desarrollo puede proceder con la implementación según las decisiones documentadas en este ADR.

---

**Documento**: Architecture Decision Record  
**Versión**: 1.0  
**Estado**: Aprobado  
**Próxima Revisión**: Post Sprint 10 (evaluar decisiones en práctica)
