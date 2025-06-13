import 'package:cloud_firestore/cloud_firestore.dart';

class ResultMdl {
  final String id;
  final String name;
  final DateTime? createdAt;
  final List<ScoreData> scoreData;

  ResultMdl({
    this.id = '',
    this.name = '',
    this.createdAt,
    this.scoreData = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'scoreData': scoreData.map((item) => item.toMap()).toList(),
    };
  }

  factory ResultMdl.fromMap(Map<String, dynamic> data, String id) {
    var scoreList = data['scoreData'] as List<dynamic>;

    List<ScoreData> scoreData = scoreList
        .map((item) => ScoreData.fromMap(item as Map<String, dynamic>))
        .toList();

    return ResultMdl(
      id: id,
      name: data['name'] as String,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      scoreData: scoreData,
    );
  }
}

class ScoreData {
  final String partName;
  final int score;

  ScoreData({
    this.partName = '',
    this.score = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'partName': partName,
      'score': score,
    };
  }

  factory ScoreData.fromMap(Map<String, dynamic> data) {
    return ScoreData(
      partName: data['partName'] as String,
      score: data['score'] as int,
    );
  }
}
