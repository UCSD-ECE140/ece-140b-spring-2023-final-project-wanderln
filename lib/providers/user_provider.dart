import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  // User Data handlers --------------------------------------------------------

  User? _user;
  User? get user => _user;
  String displayName = '';

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
}
