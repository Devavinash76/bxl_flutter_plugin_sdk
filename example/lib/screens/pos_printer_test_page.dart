import 'package:bxlflutterbgatelib_example/models/mpos_controller/mpos_pos_printer_controller.dart';
import 'package:bxlflutterbgatelib_example/models/vo/mpos_device.dart';
import 'package:bxlflutterbgatelib_example/models/vo/mpos_device_id.dart';
import 'package:bxlflutterbgatelib_example/screens/constants.dart';
import 'package:bxlflutterbgatelib_example/screens/device_id_list_page.dart';
import 'package:bxlflutterbgatelib_example/screens/device_lookup_page.dart';
import 'package:bxlflutterbgatelib_example/screens/widgets/custom_gradient_button.dart';
import 'package:bxlflutterbgatelib_example/screens/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptPrinterTestPage extends StatefulWidget {
  const ReceiptPrinterTestPage({Key? key}) : super(key: key);

  @override
  _ReceiptPrinterTestPageState createState() => _ReceiptPrinterTestPageState();
}

class _ReceiptPrinterTestPageState extends State<ReceiptPrinterTestPage> {
  final MPosPrinterController _printerController = MPosPrinterController();

  final TextEditingController _outputTextEditingController =
      TextEditingController();
  final TextEditingController _inputTextEditingController =
      TextEditingController(text: "30 31 32 33 34 35 36 37 38 39\n0d 0a");

  MPosDevice? deviceInfo;

  int deviceId = -1;
  int peripheralDeviceId = -1;

  int lookupInterfaceType = 0;
  int selectCommandMode = 1;

  bool isPrinterOpen = false;
  bool isWaiting = false;
  bool isHexString = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receipt Printing',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
        ),
        flexibleSpace: kAppbarGradient,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Output",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: CustomTextField(
                      controller: _outputTextEditingController,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Text("Lookup interface"),
                      Expanded(
                        child: CupertinoSegmentedControl(
                          borderColor: Colors.orangeAccent,
                          selectedColor: Colors.orange,
                          groupValue: lookupInterfaceType,
                          children: const <int, Widget>{
                            0: Text("Bluetooth"),
                            1: Text("Network"),
                            2: Text("USB"),
                          },
                          onValueChanged: (int newValue) {
                            setState(() {
                              lookupInterfaceType = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      CustomGradientButton(
                        buttonLabel: "Lookup",
                        onPressed: () {
                          _discoveryDevice(context);
                        },
                      ),
                      const SizedBox(width: 8.0),
                      CustomGradientButton(
                        buttonLabel: "Search Device IDs",
                        onPressed: () {
                          _getDeviceIdList(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Text("Command mode"),
                      Expanded(
                        child: CupertinoSegmentedControl(
                          borderColor: Colors.orangeAccent,
                          selectedColor: Colors.orange,
                          groupValue: selectCommandMode,
                          children: const <int, Widget>{
                            1: Text("Direct"),
                            0: Text("B-Gate"),
                          },
                          onValueChanged: (int newValue) {
                            setState(() {
                              selectCommandMode = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      CustomGradientButton(
                        buttonLabel: "Open",
                        onPressed: () {
                          _showProgressWidget(true);
                          _openDevice(context);
                          _showProgressWidget(false);
                        },
                      ),
                      const SizedBox(width: 8.0),
                      CustomGradientButton(
                        buttonLabel: "Close",
                        onPressed: () {
                          _closeDevice(context);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24.0, thickness: 1.5),
                  Row(
                    children: [
                      CustomGradientButton(
                        buttonLabel: 'Print in line mode',
                        onPressed: isPrinterOpen
                            ? () => _printInLineMode(context)
                            : null,
                      ),
                      const SizedBox(width: 8.0),
                      CustomGradientButton(
                        buttonLabel: 'Print in page mode',
                        onPressed: isPrinterOpen
                            ? () => _printInPageMode(context)
                            : null,
                      ),
                      const SizedBox(width: 8.0),
                      CustomGradientButton(
                          buttonLabel: 'Print PDF File',
                          onPressed: isPrinterOpen
                              ? () => _printPDFFile(context)
                              : null),
                    ],
                  ),
                  const Divider(height: 24.0, thickness: 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomGradientButton(
                          buttonLabel: 'Get model name',
                          onPressed: isPrinterOpen
                              ? () => _getModelName(context)
                              : null),
                      const SizedBox(width: 10),
                      CustomGradientButton(
                        buttonLabel: 'Get firmware version',
                        onPressed: isPrinterOpen
                            ? () => _getFirmwareVersion(context)
                            : null,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text(
                          "Input",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const Text("Hex mode"),
                        Switch(
                          value: isHexString,
                          onChanged: (bool isEnable) {
                            setState(() {
                              isHexString = isEnable;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: CustomTextField(
                      controller: _inputTextEditingController,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomGradientButton(
                        buttonLabel: 'Send data',
                        onPressed: () => _sendRawData(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Visibility(
              visible: isWaiting,
              child: const CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDevice(BuildContext context) async {
    if (deviceInfo == null) {
      return;
    }

    int result;

    result = await _printerController.connect(
      deviceInfo!,
      deviceId: deviceId,
      commandMode: selectCommandMode,
      printerStatusEvent: _updatePrinterStatusMessage,
      outputCompletedEvent: _outputCompletedMessage,
      dataEvent: _dataMessage,
    );

    if ((result == 0 || result == 1)) {
      setState(() {
        if (_isPosPrinter(deviceId: deviceId)) {
          isPrinterOpen = true;
          _outputTextEditingController.text = 'Connected with the printer\n';
        } else {
          _outputTextEditingController.text = "Ready to received data\n";
        }
      });
    } else {
      setState(() {
        _outputTextEditingController.text =
            "Failed to connect, error code: $result\n";
      });
    }
  }

  void _closeDevice(BuildContext context) async {
    await _printerController.disconnectAll().then((value) {
      setState(() {
        isPrinterOpen = false;
        _outputTextEditingController.text = 'Disconnect\n';
      });
    });
  }

  void _printInLineMode(BuildContext context) async {
    await _printerController.printInLineMode(deviceId: deviceId);
  }

  void _printInPageMode(BuildContext context) async {
    await _printerController.printInPageMode(deviceId: deviceId);
  }

  void _printPDFFile(BuildContext context) async {
    int result = await _printerController.printPDFFile(deviceId: deviceId);
    if (result != 0) {
      setState(() {
        _outputTextEditingController.text =
            'Failed in printing PDF file, ERR CODE: $result\n';
      });
    }
  }

  void _getFirmwareVersion(BuildContext context) async {
    final resultString =
        await _printerController.getFirmwareVersion(deviceId: deviceId);
    setState(() {
      _outputTextEditingController.text = '$resultString\n';
    });
  }

  void _getModelName(BuildContext context) async {
    final resultString =
        await _printerController.getModelName(deviceId: deviceId);
    setState(() {
      if (resultString != null) {
        deviceInfo?.deviceName = resultString;
      }

      _outputTextEditingController.text = '$resultString\n';
    });
  }

  void _discoveryDevice(BuildContext context) async {
    final device = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceLookupPage(
          interfaceType: lookupInterfaceType,
        ),
      ),
    );

    setState(() {
      if (device != null) {
        deviceInfo = device;
      }
    });

    if (device != null) {
      deviceId = -1;
      _outputTextEditingController.text =
          '${deviceInfo?.deviceName}, ${deviceInfo?.address}, ${deviceInfo?.interfaceType}\n';
    }
  }

  void _getDeviceIdList(BuildContext context) async {
    if (deviceInfo == null) {
      return;
    }

    MPosDeviceId? deviceId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceIdListPage(printerInfo: deviceInfo),
      ),
    );

    if (deviceId != null) {
      int result = await _printerController.connect(
        deviceInfo!,
        deviceId: deviceId.deviceId,
        commandMode: selectCommandMode,
        printerStatusEvent: _updatePrinterStatusMessage,
        outputCompletedEvent: _outputCompletedMessage,
        dataEvent: _dataMessage,
      );

      if (result == 0 || result == 1) {
        _outputTextEditingController.text = _outputTextEditingController.text +
            "\nPeripheral connect: ${deviceId.deviceId}, ${deviceId.deviceType}";
        peripheralDeviceId = deviceId.deviceId;
      } else {
        _outputTextEditingController.text = _outputTextEditingController.text +
            "\nPeripheral device connect error: $result";
      }
    }
  }

  void _updatePrinterStatusMessage(int status) {
    setState(
      () {
        _outputTextEditingController.text = '';
        if (status == 0) {
          _outputTextEditingController.text = 'NORMAL ($status\n';
        } else if (status < 0) {
          _outputTextEditingController.text =
              ' Failed in checking the printer status ($status)\n';
        } else {
          if (status & 1 != 0) {
            _outputTextEditingController.text += ' COVER OPEN ($status)\n';
          }
          if (status & 2 != 0) {
            _outputTextEditingController.text += ' PAPER EMPTY ($status)\n';
          }
          if (status & 4 != 0) {
            _outputTextEditingController.text += ' PAPER NEAR END ($status)\n';
          }
          if (status & 8 != 0) {
            _outputTextEditingController.text += ' OFFLINE ($status)\n';
          }
          if (status & 64 != 0) {
            _outputTextEditingController.text += ' BATTERY LOW ($status)\n';
          }
          if (status & 256 != 0) {
            _outputTextEditingController.text +=
                ' CASHDRAWER SIGNAL HIGH ($status)\n';
          }
          if (status & 512 != 0) {
            _outputTextEditingController.text +=
                ' CASHDRAWER SIGNAL LOW ($status)\n';
          }
        }
      },
    );
  }

  void _outputCompletedMessage(void _) {
    setState(() {
      _outputTextEditingController.text = 'OutputCompletedEvent received\n';
    });
  }

  void _dataMessage(List<int> dataArray) {
    String dataString = dataArray
        .map((int element) => element.toRadixString(16).padLeft(2, "0"))
        .join(" ");

    setState(() {
      _outputTextEditingController.text +=
          "${DateFormat("HH:mm:ss").format(DateTime.now())}\n"
          "Data Received: $dataString\n\n";
    });

    debugPrint("Data Received: ${dataArray.toString()}");
  }

  void _sendRawData(context) async {
    String sendToText = _inputTextEditingController.text;

    await _printerController.sendData(
      deviceId: peripheralDeviceId,
      text: sendToText,
      isHexString: isHexString,
    );
  }

  void _showProgressWidget(bool isProgress) {
    setState(() {
      isWaiting = isProgress;
    });
  }

  bool _isPosPrinter({required int deviceId}) {
    return (deviceId == -1 || deviceId == 0) ||
        (11 <= deviceId && deviceId <= 19);
  }
}
