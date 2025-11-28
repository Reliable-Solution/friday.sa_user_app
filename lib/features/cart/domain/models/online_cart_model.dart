import 'package:friday_sa/features/item/domain/models/item_model.dart'
    as product_variation;

class OnlineCartModel {
  OnlineCartModel({
    this.id,
    this.userId,
    this.moduleId,
    this.itemId,
    this.isGuest,
    this.addOnIds,
    this.addOnQtys,
    this.itemType,
    this.price,
    this.quantity,
    this.foodVariation,
    this.createdAt,
    this.updatedAt,
    this.item,
  });

  OnlineCartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    moduleId = json['module_id'];
    itemId = json['item_id'];
    isGuest = json['is_guest'];
    addOnIds = json['add_on_ids'].cast<int>();
    addOnQtys = json['add_on_qtys'].cast<int>();
    itemType = json['item_type'];
    price = json['price']?.toDouble();
    quantity = json['quantity'];
    if (json['variation'] != null) {
      foodVariation = [];
      productVariation = [];
      json['variation'].forEach((v) {
        if (v['name'] == null) {
          productVariation!.add(product_variation.Variation.fromJson(v));
        } else {
          foodVariation!.add(Variation.fromJson(v));
        }
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    item = json['item'] != null
        ? product_variation.Item.fromJson(json['item'])
        : null;
  }
  int? id;
  int? userId;
  int? moduleId;
  int? itemId;
  bool? isGuest;
  List<int>? addOnIds;
  List<int>? addOnQtys;
  String? itemType;
  num? price;
  int? quantity;
  List<Variation>? foodVariation;
  List<product_variation.Variation>? productVariation;
  String? createdAt;
  String? updatedAt;
  product_variation.Item? item;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['module_id'] = moduleId;
    data['item_id'] = itemId;
    data['is_guest'] = isGuest;
    data['add_on_ids'] = addOnIds;
    data['add_on_qtys'] = addOnQtys;
    data['item_type'] = itemType;
    data['price'] = price;
    data['quantity'] = quantity;
    if (foodVariation != null) {
      data['variation'] = foodVariation!.map((v) => v.toJson()).toList();
    }
    if (productVariation != null) {
      data['variation'] = productVariation!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (item != null) {
      data['item'] = item!.toJson();
    }
    return data;
  }
}

class Variation {
  Variation({this.name, this.values});

  Variation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    values = json['values'] != null ? Value.fromJson(json['values']) : null;
  }
  String? name;
  Value? values;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (values != null) {
      data['values'] = values!.toJson();
    }
    return data;
  }
}

class Value {
  Value({this.label});

  Value.fromJson(Map<String, dynamic> json) {
    label = json['label'].cast<String>();
  }
  List<String>? label;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    return data;
  }
}
