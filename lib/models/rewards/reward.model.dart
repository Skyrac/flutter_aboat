class Reward {
  double? total;
  double? vested;
  double? unvested;
  double? listeningTime;

  Reward({this.total, this.vested, this.unvested, this.listeningTime});

  Reward.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    vested = json['vested'];
    unvested = json['unvested'];
    listeningTime = json['listeningTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['vested'] = this.vested;
    data['unvested'] = this.unvested;
    data['listeningTime'] = this.listeningTime;
    return data;
  }
}
