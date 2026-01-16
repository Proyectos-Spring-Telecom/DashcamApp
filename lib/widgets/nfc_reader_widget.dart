import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dashboardpro/services/nfc_service.dart';

/// Widget de ejemplo para leer tarjetas NFC
/// Muestra un botón y un loader mientras se espera la tarjeta
/// Si autoStart es true, inicia la lectura automáticamente al montar
class NfcReaderWidget extends StatefulWidget {
  final bool autoStart;
  final bool Function(String cardId)? onCardRead; // Retorna true si se encontró el monedero, false si no

  const NfcReaderWidget({
    super.key,
    this.autoStart = false,
    this.onCardRead,
  });

  @override
  State<NfcReaderWidget> createState() => _NfcReaderWidgetState();
}

class _NfcReaderWidgetState extends State<NfcReaderWidget> {
  final NfcService _nfcService = NfcService();
  bool _isReading = false;
  String? _lastCardNumber;
  String? _errorMessage;
  bool _hasStarted = false;
  bool _cardProcessed = false; // Flag para saber si la tarjeta ya fue procesada

  @override
  void initState() {
    super.initState();
    // Si autoStart está activado, iniciar lectura automáticamente después de montar
    if (widget.autoStart && !_cardProcessed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_cardProcessed && !_hasStarted) {
            _startAutoRead();
          }
        });
      });
    }
  }

  Future<void> _startAutoRead() async {
    if (_hasStarted || _cardProcessed) {
      if (kDebugMode) {
        debugPrint('⚠️ AutoStart ya iniciado o tarjeta procesada, ignorando');
      }
      return;
    }
    _hasStarted = true;
    _readCard();
  }

  Future<void> _readCard() async {
    // Si la tarjeta ya fue procesada y hay callback, no reiniciar
    if (_cardProcessed && widget.onCardRead != null) {
      if (kDebugMode) {
        debugPrint('⚠️ Tarjeta ya procesada, no reiniciando lectura');
      }
      return;
    }

    // Si ya está leyendo, no iniciar otra lectura
    if (_isReading) {
      if (kDebugMode) {
        debugPrint('⚠️ Ya hay una lectura en progreso, ignorando');
      }
      return;
    }

    setState(() {
      _isReading = true;
      _errorMessage = null;
      _lastCardNumber = null;
    });

    if (kDebugMode) {
      debugPrint('🔵 ==========================================');
      debugPrint('🔵 INICIANDO LECTURA NFC');
      debugPrint('🔵 Por favor NO acerques el tag todavía');
      debugPrint('🔵 Espera a que aparezca "Sesión NFC activa"');
      debugPrint('🔵 ==========================================');
    }

    try {
      // Verificar disponibilidad primero
      if (kDebugMode) {
        debugPrint('🔍 Verificando disponibilidad de NFC...');
      }
      final isAvailable = await _nfcService.isAvailable();
      if (!isAvailable) {
        if (kDebugMode) {
          debugPrint('❌ NFC no está disponible');
        }
        String errorMsg = 'NFC no está disponible en este dispositivo';
        
        // Detectar si es iOS web para dar un mensaje más específico
        if (kIsWeb) {
          errorMsg = 'NFC no está disponible en navegadores web. iOS Safari no soporta Web NFC API. Por favor, usa la aplicación nativa o un dispositivo Android.';
        }
        
        setState(() {
          _isReading = false;
          _errorMessage = errorMsg;
        });
        return;
      }

      if (kDebugMode) {
        debugPrint('✅ NFC está disponible');
        debugPrint('📱 Iniciando sesión NFC... AHORA SÍ puedes acercar el tag');
      }

      // Iniciar lectura
      final cardNumber = await _nfcService.readCard();

      setState(() {
        _isReading = false;
        _lastCardNumber = cardNumber;
      });

      if (cardNumber != null && cardNumber.isNotEmpty) {
        // El número ya se imprimió en consola por el servicio
        // Llamar al callback si está disponible
        if (widget.onCardRead != null && mounted && !_cardProcessed) {
          // Detener la sesión NFC antes de llamar al callback
          try {
            await _nfcService.stopSession();
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ Error al detener sesión NFC: $e');
            }
          }
          
          setState(() {
            _isReading = false;
          });
          
          // Marcar como procesada ANTES de llamar al callback para evitar múltiples llamadas
          _cardProcessed = true;
          
          // Llamar al callback - debería retornar true si encontró el monedero
          final result = widget.onCardRead!(cardNumber);
          
          // Si el resultado es true (monedero encontrado), no hacer nada más
          // Si es false (no encontrado), reiniciar lectura automáticamente
          if (result != true && widget.autoStart && mounted) {
            // Resetear el flag para permitir nueva lectura
            _cardProcessed = false;
            await Future.delayed(const Duration(seconds: 1));
            if (mounted && !_cardProcessed) {
              _readCard();
            }
          }
          // Si result == true, la navegación ya ocurrió, no reiniciar
          return;
        }
        
        // Si no hay callback, mostrar mensaje estándar
        if (widget.onCardRead == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarjeta leída correctamente. Revisa la consola para ver el número.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // Si es autoStart y no hay callback, reiniciar automáticamente después de un breve delay
        if (widget.autoStart && mounted && widget.onCardRead == null && !_cardProcessed) {
          await Future.delayed(const Duration(seconds: 3));
          if (mounted && !_cardProcessed) {
            setState(() {
              _lastCardNumber = null;
              _errorMessage = null;
            });
            _readCard();
          }
        }
      } else {
        setState(() {
          _errorMessage = 'No se pudo leer el número de tarjeta';
        });
        // Si es autoStart, reiniciar automáticamente después de un error
        if (widget.autoStart && mounted && !_cardProcessed) {
          await Future.delayed(const Duration(seconds: 2));
          if (mounted && !_cardProcessed) {
            setState(() {
              _errorMessage = null;
            });
            _readCard();
          }
        }
      }
    } on NfcException catch (e) {
      final isTimeout = e.message.toLowerCase().contains('tiempo') || 
                        e.message.toLowerCase().contains('timeout') ||
                        e.message.toLowerCase().contains('agotado');
      
      // Si es timeout y autoStart, no mostrar error, solo reiniciar
      if (isTimeout && widget.autoStart && !_cardProcessed) {
        setState(() {
          _isReading = false;
          _errorMessage = null;
        });
        // Reiniciar inmediatamente sin delay
        if (mounted && !_cardProcessed) {
          _readCard();
        }
        return;
      }

      setState(() {
        _isReading = false;
        _errorMessage = e.message;
      });

      // Solo mostrar error si NO es timeout o si NO es autoStart
      if (mounted && !isTimeout && !widget.autoStart) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      // Si es autoStart y no es un error de "usuario canceló" ni timeout, reiniciar automáticamente
      if (widget.autoStart && mounted && !_cardProcessed &&
          !e.message.toLowerCase().contains('cancel') && 
          !isTimeout) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted && !_cardProcessed) {
          setState(() {
            _errorMessage = null;
          });
          _readCard();
        }
      }
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      final isTimeout = errorStr.contains('tiempo') || 
                        errorStr.contains('timeout') ||
                        errorStr.contains('agotado');
      
      // Si es timeout y autoStart, no mostrar error, solo reiniciar
      if (isTimeout && widget.autoStart && !_cardProcessed) {
        setState(() {
          _isReading = false;
          _errorMessage = null;
        });
        // Reiniciar inmediatamente sin delay
        if (mounted && !_cardProcessed) {
          _readCard();
        }
        return;
      }

      setState(() {
        _isReading = false;
        _errorMessage = 'Error inesperado: $e';
      });

      // Solo mostrar error si NO es timeout
      if (mounted && !isTimeout && !widget.autoStart) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      // Si es autoStart y no es timeout, reiniciar automáticamente después de un error
      if (widget.autoStart && mounted && !_cardProcessed && !isTimeout) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted && !_cardProcessed) {
          setState(() {
            _errorMessage = null;
          });
          _readCard();
        }
      }
    }
  }

  @override
  void dispose() {
    // Asegurarse de cancelar la sesión NFC si está activa
    if (_isReading || _hasStarted) {
      _nfcService.stopSession().catchError((e) {
        if (kDebugMode) {
          debugPrint('⚠️ Error al detener sesión NFC en dispose: $e');
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si la tarjeta ya fue procesada y hay callback, no mostrar el widget
    if (widget.autoStart && _cardProcessed && widget.onCardRead != null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Solo mostrar el botón si NO es autoStart
        if (!widget.autoStart)
          ElevatedButton.icon(
            onPressed: _isReading ? null : _readCard,
            icon: _isReading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.nfc),
            label: Text(_isReading ? 'Leyendo... Acerca la tarjeta' : 'Leer tarjeta NFC'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
        // Mostrar el estado de lectura siempre
        if (_isReading || widget.autoStart && _hasStarted) ...[
          if (!widget.autoStart) const SizedBox(height: 16),
          const SizedBox(height: 1),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFA6CE39).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA6CE39), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nfc, size: 20, color: Color(0xFFA6CE39)),
                const SizedBox(width: 12),
                const Text(
                  'Sesión NFC activa',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA6CE39),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_errorMessage != null && !widget.autoStart) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
