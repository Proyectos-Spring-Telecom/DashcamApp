// Stub para dart:html en mobile
library html_stub;

import 'dart:async';

class ImageElement {
  String? src;
  String? crossOrigin;
  final Style style = Style();

  ImageElement();

  Stream<dynamic> get onError => const Stream.empty();
}

class Style {
  String? width;
  String? height;
  String? borderRadius;
  String? objectFit;
}

// Stubs para inyección de script de Google Maps (solo usados en web; en mobile no se llaman)
Document get document => Document();

class Document {
  Head? get head => null;
}

class Head {
  void append(dynamic node) {}
}

class ScriptElement {
  String? src;
  void setAttribute(String name, String value) {}
  Stream<dynamic> get onError => const Stream.empty();
}
