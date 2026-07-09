import 'package:dashboardpro/controller/monedero_bloc.dart';
import 'package:dashboardpro/widgets/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';

/// Validación de saldo antes de generar códigos QR de pago.
class QrSaldoValidator {
  QrSaldoValidator._();

  static const Color _confirmColor = Color(0xFF205AA8);

  /// `true` cuando el saldo es mayor a 0.00.
  static bool puedeGenerarQr() {
    final saldo = monederoBloc.wallet?.saldoTotal ?? 0.0;
    return saldo > 0.0;
  }

  static void mostrarAlertaSaldoInsuficiente(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Saldo insuficiente',
      text:
          'No puedes generar un código QR porque no cuentas con saldo suficiente. '
          'Realiza una recarga con tarjeta u otros métodos de pago disponibles '
          'para continuar.',
      confirmBtnText: 'Recargar',
      cancelBtnText: 'Cancelar',
      confirmBtnColor: _confirmColor,
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        if (context.mounted) {
          GoRouter.of(context).go(RoutesName.recargar);
        }
      },
      onCancelBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }

  /// Retorna `true` si el flujo de generación de QR puede continuar.
  static bool validarAntesDeGenerar(BuildContext context) {
    if (puedeGenerarQr()) return true;
    mostrarAlertaSaldoInsuficiente(context);
    return false;
  }
}
