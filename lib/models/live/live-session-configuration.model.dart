class LiveSessionConfiguration {
  late String roomName;
  late String? password;
  late bool onlyClubhouse;
  late bool onlySuperhostCanRemoveHost;
  late bool onlySuperhostCanAddHost;

  LiveSessionConfiguration(
      { required this.roomName,
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomName'] = this.roomName;
    data['password'] = this.password;
    data['onlyClubhouse'] = this.onlyClubhouse;
    data['onlySuperhostCanRemoveHost'] = this.onlySuperhostCanRemoveHost;
    data['onlySuperhostCanAddHost'] = this.onlySuperhostCanAddHost;
    return data;
  }
}