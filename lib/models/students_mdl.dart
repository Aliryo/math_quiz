class StudentsMdl {
  final String id;
  final String kidName;

  const StudentsMdl({
    this.id = '',
    this.kidName = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kidName': kidName,
    };
  }

  factory StudentsMdl.fromMap(Map<String, dynamic> data, String id) {
    return StudentsMdl(
      id: id,
      kidName: data['kidName'] as String,
    );
  }
}
