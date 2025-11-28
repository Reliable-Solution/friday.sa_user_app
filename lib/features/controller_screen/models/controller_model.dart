class ControllerModel {
  ControllerModel({this.message, this.data});

  factory ControllerModel.fromJson(Map<String, dynamic> json) =>
      ControllerModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ControllerData>.from(
                json["data"]!.map((x) => ControllerData.fromJson(x)),
              ),
      );
  final String? message;
  final List<ControllerData>? data;

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ControllerData {
  ControllerData({
    this.channelId,
    this.writeKey,
    this.readKey,
    this.userType,
    this.userId,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory ControllerData.fromJson(Map<String, dynamic> json) => ControllerData(
    channelId: json["chanel_id"],
    writeKey: json["write_api_key"],
    readKey: json["read_api_key"],
    userType: json["user_type"],
    id: json["id"],
    userId: json["user_id"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );
  final int? userId;
  final String? channelId;
  final String? writeKey;
  final String? readKey;
  final String? userType;
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    "chanel_id": channelId,
    "user_type": userType,
    "write_api_key": writeKey,
    "read_api_key": readKey,
    "user_id": userId,
    "id": id,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Pagination {
  Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
  );
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
  };
}
