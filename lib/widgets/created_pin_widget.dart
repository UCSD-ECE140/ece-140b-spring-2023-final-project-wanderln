import 'package:flutter/material.dart';
import '../color_schemes.g.dart';

class CreatedPinCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String childText;
  final String docId;
  final bool displayPostBtn;
  const CreatedPinCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.childText,
    required this.displayPostBtn,
    required this.docId,
  }) : super(key: key);

  @override
  _CreatedPinCardState createState() => _CreatedPinCardState();
}

class _CreatedPinCardState extends State<CreatedPinCard> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                if (widget
                    .displayPostBtn) // Only show the Go button when displayGo is true
                  ElevatedButton(
                    onPressed: () {
                      // Perform the desired action when the "Go" button is pressed
                    },
                    child: const Text('Post'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
