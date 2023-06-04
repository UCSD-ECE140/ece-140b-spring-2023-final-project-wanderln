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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    print('initial user ID is: ${user.uid}');
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => UserProvider()..setUser(user),
      ),
      ChangeNotifierProvider(
        create: (_) => BluetoothProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                await FirebaseAuth.instance
                    .authStateChanges()
                    .firstWhere((user) => user != null);
                final user = FirebaseAuth.instance.currentUser;
                userProvider.setUser(user);
                userProvider.createUser();
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
                await FirebaseAuth.instance
                    .authStateChanges()
                    .firstWhere((user) => user != null);
                final user = FirebaseAuth.instance.currentUser;
                userProvider.setUser(user);
                userProvider.createUser();
                Navigator.pushReplacementNamed(context, '/places');
              })
            ],
          );
        },
        '/places': (context) {
          // final userProvider = UserProvider();
          userProvider.setDisplayName();
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
      },
    );
  }
}
