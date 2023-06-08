import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class BluetoothProvider with ChangeNotifier {
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  final Uuid serviceId = Uuid.parse(
      '4fafc201-1fb5-459e-8fcc-c5c9c331914b'); // Convert service ID string to Uuid
  final Uuid charId = Uuid.parse(
      '8b037310-033c-11ee-be56-0242ac120002'); // Convert service ID string to Uuid
  final Uuid charIdMeta = Uuid.parse(
      'beb5483e-36e1-4688-b7f5-ea07361b26a8'); // Convert service ID string to Uuid
  final String devId = '94:3C:C6:97:56:FE'; // Convert service ID string to Uuid
  // final String devId = 'B8:D6:1A:0E:57:CA'; // Convert service ID string to Uuid

  final Uuid charIdLat = Uuid.parse('26d2f5de-05b0-11ee-be56-0242ac120002');
  final Uuid charIdLong = Uuid.parse('3136b434-05b0-11ee-be56-0242ac120002');

  bool _isConnected = false;
  bool get isConnected => _isConnected;
  late Timer _timer;
  late Position _currentLocation;

  void startLocationUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 120), (timer) async {
      _currentLocation = await Geolocator.getCurrentPosition();
      print(
          "sending lat/long: ${_currentLocation.latitude.toString()} / ${_currentLocation.longitude.toString()}");
      writeToBluetoothLat(_currentLocation.latitude.toString());
      writeToBluetoothLong(_currentLocation.longitude.toString());
    });
  }

  void stopLocationUpdates() {
    _timer.cancel();
  }

  void startScan() async {
    flutterReactiveBle
        .connectToDevice(
      id: devId,
      servicesWithCharacteristicsToDiscover: {
        serviceId: [charIdMeta, charId]
      },
      connectionTimeout: const Duration(seconds: 3),
    )
        .listen((connectionState) {
      print("the state: ${connectionState.toString()}");
      if (connectionState.toString() ==
          'ConnectionStateUpdate(deviceId: $devId, connectionState: DeviceConnectionState.connected, failure: null)') {
        print("isconnected");
        _isConnected = true;
      } else {
        print("is not connected");
        _isConnected = false;
      }

      // Handle connection state updates
    }, onError: (Object error) {
      // Handle a possible error
      _isConnected = false;
      print('Error occurred while connecting to the device');
    });
  }

  void writeToBluetoothMeta(String data) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceId,
      characteristicId: charIdMeta,
      deviceId: devId,
    );
    final value = data.codeUnits; // Convert string to UTF-8 bytes
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
        value: value);
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

  void writeToBluetoothLong(String data) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceId,
      characteristicId: charIdLong,
      deviceId: devId,
    );
    final value = data.codeUnits; // Convert string to UTF-8 bytes
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
        value: value);
  }

  void writeToBluetoothLat(String data) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceId,
      characteristicId: charIdLat,
      deviceId: devId,
    );
    final value = data.codeUnits; // Convert string to UTF-8 bytes
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
        value: value);
  }
}
