import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/location_provider.dart';

class SelectTripScreen extends StatefulWidget {
  const SelectTripScreen({Key? key}) : super(key: key);

  @override
  State<SelectTripScreen> createState() => _SelectTripScreenState();
}

class _SelectTripScreenState extends State<SelectTripScreen> {
  List<Map<String, dynamic>> selectedCards = [];

  void addToTrip(Map<String, dynamic> card) {
    setState(() {
      selectedCards.add(card);
    });
  }

  void removeFromTrip(Map<String, dynamic> card) {
    setState(() {
      selectedCards.remove(card);
    });
  }

  void orderTrip() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.currentTrip = selectedCards;
    Navigator.pushReplacementNamed(context, '/order-trip');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Center(
          child: Text(
            "Select Pins to Add to Trip",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var pin in userProvider.userPins)
                  SelectableTripCard(
                    title: pin['locationName'],
                    subtitle: calculateDistance(
                      locationProvider.currentLocation,
                      pin['location'].longitude.toDouble(),
                      pin['location'].latitude.toDouble(),
                    ),
                    childText: pin['description'],
                    onSelectedChanged: (isSelected) {
                      if (isSelected) {
                        addToTrip(pin);
                      } else {
                        removeFromTrip(pin);
                      }
                    },
                  ),
                const SizedBox(height: 16), // Adjust the height as desired
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: orderTrip,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Order Trip'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class SelectableTripCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String childText;
  final Function(bool isSelected) onSelectedChanged;

  const SelectableTripCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.childText,
    required this.onSelectedChanged,
  }) : super(key: key);

  @override
  _SelectableTripCardState createState() => _SelectableTripCardState();
}

class _SelectableTripCardState extends State<SelectableTripCard> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.childText),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Transform.scale(
                scale: 1.5,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      isSelected = value ?? false;
                      widget.onSelectedChanged(isSelected);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
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
