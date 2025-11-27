// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class EscaneoQRConstanciaPage extends StatefulWidget {
  const EscaneoQRConstanciaPage({super.key});

  @override
  State<EscaneoQRConstanciaPage> createState() => _EscaneoQRConstanciaPageState();
}

class _EscaneoQRConstanciaPageState extends State<EscaneoQRConstanciaPage> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, textColor: textColor, isDark: isDark),
                
                // Camera preview
                Expanded(
                  child: Stack(
                    children: [
                      // QR Scanner
                      MobileScanner(
                        controller: _controller,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null) {
                              // QR code detected
                              _handleQRCodeScanned(barcode.rawValue!);
                              break;
                            }
                          }
                        },
                      ),
                      
                      // Overlay with scanning frame
                      _buildScanningOverlay(textColor: textColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleQRCodeScanned(String qrCode) {
    // Stop scanning
    _controller.stop();
    
    // Show result and navigate back
    Navigator.of(context).pop();
    
    // You can process the QR code data here
    // For example, show a dialog or navigate to another screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR escaneado: $qrCode'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context,
      {Color textColor = Colors.white, bool isDark = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.black.withOpacity(0.7),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              _controller.stop();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                GoRouter.of(context).go(RoutesName.perfil);
              }
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Escanear QR de Constancia",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Spacer for balance
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay({Color textColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container()),
                // Scanning frame
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFA6CE39), // Green
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Corner indicators
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: const Color(0xFFA6CE39), width: 4),
                              left: BorderSide(color: const Color(0xFFA6CE39), width: 4),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: const Color(0xFFA6CE39), width: 4),
                              right: BorderSide(color: const Color(0xFFA6CE39), width: 4),
                            ),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: const Color(0xFFA6CE39), width: 4),
                              left: BorderSide(color: const Color(0xFFA6CE39), width: 4),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: const Color(0xFFA6CE39), width: 4),
                              right: BorderSide(color: const Color(0xFFA6CE39), width: 4),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          // Instructions
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Colors.black.withOpacity(0.7),
            child: Column(
              children: [
                Text(
                  "Apunta la cámara al código QR",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "El código se escaneará automáticamente",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

