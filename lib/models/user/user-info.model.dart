class UserInfoData {
  String? userName;
  String? email;
  bool? verified;
  List<String>? addresses;
  num? rewards;
  int? referrer;
  bool? ambassador;
  Map<String, dynamic>? userBadge;
  bool? artist;

  UserInfoData(
      {this.userName,
      this.email,
      this.verified,
      this.addresses,
      this.rewards,
      this.referrer,
      this.ambassador,
      this.userBadge,
      this.artist});

  UserInfoData.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    email = json['email'];
    verified = json['verified'];
    addresses = json['addresses'].cast<String>();
    rewards = json['rewards'];
    referrer = json['referrer'];
    ambassador = json['ambassador'];
    userBadge = json['userBadge']['userBadge'];
    artist = json['artist'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['email'] = email;
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
