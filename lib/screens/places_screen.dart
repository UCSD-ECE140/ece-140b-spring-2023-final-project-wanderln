import 'package:flutter/material.dart';
import '../widgets/card_widget.dart';
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PlacesCard(
                    title: 'Pin Card 1',
                    subtitle: 'Pin Subtitle 1',
                    childText: 'Pin Child Text 1',
                    displayGo: true,
                  ),
                  SizedBox(height: 16),
                  PlacesCard(
                    title: 'Pin Card 2',
                    subtitle: 'Pin Subtitle 2',
                    childText: 'Pin Child Text 2',
                    displayGo: true,
                  ),
                  SizedBox(height: 16),
                  PlacesCard(
                    title: 'Pin Card 3',
                    subtitle: 'Pin Subtitle 3',
                    childText: 'Pin Child Text 3',
                    displayGo: true,
                  ),
                  // Add more PlacesCard widgets here if needed
                ],
              ),
            ),
          ),
          // Trips Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PlacesCard(
                    title: 'Trip Card 1',
                    subtitle: 'Trip Subtitle 1',
                    childText: 'Trip Child Text 1',
                    displayGo: true,
                  ),
                  SizedBox(height: 16),
                  PlacesCard(
                    title: 'Trip Card 2',
                    subtitle: 'Trip Subtitle 2',
                    childText: 'Trip Child Text 2',
                    displayGo: true,
                  ),
                  SizedBox(height: 16),
                  PlacesCard(
                    title: 'Trip Card 3',
                    subtitle: 'Trip Subtitle 3',
                    childText: 'Trip Child Text 3',
                    displayGo: true,
                  ),
                  // Add more PlacesCard widgets here if needed
                ],
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
