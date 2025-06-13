import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/models/student_mdl.dart';

class FirebaseHelper {
  FirebaseHelper._();

  //? Membuat Akun Siswa Baru Ke Firebase
  static Future<void> createStudent(StudentMdl student) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: student.email,
        password: student.password,
      );

      _addKidName(StudentMdl(
        id: userCredential.user?.uid ?? '',
        kidName: student.kidName,
        email: student.email,
        password: student.password,
      ));
    } catch (e) {
      rethrow;
    }
  }

  static Future<StudentMdl> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(userCredential.user?.uid)
              .get();

      if (docSnapshot.reference.id.isNotEmpty) {
        return StudentMdl.fromMap(docSnapshot.data()!, docSnapshot.id);
      } else {
        throw Exception();
      }
    } catch (e) {
      rethrow;
    }
  }

  //? Menambah Nama Siswa Ke Firebase
  static Future<void> _addKidName(StudentMdl student) async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(student.id)
        .set(student.toMap());
  }

  //? Menambah Pertanyaan Kuis Ke Firebase
  static Future<void> addQuestion(QuestionMdl question) async {
    await FirebaseFirestore.instance
        .collection('questions')
        .add(question.toMap());
  }

  //? Menambah Materi Ke Firebase
  static Future<void> addLesson(LessonMdl lesson) async {
    final CollectionReference resultsRef =
        FirebaseFirestore.instance.collection('lessons');

    final QuerySnapshot querySnapshot =
        await resultsRef.where('partName', isEqualTo: lesson.partName).get();

    if (querySnapshot.docs.isNotEmpty) {
      final String existingDocId = querySnapshot.docs.first.id;

      await resultsRef.doc(existingDocId).update(lesson.toMap());
    } else {
      await resultsRef.add(lesson.toMap());
    }
  }

  //? Menambah Hasil Kuis Ke Firebase
  static Future<void> addResult(ResultMdl result) async {
    final CollectionReference resultsRef =
        FirebaseFirestore.instance.collection('results');

    final QuerySnapshot querySnapshot =
        await resultsRef.where('name', isEqualTo: result.name).get();

    if (querySnapshot.docs.isNotEmpty) {
      final String existingDocId = querySnapshot.docs.first.id;

      await resultsRef.doc(existingDocId).update(result.toMap());
    } else {
      await resultsRef.add(result.toMap());
    }
  }

  //? Menambah Modul Kuis Ke Firebase
  static Future<void> addModule(ModuleMdl module) async {
    await FirebaseFirestore.instance.collection('modules').add(module.toMap());
  }

  //? Menambah Materi Kuis Ke Firebase
  static Future<void> addPart(PartMdl part) async {
    await FirebaseFirestore.instance.collection('parts').add(part.toMap());
  }

  //? Mengambil Data-Data Kuis Dari Firebase Lalu Dilakukan Knuth Shuffle
  static Future<List<QuestionMdl>> fetchAndShuffleQuestions(
    String partName,
  ) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('partName', isEqualTo: partName)
        .get();

    List<QuestionMdl> questions = snapshot.docs
        .map((doc) =>
            QuestionMdl.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    CommonHelper.fisherYatestShuffle(questions);

    return questions;
  }

  //? Mengambil Data-Data Materi Dari Firebase
  static Future<LessonMdl> fetchLesson(String partName) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .where('partName', isEqualTo: partName)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return LessonMdl.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }

    return const LessonMdl();
  }

  //? Mengambil Data-Data Modul Dari Firebase
  static Future<List<ModuleMdl>> fetchModules() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('modules')
        .orderBy('moduleName', descending: false)
        .get();

    List<ModuleMdl> modules = snapshot.docs
        .map((doc) =>
            ModuleMdl.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return modules;
  }

  //? Mengambil Data-Data Materi Dari Firebase
  static Future<List<PartMdl>> fetchParts(String moduleName) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('parts')
        .orderBy('moduleName', descending: false)
        .where('moduleName', isEqualTo: moduleName)
        .get();

    List<PartMdl> parts = snapshot.docs
        .map((doc) =>
            PartMdl.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return parts;
  }

  //? Mengambil Data-Data Hasil Siswa Dari Firebase
  static Future<List<ResultMdl>> fetchResults(
    String partName, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('results');

    if (startDate != null) {
      query = query.where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final QuerySnapshot<Map<String, dynamic>> resultsRef = await query.get();

    final List<ResultMdl> filteredResults = resultsRef.docs
        .map((doc) => ResultMdl.fromMap(doc.data(), doc.id))
        .where((result) =>
            result.scoreData.any((score) => score.partName == partName))
        .toList();

    filteredResults.sort((a, b) {
      final aScore = a.scoreData
          .firstWhere((score) => score.partName == partName,
              orElse: () => ScoreData(score: 0))
          .score;

      final bScore = b.scoreData
          .firstWhere((score) => score.partName == partName,
              orElse: () => ScoreData(score: 0))
          .score;

      return bScore.compareTo(aScore);
    });

    return filteredResults;
  }

  //? Menghapus Satu Pertanyaan
  static Future<void> deleteQuestion(String documentId) async {
    await FirebaseFirestore.instance
        .collection('questions')
        .doc(documentId)
        .delete();
  }

  //? Menghapus Satu Modul
  static Future<void> deleteModule(String documentId) async {
    await FirebaseFirestore.instance
        .collection('modules')
        .doc(documentId)
        .delete();
  }

  //? Menghapus Satu Materi
  static Future<void> deletePart(String documentId) async {
    await FirebaseFirestore.instance
        .collection('parts')
        .doc(documentId)
        .delete();
  }

  //? Upload File Ke Firebase
  static Future<String?> uploadFile(File file) async {
    final String fileName = file.path.split('/').last;

    final Reference storageRef =
        FirebaseStorage.instance.ref().child('quiz/$fileName');

    final UploadTask uploadTask = storageRef.putFile(file);

    final TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }
}
