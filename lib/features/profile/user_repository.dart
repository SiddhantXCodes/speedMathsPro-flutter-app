import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final _users = FirebaseFirestore.instance.collection('users');

  Future<void> updateUsername({
    required String userId,
    required String username,
  }) async {
    await _users.doc(userId).set(
      {
        'username': username,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
