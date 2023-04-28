import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jakim_zones_map/locations/location_coordinate.dart';
import 'package:latlong2/latlong.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Color _getBgColor(String input) {
    Random random = Random(input.hashCode);
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
    ];
    int index = random.nextInt(colors.length);
    return colors[index];
  }

  Color getContrastingTextColor(Color color) {
    double darkness = 1 -
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return darkness < 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        // center: LatLng(3.1476, 101.6962),
        zoom: 9.5,
      ),
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: null,
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            for (var loc in LocationCoordinate.azanProZones)
              Marker(
                point: LatLng(loc.lat!, loc.lng!),
                width: 80,
                height: 80,
                builder: (context) {
                  return Chip(
                    backgroundColor: _getBgColor(loc.zone.substring(0, 3)),
                    label: Text(
                      loc.zone,
                      style: TextStyle(
                        color: getContrastingTextColor(
                            _getBgColor(loc.zone.substring(0, 3))),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
