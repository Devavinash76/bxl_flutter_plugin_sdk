import 'dart:convert';

import 'package:bxlflutterbgatelib_example/models/mpos_controller/mpos_config_controller.dart';
import 'package:bxlflutterbgatelib_example/models/vo/mpos_device.dart';
import 'package:bxlflutterbgatelib_example/models/vo/mpos_device_id.dart';
import 'package:bxlflutterbgatelib_example/screens/constants.dart';
import 'package:flutter/material.dart';

class DeviceIdListPage extends StatefulWidget {
  final MPosDevice? _printerInfo;

  const DeviceIdListPage({
    Key? key,
    required MPosDevice? printerInfo,
  })  : _printerInfo = printerInfo,
        super(key: key);

  @override
  _DeviceIdListPageState createState() => _DeviceIdListPageState();
}

class _DeviceIdListPageState extends State<DeviceIdListPage> {
  final configController = MPosConfigController();

  List<MPosDeviceId>? deviceIdList;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    refreshDeviceIdList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          title: const Text('Device ID List'),
          flexibleSpace: kAppbarGradient,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: IconButton(
                  onPressed: () {
                    if (!isRefreshing) {
                      refreshDeviceIdList();
                    }
                  },
                  icon: const Icon(Icons.refresh)),
            ),
          ],
        ),
      ),
      body: deviceIdList != null
          ? (deviceIdList!.isNotEmpty
              ? ListView.builder(
                  itemCount: deviceIdList!.length,
                  itemBuilder: _buildRow,
                )
              : const Center(
                  child: Text('NO Devices or NOT supported'),
                ))
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
    );
  }

  Widget _buildRow(BuildContext context, int i) {
    final MPosDeviceId device = deviceIdList!.elementAt(i);

    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        gradient: kOrangeGradientDecoration,
      ),
      child: ListTile(
        onTap: () => Navigator.pop(context, device),
        title: Row(
          children: [
            const Icon(
              Icons.local_print_shop,
              color: Colors.white,
            ),
            const SizedBox(
              width: 20,
              height: 70,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    text: TextSpan(
                        text: 'Device ID : ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        children: [TextSpan(text: '${device.deviceId}')])),
                RichText(
                    text: TextSpan(
                        text: 'USB ID : ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        children: [TextSpan(text: device.vidPid)])),
                RichText(
                    text: TextSpan(
                        text: device.deviceType,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void refreshDeviceIdList() async {
    isRefreshing = true;

    setState(() {
      this.deviceIdList = null;
    });

    List<MPosDeviceId> deviceIdList = [];

    await configController.connect(widget._printerInfo).then(
      (bool result) async {
        if (result == false) {
          return;
        }

        String? jsonString = await configController.searchDevices() ?? '[]';
        Iterable l = json.decode(jsonString);

        for (final element in l) {
          int deviceID = element['device_id'];
          String vidPid = await configController.getUSBDevice(deviceID) ?? '';
          element['vid_pid'] = vidPid;
        }

        List<MPosDeviceId> idList = List<MPosDeviceId>.from(
            l.map((device) => MPosDeviceId.fromJson(device)));

        deviceIdList.addAll(idList);
      },
    );

    await configController.disconnect(timeout: 3);

    setState(() {
      this.deviceIdList = deviceIdList;
    });

    debugPrint('isEmpty: ${deviceIdList.isEmpty}');

    isRefreshing = false;
  }
}
