import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

class DataService {
  FirebaseDatabase database = FirebaseDatabase.instance;

  // Get all data
  Future<Map<String, dynamic>> getAllData(String path) async {
    DatabaseReference ref = database.ref(path);
    DataSnapshot snapshot = await ref.get();
    
    if (snapshot.exists && snapshot.value != null) {
      if (snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        return {};
      }
    } else {
      return {};
    }
  }

  // Get data by key
  Future<Map<String, dynamic>> getDataByKey(String path, String key) async {
    DatabaseReference ref = database.ref(path);
    DataSnapshot snapshot = await ref.child(key).get();
    
    if (snapshot.exists && snapshot.value != null) {
      if (snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        throw Exception('Data is not in expected format');
      }
    } else {
      throw Exception('Data not found for key: $key');
    }
  }

  // Get data by id
  Future<Map<String, dynamic>> getDataById(String path, String id) async {
    DatabaseReference ref = database.ref(path);
    DataSnapshot snapshot = await ref.child(id).get();
    
    if (snapshot.exists && snapshot.value != null) {
      if (snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        throw Exception('Data is not in expected format');
      }
    } else {
      throw Exception('Data not found for id: $id');
    }
  }

  // Add data
  Future<void> addData(String path, Map<String, dynamic> data) async {
    DatabaseReference ref = database.ref(path);
    await ref.push().set(data);
  }

  // Update data
  Future<void> updateData(
      String path, String key, Map<String, dynamic> data) async {
    DatabaseReference ref = database.ref(path);
    await ref.child(key).update(data);
  }

  // Delete data
  Future<void> deleteData(String path, String key) async {
    DatabaseReference ref = database.ref(path);
    await ref.child(key).remove();
  }

  // Random generation of unique code
  String generateUniqueCode() {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
