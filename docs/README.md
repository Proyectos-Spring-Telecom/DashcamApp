# Monedero Digital - Flutter Wallet App

📱 Introducción

Esta aplicación es un monedero electrónico (wallet) desarrollado en Flutter, diseñado para facilitar la administración y el uso de saldo digital de manera rápida, segura y eficiente.

El sistema permite a los usuarios consultar su saldo, realizar recargas, efectuar pagos mediante códigos QR, visualizar movimientos financieros y analizar sus gastos a través de gráficos interactivos, ofreciendo una experiencia moderna y centralizada para la gestión de dinero electrónico.

La aplicación está pensada para ser multiplataforma, funcionando correctamente en Android, iOS y Web, y está orientada a escenarios de uso como pagos digitales, transporte, control de gastos y consumo mensual.

## ✨ Características

- Visualización de saldo
- Recarga de saldo
- Pagos mediante códigos QR
- Consulta de servicios de transporte
- Historial de movimientos
    - Recargas
    - Débitos
- Gráficos de análisis financiero
    - Balance de saldo vs gastos
    - Gastos mensuales
- Soporte multiplataforma
    - Android
    - iOS
    - Web
- Arquitectura preparada para manejo seguro de información

## Para comenzar

Para usar Monedero Digital, sigue estos pasos:

1. Clona este repositorio en tu máquina local.
2. Abra el directorio del proyecto en su IDE o editor de código preferido.
3. Ejecuta `flutter pub get` para instalar las dependencias necesarias.
4. Actualice la configuración de Firebase en el `main.dart` archivo.
5. Ejecuta la aplicación con `flutter run`.

## Construir en web (deploy en /dashcampay/)

Si tu app se sirve desde una carpeta en el servidor como `/dashcampay/`, debes compilar con `--base-href` para que el `build/web/index.html` quede con:

`<base href="/dashcampay/">`

Comando:

`flutter build web --release --base-href /dashcampay/`

Importante: **sube al servidor la carpeta `build/web/`**, no `web/`.

## Screenshots

Aquí hay algunas capturas de pantalla de Monedero Digital en acción:

[Insert your screenshots here]

## Licencia

Este proyecto actualmente no cuenta con una licencia definida.

Todos los derechos están reservados hasta que se especifique una licencia oficial.
El uso, modificación o distribución del código queda sujeto a autorización expresa del propietario del proyecto.

## Contacto

Para dudas, soporte o información relacionada con el proyecto, puedes contactar a:

Spring Telecom
📧 Correo: proyectospring.telecom@gmail.com


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
