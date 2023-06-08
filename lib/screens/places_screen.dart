import 'package:flutter/material.dart';
import 'package:wanderin_app/widgets/nearby_card_widget.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';
import 'package:geolocator/geolocator.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({Key? key}) : super(key: key);

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen>
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
            "Nearby Pins and Trips",
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
                    for (var pin in userProvider.nearbyPins)
                      NearbyPinCard(
                        title: pin['locationName'],
                        subtitle: "${calculateDistance(
                          locationProvider.currentLocation,
                          pin['location'].longitude.toDouble(),
                          pin['location'].latitude.toDouble(),
                        ).toStringAsFixed(4)} Miles Away",
                        childText: pin['description'],
                        docId: pin['documentId'].toString(),
                        isTrip: false,
                        latitude: pin['location'].latitude.toDouble(),
                        longitude: pin['location'].longitude.toDouble(),
                      ),
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
                      NearbyPinCard(
                        title: trip['tripName'],
                        subtitle: "${calculateDistance(
                          locationProvider.currentLocation,
                          trip['location'].longitude.toDouble(),
                          trip['location'].latitude.toDouble(),
                        ).toStringAsFixed(4)} Miles Away",
                        childText: trip['description'],
                        docId: trip['documentId'].toString(),
                        isTrip: true,
                        latitude: trip['location'].latitude.toDouble(),
                        longitude: trip['location'].longitude.toDouble(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
