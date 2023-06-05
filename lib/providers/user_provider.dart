import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;
  String displayName = '';
  final GeoFlutterFire _geo = GeoFlutterFire();

  void setUser(User? user) {
    _user = user;
  }

  Future<void> createUser() async {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    final userData = {'displayName': ''};
    await docUser.set(userData);
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

  Future<List<Map<String, dynamic>>> getUserPins() async {
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('pins')
          .where('uid', isEqualTo: user!.uid)
          .get();

      final userPins = querySnapshot.docs.map((doc) => doc.data()).toList();
      return userPins;
    }
    return [];
  }

  Future<void> createPin(
      String locationName, String description, Position location) async {
    if (user != null) {
      final pinData = {
        'description': description,
        'location': GeoPoint(location.latitude, location.longitude),
        'locationName': locationName,
        'tripId': '',
        'uid': user!.uid,
      };

      await FirebaseFirestore.instance.collection('pins').add(pinData);
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyPins(Position location) async {
    if (user != null) {
      GeoFirePoint center = _geo.point(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      double radius = 2.0; // in miles
      String collection = 'pins';
      Stream<List<DocumentSnapshot>> stream = _geo
          .collection(
              collectionRef: FirebaseFirestore.instance.collection(collection))
          .within(
            center: center,
            radius: radius,
            field: 'location',
            strictMode: true,
          );

      List<DocumentSnapshot> documents = await stream.first;
      List<Map<String, dynamic>> nearbyPins = documents
          .map((doc) => doc.data() as Map<String, dynamic>?)
          .where((data) => data != null)
          .toList() as List<Map<String, dynamic>>;
      return nearbyPins;
    }

    return [];
  }
}
