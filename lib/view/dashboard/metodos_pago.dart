// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'dashboard.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:async';
import 'package:flutter/material.dart';

// Painter para el diseño del circuito del chip (basado en la imagen de referencia)
class ChipCircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF505050)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Forma escudo/ovalada alargada en el centro
    final shieldPath = Path();
    shieldPath.moveTo(centerX, centerY - 8); // Punto superior
    shieldPath.quadraticBezierTo(
      centerX - 7, centerY - 4,
      centerX - 7, centerY,
    );
    shieldPath.quadraticBezierTo(
      centerX - 7, centerY + 6,
      centerX, centerY + 6,
    );
    shieldPath.quadraticBezierTo(
      centerX + 7, centerY + 6,
      centerX + 7, centerY,
    );
    shieldPath.quadraticBezierTo(
      centerX + 7, centerY - 4,
      centerX, centerY - 8,
    );
    shieldPath.close();
    
    canvas.drawPath(shieldPath, paint);

    // Punto oscuro pequeño en la parte superior
    paint..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(centerX, centerY - 7),
      1.5,
      paint..color = const Color(0xFF2A2A2A),
    );

    // Líneas horizontales segmentadas desde el escudo hacia los bordes
    paint..color = const Color(0xFF505050);
    paint..style = PaintingStyle.stroke;
    paint..strokeWidth = 2.0;

    // Líneas hacia la izquierda (segmentadas)
    canvas.drawLine(
      Offset(centerX - 7, centerY - 2),
      Offset(centerX - 11, centerY - 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - 13, centerY - 2),
      Offset(5, centerY - 2),
      paint,
    );

    canvas.drawLine(
      Offset(centerX - 7, centerY),
      Offset(centerX - 11, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - 13, centerY),
      Offset(5, centerY),
      paint,
    );

    canvas.drawLine(
      Offset(centerX - 7, centerY + 2),
      Offset(centerX - 11, centerY + 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - 13, centerY + 2),
      Offset(5, centerY + 2),
      paint,
    );

    // Líneas hacia la derecha (segmentadas)
    canvas.drawLine(
      Offset(centerX + 7, centerY - 2),
      Offset(centerX + 11, centerY - 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 13, centerY - 2),
      Offset(size.width - 5, centerY - 2),
      paint,
    );

    canvas.drawLine(
      Offset(centerX + 7, centerY),
      Offset(centerX + 11, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 13, centerY),
      Offset(size.width - 5, centerY),
      paint,
    );

    canvas.drawLine(
      Offset(centerX + 7, centerY + 2),
      Offset(centerX + 11, centerY + 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 13, centerY + 2),
      Offset(size.width - 5, centerY + 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter para el ícono NFC (ondas contactless - 4 arcos concéntricos)
class NfcIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final startX = 4.0; // Comenzar desde la izquierda
    final centerY = size.height / 2;

    // 4 arcos concéntricos que aumentan en longitud de izquierda a derecha
    // Arco 1 (más corto)
    canvas.drawArc(
      Rect.fromLTWH(startX, centerY - 4, 8, 8),
      -1.57, // -90 grados
      1.57, // 90 grados (semicírculo)
      false,
      paint,
    );

    // Arco 2 (más largo)
    canvas.drawArc(
      Rect.fromLTWH(startX, centerY - 6, 12, 12),
      -1.57, // -90 grados
      1.57, // 90 grados
      false,
      paint,
    );

    // Arco 3 (aún más largo)
    canvas.drawArc(
      Rect.fromLTWH(startX, centerY - 8, 16, 16),
      -1.57, // -90 grados
      1.57, // 90 grados
      false,
      paint,
    );

    // Arco 4 (más largo - casi completo)
    canvas.drawArc(
      Rect.fromLTWH(startX, centerY - 10, 20, 20),
      -1.57, // -90 grados
      1.57, // 90 grados
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MetodosPagoPage extends StatefulWidget {
  const MetodosPagoPage({super.key});

  @override
  State<MetodosPagoPage> createState() => _MetodosPagoPageState();
}

class _MetodosPagoPageState extends State<MetodosPagoPage> with TickerProviderStateMixin {
  String? _tarjetaEliminandoToken; // Token de la tarjeta que se está eliminando
  bool _isExpanded = false; // Estado de expansión de las tarjetas
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de animación
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOut,
    );
    // Intentar cargar las tarjetas inmediatamente si el wallet ya está disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Si el wallet no está cargado, cargarlo primero
      if (monederoBloc.wallet == null) {
        monederoBloc.obtenerWallet();
        return; // Esperar a que se cargue el wallet
      }
      
      // Verificar si ya hay datos válidos en caché antes de cargar
      final wallet = monederoBloc.wallet;
      if (wallet != null && 
          wallet.customerIdNetPay != null && 
          wallet.customerIdNetPay!.isNotEmpty) {
        // Si hay customerIdNetPay, intentar cargar las tarjetas
        if (netPayBloc.currentStatus != NetPayStatus.loading) {
          _intentarCargarTarjetas();
        }
      } else {
        // Si NO hay customerIdNetPay, establecer estado vacío inmediatamente
        // No intentar cargar tarjetas porque el servicio requiere customerId
        if (netPayBloc.currentStatus != NetPayStatus.empty) {
          netPayBloc.limpiar();
        }
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cuando la ruta cambia (viene de agregar tarjeta), verificar si necesita recarga
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final wallet = monederoBloc.wallet;
          if (wallet != null && 
              wallet.customerIdNetPay != null && 
              wallet.customerIdNetPay!.isNotEmpty &&
              netPayBloc.currentStatus != NetPayStatus.loading) {
            // Solo recargar si no hay datos válidos en caché
            // El método obtenerClienteNetPay verificará el caché automáticamente
            netPayBloc.obtenerClienteNetPay(wallet.customerIdNetPay!, forceRefresh: false);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _expansionController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    if (_expansionController.isAnimating) {
      return; // Evitar múltiples toques durante la animación
    }
    
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expansionController.forward();
      } else {
        _expansionController.reverse();
      }
    });
  }

  void _intentarCargarTarjetas() {
    // Evitar cargas múltiples solo si ya está en proceso de carga
    if (netPayBloc.currentStatus == NetPayStatus.loading) {
      return;
    }
    
    // Verificar si ya hay tarjetas cargadas en NetPayBloc y el estado es exitoso
    final currentCustomer = netPayBloc.currentCustomer;
    if (currentCustomer != null && 
        currentCustomer.paymentSources.isNotEmpty && 
        netPayBloc.currentStatus == NetPayStatus.success) {
      return; // Ya hay tarjetas cargadas exitosamente, no hacer nada
    }

    // Verificar si el wallet ya tiene customerIdNetPay
    final wallet = monederoBloc.wallet;
    if (wallet == null) {
      // Si no hay wallet, esperar a que se cargue
      return;
    }

    // VALIDACIÓN CRÍTICA: Si no hay customerIdNetPay, NO intentar cargar tarjetas
    // El servicio /netpay/customers requiere customerId y fallará si es null
    if (wallet.customerIdNetPay == null || wallet.customerIdNetPay!.isEmpty) {
      // Establecer estado vacío inmediatamente
      netPayBloc.limpiar();
      return;
    }

    // Si hay customerIdNetPay, cargar las tarjetas
    netPayBloc.obtenerClienteNetPay(wallet.customerIdNetPay!);
  }

  void _cargarTarjetasNetPay({PasajeroWalletModel? wallet}) {
    // Evitar cargas múltiples si ya está en proceso de carga o si se está eliminando
    if (netPayBloc.currentStatus == NetPayStatus.loading || netPayBloc.isDeleting) {
      return;
    }
    
    if (wallet != null && wallet.customerIdNetPay != null && wallet.customerIdNetPay!.isNotEmpty) {
      // El método obtenerClienteNetPay verificará automáticamente el caché
      // No forzar recarga a menos que sea necesario
      netPayBloc.obtenerClienteNetPay(wallet.customerIdNetPay!, forceRefresh: false);
    } else {
      // Si no hay customerIdNetPay, establecer estado vacío
      netPayBloc.limpiar();
    }
  }

  Future<bool?> _mostrarDialogoConfirmacion(BuildContext context, String lastFourDigits) async {
    final completer = Completer<bool?>();
    
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Confirmar eliminación',
      text: '¿Estás seguro de eliminar la tarjeta terminada en $lastFourDigits?',
      confirmBtnText: 'Confirmar',
      cancelBtnText: 'Cancelar',
      confirmBtnColor: const Color(0xFF205AA8),
      onConfirmBtnTap: () {
        Navigator.pop(context);
        completer.complete(true);
      },
      onCancelBtnTap: () {
        Navigator.pop(context);
        completer.complete(false);
      },
    );
    
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

        const systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle,
          child: Scaffold(
            backgroundColor: backgroundColor,
            extendBodyBehindAppBar: true,
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: backgroundColor,
                child: Column(
                  children: [
                    Expanded(
                      child: Responsive(
                        mobile: mobileView(context: context, isDark: isDark, textColor: textColor),
                        desktop: desktopView(context: context, isDark: isDark, textColor: textColor),
                        tablet: mobileView(context: context, isDark: isDark, textColor: textColor),
                      ),
                    ),
                    // Botón fijo en la parte inferior
                    _buildAddCardButton(isDark: isDark),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
          ),
        );
      },
    );
  }

  Widget _buildContent({required BuildContext context, required bool isDark, required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Section title con botón colapsar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Mis tarjetas",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Botón para colapsar (solo visible cuando está expandido)
                    if (_isExpanded)
                      GestureDetector(
                        onTap: () {
                          if (!_expansionController.isAnimating) {
                            _toggleExpansion();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.expand_less,
                                size: 20,
                                color: textColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Colapsar',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // StreamBuilder para obtener el wallet y cargar las tarjetas
                StreamBuilder<PasajeroWalletModel?>(
                  stream: monederoBloc.walletStream,
                  builder: (context, walletSnapshot) {
                    final wallet = walletSnapshot.data ?? monederoBloc.wallet;
                    
                    // Cargar tarjetas inmediatamente cuando el wallet esté disponible
                    // PERO NO si se está eliminando una tarjeta (para evitar recargas innecesarias)
                    // VALIDACIÓN: Solo cargar si hay customerIdNetPay
                    if (wallet != null && 
                        wallet.customerIdNetPay != null && 
                        wallet.customerIdNetPay!.isNotEmpty &&
                        !netPayBloc.isDeleting) {
                      // Usar addPostFrameCallback para evitar llamadas durante el build
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !netPayBloc.isDeleting) {
                          _cargarTarjetasNetPay(wallet: wallet);
                        }
                      });
                    } else if (wallet != null && 
                               (wallet.customerIdNetPay == null || wallet.customerIdNetPay!.isEmpty)) {
                      // Si el wallet está cargado pero NO tiene customerIdNetPay,
                      // establecer estado vacío inmediatamente para evitar "Cargando..." indefinido
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && netPayBloc.currentStatus != NetPayStatus.empty) {
                          netPayBloc.limpiar();
                        }
                      });
                    }
                    
                    // StreamBuilder para el estado del NetPay
                    return StreamBuilder<NetPayStatus>(
                  stream: netPayBloc.statusStream,
                  builder: (context, statusSnapshot) {
                    final status = statusSnapshot.data ?? netPayBloc.currentStatus;

                    if (status == NetPayStatus.loading) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF205AA8),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Cargando tarjetas...',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (status == NetPayStatus.error) {
                      return StreamBuilder<String?>(
                        stream: netPayBloc.errorStream,
                        builder: (context, errorSnapshot) {
                          final error = errorSnapshot.data ?? 'Error al cargar los métodos de pago';
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  error,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: () {
                                    // Permitir reintento al hacer clic
                                    final wallet = monederoBloc.wallet;
                                    if (wallet != null && 
                                        wallet.customerIdNetPay != null && 
                                        wallet.customerIdNetPay!.isNotEmpty) {
                                      netPayBloc.obtenerClienteNetPay(wallet.customerIdNetPay!);
                                    }
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Reintentar'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF205AA8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    if (status == NetPayStatus.empty) {
                      // Verificar si el problema es que no hay customerIdNetPay
                      final wallet = monederoBloc.wallet;
                      final noTieneCustomerId = wallet == null || 
                                               wallet.customerIdNetPay == null || 
                                               wallet.customerIdNetPay!.isEmpty;
                      
                      return Container(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 64,
                                color: textColor.withOpacity(0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                noTieneCustomerId
                                    ? 'Agrega tu primera tarjeta para comenzar'
                                    : 'No tienes métodos de pago registrados',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (noTieneCustomerId) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Ingresa tus datos bancarios para poder realizar tus recargas.',
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    // StreamBuilder para manejar estados de eliminación
                    return StreamBuilder<NetPayStatus>(
                      stream: netPayBloc.statusStream,
                      initialData: netPayBloc.currentStatus,
                      builder: (context, deleteStatusSnapshot) {
                        final deleteStatus = deleteStatusSnapshot.data ?? NetPayStatus.idle;
                        
                        // Mostrar mensajes de éxito/error de eliminación
                        if (deleteStatus == NetPayStatus.success && _tarjetaEliminandoToken != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _tarjetaEliminandoToken != null) {
                              final tokenEliminado = _tarjetaEliminandoToken;
                              _tarjetaEliminandoToken = null;
                              
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: '¡Éxito!',
                                text: 'Tarjeta eliminada correctamente',
                                confirmBtnText: 'Aceptar',
                                onConfirmBtnTap: () {
                                  Navigator.pop(context);
                                },
                              );
                              // No limpiar el estado - obtenerClienteNetPay ya actualizó las tarjetas
                              // El StreamBuilder automáticamente mostrará las tarjetas actualizadas
                            }
                          });
                        }
                        
                        if (deleteStatus == NetPayStatus.error && _tarjetaEliminandoToken != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            StreamBuilder<String?>(
                              stream: netPayBloc.errorStream,
                              builder: (context, errorSnapshot) {
                                final error = errorSnapshot.data;
                                if (error != null && mounted && _tarjetaEliminandoToken != null) {
                                  _tarjetaEliminandoToken = null;
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'Error',
                                    text: error,
                                    confirmBtnText: 'Aceptar',
                                    onConfirmBtnTap: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                  // No limpiar el estado - mantener las tarjetas actuales en caso de error
                                }
                                return const SizedBox.shrink();
                              },
                            );
                          });
                        }
                        
                        // StreamBuilder para las tarjetas
                        return StreamBuilder<NetPayCustomerModel?>(
                          stream: netPayBloc.customerStream,
                          builder: (context, customerSnapshot) {
                            final customer = customerSnapshot.data ?? netPayBloc.currentCustomer;
                            
                            // Variable para verificar si se está eliminando
                            final isDeleting = deleteStatus == NetPayStatus.deleting;
                            
                            // Si está cargando (y no está eliminando) y no hay datos, mostrar indicador de carga
                            if ((deleteStatus == NetPayStatus.loading || deleteStatus == NetPayStatus.idle) && 
                                !isDeleting && 
                                customer == null) {
                              // Verificar si realmente se está cargando (el estado puede estar en idle pero iniciando carga)
                              if (netPayBloc.currentStatus == NetPayStatus.loading || 
                                  (deleteStatus == NetPayStatus.idle && netPayBloc.currentCustomer == null)) {
                                return Container(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xFF205AA8),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Cargando tarjetas...',
                                          style: TextStyle(
                                            color: textColor.withOpacity(0.7),
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }

                        if (customer == null || customer.paymentSources.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    size: 64,
                                    color: textColor.withOpacity(0.4),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tienes métodos de pago registrados',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Lista de tarjetas con overlay de carga si se está eliminando
                        if (isDeleting) {
                          return Stack(
                            children: [
                              // Asegurar que esté en modo apilado durante la eliminación
                              IgnorePointer(
                                child: _buildWalletCardStack(
                                  paymentSources: customer.paymentSources,
                                  textColor: textColor,
                                  isDark: isDark,
                                ),
                              ),
                              // Overlay de carga cuando se está eliminando (sin fondo oscuro)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24.0),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[900] : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF205AA8),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Eliminando tarjeta...',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        
                        // Lista de tarjetas normal cuando NO se está eliminando
                        return _buildWalletCardStack(
                          paymentSources: customer.paymentSources,
                          textColor: textColor,
                          isDark: isDark,
                        );
                          },
                        );
                      },
                    );
                  },
                );
                  },
                ),
              ],
            ),
          );
  }

  Widget _buildAddCardButton({required bool isDark}) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              // Navigate to Nueva Tarjeta screen
              GoRouter.of(context).go(RoutesName.nuevaTarjeta);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFA6CE39), // Lime green
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Agregar tarjeta",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget mobileView({required BuildContext context, required bool isDark, required Color textColor}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, textColor: textColor, isDark: isDark),
          // Content
          _buildContent(context: context, isDark: isDark, textColor: textColor),
        ],
      ),
    );
  }

  Widget desktopView({required BuildContext context, required bool isDark, required Color textColor}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, textColor: textColor, isDark: isDark),
          // Content - Reutilizar la misma lógica sin duplicar el header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildContent(context: context, isDark: isDark, textColor: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {Color textColor = Colors.white, bool isDark = true}) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: paddingTop + 16.0,
        bottom: 16.0,
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              } else {
                GoRouter.of(context).go(RoutesName.perfil); // Fallback
              }
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Métodos de pago",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Profile avatar - dinámico
          GestureDetector(
            onTap: () {
              GoRouter.of(context).go(RoutesName.perfil);
            },
            child: StreamBuilder<User?>(
              stream: authBloc.userStream,
              builder: (context, userSnapshot) {
                final user = userSnapshot.data ?? authBloc.currentUser;
                final textColor = isDark ? Colors.white : Colors.black;
                return UserAvatar(
                  imageUrl: user?.fotoPerfil,
                  radius: 20,
                  backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  iconColor: textColor,
                  iconSize: 24,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCardStack({
    required List<PaymentSourceModel> paymentSources,
    required Color textColor,
    required bool isDark,
  }) {
    const double cardHeight = 200.0;
    const double cardSpacing = 16.0; // Espaciado en modo lista
    const double stackOffset = 80.0; // Desplazamiento vertical en modo apilado (solo Y)

    // Calcular altura total para modo apilado (con espacio suficiente para que no se corte)
    // Agregamos un poco más de espacio al final para evitar recortes
    final double stackedHeight = cardHeight + (paymentSources.length - 1) * stackOffset + 8.0;
    // Altura expandida: incluye todas las tarjetas + espaciado + padding adicional al final para ver la última tarjeta completa
    final double expandedHeight = paymentSources.length * (cardHeight + cardSpacing) - cardSpacing + 32.0;

    return AnimatedBuilder(
      animation: _expansionAnimation,
      builder: (context, child) {
        // Interpolar entre modo apilado y expandido
        final double currentHeight = stackedHeight + (expandedHeight - stackedHeight) * _expansionAnimation.value;
        final bool isAnimating = _expansionController.isAnimating;

        return SizedBox(
          height: currentHeight,
          width: double.infinity,
          child: _isExpanded
              ? // Modo LISTA (expandido)
                SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ...paymentSources.asMap().entries.map((entry) {
                        final index = entry.key;
                        final paymentSource = entry.value;
                        final card = paymentSource.card;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < paymentSources.length - 1 ? cardSpacing : 32.0,
                          ),
                          child: Dismissible(
                            key: Key('tarjeta_${card.token}_${index}'),
                            direction: _tarjetaEliminandoToken != null 
                                ? DismissDirection.none 
                                : DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _tarjetaEliminandoToken == card.token
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                            ),
                            confirmDismiss: (direction) async {
                              if (_tarjetaEliminandoToken != null) {
                                return false;
                              }
                              
                              final result = await _mostrarDialogoConfirmacion(
                                context,
                                card.lastFourDigits,
                              );
                              
                              if (result == true) {
                                final wallet = monederoBloc.wallet;
                                if (wallet != null && 
                                    wallet.customerIdNetPay != null && 
                                    wallet.customerIdNetPay!.isNotEmpty) {
                                  setState(() {
                                    _tarjetaEliminandoToken = card.token;
                                  });
                                  
                                  await netPayBloc.eliminarTarjeta(
                                    customerId: wallet.customerIdNetPay!,
                                    tokenCard: card.token,
                                  );
                                  
                                  setState(() {
                                    _tarjetaEliminandoToken = null;
                                  });
                                }
                              }
                              
                              return false;
                            },
                            child: _buildNetPayCard(
                              card: card,
                              isDefault: paymentSource.cardDefault,
                              textColor: textColor,
                              isDark: isDark,
                              isActiveCard: true, // En modo expandido, todas las tarjetas muestran el chip
                            ),
                          ),
                        );
                        }).toList(),
                      ],
                    ),
                  )
              : // Modo APILADO
                Stack(
                    clipBehavior: Clip.none,
                    children: paymentSources.asMap().entries.map((entry) {
                      final index = entry.key;
                      final paymentSource = entry.value;
                      final card = paymentSource.card;
                      
                      // Calcular valores para modo apilado (SOLO VERTICAL)
                      final double stackedOffsetY = index * stackOffset;
                      
                      // Interpolar durante la animación hacia modo expandido
                      final double expandedOffsetY = index * (cardHeight + cardSpacing);
                      
                      // Interpolación suave entre estados
                      final double currentOffsetY = stackedOffsetY + (expandedOffsetY - stackedOffsetY) * _expansionAnimation.value;

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        top: currentOffsetY,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            if (!isAnimating) {
                              // Cualquier tarjeta puede expandir/colapsar
                              _toggleExpansion();
                            }
                          },
                          child: Dismissible(
                              key: Key('tarjeta_${card.token}_${index}'),
                              direction: _tarjetaEliminandoToken != null 
                                  ? DismissDirection.none 
                                  : DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: _tarjetaEliminandoToken == card.token
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                              ),
                              confirmDismiss: (direction) async {
                                if (_tarjetaEliminandoToken != null) {
                                  return false;
                                }
                                
                                final result = await _mostrarDialogoConfirmacion(
                                  context,
                                  card.lastFourDigits,
                                );
                                
                                if (result == true) {
                                  final wallet = monederoBloc.wallet;
                                  if (wallet != null && 
                                      wallet.customerIdNetPay != null && 
                                      wallet.customerIdNetPay!.isNotEmpty) {
                                    setState(() {
                                      _tarjetaEliminandoToken = card.token;
                                    });
                                    
                                    await netPayBloc.eliminarTarjeta(
                                      customerId: wallet.customerIdNetPay!,
                                      tokenCard: card.token,
                                    );
                                    
                                    setState(() {
                                      _tarjetaEliminandoToken = null;
                                    });
                                  }
                                }
                                
                                return false;
                              },
                              child: _buildNetPayCard(
                                card: card,
                                isDefault: paymentSource.cardDefault,
                                textColor: textColor,
                                isDark: isDark,
                                isActiveCard: true, // Todas las tarjetas muestran el chip
                              ),
                            ),
                          ),
                        );
                    }).toList(),
                  ),
        );
      },
    );
  }

  Widget _buildCardChipWithNfc() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chip usando imagen
        Image.asset(
          'assets/images/chip.png',
          width: 58,
          height: 42,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading chip.png: $error');
            return Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color(0xFF707070),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(Icons.credit_card, size: 20, color: Color(0xFF707070)),
              ),
            );
          },
        ),
        const SizedBox(width: 1),
        // Ícono NFC usando imagen
        Image.asset(
          'assets/images/nfc.png',
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading nfc.png: $error');
            return Icon(
              Icons.contactless,
              color: Colors.white,
              size: 32,
            );
          },
        ),
      ],
    );
  }

  Widget _buildNetPayCard({
    required CardModel card,
    required bool isDefault,
    required Color textColor,
    required bool isDark,
    bool isActiveCard = false, // Por defecto, no mostrar el chip
  }) {
    final bankName = card.bank ?? '--';
    final bankNameLower = bankName.toLowerCase();
    
    // Verificar si es NuBank
    final isNuBank = bankNameLower.contains('nubank') || 
                     bankNameLower.contains('nu bank') ||
                     bankNameLower == 'nu';
    
    // Determinar colores del gradiente basado en la marca de la tarjeta y el banco
    List<Color> gradientColors;
    bool useGradient = false;
    
    if (isNuBank) {
      // Degradado morado para NuBank (similar a la imagen)
      gradientColors = [
        const Color(0xFF8B4EB8), // Morado vibrante claro
        const Color(0xFF6B2C91), // Morado oscuro
        const Color(0xFF5A1F7A), // Morado más oscuro
      ];
      useGradient = true;
    } else {
      switch (card.brand.toLowerCase()) {
        case 'visa':
          // Degradado azul profundo y vibrante para VISA (más claro arriba, más oscuro abajo)
          gradientColors = [
            const Color(0xFF2E4C8F), // Azul más claro en la parte superior
            const Color(0xFF1A3570), // Azul medio
            const Color(0xFF0F2449), // Azul profundo y oscuro en la parte inferior
          ];
          useGradient = true;
          break;
        case 'mastercard':
          gradientColors = [
            const Color(0xFFEB001B),
            const Color(0xFFF79E1B),
          ];
          useGradient = true;
          break;
        default:
          // Usar el mismo azul que en "Agregar método de pago"
          gradientColors = [
            const Color(0xFF205AA8), // Azul principal
            const Color(0xFF205AA8), // Mismo azul (color sólido)
          ];
          useGradient = false;
      }
    }

    final cardNumberMasked = '**** **** **** ${card.lastFourDigits}';
    final expirationDate = card.expirationFormatted;
    final cardType = card.typeFormatted;
    
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: useGradient ? null : const Color(0xFF205AA8), // Color sólido para tarjetas por defecto
        gradient: useGradient ? LinearGradient( // Gradiente para Visa, Mastercard y NuBank
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          // Chip realista con ícono NFC (top left) - Solo en tarjeta activa
          if (isActiveCard)
            Positioned(
              top: 20,
              left: 20,
              child: _buildCardChipWithNfc(),
            ),
          // Logo de Visa o Mastercard (top right)
          if (card.brand.toLowerCase() == 'visa' || card.brand.toLowerCase() == 'mastercard')
            Positioned(
              top: 10,
              right: 20,
              child: Image.asset(
                card.brand.toLowerCase() == 'visa'
                    ? 'assets/images/visa.png'
                    : 'assets/images/mastercard.png',
                width: 50,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading ${card.brand} logo: $error');
                  return Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        card.brand.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          // Main content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 62, bottom: 16, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card number
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      cardNumberMasked,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        height: 1.2,
                      ),
                    ),
                  ),
                  // Bank, Expiration and Type row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banco
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BANCO',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                bankName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Válida hasta
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VÁLIDA HASTA',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                expirationDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tipo
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TIPO',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                cardType,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String cardNumber,
    required String cvv,
    required String cardholderName,
    required List<Color> gradientColors,
    required Color textColor,
    required String cardType,
  }) {
    return Container(
      width:
          double.infinity, // Ocupa todo el ancho disponible, igual que el botón
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Spacing to move card number down
              const SizedBox(height: 24),
              // Card number
              Text(
                cardNumber,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              // CVV and Cardholder name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cvv,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cardholderName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Card logo (bottom right)
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildCardLogo(cardType),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLogo(String cardType) {
    if (cardType == 'mastercard') {
      // MasterCard logo from assets - tamaño original
      return Image.asset(
        'assets/images/mastercard.png',
        errorBuilder: (context, error, stackTrace) {
          // Mostrar un placeholder si hay error
          debugPrint('Error loading mastercard.png: $error');
          return Container(
            width: 60,
            height: 40,
            color: Colors.white.withOpacity(0.2),
            child:
                const Icon(Icons.credit_card, color: Colors.white, size: 24),
          );
        },
      );
    } else if (cardType == 'visa') {
      // Visa logo from assets - tamaño original
      return Image.asset(
        'assets/images/visa.png',
        errorBuilder: (context, error, stackTrace) {
          // Mostrar un placeholder si hay error
          debugPrint('Error loading visa.png: $error');
          return Container(
            width: 40,
            height: 20,
            color: Colors.white.withOpacity(0.2),
            child:
                const Icon(Icons.credit_card, color: Colors.white, size: 24),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    final navBarColor = isDark ? Colors.grey[900] : Colors.grey[100];
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: navBarColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF205AA8), // Blue
          unselectedItemColor: Colors.grey[600],
          currentIndex: 2, // Configuración is selected
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          iconSize: 24,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Monedero',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: 'Actividad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configuración',
            ),
          ],
        onTap: (index) {
          if (index == 0) {
            GoRouter.of(context).go(RoutesName.dashboard);
          } else if (index == 1) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const MonederoBottomSheet(),
            );
          } else if (index == 2) {
            GoRouter.of(context).go(RoutesName.perfil);
          }
        },
      ),
      ),
    );
  }
}
