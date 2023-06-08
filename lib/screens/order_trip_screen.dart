import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';

class OrderTripScreen extends StatelessWidget {
  const OrderTripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void createTrip() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print("currentTrip: ${userProvider.currentTrip}");
      List<String> pinIds = userProvider.currentTrip
          .map((data) => data['documentId'] as String)
          .toList();

      final firstPin = userProvider.currentTrip.first;
      final location = firstPin['location'] as GeoPoint;

      print("current trip: ${userProvider.currentTrip}");
      print("trip name: ${userProvider.tripName}");
      print("trip desc: ${userProvider.tripDescription}");
      print("trip location: ${location}");
      userProvider.createTrip(pinIds, location);
      Navigator.pushReplacementNamed(context, '/pins');
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // final List<Map<String, dynamic>> allPins = userProvider.currentTrip;
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Center(
          child: Text(
            "Hold to Drag & Order Pins",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: userProvider.currentTrip.length,
        itemBuilder: (BuildContext context, int index) {
          final pin = userProvider.currentTrip[index];
          return DraggableTripCard(
            key: ValueKey(
                index), // Use ValueKey with the index as the identifier
            index: index,
            title: pin['locationName'],
            subtitle: calculateDistance(
              locationProvider.currentLocation,
              pin['location'].longitude.toDouble(),
              pin['location'].latitude.toDouble(),
            ),
            childText: pin['description'],
          );
        },
        onReorder: (int oldIndex, int newIndex) {
          _reorderPins(userProvider.currentTrip, oldIndex, newIndex);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createTrip,
        icon: const Icon(Icons.check),
        label: const Text('Done'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _reorderPins(
      List<Map<String, dynamic>> pins, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final pin = pins.removeAt(oldIndex);
    pins.insert(newIndex, pin);

    // Adjust the index of the pinned item
    if (newIndex < oldIndex) {
      pin['index'] = newIndex;
      for (int i = newIndex + 1; i <= oldIndex; i++) {
        pins[i]['index'] = i;
      }
    } else {
      pin['index'] = newIndex;
      for (int i = oldIndex; i < newIndex; i++) {
        pins[i]['index'] = i + 1;
      }
    }
  }
}

class DraggableTripCard extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final String childText;

  const DraggableTripCard({
    Key? key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.childText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key, // Use the provided key
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(childText),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

String calculateDistance(
    Position positionA, double longitude, double latitude) {
  final double startLatitude = positionA.latitude;
  final double startLongitude = positionA.longitude;

  final double distanceInMeters = Geolocator.distanceBetween(
    startLatitude,
    startLongitude,
    latitude,
    longitude,
  );

  final double distanceInMiles = distanceInMeters * 0.000621371;
  return '${distanceInMiles.toStringAsFixed(4)} Miles Away';
}
