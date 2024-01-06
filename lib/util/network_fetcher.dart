import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../model/zones_data_model.dart';

class NetworkFetcher {
  static Future<List<ZonesDataModel>> fetchJakimZones() async {
    var uri = Uri.parse(
        'https://github.com/mptwaktusolat/mpt-server/raw/53aaa43ddd95d2498db2dc7b9faeac110912450e/json/zoneStatesData/jakimZones.json');

    var res = await _fetchJsonFromInternet(uri);
    return ZonesDataModel.fromList(res);
  }

  static Future<List<ZonesDataModel>> fetchAzanproZones() async {
    var uri = Uri.parse(
        'https://github.com/mptwaktusolat/mpt-server/raw/53aaa43ddd95d2498db2dc7b9faeac110912450e/json/zoneStatesData/azanProZones.json');

    var res = await _fetchJsonFromInternet(uri);
    return ZonesDataModel.fromList(res);
  }

  static Future<String> fetchMalaysiaDistrictGeojson() async {
    // Originally from https://github.com/nullifye/malaysia.geojson
    var uri = Uri.parse(
        'https://github.com/mptwaktusolat/jakim.geojson/raw/master/malaysia.district-jakim.geojson');

    return await _fetchRawFromInternet(uri);
  }

  static Future<String> getWaktuSolatApiFromGps(LatLng latLng) async {
    var uri = Uri.https('api.waktusolat.app', '/api/zones/gps', {
      'lat': latLng.latitude.toString(),
      'long': latLng.longitude.toString()
    });

    var res = await _fetchRawFromInternet(uri);
    var resDecoded = jsonDecode(res);
    return resDecoded['zone'];
  }

  static Future<String> _fetchRawFromInternet(Uri uri) async {
    var res = await http.get(uri);

    if (res.statusCode == 200) {
      return res.body;
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  static Future<dynamic> _fetchJsonFromInternet(Uri uri) async {
    var res = await http.get(uri);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}
