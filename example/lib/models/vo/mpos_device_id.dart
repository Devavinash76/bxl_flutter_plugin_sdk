class MPosDeviceId {
  int deviceId = 0;
  String deviceType = '';
  String vidPid = '';

  static MPosDeviceId fromJson(Map<String, dynamic> json) {
    var device = MPosDeviceId();

    device.deviceId = json['device_id'];
    device.deviceType = json['device_type'];
    device.vidPid = json['vid_pid'];

    return device;
  }
}
