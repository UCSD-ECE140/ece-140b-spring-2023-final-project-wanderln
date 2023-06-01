import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../color_schemes.g.dart';


class PlacesCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String childText;

  const PlacesCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.childText,
  }) : super(key: key);

  @override
  _PlacesCardState createState() => _PlacesCardState();
}

class _PlacesCardState extends State<PlacesCard> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {

    final ButtonStyle goButtonStyle = ElevatedButton.styleFrom(
      primary: Colors.lightGreen, // Set the light green color
      padding: const EdgeInsets.all(12.0), // Adjust the padding as desired
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30.0)), // Make it more circular
      ),
    );


    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(widget.childText),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  splashColor: Colors.red,
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? lightColorScheme.primary : null,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Perform the desired action when the "Go" button is pressed
                  },
                  child: Text('Go'),

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
