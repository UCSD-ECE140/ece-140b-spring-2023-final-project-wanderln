import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';
import 'package:provider/provider.dart';

class AddPinScreen extends StatefulWidget {
  const AddPinScreen({Key? key}) : super(key: key);

  @override
  State<AddPinScreen> createState() => AddPinScreenState();
}

class AddPinScreenState extends State<AddPinScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Position? _position;
  LatLng? _sourceLocation;
  Set<Marker> _markers = {};

  // Define the initial markers
  Marker sourceMarker = const Marker(
    markerId: MarkerId('sourceMarker'),
    position: LatLng(0, 0),
  );

  @override
  void initState() {
    super.initState();
    setState(() {
      _markers = {
        sourceMarker,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    _position =
        Provider.of<LocationProvider>(context, listen: false).currentLocation;
    _sourceLocation = LatLng(_position!.latitude, _position!.longitude);
    _markers.add(
      Marker(
        markerId: const MarkerId('sourceMarker'),
        position: _sourceLocation ?? const LatLng(0, 0),
        infoWindow: const InfoWindow(title: 'Pinned Location'),
        draggable: true,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Center(
          child: Text(
            "Hold to Drag Pin",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _controller.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _sourceLocation ?? const LatLng(0, 0),
              zoom: 17,
            ),
            markers: _markers,
            zoomControlsEnabled: false,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _openModal,
              tooltip: "Add Location",
              child: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }

  void _openModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String locationName = '';
        String description = '';

        return AlertDialog(
          title: const Text('Add Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  onChanged: (value) {
                    locationName = value;
                  },
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: TextField(
                  onChanged: (value) {
                    description = value;
                  },
                  maxLength: 150,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Perform any validation or processing here
                // Once done, you can close the modal
                Navigator.pushReplacementNamed(context, '/pins');
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                // Close the modal without saving any data
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
