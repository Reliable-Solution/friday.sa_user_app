class PredictionModel {
  PredictionModel({
    this.description,
    this.id,
    this.distanceMeters,
    this.placeId,
    this.reference,
    this.place,
    this.text,
    this.structuredFormat,
    this.types,
  });

  PredictionModel.fromJson(Map<String, dynamic> json) {
    description = json['placePrediction']['text']['text'];
    id = json['placePrediction']['placeId'];
    placeId = json['placePrediction']['placeId'];
    place = json['placePrediction']['place'];
    reference = json['placePrediction']['text']['text'];
    types = List<String>.from(json['placePrediction']['types'] ?? []);
    text = json['placePrediction']['text'] != null
        ? TextModel.fromJson(json['placePrediction']['text'])
        : null;
    structuredFormat = json['placePrediction']['structuredFormat'] != null
        ? StructuredFormat.fromJson(json['placePrediction']['structuredFormat'])
        : null;
  }
  String? description;
  String? id;
  int? distanceMeters;
  String? placeId;
  String? reference;
  String? place;
  TextModel? text;
  StructuredFormat? structuredFormat;
  List<String>? types;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['placePrediction'] = {
      'text': text?.toJson(),
      'placeId': placeId,
      'place': place,
      'types': types,
      'structuredFormat': structuredFormat?.toJson(),
    };
    return data;
  }
}

class TextModel {
  TextModel({this.text, this.matches});

  TextModel.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    if (json['matches'] != null) {
      matches = <Match>[];
      json['matches'].forEach((v) {
        matches!.add(Match.fromJson(v));
      });
    }
  }
  String? text;
  List<Match>? matches;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    if (matches != null) {
      data['matches'] = matches!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Match {
  Match({this.endOffset});

  Match.fromJson(Map<String, dynamic> json) {
    endOffset = json['endOffset'];
  }
  int? endOffset;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['endOffset'] = endOffset;
    return data;
  }
}

class StructuredFormat {
  StructuredFormat({this.mainText, this.secondaryText});

  StructuredFormat.fromJson(Map<String, dynamic> json) {
    mainText =
        json['mainText'] != null ? MainText.fromJson(json['mainText']) : null;
    secondaryText = json['secondaryText'] != null
        ? SecondaryText.fromJson(json['secondaryText'])
        : null;
  }
  MainText? mainText;
  SecondaryText? secondaryText;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mainText != null) {
      data['mainText'] = mainText!.toJson();
    }
    if (secondaryText != null) {
      data['secondaryText'] = secondaryText!.toJson();
    }
    return data;
  }
}

class MainText {
  MainText({this.text, this.matches});

  MainText.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    if (json['matches'] != null) {
      matches = <Match>[];
      json['matches'].forEach((v) {
        matches!.add(Match.fromJson(v));
      });
    }
  }
  String? text;
  List<Match>? matches;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    if (matches != null) {
      data['matches'] = matches!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SecondaryText {
  SecondaryText({this.text});

  SecondaryText.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }
  String? text;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}
