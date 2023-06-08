import 'package:flutter/material.dart';
import '../widgets/created_pin_widget.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/user_provider.dart';
import '../providers/location_provider.dart';
import 'package:provider/provider.dart';

class PinsScreen extends StatefulWidget {
  const PinsScreen({Key? key}) : super(key: key);

  @override
  _PinsScreenState createState() => _PinsScreenState();
}

class _PinsScreenState extends State<PinsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void openModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        return AlertDialog(
          title: const Text('Create Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  onChanged: (value) {
                    userProvider.tripName = value;
                  },
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Trip Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: TextField(
                  onChanged: (value) {
                    userProvider.tripDescription = value;
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
                Navigator.pushReplacementNamed(context, '/select-trip');
              },
              child: const Text('Next'),
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    userProvider.getUserPins();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Center(
          child: Text(
            'Created Pins & Trips',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pins'),
            Tab(text: 'Trips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pins Tab
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var pin in userProvider.userPins)
                      CreatedPinCard(
                        title: pin['locationName'],
                        subtitle: "${calculateDistance(
                          locationProvider.currentLocation,
                          pin['location'].longitude.toDouble(),
                          pin['location'].latitude.toDouble(),
                        ).toStringAsFixed(4)} Miles Away",
                        childText: pin['description'],
                        displayPostBtn: calculateDistance(
                              locationProvider.currentLocation,
                              pin['location'].longitude.toDouble(),
                              pin['location'].latitude.toDouble(),
                            ) <
                            0.01,
                        docId: "djasfhadskf",
                      ),
                    const SizedBox(height: 16), // Adjust the height as desired
                  ],
                ),
              ),
            ),
          ),
          // Trips Tab
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var trip in userProvider.userTrips)
                      CreatedPinCard(
                        title: trip['tripName'],
                        subtitle: "${calculateDistance(
                          locationProvider.currentLocation,
                          trip['location'].longitude.toDouble(),
                          trip['location'].latitude.toDouble(),
                        ).toStringAsFixed(4)} Miles Away",
                        childText: trip['description'],
                        displayPostBtn: calculateDistance(
                              locationProvider.currentLocation,
                              trip['location'].longitude.toDouble(),
                              trip['location'].latitude.toDouble(),
                            ) <
                            0.01,
                        docId: "djasfhadskf",
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Trip'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

double calculateDistance(
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
  return distanceInMiles;
}
