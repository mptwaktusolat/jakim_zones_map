/// Properties data for malaysia.district-jakim.geojson
class DistrictJakimProperties {
  late String name;
  late int codeState;
  late String state;
  String? jakimCode;

  DistrictJakimProperties(
      {required this.name,
      required this.codeState,
      required this.state,
      this.jakimCode});

  DistrictJakimProperties.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    codeState = json['code_state'];
    state = json['state'];
    jakimCode = json['jakim_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code_state'] = codeState;
    data['state'] = state;
    data['jakim_code'] = jakimCode;
    return data;
  }

  @override
  String toString() {
    return 'DistrictJakimProperties{name: $name, codeState: $codeState, state: $state, jakimCode: $jakimCode}';
  }
}
