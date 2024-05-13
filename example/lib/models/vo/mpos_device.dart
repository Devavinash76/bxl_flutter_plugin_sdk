class MPosDevice {
  //    MPOS_INTERFACE_WIFI          = 1,
  //     MPOS_INTERFACE_ETHERNET     = 2,
  //     MPOS_INTERFACE_BLUETOOTH    = 4,
  //     MPOS_INTERFACE_BLE          = 8,
  //     MPOS_INTERFACE_USB          = 16,
  int interfaceType = 0;

  String deviceName = '';
  String address = '';
  String productName = '';

  static MPosDevice fromJson(Map<String, dynamic> json) {
    var device = MPosDevice();

    device.address = json['address'] ?? '';
    device.deviceName = json['device_name'] ?? '';
    device.interfaceType = json['interface_type'] ?? -1;
    device.productName = json['product_name'] ?? '';

    return device;
  }
}
