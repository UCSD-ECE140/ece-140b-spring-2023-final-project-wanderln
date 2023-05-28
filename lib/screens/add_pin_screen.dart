import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../secrets.dart';
import 'package:geolocator/geolocator.dart';

class AddPinScreen extends StatefulWidget {
  const AddPinScreen({Key? key}) : super(key: key);

  @override
  State<AddPinScreen> createState() => AddPinScreenState();
}

class AddPinScreenState extends State<AddPinScreen> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  final Completer<GoogleMapController> _controller = Completer();
  Position? _position;
  LatLng? _sourceLocation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Center(
          child: Text(
            "Pin a Location",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Position>(
        future: _determinePosition(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for the future to complete
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if the future throws an error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // The future has completed successfully
            _position = snapshot.data;
            _sourceLocation = LatLng(_position!.latitude, _position!.longitude);
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _sourceLocation ?? const LatLng(0, 0),
                zoom: 17,
              ),
              markers: {
                const Marker(
                  markerId: MarkerId("source"),
                  position: LatLng(0, 0),
                ),
              },
            );
          }
        },
      ),
    );
  }
}
