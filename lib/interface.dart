import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef RecordComplete = void Function(PickedFile file);

class QrScanError implements Exception {
  final String? message;
  final String? code;
  QrScanError({this.code, this.message});
}

class MediaRecorderException implements Exception {
  MediaRecorderException(this.code, this.description);

  String code;
  String description;

  @override
  String toString() => '$runtimeType($code, $description)';
}

/// The state of a [MultiPartyRecorder].
class QRValue {
  const QRValue({
    this.isInitialized,
    this.isPaused,
    this.errorDescription,
    this.isRunning,
    this.result,
  });

  const QRValue.uninitialized()
      : this(isInitialized: false, isRunning: false, isPaused: false);

  /// True after [RecorderValue.initialize] has completed successfully.
  final bool? isInitialized;

  /// True after [RecorderValue.pause] has completed successfully.
  final bool? isPaused;

  /// True when the camera is recording (not the same as previewing).
  final bool? isRunning;

  final String? errorDescription;

  final String? result;

  bool get hasError => errorDescription != null;

  QRValue copyWith({
    bool? isInitialized,
    bool? isRunning,
    bool? isPaused,
    String? errorDescription,
    String? result,
  }) {
    return QRValue(
        isInitialized: isInitialized ?? this.isInitialized,
        isPaused: isPaused ?? this.isPaused,
        errorDescription: errorDescription,
        result: result ?? this.result,
        isRunning: isRunning ?? this.isRunning);
  }

  @override
  String toString() {
    return '$runtimeType('
        'isRunning: $isRunning, '
        'isPaused: $isPaused, '
        'isInitialized: $isInitialized, '
        'errorDescription: $errorDescription, '
        'result: $result)';
  }
}

abstract class IQrScanner extends ValueNotifier<QRValue> {
  IQrScanner() : super(const QRValue.uninitialized());
  Future<void> start(
    dynamic mediaStream, {
    bool mirror = true,
  });
  Future<void> stop();
}
