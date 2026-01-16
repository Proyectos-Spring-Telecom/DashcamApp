# Guía de Validación - Tokenización NetPay

Esta guía te ayudará a verificar que la implementación de tokenización de NetPay está funcionando correctamente.

## 📋 Checklist de Validación

### 1. Verificar Configuración

✅ **Llaves configuradas:**
- [ ] La llave pública está configurada en `netpay_tokenization_service.dart`
- [ ] El servicio está usando el ambiente sandbox (`useSandbox = true`)
- [ ] La URL base es correcta (`https://sandbox.netpay.com.mx`)

### 2. Probar con Tarjetas de Prueba de NetPay

NetPay proporciona tarjetas de prueba para el ambiente sandbox. Usa estas tarjetas para validar:

#### Tarjeta de Prueba VISA (Aprobada)
- **Número:** `4111111111111111`
- **CVV:** `123`
- **Fecha:** Cualquier fecha futura (ej: 12/25)
- **Nombre:** Cualquier nombre

#### Tarjeta de Prueba MasterCard (Aprobada)
- **Número:** `5555555555554444`
- **CVV:** `123`
- **Fecha:** Cualquier fecha futura (ej: 12/25)
- **Nombre:** Cualquier nombre

#### Tarjeta de Prueba (Rechazada)
- **Número:** `4000000000000002`
- **CVV:** `123`
- **Fecha:** Cualquier fecha futura
- **Resultado esperado:** Error de tokenización

### 3. Verificar Logs de Debug

Cuando ejecutes la aplicación en modo debug, deberías ver estos logs en la consola:

```
🔄 Iniciando tokenización de tarjeta...
🔄 Ambiente: SANDBOX
🔄 URL base: https://sandbox.netpay.com.mx
✅ Validación Luhn exitosa
✅ Tipo de tarjeta detectado: visa
📤 Enviando petición a NetPay...
📤 Endpoint: /v1/tokens
🔵 NetPay Request: POST https://sandbox.netpay.com.mx/v1/tokens
🔵 Headers: Content-Type, Accept, Authorization
📥 Respuesta recibida: 200
✅ NetPay Response: 200
✅ Token recibido: tok_xxxxx... (truncado)
✅ Tokenización exitosa!
✅ Token generado: tok_xxxxx... (truncado)
✅ Últimos 4 dígitos: 1111
✅ Tipo de tarjeta: visa
```

### 4. Verificar Flujo Completo en la UI

1. **Abrir el formulario:**
   - Navegar a "Seleccionar método de pago"
   - Seleccionar "NetPay"
   - Deberías ver el formulario de nueva tarjeta

2. **Llenar el formulario:**
   - Nombre(s): "Juan"
   - Apellido(s): "Pérez"
   - Correo: "test@example.com"
   - Teléfono: "1234567890"
   - Número de tarjeta: `4111111111111111`
   - Mes: `12`
   - Año: `25`
   - CVV: `123`

3. **Presionar "Pagar":**
   - El botón debe mostrar un indicador de carga
   - Debe estar deshabilitado durante el proceso
   - No debe mostrar errores de validación local

4. **Resultado esperado:**
   - Si es exitoso: Mensaje "¡Éxito! Tarjeta tokenizada correctamente"
   - El token se genera y se puede usar para pagos
   - Los campos sensibles se limpian automáticamente

### 5. Verificar Respuesta de NetPay

La respuesta exitosa debería contener:

```json
{
  "token": "tok_xxxxxxxxxxxxx",
  "card_type": "visa",
  "last4": "1111",
  "brand": "Visa",
  "success": true
}
```

### 6. Verificar Manejo de Errores

Prueba estos escenarios de error:

#### Error de Validación Local
- **Número de tarjeta inválido:** `1234567890123456`
- **Resultado esperado:** "El número de tarjeta no es válido" (antes de enviar a NetPay)

#### Error de Red
- **Desconectar internet**
- **Resultado esperado:** "Error de conexión. Verifica tu conexión a internet"

#### Error de NetPay
- **Tarjeta rechazada:** `4000000000000002`
- **Resultado esperado:** Mensaje de error amigable de NetPay

### 7. Verificar Seguridad

✅ **Datos sensibles NO se almacenan:**
- [ ] Los campos de tarjeta se limpian después de tokenizar
- [ ] No hay logs que muestren el número completo de tarjeta
- [ ] No hay logs que muestren el CVV
- [ ] Solo se guarda el token (no datos sensibles)

✅ **HTTPS obligatorio:**
- [ ] Todas las peticiones usan HTTPS
- [ ] La URL base es `https://sandbox.netpay.com.mx`

### 8. Verificar en el Código

Revisa estos puntos en el código:

1. **Servicio configurado:**
   ```dart
   // lib/services/netpay_tokenization_service.dart
   static const String _publicApiKey = 'pk_netpay_JGFtQNUFIENMlhkoBXdgiozmQ';
   ```

2. **BLoC inicializado:**
   ```dart
   // lib/controller/netpay_tokenization_bloc.dart
   final netPayTokenizationBloc = NetPayTokenizationBloc();
   ```

3. **Integración en el formulario:**
   ```dart
   // lib/view/dashboard/nueva_tarjeta.dart
   await netPayTokenizationBloc.tokenizeCard(request);
   ```

## 🔍 Debugging

### Si la tokenización falla:

1. **Verifica los logs:**
   - Busca los emojis 🔵, ✅, ❌ en la consola
   - Revisa el código de estado HTTP
   - Revisa el mensaje de error

2. **Verifica la configuración:**
   - ¿La llave pública está correcta?
   - ¿Estás usando sandbox?
   - ¿La URL es correcta?

3. **Verifica la red:**
   - ¿Hay conexión a internet?
   - ¿El endpoint de NetPay está accesible?

4. **Verifica los datos:**
   - ¿Los datos de la tarjeta son válidos?
   - ¿La fecha no está vencida?
   - ¿El CVV es correcto?

### Logs Útiles para Debugging

Los logs incluyen:
- 🔵 = Request (petición)
- ✅ = Success (éxito)
- ❌ = Error (error)
- 🔄 = Process (proceso)
- 📤 = Sending (enviando)
- 📥 = Receiving (recibiendo)

## 📝 Notas Importantes

1. **Solo usar tarjetas de prueba en sandbox**
2. **Nunca usar tarjetas reales en sandbox**
3. **El token generado es solo para pruebas**
4. **En producción, usar llaves de producción**

## ✅ Criterios de Éxito

La implementación está correcta si:

- ✅ Puedes tokenizar una tarjeta de prueba exitosamente
- ✅ Recibes un token válido en la respuesta
- ✅ Los datos sensibles se limpian después de tokenizar
- ✅ Los errores se muestran de forma amigable
- ✅ Los logs muestran el flujo completo sin datos sensibles
- ✅ El botón muestra estado de carga correctamente
- ✅ El mensaje de éxito aparece cuando se completa

## 🚀 Próximos Pasos

Una vez validado en sandbox:

1. Obtener llaves de producción de NetPay
2. Cambiar `useSandbox = false` o usar variables de entorno
3. Actualizar la llave pública con la de producción
4. Probar con tarjetas reales (en producción)
5. Integrar el token con el backend para procesar pagos

