# Documentación del proyecto

Documentación de contexto y contratos de **toda la solución** (Monedero Digital DashCamPay).

## Documentos principales

| Documento | Contenido |
|----------|------------|
| [01_CONTEXTO_SOLUCION.md](01_CONTEXTO_SOLUCION.md) | Descripción general de la solución: producto, plataformas, arquitectura de capas, módulos (Auth, Monedero, Transacciones/Viajes, NetPay, Transporte, Clientes, Extravío, etc.), API backend, navegación, roles, seguridad y estructura de carpetas. |
| [02_CONTRATOS_SOLUCION.md](02_CONTRATOS_SOLUCION.md) | Contratos por capa: dominio (Result, repositorios), datos (datasources, implementaciones), API (endpoints por servicio), interceptores, servicios, presentación (Blocs/Controllers), modelos y navegación. |

## Documentación por módulo (detalle)

| Documento | Alcance |
|-----------|---------|
| [01_CONTEXTO_VIAJES_DEL_DIA.md](01_CONTEXTO_VIAJES_DEL_DIA.md) | Contexto del flujo “Viajes del día” (reutilización de POST /transacciones/paginado). |
| [02_CONTRATOS_VIAJES_DEL_DIA.md](02_CONTRATOS_VIAJES_DEL_DIA.md) | Contratos detallados del flujo Viajes del día (API, modelo, repositorio, datasource, controller, UI). |
