import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final flutterReactiveBle = FlutterReactiveBle();
  final serviceId = Uuid.parse(
      '4fafc201-1fb5-459e-8fcc-c5c9c331914b'); // Convert service ID string to Uuid
  final charId = Uuid.parse(
      'beb5483e-36e1-4688-b7f5-ea07361b26a8'); // Convert service ID string to Uuid
  final devId = '94:3C:C6:97:56:FE'; // Convert service ID string to Uuid
  bool isConnected = false;
  String displayName = '';
  bool isDisplayNameTaken = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    flutterReactiveBle
        .connectToDevice(
      id: devId,
      servicesWithCharacteristicsToDiscover: {
        serviceId: [serviceId]
      },
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionState) {
      print(connectionState.deviceId);
      setState(() {
        isConnected = connectionState == DeviceConnectionState.connected;
      });
      // Handle connection state updates
    }, onError: (Object error) {
      // Handle a possible error
      print(error.toString());
    });

    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId, characteristicId: charId, deviceId: devId);
    final value = 'hello world'.codeUnits; // Convert string to UTF-8 bytes
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
        value: value);
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
    final user = FirebaseAuth.instance.currentUser;
    user?.delete().then((_) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }).catchError((error) {
      // Handle delete account error
      print('Delete account error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Form is valid, perform further actions
                          String displayName = _displayNameController.text;
                          // TODO: Use the display name as needed
                        }
                      },
                      icon: const Icon(Icons.check),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a display name to comment.';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      isConnected
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
