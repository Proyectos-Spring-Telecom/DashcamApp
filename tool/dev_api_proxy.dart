import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Proxy local para desarrollo Flutter Web.
///
/// Reenvía `http://127.0.0.1:<port>/apidev/*` → `https://dashcampay.com/apidev/*`
/// e inyecta cabeceras CORS (el navegador bloquea localhost → dashcampay.com).
///
/// Importante: no reenvía `Origin`/`Referer` al backend. Algunos entornos Dev
/// responden 500 ante `Origin: http://localhost:*`; el proxy gestiona CORS solo
/// hacia el navegador.
///
/// Uso:
///   dart run tool/dev_api_proxy.dart
///   flutter run -d chrome --dart-define-from-file=.env ...
const _defaultPort = 8090;
const _targetHost = 'dashcampay.com';
const _targetScheme = 'https';

/// Cabeceras hop-by-hop / de navegador que no deben ir al upstream.
const _blockedUpstreamRequestHeaders = {
  'host',
  'connection',
  'content-length',
  'transfer-encoding',
  'origin',
  'referer',
};

/// Cabeceras CORS del upstream: las sustituye el proxy hacia el navegador.
const _blockedUpstreamResponseHeaders = {
  'transfer-encoding',
  'content-encoding',
  'access-control-allow-origin',
  'access-control-allow-credentials',
  'access-control-allow-methods',
  'access-control-allow-headers',
  'access-control-expose-headers',
  'access-control-max-age',
  'vary',
};

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args.first) ?? _defaultPort : _defaultPort;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

  stdout.writeln('🌐 Dev API proxy escuchando en http://127.0.0.1:$port/apidev');
  stdout.writeln('   → $_targetScheme://$_targetHost/apidev');
  stdout.writeln('   Detén con Ctrl+C');

  await for (final request in server) {
    unawaited(_handleRequest(request));
  }
}

Future<void> _handleRequest(HttpRequest request) async {
  final origin = request.headers.value('origin') ?? '*';

  if (request.method == 'OPTIONS') {
    _writeCorsHeaders(request.response, origin);
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  try {
    final incomingUri = request.uri;
    final targetUri = Uri(
      scheme: _targetScheme,
      host: _targetHost,
      path: incomingUri.path,
      query: incomingUri.hasQuery ? incomingUri.query : null,
    );

    final client = HttpClient();
    client.autoUncompress = true;

    late HttpClientRequest upstream;
    switch (request.method.toUpperCase()) {
      case 'GET':
        upstream = await client.getUrl(targetUri);
        break;
      case 'POST':
        upstream = await client.postUrl(targetUri);
        break;
      case 'PUT':
        upstream = await client.putUrl(targetUri);
        break;
      case 'PATCH':
        upstream = await client.patchUrl(targetUri);
        break;
      case 'DELETE':
        upstream = await client.deleteUrl(targetUri);
        break;
      default:
        upstream = await client.openUrl(request.method, targetUri);
    }

    request.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (_blockedUpstreamRequestHeaders.contains(lower)) {
        return;
      }
      for (final value in values) {
        upstream.headers.set(name, value);
      }
    });

    upstream.headers.set('Host', _targetHost);

    final bodyBytes = await _collectRequestBody(request);
    if (bodyBytes.isNotEmpty) {
      upstream.add(bodyBytes);
    }

    final upstreamResponse = await upstream.close();
    final responseBytes = await _collectResponseBody(upstreamResponse);

    request.response.statusCode = upstreamResponse.statusCode;
    upstreamResponse.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (_blockedUpstreamResponseHeaders.contains(lower)) return;
      for (final value in values) {
        request.response.headers.set(name, value);
      }
    });
    // CORS hacia el navegador (nunca reenviar Origin al backend).
    _writeCorsHeaders(request.response, origin);
    request.response.add(responseBytes);
    await request.response.close();
    client.close(force: true);
  } catch (e, stack) {
    stderr.writeln('❌ Proxy error ${request.method} ${request.uri}: $e');
    stderr.writeln(stack);
    _writeCorsHeaders(request.response, request.headers.value('origin') ?? '*');
    request.response.statusCode = HttpStatus.badGateway;
    request.response.write(jsonEncode({'message': 'Dev proxy error: $e'}));
    await request.response.close();
  }
}

void _writeCorsHeaders(HttpResponse response, String origin) {
  response.headers.set('Access-Control-Allow-Origin', origin);
  response.headers.set('Access-Control-Allow-Credentials', 'true');
  response.headers.set(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD',
  );
  response.headers.set(
    'Access-Control-Allow-Headers',
    'Origin, Content-Type, Accept, Authorization, X-Requested-With',
  );
  response.headers.set('Access-Control-Expose-Headers', '*');
  response.headers.set('Access-Control-Max-Age', '86400');
  response.headers.set('Vary', 'Origin');
}

Future<List<int>> _collectResponseBody(HttpClientResponse response) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in response) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}

Future<List<int>> _collectRequestBody(HttpRequest request) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in request) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}
