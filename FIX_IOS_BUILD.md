# Solución para el error de compilación iOS - gRPC-Core

## Error
```
Parse Issue (Xcode): A template argument list is expected after a name prefixed by the template keyword
/Users/andreabarajas/Desarrollo/Flutter/pos/ios/Pods/gRPC-Core/src/core/lib/promise/detail/basic_seq.h:102:37
```

## Solución Aplicada

He actualizado el `Podfile` con configuraciones mejoradas para gRPC-Core que son compatibles con Xcode 26.2.

## Pasos para resolver (ejecutar en orden):

### 1. Limpiar el proyecto Flutter
```bash
cd /Users/andreabarajas/Desarrollo/Flutter/pos
flutter clean
```

### 2. Obtener dependencias de Flutter
```bash
flutter pub get
```

### 3. Limpiar CocoaPods
```bash
cd ios
rm -rf Pods Podfile.lock .symlinks
```

### 4. Reinstalar CocoaPods
```bash
pod install --repo-update
```

Si tienes problemas de permisos, intenta:
```bash
sudo pod install --repo-update
```

### 5. Limpiar build de Xcode (opcional pero recomendado)
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### 6. Intentar compilar nuevamente
```bash
cd ..
flutter run -d "iPhone 17 Pro Max Barajas"
```

## Si el error persiste:

### Opción A: Actualizar CocoaPods
```bash
sudo gem install cocoapods
pod repo update
cd ios
pod install
```

### Opción B: Verificar versión de Xcode
Asegúrate de tener Xcode 26.2 correctamente instalado:
```bash
xcodebuild -version
```

### Opción C: Usar un dispositivo físico
Si el simulador sigue dando problemas, intenta con un dispositivo físico conectado.

## Cambios realizados en Podfile

Se agregaron las siguientes configuraciones para gRPC-Core:
- `CLANG_CXX_LANGUAGE_STANDARD = 'c++17'`
- `CLANG_CXX_LIBRARY = 'libc++'`
- Flags adicionales para manejar templates: `-Wno-template-id-cdtor`
- Configuraciones para habilitar módulos y autolink
- Deshabilitación de warnings que causan errores en Xcode 26.2

