import 'package:dashboardpro/model/netpay/card_token_request.dart';
import 'package:dashboardpro/model/netpay/card_token_response.dart';

class NetPayWebTokenizer {
  Future<CardTokenResponse> tokenizeCard({
    required CardTokenRequest request,
    required bool useSandbox,
    required String apiKey,
  }) {
    throw UnsupportedError(
      'NetPayWebTokenizer solo esta disponible en Flutter Web.',
    );
  }
}
