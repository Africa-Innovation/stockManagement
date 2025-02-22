import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> syncUserToFirebase(String name, String phone, String password) async {
    await users.doc(phone).set({
      'name': name,
      'phone': phone,
      'password': password, // Idéalement, utilise un hachage
    });
  }

  Future<Map<String, dynamic>?> getUserFromFirebase(String phone) async {
    final doc = await users.doc(phone).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }
}


