class CategoryModel {
  CategoryModel({
    int? id,
    String? name,
    int? parentId,
    int? position,
    String? createdAt,
    String? updatedAt,
    String? imageFullUrl,
    List<CategoryModel>? childes,
  }) {
    _id = id;
    _name = name;
    _parentId = parentId;
    _position = position;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _imageFullUrl = imageFullUrl;
    _childes = childes;
  }

  CategoryModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _parentId = json['parent_id'];
    _position = json['position'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _imageFullUrl = json['image_full_url'];
    if (json['childes'] != null) {
      _childes = <CategoryModel>[];
      json['childes'].forEach((v) {
        _childes!.add(CategoryModel.fromJson(v));
      });
    }
  }
  int? _id;
  String? _name;
  int? _parentId;
  int? _position;
  String? _createdAt;
  String? _updatedAt;
  String? _imageFullUrl;
  List<CategoryModel>? _childes;

  int? get id => _id;
  String? get name => _name;
  int? get parentId => _parentId;
  int? get position => _position;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get imageFullUrl => _imageFullUrl;
  List<CategoryModel>? get childes => _childes;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['parent_id'] = _parentId;
    data['position'] = _position;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['image_full_url'] = _imageFullUrl;
    if (_childes != null) {
      data['childes'] = _childes!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
