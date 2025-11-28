class SearchSuggestionModel {
  SearchSuggestionModel({this.items, this.stores});

  SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    if (json['stores'] != null) {
      stores = <Stores>[];
      json['stores'].forEach((v) {
        stores!.add(Stores.fromJson(v));
      });
    }
  }
  List<Items>? items;
  List<Stores>? stores;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (stores != null) {
      data['stores'] = stores!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  Items({
    this.id,
    this.name,
    this.image,
    this.unitType,
    this.imageFullUrl,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    unitType = json['unit_type'];
    imageFullUrl = json['image_full_url'];
  }
  int? id;
  String? name;
  String? image;
  String? unitType;
  String? imageFullUrl;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['unit_type'] = unitType;
    return data;
  }
}

class Stores {
  Stores({
    this.id,
    this.name,
    this.logo,
    this.gstStatus,
    this.gstCode,
    this.logoFullUrl,
  });

  Stores.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    gstStatus = json['gst_status'];
    gstCode = json['gst_code'];
    logoFullUrl = json['logo_full_url'];
  }
  int? id;
  String? name;
  String? logo;
  bool? gstStatus;
  String? gstCode;
  String? logoFullUrl;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['logo_full_url'] = logoFullUrl;
    return data;
  }
}
