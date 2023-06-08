import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String childText;
  // final bool isChecked;

  const TripCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.childText,
  }) : super(key: key);

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
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(childText),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
