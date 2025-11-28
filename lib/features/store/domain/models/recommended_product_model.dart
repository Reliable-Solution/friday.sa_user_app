import 'package:friday_sa/features/item/domain/models/item_model.dart';

class RecommendedItemModel {
  RecommendedItemModel({this.totalSize, this.limit, this.offset, this.items});

  RecommendedItemModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['items'] != null) {
      items = <Item>[];
      json['items'].forEach((v) {
        items!.add(Item.fromJson(v));
      });
    }
  }
  int? totalSize;
  String? limit;
  String? offset;
  List<Item>? items;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (items != null) {
      data['products'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
