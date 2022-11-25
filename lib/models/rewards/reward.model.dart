class Reward {
  num? total;
  num? vested;
  num? unvested;
  num? listeningTime;

  Reward({this.total, this.vested, this.unvested, this.listeningTime});

  Reward.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    vested = json['vested'];
    unvested = json['unvested'];
    listeningTime = json['listeningTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['vested'] = vested;
    data['unvested'] = unvested;
    data['listeningTime'] = listeningTime;
    return data;
  }
}
