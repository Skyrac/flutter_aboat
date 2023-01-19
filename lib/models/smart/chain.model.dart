class Chain {
  int? chainId;
  String? chainName;
  String? rpcUrl;
  String? explorer;
  String? coin;

  Chain({this.chainId, this.chainName, this.rpcUrl, this.explorer, this.coin});

  Chain.fromJson(Map<String, dynamic> json) {
    chainId = json['chainId'];
    chainName = json['chainName'];
    rpcUrl = json['rpcUrl'];
    explorer = json['explorer'];
    coin = json['coin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chainId'] = chainId;
    data['chainName'] = chainName;
    data['rpcUrl'] = rpcUrl;
    data['explorer'] = explorer;
    data['coin'] = coin;
    return data;
  }
}
