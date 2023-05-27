class ZonesDataModel {
  late String zone;
  late String negeri;
  late String lokasi;
  late double lat;
  late double lang;
  late String stateIso;

  ZonesDataModel(
      {required this.zone,
      required this.negeri,
      required this.lokasi,
      required this.lat,
      required this.lang,
      required this.stateIso});

  ZonesDataModel.fromJson(Map<String, dynamic> json) {
    zone = json["zone"];
    negeri = json["negeri"];
    lokasi = json["lokasi"];
    lat = json["lat"];
    lang = json["lang"];
    stateIso = json["state_iso"];
  }

  static List<ZonesDataModel> fromList(List<dynamic> list) {
    return list.map((map) => ZonesDataModel.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["zone"] = zone;
    data["negeri"] = negeri;
    data["lokasi"] = lokasi;
    data["lat"] = lat;
    data["lang"] = lang;
    data["state_iso"] = stateIso;
    return data;
  }
}
