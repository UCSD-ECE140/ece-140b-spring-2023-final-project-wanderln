import 'package:flutter/material.dart';
import '../widgets/card_widget.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({Key? key}) : super(key: key);
  

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Center(
          child: Text(
            "Nearby Places",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlacesCard(
                title: 'Card 1',
                subtitle: 'Subtitle 1',
                childText: 'Child Text 1',
              ),
              SizedBox(height: 16), // Adjust the height as desired
              PlacesCard(
                title: 'Card 2',
                subtitle: 'Subtitle 2',
                childText: 'Child Text 2',
              ),
              SizedBox(height: 16), // Adjust the height as desired
              PlacesCard(
                title: 'Card 3',
                subtitle: 'Subtitle 3',
                childText: 'Child Text 3',
              ),
              // Add more PlacesCard widgets here if needed
            ],
          ),
        ),
      ),
    );
  }
}
