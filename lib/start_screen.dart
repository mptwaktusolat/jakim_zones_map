import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geojson/geojson.dart';

import 'map_view.dart';
import 'util/network_fetcher.dart';

/// Fetch all data required before return the main view (which is the map)
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String textStatus = 'Waktu Solat Zones visualization tool';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(textStatus, textAlign: TextAlign.center),
            const SizedBox(height: 16.0),
            ElevatedButton(
                onPressed: () async {
                  GeoJsonParser geojson = GeoJsonParser();
                  final geo = GeoJson();
                  setState(() => textStatus = 'Fetching Azanpro zones...');
                  var azp = await NetworkFetcher.fetchAzanproZones();
                  setState(() => textStatus = 'Fetching Jakim zones...');
                  var jakim = await NetworkFetcher.fetchJakimZones();
                  setState(() => textStatus = 'Fetching geoJson...');
                  var res = await NetworkFetcher.fetchMalaysiaDistrictGeojson();
                  geojson.parseGeoJsonAsString(res);
                  if (kIsWeb) {
                    await geo.parseInMainThread(res.toString(), verbose: true);
                  } else {
                    await geo.parse(res.toString());
                  }
                  setState(() => textStatus = 'Completed. Starting...');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MapView(
                        geo: geo,
                        myGeoJson: geojson,
                        azanProZones: azp,
                        jakimZones: jakim,
                      ),
                    ),
                  );
                },
                child: const Text('Start'))
          ],
        ),
      ),
    );
  }
}
