import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:wanderin_app/screens/welcomescreen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'screens/screen_manager.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'color_schemes.g.dart';
import '../providers/location_provider.dart';
import 'screens/order_trip_screen.dart';
import 'screens/select_trip_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  User? user = FirebaseAuth.instance.currentUser;
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => UserProvider()..setUser(user),
      ),
      ChangeNotifierProvider(
        create: (_) => BluetoothProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => LocationProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  Future<void> initializeProviders(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);

    await locationProvider.determinePosition();
    bluetoothProvider.startLocationUpdates();
    await FirebaseAuth.instance
        .authStateChanges()
        .firstWhere((user) => user != null);
    final user = FirebaseAuth.instance.currentUser;
    await userProvider.createUser();
    await userProvider.setDisplayName();
    userProvider.getUserPins();
    userProvider.getUserTrips();

    await userProvider.getNearbyPins(locationProvider.currentLocation.latitude,
        locationProvider.currentLocation.longitude);
    await userProvider.getNearbyTrips(locationProvider.currentLocation.latitude,
        locationProvider.currentLocation.longitude);

    print("nearbyPins: ${userProvider.nearbyPins}");
    print("nearbyTrips: ${userProvider.nearbyTrips}");

    // String jsonString =
    //     "{\"post_id\": z9Nz6IB5CjjWMhp9oliz, \"post_title:\": Geisel Library,\"description\": The library at ucsd}";
    // String jsonString2 =
    //     "{\"post_id\": mQIT609kDE57xERnNPP6, \"post_title:\":  Biomedical Library,\"description\": The other library at ucsd}";

    // String jsonString =
    //     "{\"post_id\": 1, \"post_title:\": Geisel Library,\"description\": The library at ucsd}";
    // String jsonString2 =
    //     "{\"post_id\": 2, \"post_title:\":  Biomedical Library,\"description\": The other library at ucsd}";

    // String jsonString =
    //     '{\'post_id\': "1", \'trip_name\': "G",\'latitude\': "T",\'longitude\': "T"}';
    // String jsonString2 =
    //     '{\'post_id\': "2", \'post_title\': "B",\'description\': "T"}';
    // bluetoothProvider.startScan();
    // bluetoothProvider.writeToBluetoothMeta(jsonString);
    // bluetoothProvider.writeToBluetooth(jsonString2);
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      padding:
          MaterialStateProperty.all(const EdgeInsets.only(top: 3, left: 3)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
    final providers = [EmailAuthProvider()];
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return FutureBuilder(
      future: initializeProviders(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/images/pin.png',
                  height: 400,
                  width: 400,
                ),
              ));
        } else {
          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightColorScheme,
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
              textButtonTheme: TextButtonThemeData(style: buttonStyle),
              outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: userProvider.user == null ? '/welcome' : '/places',
            routes: {
              '/sign-in': (context) {
                return SignInScreen(
                  providers: providers,
                  actions: [
                    AuthStateChangeAction<SignedIn>((context, state) {
                      Navigator.pushReplacementNamed(context, '/places');
                    }),
                    AuthStateChangeAction<SigningUp>((context, state) async {
                      Navigator.pushReplacementNamed(context, '/places');
                    })
                  ],
                  styles: const {
                    EmailFormStyle(signInButtonVariant: ButtonVariant.filled),
                  },
                  headerBuilder: (context, constraints, shrinkOffset) {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SingleChildScrollView(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/pin.png',
                              height: 80,
                            ),
                            const Text(
                              "WanderIn",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 50),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  headerMaxExtent: 220,
                );
              },
              '/create-account': (context) {
                return RegisterScreen(
                  providers: providers,
                  actions: [
                    AuthStateChangeAction<SignedIn>((context, state) {
                      Navigator.pushReplacementNamed(context, '/places');
                    }),
                    AuthStateChangeAction<SigningUp>((context, state) async {
                      Navigator.pushReplacementNamed(context, '/places');
                    })
                  ],
                );
              },
              '/places': (context) {
                return const MainScreen(initialTab: TabItem.places);
              },
              '/pins': (context) {
                return const MainScreen(initialTab: TabItem.pins);
              },
              '/add': (context) {
                return const MainScreen(initialTab: TabItem.add);
              },
              '/saved': (context) {
                return const MainScreen(initialTab: TabItem.saved);
              },
              '/profile': (context) {
                return const MainScreen(initialTab: TabItem.profile);
              },
              '/welcome': (context) {
                return const WelcomePage();
              },
              '/order-trip': (context) {
                return const OrderTripScreen();
              },
              '/select-trip': (context) {
                return const SelectTripScreen();
              },
            },
          );
        }
      },
    );
  }
}
