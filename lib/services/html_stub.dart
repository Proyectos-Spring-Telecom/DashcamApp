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
