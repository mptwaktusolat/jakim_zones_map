import 'dart:convert';

import 'package:http/http.dart' as http;
import '../model/zones_data_model.dart';

class NetworkFetcher {
  static Future<List<ZonesDataModel>> fetchJakimZones() async {
    var uri = Uri.parse(
        'https://raw.githubusercontent.com/mptwaktusolat/mpt-server/main/json/zoneStatesData/jakimZones.json');

    var res = await _fetchJsonFromInternet(uri);
    return ZonesDataModel.fromList(res);
  }

  static Future<List<ZonesDataModel>> fetchAzanproZones() async {
    var uri = Uri.parse(
        'https://raw.githubusercontent.com/mptwaktusolat/mpt-server/main/json/zoneStatesData/azanProZones.json');

    var res = await _fetchJsonFromInternet(uri);
    return ZonesDataModel.fromList(res);
  }

  static Future<String> fetchMalaysiaDistrictGeojson() async {
    // Originally from https://github.com/nullifye/malaysia.geojson
    var uri = Uri.parse(
        'https://raw.githubusercontent.com/mptwaktusolat/malaysia.geojson/master/malaysia.district.geojson');

    return await _fetchRawFromInternet(uri);
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
