class PartMdl {
  final String id;
  final String moduleName;
  final String partName;

  PartMdl({
    this.id = '',
    this.moduleName = '',
    this.partName = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleName': moduleName,
      'partName': partName,
    };
  }

  factory PartMdl.fromMap(Map<String, dynamic> data, String id) {
    return PartMdl(
      id: id,
      moduleName: data['moduleName'] as String,
      partName: data['partName'] as String,
    );
  }

  PartMdl copyWith({
    String? id,
    String? moduleName,
    String? partName,
  }) {
    return PartMdl(
      id: id ?? this.id,
      moduleName: moduleName ?? this.moduleName,
      partName: partName ?? this.partName,
    );
  }
}
