import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/bluetooth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayName = '';

  bool isDisplayNameTaken = true;
  String? _displayNameError;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print("displayname: ${userProvider.displayName}");
    displayName = userProvider.displayName;
    _displayNameError =
        displayName == '' ? 'Enter a valid display name to comment.' : '';
    _displayNameController = TextEditingController(text: displayName);
    super.initState();
  }

  void _signOut() {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }).catchError((error) {
      // Handle sign-out error
      print('Sign-out error: $error');
    });
  }

  void _deleteAccount() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    user?.delete().then((_) {
      userProvider.deleteAccount();
      Navigator.pushReplacementNamed(context, '/welcome');
    }).catchError((error) {
      // Handle delete account error
      print('Delete account error: $error');
    });
  }

  void _validateDisplayName(String? value) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (value == null || value.isEmpty) {
      setState(() {
        _displayNameError = 'Please enter a display name.';
      });
      return;
    }

    if (value.length < 3) {
      setState(() {
        _displayNameError = 'Please enter a name with more than 3 characters.';
      });
      return;
    }

    bool isAvailable = await userProvider.displayNameAvailable(value);
    print('checking $value');
    if (isAvailable) {
      setState(() {
        _displayNameError = 'Display name saved.';
      });
      userProvider.saveDisplayName(value);
    } else {
      setState(() {
        _displayNameError = 'Display name not available.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          print("checking $displayName");
                          _validateDisplayName(displayName);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0, // Remove the button elevation
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Make the button rounder
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                    errorText: _displayNameError,
                    errorStyle: const TextStyle(color: Colors.red),
                    helperText: _displayNameError == 'Display name available.'
                        ? 'Display name not available.'
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      displayName = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: bluetoothProvider.isConnected
                      ? Colors.green[100]
                      : Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      bluetoothProvider.isConnected
                          ? 'WanderIn Band Connected'
                          : 'WanderIn Band Not Connected',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signOut,
                  child: const Text('Sign Out'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _deleteAccount,
                  child: const Text('Delete Account'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
