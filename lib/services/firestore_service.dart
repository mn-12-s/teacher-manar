import 'package:cloud_firestore/cloud_firestore.dart';

/// طبقة الوصول إلى Firestore — مطابقة لـ getAll/addRec/updRec في الأصل.
class FirestoreService {
  final FirebaseFirestore _db;
  FirestoreService(this._db);

  /// قراءة كل مستندات مجموعة كقائمة خرائط مع id.
  Future<List<({String id, Map<String, dynamic> data})>> getAll(
      String collection) async {
    final snap = await _db.collection(collection).get();
    return snap.docs
        .map((d) => (id: d.id, data: d.data()))
        .toList(growable: false);
  }

  /// إضافة مستند مع طابع زمني (_ts) — يعيد المعرّف.
  Future<String> add(String collection, Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add({
      ...data,
      '_ts': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// تحديث مستند.
  Future<void> update(
      String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).update(data);
  }
}
