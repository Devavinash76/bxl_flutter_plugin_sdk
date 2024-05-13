import 'package:bxlflutterbgatelib/mpos_controller_devices.dart';
import 'package:flutter/services.dart';

class MPosControllerScanner extends MPosControllerDevices {
  @override
  MethodChannel get channel =>
      const MethodChannel('com.bixolon.mposcontroller/scanner');

  @override
  EventChannel get dataChannel =>
      const EventChannel('com.bixolon.mposcontroller/scanner/data');

  @override
  Stream<List<int>> get dataEventStream {
    return dataChannel.receiveBroadcastStream().cast();
  }
}
