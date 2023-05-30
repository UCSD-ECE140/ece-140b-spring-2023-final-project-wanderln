import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'add_pin_screen.dart';
import 'places_screen.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

enum TabItem { places, pins, saved, add, profile }

class MainScreen extends StatefulWidget {
  final TabItem initialTab; // Change the type to TabItem

  const MainScreen({Key? key, required this.initialTab}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TabItem _selectedTab = TabItem.places; // Change the type to TabItem

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab; // Set initial tab from the argument
  }

  Widget _buildSelectedTab() {
    switch (_selectedTab) {
      case TabItem.places:
        return PlacesScreen();
      case TabItem.pins:
        return const Text(
          'Pins',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
        );
      case TabItem.saved:
        return const Text(
          'Saved',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
        );
      case TabItem.add:
        return const AddPinScreen();
      case TabItem.profile:
        return ProfileScreen(
          actions: [
            SignedOutAction((context) {
              Navigator.pushReplacementNamed(context, '/sign-in');
            }),
            AuthStateChangeAction<SignedIn>((context, state) {
              Navigator.pushReplacementNamed(context, '/main');
            }),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _buildSelectedTab(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: LineIcons.alternateMapMarked,
                  text: 'Places',
                ),
                GButton(
                  icon: LineIcons.mapMarker,
                  text: 'Pins',
                ),
                GButton(
                  icon: LineIcons.plusCircle,
                  text: 'Add',
                ),
                GButton(
                  icon: LineIcons.heart,
                  text: 'Saved',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndexFromTab(),
              onTabChange: (index) {
                setState(() {
                  _selectedTab = _tabFromSelectedIndex(index);
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  int _selectedIndexFromTab() {
    switch (_selectedTab) {
      case TabItem.places:
        return 0;
      case TabItem.pins:
        return 1;
      case TabItem.add:
        return 2;
      case TabItem.saved:
        return 3;
      case TabItem.profile:
        return 4;
    }
  }

  TabItem _tabFromSelectedIndex(int index) {
    switch (index) {
      case 0:
        return TabItem.places;
      case 1:
        return TabItem.pins;
      case 2:
        return TabItem.add;
      case 3:
        return TabItem.saved;
      case 4:
        return TabItem.profile;
      default:
        return TabItem.places;
    }
  }
}
