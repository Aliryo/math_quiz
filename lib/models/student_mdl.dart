class StudentMdl {
  final String id;
  final String email;
  final String password;
  final String kidName;

  StudentMdl({
    this.id = '',
    this.email = '',
    this.password = '',
    this.kidName = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'kidName': kidName,
    };
  }

  factory StudentMdl.fromMap(Map<String, dynamic> data, String id) {
    return StudentMdl(
      id: data['id'] as String,
      email: data['email'] as String,
      password: data['password'] as String,
      kidName: data['kidName'] as String,
    );
  }
}
