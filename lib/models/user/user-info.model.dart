class UserInfo {
  String? userName;
  String? email;
  bool? verified;
  List<String>? addresses;
  int? rewards;
  int? referrer;
  bool? ambassador;
  int? userBadge;
  bool? artist;

  UserInfo(
      {this.userName,
      this.email,
      this.verified,
      this.addresses,
      this.rewards,
      this.referrer,
      this.ambassador,
      this.userBadge,
      this.artist});

  UserInfo.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    email = json['email'];
    verified = json['verified'];
    addresses = json['addresses'].cast<String>();
    rewards = json['rewards'];
    referrer = json['referrer'];
    ambassador = json['ambassador'];
    userBadge = json['userBadge'];
    artist = json['artist'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['email'] = this.email;
    data['verified'] = this.verified;
    data['addresses'] = this.addresses;
    data['rewards'] = this.rewards;
    data['referrer'] = this.referrer;
    data['ambassador'] = this.ambassador;
    data['userBadge'] = this.userBadge;
    data['artist'] = this.artist;
    return data;
  }
}
