import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';


class BluetoothProvider with ChangeNotifier {
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  final Uuid serviceId = Uuid.parse(
      '4fafc201-1fb5-459e-8fcc-c5c9c331914b'); // Convert service ID string to Uuid
  final Uuid charId = Uuid.parse(
      'beb5483e-36e1-4688-b7f5-ea07361b26a8'); // Convert service ID string to Uuid
  final String devId = '94:3C:C6:97:56:FE'; // Convert service ID string to Uuid
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;


  void setConnection(bool isConnected) {}

  void startScan() async {
    flutterReactiveBle
        .connectToDevice(
      id: devId,
      servicesWithCharacteristicsToDiscover: {
        serviceId: [charId]
      },
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionState) {
      if (connectionState.toString() == 'DeviceConnectionState.connected') {
        _isConnected = true;
      } else {
        _isConnected = false;
      }

      // Handle connection state updates
    }, onError: (Object error) {
      // Handle a possible error
      _isConnected = false;
      print('Error occurred while connecting to the device');
    });
  }

  void writeToBluetooth(String data) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceId,
      characteristicId: charId,
      deviceId: devId,
    );
    final value = data.codeUnits; // Convert string to UTF-8 bytes
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
        value: value);
  }
}
