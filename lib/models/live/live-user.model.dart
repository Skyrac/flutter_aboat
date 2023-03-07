class LiveUser {
  late int userId;
  late String userName;

  LiveUser({required this.userId, required this.userName});

  LiveUser.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['userName'] = userName;
    return data;
  }
}
