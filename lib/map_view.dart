import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geojson/geojson.dart';
import 'model/district_jakim_properties.dart';
import 'model/zones_data_model.dart';
import 'util/network_fetcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

enum PlaceData { azanPro, jakim }

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  List<ZonesDataModel>? _locationDatas;
  late Future<List<dynamic>> _zonesData;
  LatLng? _lastTap;
  DistrictJakimProperties? _selectedDistrict;

  PlaceData _placeData = PlaceData.azanPro;
  double _zoomValue = 6.5;

  GeoJsonParser myGeoJson = GeoJsonParser();
  final geo = GeoJson();

  bool showPrayerZonesPill = false;

  @override
  void initState() {
    super.initState();
    // jakimZones = NetworkFetcher.fetchJakimZones();
    // azanProZones = NetworkFetcher.fetchAzanproZones();
    _zonesData = _getZonesData();
  }

  Future<List<dynamic>> _getZonesData() async => Future.wait([
        NetworkFetcher.fetchAzanproZones(),
        NetworkFetcher.fetchJakimZones(),
        _parseGeoJsonData()
      ]);

  Color _getBgColor(String input) {
    // generate random colour for each state
    Random random = Random(input.hashCode);
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  Future<void> _parseGeoJsonData() async {
    var res = await NetworkFetcher.fetchMalaysiaDistrictGeojson();
    myGeoJson.parseGeoJsonAsString(res);
    if (kIsWeb) {
      await geo.parseInMainThread(res.toString(), verbose: true);
    } else {
      await geo.parse(res.toString());
    }
  }

  Color getContrastingTextColor(Color color) {
    double darkness = 1 -
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return darkness < 0.5 ? Colors.black : Colors.white;
  }

  DistrictJakimProperties? _getPlaceInfo(LatLng point) {
    // Not working on the web
    for (var mps in geo.features) {
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
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _zonesData,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          // var geoJsonString = snapshot.data![2];
          // var geoData = geo.features;
          // if (geo.features.isEmpty) geo.parse(geoJsonString);
          // if (myGeoJson.polygons.isEmpty) myGeoJson.parseGeoJson(geoJsonString);
          _locationDatas ??= snapshot.data![_placeData.index];
          return FlutterMap(
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
                  top: 10,
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
                        _mapController.move(
                            _mapController.center, newZoomValue);
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
                                _locationDatas =
                                    snapshot.data![_placeData.index];
                              });
                            } else {
                              setState(() {
                                _placeData = PlaceData.azanPro;
                                _locationDatas =
                                    snapshot.data![_placeData.index];
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
                    "${_locationDatas!.length} locations",
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
              PolygonLayer(polygons: myGeoJson.polygons),
              PolylineLayer(polylines: myGeoJson.polylines),
              if (showPrayerZonesPill)
                MarkerLayer(
                  markers: [
                    for (var loc in _locationDatas!)
                      Marker(
                        point: LatLng(loc.lat, loc.lang),
                        width: 80,
                        height: 80,
                        builder: (context) {
                          return Chip(
                            backgroundColor:
                                _getBgColor(loc.zone.substring(0, 3)),
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
              ])
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
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
