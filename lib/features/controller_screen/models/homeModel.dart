class HomeModel {
  HomeModel({
    this.createdAt,
    this.entryId,
    this.field1,
    this.field2,
    this.field3,
    this.field4,
    this.field7,
    this.field8,
  });

  HomeModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    entryId = json['entry_id'];
    field1 = json['field1'];
    field2 = json['field2'];
    field3 = json['field3'];
    field4 = json['field4'];
    field7 = json['field7'];
    field8 = json['field8'];
  }
  String? createdAt;
  String? entryId;
  String? field1;
  String? field2;
  String? field3;
  String? field4;
  String? field7;
  String? field8;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['entry_id'] = entryId;
    data['field1'] = field1;
    data['field2'] = field2;
    data['field3'] = field3;
    data['field4'] = field4;
    data['field7'] = field7;
    data['field8'] = field8;
    return data;
  }
}
