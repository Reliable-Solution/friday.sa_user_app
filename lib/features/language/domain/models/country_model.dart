// To parse this JSON data, do
//
//     final CountryModel = CountryModelFromJson(jsonString);

import 'dart:convert';

class CountryResModel {
  CountryResModel({
    this.success,
    this.message,
    this.data,
  });

  factory CountryResModel.fromJson(Map<String, dynamic> json) =>
      CountryResModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : (json["data"] as List)
                .map((e) => CountryModel.fromJson(e))
                .toList(),
      );
  final bool? success;
  final String? message;
  final List<CountryModel>? data;

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

CountryModel countryModelFromJson(String str) =>
    CountryModel.fromJson(json.decode(str));

String countryModelToJson(CountryModel data) => json.encode(data.toJson());

class CountryModel {
  CountryModel({
    this.id,
    this.country,
    this.url,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json["id"],
        country: json["country"],
        url: json["url"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );
  final int? id;
  final String? country;
  final String? url;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        "id": id,
        "country": country,
        "url": url,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
