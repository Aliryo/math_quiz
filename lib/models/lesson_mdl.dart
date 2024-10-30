class LessonMdl {
  final String id;
  final String moduleName;
  final String partName;
  final String lessonPath;

  const LessonMdl({
    this.id = '',
    this.moduleName = '',
    this.partName = '',
    this.lessonPath = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleName': moduleName,
      'partName': partName,
      'lessonPath': lessonPath,
    };
  }

  factory LessonMdl.fromMap(Map<String, dynamic> data, String id) {
    return LessonMdl(
      id: id,
      moduleName: data['moduleName'] as String,
      partName: data['partName'] as String,
      lessonPath: data['lessonPath'] as String,
    );
  }
}
