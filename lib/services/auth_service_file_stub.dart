// Stub para File y SocketException en web
// Este archivo solo se usa cuando dart:io no está disponible (web)

import 'dart:typed_data';

class File {
  final String path;
  File(this.path);
  
  Future<bool> exists() async {
    throw UnsupportedError('File.exists() no está disponible en web');
  }
  
  Future<Uint8List> readAsBytes() async {
    throw UnsupportedError('File.readAsBytes() no está disponible en web');
  }
  
  Future<int> length() async {
    throw UnsupportedError('File.length() no está disponible en web');
  }
}

class SocketException implements Exception {
  final String? message;
  final dynamic osError;
  
  const SocketException([this.message, this.osError]);
  
  @override
  String toString() => 'SocketException: ${message ?? 'Socket error'}';
}
