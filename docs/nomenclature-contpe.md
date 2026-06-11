# Nomenclatura del proyecto CONTPE
## Generador PDF HCM — Estándar LATAM

**Sigla proyecto**: `CONTPE` (Certificados / Contratos PDF — Empleados)  
**Paquete ABAP**: `ZHR_CONTPE`  
**Referencia**: [sap-abap-estandar-latam.md](../sap-abap-estandar-latam.md)

---

## Regla general

La sigla `CONTPE` se inserta **después del módulo HR** en el nombre del objeto, siguiendo el mismo criterio que el ejemplo LATAM `ZHR_CLN_CONFIG` (sigla `CLN`).

```
Z + HR + _ + CONTPE + _ + <SUFIJO>
```

Para programas y transacciones del rango funcional 770–772:

```
Z + H + HR + <TIPO> + CONTPE + _ + <NNN>
```

---

## Catálogo de objetos

| Tipo | Patrón | Ejemplo |
|------|--------|---------|
| Paquete | `ZHR_CONTPE` | `ZHR_CONTPE` |
| Tabla | `ZHR_CONTPE_<SUF>` | `ZHR_CONTPE_TPL` |
| Elemento dato | `ZDE_CONTPE_<SUF>` | `ZDE_CONTPE_TPL_ID` |
| Dominio | `ZDO_CONTPE_<SUF>` | `ZDO_CONTPE_STATUS` |
| Estructura | `ZHR_CONTPE_S_<SUF>` | `ZHR_CONTPE_S_FORM` |
| Tabla interna | `ZHR_CONTPE_TT_<SUF>` | `ZHR_CONTPE_TTPER` |
| Clase | `ZCL_HHR_CONTPE_<SUF>` | `ZCL_HHR_CONTPE_GENERATOR` |
| Interface | `ZIF_HHR_CONTPE_<SUF>` | `ZIF_HHR_CONTPE_RENDERER` |
| Excepción | `ZCX_HHR_CONTPE_<SUF>` | `ZCX_HHR_CONTPE_BASE_ERROR` |
| Clase mensajes | `ZHR_CONTPE` | `ZHR_CONTPE` |
| CDS (interface) | `ZHR_CONTPE_I_<SUF>` | `ZHR_CONTPE_I_TEMPLATES` |
| CDS (consumption) | `ZHR_CONTPE_C_<SUF>` | `ZHR_CONTPE_C_TEMPLATES` |
| Servicio OData | `ZUI_HHR_CONTPE_<SUF>_O4` | `ZUI_HHR_CONTPE_TPL_O4` |
| Adobe Form | `ZHR_CONTPE_F_<NNN>` | `ZHR_CONTPE_F_001` |
| Programa (Call trans.) | `ZHHRCONTPE_<NNN>` | `ZHHRCONTPE_770` |
| Transacción | `ZHHRTCONTPE_<NNN>` | `ZHHRTCONTPE_770` |
| Report / batch | `ZHHRCONTPE_<NNN>` o `ZHHRDCONTPE_<NNN>` | `ZHHRDCONTPE_001` |
| Grupo funciones | `ZHHRCONTPE_<NNN>` | `ZHHRCONTPE_001` |
| Función | `ZHHRCONTPE_<TEXTO>` | `ZHHRCONTPE_GENERATE_PDF` |
| App Fiori | `zhr_contpe_<nombre>` | `zhr_contpe_template_list` |
| Semantic Object | `ZCONTPE<Entidad>` | `ZCONTPEPdfTemplate` |
| Rol PFCG | `Z_HR_CONTPE_<ROL>` | `Z_HR_CONTPE_FULL` |
| ArchiveLink doc.class | `Z_HR_CONTPE` | — |

---

## Transacciones del proyecto (770–772)

| Corr. | Transacción | Programa | Función |
|-------|-------------|----------|---------|
| 770 | `ZHHRTCONTPE_770` | `ZHHRCONTPE_770` | Mantenimiento plantillas |
| 771 | `ZHHRTCONTPE_771` | `ZHHRCONTPE_771` | Generación PDF |
| 772 | `ZHHRTCONTPE_772` | `ZHHRCONTPE_772` | Consulta histórico PDF |

---

## Tablas principales

| Tabla | Descripción |
|-------|-------------|
| `ZHR_CONTPE_TPL` | Cabecera plantillas |
| `ZHR_CONTPE_TVER` | Versiones de plantilla |
| `ZHR_CONTPE_FMAP` | Mapeo placeholders |
| `ZHR_CONTPE_FCOL` | Columnas tablas repetitivas |
| `ZHR_CONTPE_SIGN` | Firmantes |
| `ZHR_CONTPE_DLOG` | Log documentos generados |
| `ZHR_CONTPE_AUD` | Auditoría |
| `ZHR_CONTPE_CFG` | Parámetros |
| `ZHR_CONTPE_LOGOS` | Logos corporativos |
| `ZHR_CONTPE_STYLES` | Estilos corporativos |

---

## Migración desde nomenclatura anterior

| Anterior | Nuevo (CONTPE) |
|----------|----------------|
| `ZPDF_HCM_GENERATOR` (paquete) | `ZHR_CONTPE` |
| `ZHR_PDF_*` (tablas) | `ZHR_CONTPE_*` |
| `ZHRTMP_*` / `ZDE_*` genérico | `ZDE_CONTPE_*` |
| `ZCL_PDF_DOC_*` | `ZCL_HHR_CONTPE_*` |
| `ZIF_PDF_DOC_*` | `ZIF_HHR_CONTPE_*` |
| `ZCX_PDF_DOC_*` | `ZCX_HHR_CONTPE_*` |
| `ZHR_PDF` (mensajes) | `ZHR_CONTPE` |
| `ZHHRT_770` | `ZHHRTCONTPE_770` |
| `ZHHRC_770` | `ZHHRCONTPE_770` |
