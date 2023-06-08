import 'package:flutter/material.dart';
import '../color_schemes.g.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/bluetooth_provider.dart';

class NearbyPinCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String childText;
  final String docId;
  final bool isTrip;
  final double latitude;
  final double longitude;
  const NearbyPinCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.childText,
    required this.docId,
    required this.isTrip,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _NearbyPinCardState createState() => _NearbyPinCardState();
}

class _NearbyPinCardState extends State<NearbyPinCard> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void sendData(String docId, String tripName, double latitude,
      double longitude, String title, String childText) {
    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);
    String metaString =
        '{\'post_id\': "$docId", \'trip_name\': "$tripName",\'latitude\': "${latitude.toString()}",\'longitude\': "${longitude.toString()}"}';
    String contentString =
        '{\'post_id\': "$docId", \'post_title\': "$title",\'description\': "$childText"}';
    // bluetoothProvider.startScan();
    // bluetoothProvider.writeToBluetoothMeta(metaString);
    // bluetoothProvider.writeToBluetooth(contentString);

    print("sent: $metaString and $contentString");
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
                ElevatedButton(
                  onPressed: () {
                    sendData(
                        widget.docId,
                        widget.isTrip ? widget.title : "null",
                        widget.latitude,
                        widget.longitude,
                        widget.title,
                        widget.childText);
                  },
                  child: const Text('Go'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
