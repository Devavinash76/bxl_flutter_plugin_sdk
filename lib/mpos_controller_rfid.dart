import 'package:bxlflutterbgatelib/mpos_controller_devices.dart';
import 'package:flutter/services.dart';

class MPosControllerRfid extends MPosControllerDevices {
  @override
  MethodChannel get channel =>
      const MethodChannel('com.bixolon.mposcontroller/rfid');

  @override
  EventChannel get dataChannel =>
      const EventChannel('com.bixolon.mposcontroller/rfid/data');

  @override
  Stream<List<int>> get dataEventStream {
    return dataChannel.receiveBroadcastStream().cast();
  }
}
