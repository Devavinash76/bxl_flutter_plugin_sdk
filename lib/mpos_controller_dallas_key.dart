import 'package:bxlflutterbgatelib/mpos_controller_devices.dart';
import 'package:flutter/services.dart';

class MPosControllerDallasKey extends MPosControllerDevices {
  @override
  MethodChannel get channel =>
      const MethodChannel('com.bixolon.mposcontroller/dallaskey');

  @override
  EventChannel get dataChannel =>
      const EventChannel('com.bixolon.mposcontroller/dallaskey/data');

  @override
  Stream<List<int>> get dataEventStream {
    return dataChannel.receiveBroadcastStream().cast();
  }
}
