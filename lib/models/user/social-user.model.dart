class SocialUser {
  String? userName;
  int? userId;
  String? email;
  bool? verified;
  bool? ambassador;
  bool? artist;

  SocialUser(
      {this.userName,
      this.email,
        this.userId,
      this.verified,
      this.ambassador,
      this.artist});

  SocialUser.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userId = json['userId'];
    email = json['email'];
    verified = json['verified'] ?? false;
    ambassador = json['ambassador'] ?? false;
    artist = json['artist'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['email'] = email;
    data['userId'] = userId;
    data['verified'] = verified;
    data['ambassador'] = ambassador;
    data['artist'] = artist;
    return data;
  }
}
