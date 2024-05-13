import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class MPosControllerDevices {
  final MethodChannel channel =
      const MethodChannel('com.bixolon.mposcontroller/devices');

  final EventChannel deviceStatusChannel =
      const EventChannel('com.bixolon.mposcontroller/devices/status');
  final EventChannel dataChannel =
      const EventChannel('com.bixolon.mposcontroller/devices/data');

  Stream<int> get printerStatusEventStream {
    return deviceStatusChannel.receiveBroadcastStream().cast();
  }

  Stream<List<int>> get dataEventStream {
    return dataChannel.receiveBroadcastStream().cast();
  }

  Future<int?> openService({int deviceId = -1, int timeout = 3}) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'device_id': deviceId,
      'time_out': timeout
    };
    return await channel.invokeMethod('openService', params);
  }

  Future<int?> closeService({int timeout = 3}) async {
    final Map<String, dynamic> params = <String, dynamic>{'time_out': timeout};
    return await channel.invokeMethod('closeService', params);
  }

  Future<int?> selectInterface(int interfaceType, String address) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'interface_type': interfaceType,
      'address': address
    };
    return await channel.invokeMethod('selectInterface', params);
  }

  Future<int?> selectCommandMode(int commandMode) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'command_mode': commandMode,
    };
    return await channel.invokeMethod('selectCommandMode', params);
  }

  Future<int?> setTransaction(int transaction) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'transaction': transaction,
    };
    return await channel.invokeMethod('setTransaction', params);
  }

  Future<int?> setReadMode(int mode) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'read_mode': mode,
    };
    return await channel.invokeMethod('setReadMode', params);
  }

  Future<int?> setKeepNetworkConnection(int keepConnection) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'keep_connection': keepConnection,
    };
    return await channel.invokeMethod('setKeepNetworkConnection', params);
  }

  Future<int?> directIO(List<int> data) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'data_array': data,
    };
    return await channel.invokeMethod('directIO', params);
  }

  Future<int?> isOpen() async {
    return await channel.invokeMethod('isOpen');
  }

  Future<int?> getDeviceId() async {
    return await channel.invokeMethod('getDeviceId');
  }

  Future<int?> isUsbPeripheralPrinter() async {
    return await channel.invokeMethod('isUsbPeripheralPrinter');
  }

  Future<String?> getSdkVersion() async {
    return await channel.invokeMethod('getSdkVersion');
  }

  Future<List<int>?> getOccurredData() async {
    if (Platform.isAndroid) {
      return await channel.invokeMethod('getOccuredData');
    } else {
      return null;
    }
  }
}
