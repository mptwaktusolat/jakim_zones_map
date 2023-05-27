import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jakim_zones_map/model/zones_data_model.dart';

class NetworkFetcher {
  static Future<List<ZonesDataModel>> fetchJakimZones() async {
    var uri = Uri.parse(
        'https://raw.githubusercontent.com/mptwaktusolat/mpt-server/main/json/zoneStatesData/jakimZones.json');

    var res = await _fetchLocationJson(uri);
    return ZonesDataModel.fromList(res);
  }

  static Future<List<ZonesDataModel>> fetchAzanproZones() async {
    var uri = Uri.parse(
        'https://raw.githubusercontent.com/mptwaktusolat/mpt-server/main/json/zoneStatesData/azanProZones.json');

    var res = await _fetchLocationJson(uri);
    return ZonesDataModel.fromList(res);
  }

  static Future<dynamic> _fetchLocationJson(Uri uri) async {
    var res = await http.get(uri);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}
