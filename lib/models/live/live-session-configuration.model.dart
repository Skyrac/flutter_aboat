class LiveSessionConfiguration {
  late String roomName;
  late String? password;
  late bool onlyClubhouse;
  late bool onlySuperhostCanRemoveHost;
  late bool onlySuperhostCanAddHost;

  LiveSessionConfiguration(
      {required this.roomName,
      this.password,
      required this.onlyClubhouse,
      required this.onlySuperhostCanRemoveHost,
      required this.onlySuperhostCanAddHost});

  LiveSessionConfiguration.fromJson(Map<String, dynamic> json) {
    roomName = json['roomName'];
    password = json['password'];
    onlyClubhouse = json['onlyClubhouse'];
    onlySuperhostCanRemoveHost = json['onlySuperhostCanRemoveHost'];
    onlySuperhostCanAddHost = json['onlySuperhostCanAddHost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['roomName'] = roomName;
    data['password'] = password;
    data['onlyClubhouse'] = onlyClubhouse;
    data['onlySuperhostCanRemoveHost'] = onlySuperhostCanRemoveHost;
    data['onlySuperhostCanAddHost'] = onlySuperhostCanAddHost;
    return data;
  }
}
