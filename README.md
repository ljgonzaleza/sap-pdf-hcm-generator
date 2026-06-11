<<<<<<< HEAD
# Generador de Documentos PDF HCM - SAP S/4HANA

## Descripción

Aplicación SAP S/4HANA para generar documentos PDF para empleados (certificados, cartas, contratos) usando plantillas mantenibles directamente en productivo sin transportes.

## Características Principales

- ✅ Gestión de plantillas en productivo (sin transportes)
- ✅ Editor de plantillas con texto enriquecido
- ✅ Mapeo configurable de campos desde infotipos PA
- ✅ Generación individual y masiva de documentos
- ✅ Sigla proyecto **CONTPE** en todos los objetos (estándar LATAM)
- ✅ Transacciones: `ZHHRTCONTPE_770`, `ZHHRTCONTPE_771`, `ZHHRTCONTPE_772`
- ✅ Versionamiento completo de plantillas
- ✅ Trazabilidad y auditoría
- ✅ Integración con ArchiveLink
- ✅ Firma digital preparada (fase futura)

## Stack Tecnológico

- **Backend**: ABAP OO, RAP (ABAP RESTful Application Programming), CDS Views
- **Frontend**: SAP Fiori Elements + Custom SAPUI5
- **Motor PDF**: Adobe Forms con Adobe Document Services (ADS)
- **Almacenamiento**: SAP ArchiveLink + Content Server
- **Versión SAP**: S/4HANA 2023 o superior

## Estructura del Proyecto

```
sap-pdf-hcm-generator/
├── specs/                      # Especificaciones
│   └── active/
│       └── specs.md           # Especificación completa
├── src/                        # Código fuente ABAP
│   ├── tables/                # Definiciones de tablas Z
│   ├── classes/               # Clases ABAP
│   ├── interfaces/            # Interfaces
│   ├── exceptions/            # Clases de excepción
│   ├── cds/                   # CDS Views
│   ├── behavior/              # RAP Behavior Definitions
│   ├── services/              # Servicios OData
│   └── forms/                 # Adobe Forms
├── fiori-apps/                # Aplicaciones Fiori
├── docs/                      # Documentación
├── config/                    # Configuración
└── tests/                     # Pruebas unitarias
```

## Instalación

Ver [docs/installation.md](docs/installation.md)

## Documentación

- [Especificaciones Técnicas](specs/active/specs.md)
- [Guía de Usuario](docs/user-guide.md)
- [Transacciones Z (LATAM)](docs/transactions.md)
- [Nomenclatura CONTPE](docs/nomenclature-contpe.md)
- [Estándar ABAP LATAM](sap-abap-estandar-latam.md)
- [Arquitectura](docs/architecture-decision-record.md)
- [Preguntas Frecuentes](docs/faq.md)

## Estado del Proyecto

**Fase Actual**: Fundación - Sprint 1
**Inicio**: Junio 2026
**Duración Estimada**: 22-27 semanas

## Contacto

Proyecto: **CONTPE** — Paquete `ZHR_CONTPE`
País: Perú (MOLGA PE)
Versión: 1.0.0-alpha
=======
# sap-pdf-hcm-generator
Generador de PDF para contratos Perú
>>>>>>> origin/main
