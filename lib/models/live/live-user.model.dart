class LiveUser {
  late String userName;

  LiveUser({required this.userName});

  LiveUser.fromJson(Map<String, dynamic> json) {
    userName = json["userName"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    return data;
  }
}
