class QueryModel {
  final String queryId;
  final String farmerId;
  final String queryText;
  final DateTime queryDate;

  QueryModel({this.queryId, this.farmerId, this.queryText, this.queryDate});

  factory QueryModel.fromJson(Map<String, dynamic> json) {
    return QueryModel(
      queryId: json['queryId'],
      farmerId: json['farmerId'],
      queryText: json['queryText'],
      queryDate: DateTime.parse(json['queryDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'queryId': queryId,
      'farmerId': farmerId,
      'queryText': queryText,
      'queryDate': queryDate.toIso8601String(),
    };
  }
}