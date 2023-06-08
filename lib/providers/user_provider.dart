import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;
  String displayName = '';
  List<Map<String, dynamic>> allSavedPins = [];
  List<Map<String, dynamic>> nearbyPins = [];
  List<Map<String, dynamic>> nearbyTrips = [];
  List<Map<String, dynamic>> userPins = [];
  List<Map<String, dynamic>> userTrips = [];
  List<Map<String, dynamic>> currentTrip = [];

  String tripName = "";
  String tripDescription = "";

  void setUser(User? user) {
    _user = user;
  }

  Future<void> createUser() async {
    if (user != null) {
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final snapshot = await docUser.get();
      final data = snapshot.data();
      if (data != null && data['displayName'] != '') {
        return; // Abort user creation if displayName is not empty
      }
      final userData = {'displayName': displayName};
      await docUser.set(userData);
    }
  }

  Future<void> deleteAccount() async {
    if (user != null) {
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      await docUser.delete();
      await user!.delete();
    }
  }

  Future<bool> displayNameAvailable(String displayName) async {
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('displayName', isEqualTo: displayName)
          .limit(1)
          .get();
      return querySnapshot.docs.isEmpty;
    }
    return false;
  }

  Future<void> saveDisplayName(String displayName) async {
    if (user != null) {
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final userData = {'displayName': displayName};
      this.displayName = displayName;
      await docUser.update(userData);
    }
  }

  Future<void> setDisplayName() async {
    if (user != null) {
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final snapshot = await docUser.get();
      final data = snapshot.data();
      if (data != null) {
        displayName = data['displayName'];
      }
    }
    print("found name of $displayName");
  }

  Future<void> getUserPins() async {
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('pins')
          .where('uid', isEqualTo: user!.uid)
          .get();
      userPins = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'documentId': doc.id,
        };
      }).toList();
    }
  }

  Future<void> getUserTrips() async {
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('uid', isEqualTo: user!.uid)
          .get();
      userTrips = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final pins = List<String>.from(data['pins']);
        return {
          'description': data['description'] as String,
          'location': data['location'] as GeoPoint,
          'pins': pins,
          'tripName': data['tripName'] as String,
          'uid': data['uid'] as String,
        };
      }).toList();
    }
  }

  Future<void> createPin(
      String locationName, String description, Position location) async {
    if (user != null) {
      final pinData = {
        'description': description,
        'location': GeoPoint(location.latitude, location.longitude),
        'locationName': locationName,
        'uid': user!.uid,
        'hidden': true,
      };
      userPins.add(pinData);
      final docRef =
          await FirebaseFirestore.instance.collection('pins').add(pinData);
      final pinId = docRef.id;
      pinData['documentId'] = pinId;
      Position currentLocation = await Geolocator.getCurrentPosition();
      pinData['distance'] = calculateDistance(currentLocation.latitude,
          currentLocation.longitude, location.latitude, location.longitude);
      print(
          "${pinData["locationName"]} will be added with distance ${pinData["distance"]}");

      if ((pinData['distance'] as double) < 2) {
        nearbyPins.add(pinData);
      }
    }
  }

  Future<void> createTrip(List<String> pinIds, GeoPoint location) async {
    if (user != null) {
      final tripData = {
        'description': tripDescription,
        'location': location,
        'pins': pinIds,
        'tripName': tripName,
        'uid': user!.uid,
      };
      userTrips.add(tripData);
      final docRef =
          await FirebaseFirestore.instance.collection('trips').add(tripData);
      final tripId = docRef.id;
      tripData['documentId'] = tripId;
      Position currentLocation = await Geolocator.getCurrentPosition();
      tripData['distance'] = calculateDistance(currentLocation.latitude,
          currentLocation.longitude, location.latitude, location.longitude);
      if ((tripData['distance'] as double) < 2) {
        nearbyTrips.add(tripData);
      }
    }
  }

  Future<void> getNearbyPins(double latitude, double longitude) async {
    if (user != null) {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('pins').get();
      nearbyPins = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            final location = data['location'] as GeoPoint;
            final pinLongitude = location.longitude;
            final pinLatitude = location.latitude;
            final distance = calculateDistance(
                longitude, latitude, pinLongitude, pinLatitude);
            return {
              ...data,
              'documentId': doc.id,
              'distance': distance,
            };
          })
          .where((pin) => pin['distance'] <= 2)
          .toList();
    }
  }

  Future<void> getNearbyTrips(double latitude, double longitude) async {
    if (user != null) {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('trips').get();
      nearbyTrips = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            final location = data['location'] as GeoPoint;
            final tripLongitude = location.longitude;
            final tripLatitude = location.latitude;
            final distance = calculateDistance(
                longitude, latitude, tripLongitude, tripLatitude);
            return {
              ...data,
              'documentId': doc.id,
              'distance': distance,
            };
          })
          .where((trip) => trip['distance'] <= 2)
          .toList();
    }
  }
}

double calculateDistance(
    double longitudeA, double latitudeA, double longitudeB, double latitudeB) {
  final double distanceInMeters = Geolocator.distanceBetween(
    latitudeA,
    longitudeA,
    latitudeB,
    longitudeB,
  );
  final double distanceInMiles = distanceInMeters * 0.000621371;
  return distanceInMiles;
}
