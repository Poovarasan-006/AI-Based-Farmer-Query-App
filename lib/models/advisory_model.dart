class AdvisoryModel {
  String advisoryId;
  String farmerId;
  String title;
  String description;
  List<String> recommendations;
  String cropType;
  String soilType;
  String weatherCondition;
  DateTime timestamp;

  AdvisoryModel({
    required this.advisoryId,
    required this.farmerId,
    required this.title,
    required this.description,
    required this.recommendations,
    required this.cropType,
    required this.soilType,
    required this.weatherCondition,
    required this.timestamp,
  });

  // Convert a AdvisoryModel to a Map.
  Map<String, dynamic> toJson() {
    return {
      'advisoryId': advisoryId,
      'farmerId': farmerId,
      'title': title,
      'description': description,
      'recommendations': recommendations,
      'cropType': cropType,
      'soilType': soilType,
      'weatherCondition': weatherCondition,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert a Map to a AdvisoryModel.
  factory AdvisoryModel.fromJson(Map<String, dynamic> json) {
    return AdvisoryModel(
      advisoryId: json['advisoryId'],
      farmerId: json['farmerId'],
      title: json['title'],
      description: json['description'],
      recommendations: List<String>.from(json['recommendations']),
      cropType: json['cropType'],
      soilType: json['soilType'],
      weatherCondition: json['weatherCondition'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}