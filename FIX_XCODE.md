# Solución para el error de Xcode Simulator Runtimes

## Problema
```
[!] Xcode - develop for iOS and macOS (Xcode 26.2)
    ✗ Unable to get list of installed Simulator runtimes.
```

## Soluciones (en orden de preferencia)

### 1. Aceptar las licencias de Xcode
```bash
sudo xcodebuild -license accept
```

### 2. Reiniciar CoreSimulatorService
```bash
# Matar procesos relacionados con el simulador
killall -9 com.apple.CoreSimulator.CoreSimulatorService
killall -9 SimulatorBridge
killall -9 simctl

# Reiniciar el servicio
xcrun simctl shutdown all
```

### 3. Limpiar y reconstruir la caché de simuladores
```bash
# Eliminar la caché del simulador
rm -rf ~/Library/Developer/CoreSimulator/Caches/*

# Limpiar datos del simulador (OPCIONAL - esto eliminará todos los simuladores)
# rm -rf ~/Library/Developer/CoreSimulator/Devices/*
```

### 4. Verificar e instalar componentes de Xcode
Abre Xcode y ve a:
- **Xcode > Settings > Platforms** (o **Components** en versiones antiguas)
- Verifica que los iOS Simulator Runtime estén instalados
- Si no están, instálalos desde ahí

### 5. Reinstalar Command Line Tools
```bash
# Eliminar herramientas actuales
sudo rm -rf /Library/Developer/CommandLineTools

# Reinstalar
xcode-select --install
```

### 6. Si nada funciona - Reiniciar Mac
A veces el servicio necesita un reinicio completo del sistema para reinicializarse correctamente.

## Verificación
Después de aplicar las soluciones, verifica con:
```bash
flutter doctor -v
xcrun simctl list runtimes
```

