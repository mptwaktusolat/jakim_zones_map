import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geojson/geojson.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/district_jakim_properties.dart';
import 'model/zones_data_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

enum PlaceData { azanPro, jakim }

class MapView extends StatefulWidget {
  const MapView(
      {super.key,
      required this.myGeoJson,
      required this.geo,
      required this.azanProZones,
      required this.jakimZones});

  final GeoJsonParser myGeoJson;
  final GeoJson geo;
  final List<ZonesDataModel> azanProZones;
  final List<ZonesDataModel> jakimZones;
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  late List<ZonesDataModel> _locationDatas;
  final GlobalKey<ScaffoldState> key = GlobalKey(); // Create a key

  LatLng? _lastTap;
  DistrictJakimProperties? _selectedDistrict;

  PlaceData _placeData = PlaceData.azanPro;
  double _zoomValue = 6.5;

  bool showPrayerZonesPill = false;

  var favMarkers = {
    "Rumah": LatLng(3.0670, 101.6369),
    "Rumah Nenek": LatLng(3.1832, 102.2777),
    "UIA Gombak": LatLng(3.247313, 101.739126),
  };

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

  DistrictJakimProperties? _getPlaceInfo(LatLng point) {
    // Not working on the web
    for (var mps in widget.geo.features) {
      List<mp.LatLng> points = [];
      // mps.geometry: GeoJsonMultiPolygon
      for (GeoJsonPolygon p in mps.geometry.polygons) {
        for (var gs in p.geoSeries) {
          for (var gp in gs.geoPoints) {
            points.add(mp.LatLng(gp.latitude, gp.longitude));
          }
        }
      }
      var res = mp.PolygonUtil.containsLocationAtLatLng(
          point.latitude, point.longitude, points, true);

      if (res) {
        var data = DistrictJakimProperties.fromJson(mps.properties!);
        debugPrint("tapped on $data");
        return data;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _locationDatas = widget.azanProZones;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: ElevatedButton(
          onPressed: () {
            key.currentState!.openDrawer();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black45,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
          ),
          child: const Icon(Icons.menu),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.amber,
              ),
              child: Text('Waktu Solat Zones visualization tool'),
            ),
            ListTile(
              title: const Text('GitHub'),
              onTap: () {
                launchUrl(
                    Uri.parse(
                        'https://github.com/mptwaktusolat/jakim_zones_map'),
                    mode: LaunchMode.externalApplication);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('MPT Server Locations'),
              onTap: () {
                launchUrl(Uri.parse('https://mpt-server.vercel.app/locations'),
                    mode: LaunchMode.externalApplication);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(4.92, 108.23),
          zoom: _zoomValue,
          minZoom: 5,
          maxZoom: 15,
          onTap: (_, point) {
            setState(() {
              _lastTap = point;
              _selectedDistrict = _getPlaceInfo(point);
            });
          },
          onMapEvent: (MapEvent mapEvent) {
            if (mapEvent is MapEventScrollWheelZoom) {
              setState(() => _zoomValue = mapEvent.zoom);
            }
          },
        ),
        nonRotatedChildren: [
          if (_lastTap != null)
            Positioned(
              right: 10,
              top: 30,
              child: SizedBox(
                  width: 250,
                  child: _MyCardInfo(
                    data: _selectedDistrict,
                    point: _lastTap,
                  )),
            ),
          Positioned(
            bottom: 60,
            right: 10,
            child: SizedBox(
                width: 275,
                child: SwitchListTile(
                  title: const Text('Prayer Zones'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: showPrayerZonesPill,
                  onChanged: (value) {
                    setState(() {
                      showPrayerZonesPill = value;
                    });
                  },
                )),
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
                onPressed: showPrayerZonesPill
                    ? () {
                        if (_placeData == PlaceData.azanPro) {
                          setState(() {
                            _placeData = PlaceData.jakim;
                            _locationDatas = widget.jakimZones;
                          });
                        } else {
                          setState(() {
                            _placeData = PlaceData.azanPro;
                            _locationDatas = widget.azanProZones;
                          });
                        }
                      }
                    : null,
                child: Text(_placeData.name.toUpperCase())),
          ),
          Positioned(
              bottom: 20,
              left: 12,
              child: Text(
                "${_locationDatas.length} locations",
              )),
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
          PolygonLayer(polygons: widget.myGeoJson.polygons),
          PolylineLayer(polylines: widget.myGeoJson.polylines),
          if (showPrayerZonesPill)
            MarkerLayer(
              markers: [
                for (var loc in _locationDatas)
                  Marker(
                    point: LatLng(loc.lat, loc.lang),
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
          MarkerLayer(markers: [
            if (_lastTap != null) _buildPointMarker(_lastTap!),
            ...favMarkers.values.map((e) => _buildFavMarker(e)).toList(),
          ])
        ],
      ),
    );
  }
}

Marker _buildPointMarker(LatLng point) {
  return Marker(
    point: point,
    width: 15,
    height: 15,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white,
              width: 4,
              strokeAlign: BorderSide.strokeAlignOutside),
        ),
      );
    },
  );
}

Marker _buildFavMarker(LatLng point) {
  return Marker(
    point: point,
    width: 15,
    height: 15,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.rectangle,
          border: Border.all(
              color: Colors.white,
              width: 4,
              strokeAlign: BorderSide.strokeAlignOutside),
        ),
      );
    },
  );
}

class _MyCardInfo extends StatelessWidget {
  const _MyCardInfo({Key? key, this.data, this.point}) : super(key: key);

  final DistrictJakimProperties? data;
  final LatLng? point;

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copied to clipboard"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            title: Text(
              point != null
                  ? "${point!.latitude.toStringAsFixed(4)}, ${point!.longitude.toStringAsFixed(4)}"
                  : "N/A",
            ),
            subtitle: const Text("Lat, Lang"),
            onTap: () {
              _copyToClipboard(context,
                  "${point!.latitude.toStringAsFixed(4)}, ${point!.longitude.toStringAsFixed(4)}");
            },
          ),
          ListTile(
            title: Text(data?.name ?? "N/A"),
            subtitle: const Text("Name"),
            onTap: () {
              _copyToClipboard(context, data?.name ?? "N/A");
            },
          ),
          ListTile(
            title: Text(
              data?.jakimCode ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Jakim Code"),
            onTap: () {
              _copyToClipboard(context, data?.jakimCode ?? "N/A");
            },
          ),
          ListTile(
            title: Text(
              "${data?.state ?? "N/A"} (${data?.codeState.toString() ?? "N/A"})",
            ),
            subtitle: const Text("State (code)"),
            onTap: () {
              _copyToClipboard(context,
                  "${data?.state ?? "N/A"} (${data?.codeState.toString() ?? "N/A"})");
            },
          ),
        ],
      ),
    );
  }
}
