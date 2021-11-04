@JS()
library qr;

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js;
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'interface.dart' as _interface;

typedef QRResultHandler = void Function(QRResult result, dynamic error);

@JS('ZXing.BrowserQRCodeReader')
class BrowserQRCodeReader {
  external BrowserQRCodeReader();
  external Future<QRResult> decodeFromStream(html.MediaStream? stream,
      html.VideoElement? videoSource, QRResultHandler callbackFn);
  external stopContinuousDecode();
  external reset();
}

@JS()
@anonymous
class QRResult {
  external String get text;
}

bool mediaSupported() {
  return html.window.navigator.mediaDevices != null;
}

bool canEnumerateDevices() {
  final enumerate =
      js.getProperty(html.window.navigator.mediaDevices!, 'enumerateDevices');
  return !!(mediaSupported() && enumerate != null);
}

bool isQRScanningSupported() {
  try {
    final _ = html.BarcodeDetector();
    return canEnumerateDevices();
  } catch (error) {
    return canEnumerateDevices();
  }
}

class QrScanner extends _interface.IQrScanner {
  void _initialize(bool isMirror) {
    try {
      _detector = html.BarcodeDetector();
    } catch (error) {
      _videoElement = html.VideoElement()
        ..muted = true
        ..autoplay = true;
      if (isMirror) {
        _videoElement!.style.transform = 'rotateY(180deg)';
      }
      _videoElement!.width = 200;
      _videoElement!.height = 200;
      _videoElement!.setAttribute('autoplay', 'true');
      _videoElement!.setAttribute('muted', 'true');
      _videoElement!.setAttribute('playsinline', 'true');
    } finally {
      value = value.copyWith(isInitialized: true);
    }
  }

  bool running = false;
  bool _isReleased = false;
  html.ImageCapture? _imageCapture;
  html.BarcodeDetector? _detector;
  BrowserQRCodeReader? _browserQRCodeReader;
  html.VideoElement? _videoElement;

  Future<List<dynamic>?> _grabFrame() async {
    final bitmap = await _imageCapture!.grabFrame();
    final result = await _detector!.detect(bitmap);
    bitmap.close();
    return result;
  }

  Future<void> detect(highResTime) async {
    try {
      if (!value.isRunning! || value.isPaused! || _isReleased) {
        return;
      }
      final barcodes = await _grabFrame();
      if (barcodes == null) {
        return;
      }
      if (barcodes.isNotEmpty) {
        final val = js.getProperty(barcodes[0], 'rawValue');
        if (!value.isRunning! || value.isPaused! || _isReleased) {
          return;
        }
        value = value.copyWith(result: val);
      }
      html.window.requestAnimationFrame(detect);
    } catch (error) {
      if (kDebugMode) {
        print('error: $error');
      }
    }
  }

  @override
  Future<void> start(
    dynamic mediaStream, {
    bool mirror = true,
  }) async {
    try {
      final stream = mediaStream as html.MediaStream;
      if (_isReleased || value.isRunning!) {
        return;
      }
      _initialize(mirror);
      if (_detector == null) {
        _browserQRCodeReader?.reset();
        _browserQRCodeReader = BrowserQRCodeReader();
        js.promiseToFuture(
          _browserQRCodeReader!.decodeFromStream(
            stream,
            _videoElement,
            allowInterop(
              (result, error) {
                if (!value.isRunning! || _isReleased) {
                  return;
                }
                value = value.copyWith(result: result.text);
              },
            ),
          ),
        );
        value = value.copyWith(isRunning: true);
      } else {
        _imageCapture = html.ImageCapture(stream.getVideoTracks().first);
        value = value.copyWith(isRunning: true);
        html.window.requestAnimationFrame(detect);
      }
    } catch (error) {
      if (kDebugMode) {
        print('error: $error');
      }
    }
  }

  @override
  Future<void> stop() async {
    if (_isReleased) {
      return;
    }
    if (!value.isRunning!) {
      return;
    }
    _imageCapture = null;
    _browserQRCodeReader?.reset();
    value = const _interface.QRValue.uninitialized();
  }

  @override
  void dispose() {
    stop();
    _isReleased = true;
    _videoElement = null;
    super.dispose();
  }
}
