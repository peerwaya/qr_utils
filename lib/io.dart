import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'interface.dart' as _interface;

bool isQRScanningSupported() {
  throw UnimplementedError();
}

class QrScanner extends _interface.IQrScanner {
  @override
  Future<void> start(
    dynamic mediaStream, {
    bool mirror = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<PickedFile> stop() async {
    throw UnimplementedError();
  }
}
