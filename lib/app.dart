import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jakim_zones_map/locations/location_coordinate.dart';
import 'package:latlong2/latlong.dart';

import 'locations/location_coordinate_model.dart';

enum PlaceData { azanPro, jakim }

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final MapController _mapController = MapController();
  late List<LocationCoordinateData> _locationDatas;

  PlaceData _placeData = PlaceData.azanPro;
  double _zoomValue = 6.5;

  @override
  void initState() {
    super.initState();
    _locationDatas = _placeData == PlaceData.azanPro
        ? LocationCoordinate.azanProZones
        : LocationCoordinate.jakimZones;
  }

  Color _getBgColor(String input) {
    // generate random colour for each state
    Random random = Random(input.hashCode);
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  Color getContrastingTextColor(Color color) {
    double darkness = 1 -
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return darkness < 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: LatLng(4.92, 108.23),
        zoom: _zoomValue,
        minZoom: 5,
        maxZoom: 15,
        onMapEvent: (MapEvent mapEvent) {
          if (mapEvent is MapEventScrollWheelZoom) {
            setState(() => _zoomValue = mapEvent.zoom);
          }
        },
      ),
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: null,
        ),
        Positioned(
          bottom: 20,
          right: 10,
          child: SizedBox(
            width: 275,
            child: Slider(
                label: "Zoom",
                value: _zoomValue,
                max: 15,
                min: 5,
                onChanged: (double newZoomValue) {
                  setState(() => _zoomValue = newZoomValue);
                  _mapController.move(_mapController.center, newZoomValue);
                }),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 10,
          child: ElevatedButton(
              onPressed: () {
                if (_placeData == PlaceData.azanPro) {
                  setState(() {
                    _placeData = PlaceData.jakim;
                    _locationDatas = LocationCoordinate.jakimZones;
                  });
                } else {
                  setState(() {
                    _placeData = PlaceData.azanPro;
                    _locationDatas = LocationCoordinate.azanProZones;
                  });
                }
              },
              child: Text(_placeData.name.toUpperCase())),
        ),
        Positioned(
            bottom: 20,
            left: 12,
            child: Text(
              "${_locationDatas.length} locations",
            ))
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            for (var loc in _locationDatas)
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
