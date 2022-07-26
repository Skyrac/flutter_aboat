class UserInfoData {
  String? userName;
  int? userId;
  String? email;
  bool? verified;
  List<String>? addresses;
  int? rewards;
  int? referrer;
  bool? ambassador;
  int? userBadge;
  bool? artist;

  UserInfoData(
      {this.userName,
      this.email,
        this.userId,
      this.verified,
      this.addresses,
      this.rewards,
      this.referrer,
      this.ambassador,
      this.userBadge,
      this.artist});

  UserInfoData.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userId = json['userId'];
    email = json['email'];
    verified = json['verified'] ?? false;
    if(json['addresses']) {
      addresses = json['addresses'].cast<String>();
    }
    rewards = json['rewards'] ?? 0;
    referrer = json['referrer'] ?? 0;
    ambassador = json['ambassador'] ?? false;
    userBadge = json['userBadge'];
    artist = json['artist'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['email'] = email;
    data['userId'] = userId;
    data['verified'] = verified;
    data['addresses'] = addresses;
    data['rewards'] = rewards;
    data['referrer'] = referrer;
    data['ambassador'] = ambassador;
    data['userBadge'] = userBadge;
    data['artist'] = artist;
    return data;
  }
}
