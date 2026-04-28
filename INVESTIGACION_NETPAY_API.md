# Investigación: API REST de NetPay para Tokenización

## Problema Actual
- **Error:** `DioExceptionType.connectionTimeout`
- **Síntoma:** La conexión se agota después de 30-60 segundos
- **Estado:** Los datos se están enviando correctamente según los logs

## Análisis del Problema

### Posibles Causas del Timeout

1. **URL Base Incorrecta**
   - Actual: `https://sandbox.netpay.com.mx`
   - Posibles alternativas:
     - `https://api-sandbox.netpay.com.mx`
     - `https://api.netpay.com.mx/sandbox`
     - `https://sandbox-api.netpay.com.mx`

2. **Endpoint Incorrecto**
   - Actual: `/v1/tokens`
   - Posibles alternativas según documentación:
     - `/tokens`
     - `/v1/cards/tokenize`
     - `/v1.2.1/tokens`
     - `/api/v1/tokens`

3. **Formato de Autenticación**
   - Actual: `Authorization: Bearer {public_key}`
   - Posibles alternativas:
     - `X-Api-Key: {public_key}`
     - `X-Public-Key: {public_key}`
     - `Authorization: Basic {base64}`

4. **NetPayJS vs REST API**
   - Según búsquedas, NetPay usa principalmente **NetPayJS** (JavaScript)
   - La documentación menciona "Personaliza y adapta el formulario" pero podría ser solo vía JS
   - **Necesario verificar:** ¿Existe API REST directa o solo NetPayJS?

## Acciones Recomendadas

### 1. Consultar Documentación Oficial v1.2.1
**URL:** https://docs.netpay.com.mx/v1.2.1/reference/tokenizacion-de-tarjeta

**Verificar:**
- ✅ URL base exacta para sandbox
- ✅ Endpoint exacto para tokenización
- ✅ Formato de autenticación requerido
- ✅ Estructura exacta del request body
- ✅ Si existe API REST o solo NetPayJS

### 2. Probar Diferentes URLs/Endpoints

Si la documentación no está clara, probar estas combinaciones:

```dart
// Opción 1 (actual)
baseUrl: 'https://sandbox.netpay.com.mx'
endpoint: '/v1/tokens'

// Opción 2
baseUrl: 'https://api-sandbox.netpay.com.mx'
endpoint: '/v1/tokens'

// Opción 3
baseUrl: 'https://sandbox.netpay.com.mx'
endpoint: '/tokens'

// Opción 4
baseUrl: 'https://api.netpay.com.mx'
endpoint: '/sandbox/v1/tokens'
```

### 3. Verificar Formato de Autenticación

Probar diferentes formatos:

```dart
// Formato 1 (actual)
'Authorization': 'Bearer pk_netpay_...'

// Formato 2
'X-Api-Key': 'pk_netpay_...'

// Formato 3
'X-Public-Key': 'pk_netpay_...'

// Formato 4 (si requiere Basic Auth)
'Authorization': 'Basic ${base64Encode('pk_netpay_...:')}'
```

### 4. Verificar Request Body

El request actual incluye:
- `card_number`
- `holder_name`
- `expiration_month`
- `expiration_year`
- `cvv2`
- `street`, `city`, `state`, `postal_code`, `country`

**Verificar en documentación si:**
- Los nombres de campos son correctos
- Se requieren campos adicionales
- El formato de fecha es correcto (MM/YY vs MM/YYYY)

### 5. Contactar Soporte de NetPay

Si la documentación no es clara:
- Preguntar sobre API REST para tokenización
- Solicitar ejemplos de curl/Postman
- Verificar URLs y endpoints correctos
- Confirmar si hay API REST o solo NetPayJS

## Información Actual de Configuración

```dart
// Llaves
Public Key: pk_netpay_YbahDkYgsFmUhIFYNzijoIqDJ
Private Key: sk_netpay_VcNiErfSqYMnxOZToQxxNYLFORdUHJZpyeFeZFoGsccny

// URLs
Sandbox: https://sandbox.netpay.com.mx
Production: https://api.netpay.com.mx

// Endpoint
/v1/tokens

// Método
POST

// Headers
Content-Type: application/json
Accept: application/json
Authorization: Bearer {public_key}
```

## Próximos Pasos

1. ✅ Revisar documentación oficial v1.2.1
2. ⏳ Verificar URL base correcta
3. ⏳ Verificar endpoint correcto
4. ⏳ Verificar formato de autenticación
5. ⏳ Probar diferentes combinaciones si es necesario
6. ⏳ Contactar soporte si no hay claridad

## Nota Importante

Si NetPay **solo** ofrece tokenización vía NetPayJS (JavaScript) y no tiene API REST directa, las opciones serían:

1. **Usar WebView con NetPayJS** (más complejo)
2. **Backend intermedio** que use NetPayJS y exponga API REST
3. **Considerar otra pasarela** con API REST nativa para Flutter

