class LiveSessionChat {
  late int id;
  late String name;
  late int roomType;
  late int superAdmin;

  LiveSessionChat({
    required this.id,
    required this.name,
    required this.roomType,
    required this.superAdmin,
  });

  LiveSessionChat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    roomType = json['roomType'];
    superAdmin = json['superAdmin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['roomType'] = roomType;
    data['superAdmin'] = superAdmin;
    return data;
  }
}
