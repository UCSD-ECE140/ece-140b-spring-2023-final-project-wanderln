import 'package:flutter/material.dart';
import '../widgets/card_widget.dart';
import 'package:geolocator/geolocator.dart';


class PinsScreen extends StatelessWidget {
  const PinsScreen({Key? key}) : super(key: key);
  void _openModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String locationName = '';
        String description = '';

        return AlertDialog(
          title: Text('Add Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  onChanged: (value) {
                    locationName = value;
                  },
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: TextField(
                  onChanged: (value) {
                    description = value;
                  },
                  maxLength: 150,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Perform any validation or processing here
                // Once done, you can close the modal
                Navigator.pushReplacementNamed(context, '/pins');
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                // Close the modal without saving any data
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Center(
          child: Text(
            'Created Pins',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: const Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openModal(context),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
