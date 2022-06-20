class ResponseModel {
  int? status;
  String? text;
  String? data;

  ResponseModel({this.status, this.text, this.data});

  ResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    text = json['text'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['text'] = this.text;
    data['data'] = this.data;
    return data;
  }
}
