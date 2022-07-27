class SocialUser {
  String? userName;
  int? userId;
  String? description;
  String? image;
  String? name;
  bool? verified;
  bool? ambassador;
  bool? artist;

  SocialUser(
      {this.userName,
      this.description,
        this.image,
        this.name,
        this.userId,
      this.verified,
      this.ambassador,
      this.artist});

  SocialUser.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userId = json['userId'];
    description = json['description'];
    image = json['image'];
    name = json['name'];
    verified = json['verified'] ?? false;
    ambassador = json['ambassador'] ?? false;
    artist = json['artist'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['description'] = description;
    data['image'] = image;
    data['name'] = name;
    data['userId'] = userId;
    data['verified'] = verified;
    data['ambassador'] = ambassador;
    data['artist'] = artist;
    return data;
  }
}
