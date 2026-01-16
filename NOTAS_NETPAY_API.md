# Notas sobre la API de NetPay - Tokenización

## Problema Actual
- Error: `DioExceptionType.connectionTimeout`
- La conexión se agota después de 30 segundos
- Los datos se están enviando correctamente (según logs)

## Posibles Causas

### 1. URL/Endpoint Incorrecto
NetPay podría usar diferentes URLs o endpoints. Verificar en la documentación oficial:
- URL base: `https://sandbox.netpay.com.mx` o `https://api-sandbox.netpay.com.mx`
- Endpoint: `/v1/tokens`, `/tokens`, `/v1/cards/tokenize`, etc.

### 2. Formato de Autenticación
NetPay podría requerir un formato diferente de autenticación:
- `Authorization: Bearer {key}` (actual)
- `Authorization: Basic {base64}` 
- `X-Api-Key: {key}`
- `X-Public-Key: {key}`

### 3. NetPayJS vs REST API
Según la documentación, NetPay usa principalmente **NetPayJS** (librería JavaScript) para tokenización.
- Si NetPay solo soporta tokenización vía NetPayJS, necesitaríamos usar un WebView
- Si hay API REST, verificar el formato exacto del request

## Próximos Pasos

1. **Consultar documentación oficial de NetPay:**
   - URL: https://docs.netpay.com.mx
   - Buscar: "Tokenización de tarjeta" o "Card Tokenization API"
   - Verificar si hay API REST o solo NetPayJS

2. **Contactar soporte de NetPay:**
   - Preguntar sobre API REST para tokenización
   - Solicitar ejemplos de requests/responses
   - Verificar URLs y endpoints correctos

3. **Alternativas si no hay API REST:**
   - Usar WebView con NetPayJS
   - Usar un backend intermedio que use NetPayJS
   - Considerar otra pasarela de pago con API REST nativa

## Información Actual

- **Llave Pública:** `pk_netpay_JGFtQNUFIENMlhkoBXdgiozmQ`
- **Llave Privada:** `sk_netpay_VcNiErfSqYMnxOZToQxxNYLFORdUHJZpyeFeZFoGsccny` (solo backend)
- **URL Sandbox:** `https://sandbox.netpay.com.mx`
- **Endpoint:** `/v1/tokens` (a verificar)
- **Método:** POST
- **Headers:** `Authorization: Bearer {public_key}`

## Request Actual

```json
{
  "card_number": "4111111111111111",
  "holder_name": "Juan Pérez",
  "expiration_month": "12",
  "expiration_year": "25",
  "cvv2": "123",
  "street": "Calle ejemplo 123",
  "city": "Temixco, Lomas del Carril",
  "state": "Morelos",
  "postal_code": "62583",
  "country": "MX"
}
```

