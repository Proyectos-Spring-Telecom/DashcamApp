# Solución Definitiva para el Error de gRPC-Core

## Problema
Error de parsing en Xcode 26.2:
```
Parse Issue (Xcode): A template argument list is expected after a name prefixed by the template keyword
/Users/.../ios/Pods/gRPC-Core/src/core/lib/promise/detail/basic_seq.h:101:46
```

## Solución

### Opción 1: Ejecutar script manual (RECOMENDADO)

```bash
cd /Users/andreabarajas/Desarrollo/Flutter/pos/ios
./fix_grpc.sh
cd ..
flutter run -d "iPhone 17 Pro Max Barajas"
```

### Opción 2: Reinstalar pods (el Podfile ya tiene el fix)

```bash
cd /Users/andreabarajas/Desarrollo/Flutter/pos/ios
rm -rf Pods Podfile.lock .symlinks
pod install --repo-update
# Deberías ver: "✓ Fixed gRPC-Core template parsing error in post_install"
cd ..
flutter run -d "iPhone 17 Pro Max Barajas"
```

### Opción 3: Si nada funciona - Usar dispositivo físico o simulador diferente

El error puede ser específico de Xcode 26.2. Si persiste, considera:
- Usar un dispositivo físico conectado por USB
- Usar un simulador diferente
- Actualizar Xcode a la última versión

## Qué hace el fix

El fix une las líneas 102-103 del archivo `basic_seq.h` en una sola línea:
- **Antes:** `Construct(&state_,\n                    Traits::template CallSeqFactory(...));`
- **Después:** `Construct(&state_, Traits::template CallSeqFactory(...));`

Esto resuelve el problema de parsing de templates en Xcode 26.2.

