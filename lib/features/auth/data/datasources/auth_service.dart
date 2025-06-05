import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_management/features/auth/domain/entities/user_entity.dart';
import 'package:home_management/features/core/data/datasource/data_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DataService _dataService = DataService();

  // Get User by Id
  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      // Get all users from database
      Map<String, dynamic> allUsers = await _dataService.getAllData('users');
      
      // Check if users data exists
      if (allUsers.isEmpty) {
        throw Exception('No users found in database');
      }
      
      // Find user by id field in the data
      for (String key in allUsers.keys) {
        var userData = allUsers[key];
        if (userData is Map && userData['id'] == id) {
          return Map<String, dynamic>.from(userData);
        }
      }
      
      // If not found, throw exception
      throw Exception('User not found with id: $id');
    } catch (e) {
      throw Exception('Error getting user: ${e.toString()}');
    }
  }

  // Get User by Email
  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    List<Map<String, dynamic>> users = await getAllUsers();
    Map<String, dynamic> user = {};
    for (int i = 0; i < users.length; i++) {
      if (users[i]['email'] == email) {
        user = users[i];
        break;
      }
    }
    return user;
  }

  // Create User
  Future<void> createUser(Map<String, dynamic> user) async {
    await _dataService.addData('users', user);
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

        UserEntity userEntity = UserEntity(
          id: result.user!.uid,
          name: name,
          email: email,
          role: UserRole.user,
          createdAt: DateTime.now(),
        );

        // Convert UserEntity to Map before passing to createUser
        await createUser(userEntity.toMap());
    return result.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<bool> isUserLoggedIn() async {
    User? user = _firebaseAuth.currentUser;
    return user != null;
  }

  // Current User
  Future<User?> getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    return user;
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Send Password Reset Email (missing method)
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Get All Users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      Map<String, dynamic> data = await _dataService.getAllData('users');
      List<Map<String, dynamic>> users = [];
      
      data.forEach((key, value) {
        if (value is Map) {
          users.add(Map<String, dynamic>.from(value));
        }
      });
      
      return users;
    } catch (e) {
      throw Exception('Error getting all users: ${e.toString()}');
    }
  }

  // Update User - modified to work with Firebase push keys
  Future<void> updateUser(Map<String, dynamic> user) async {
    try {
      String userId = user['id'];
      
      // Get all users to find the correct key
      Map<String, dynamic> allUsers = await _dataService.getAllData('users');
      
      if (allUsers.isEmpty) {
        throw Exception('No users found in database');
      }
      
      String? userKey;
      for (String key in allUsers.keys) {
        var userData = allUsers[key];
        if (userData is Map && userData['id'] == userId) {
          userKey = key;
          break;
        }
      }
      
      if (userKey != null) {
        await _dataService.updateData('users', userKey, user);
      } else {
        throw Exception('User not found for update');
      }
    } catch (e) {
      throw Exception('Error updating user: ${e.toString()}');
    }
  }
  
  // Delete User - modified to work with Firebase push keys
  Future<void> deleteUser(String id) async {
    try {
      // Get all users to find the correct key
      Map<String, dynamic> allUsers = await _dataService.getAllData('users');
      
      if (allUsers.isEmpty) {
        throw Exception('No users found in database');
      }
      
      String? userKey;
      for (String key in allUsers.keys) {
        var userData = allUsers[key];
        if (userData is Map && userData['id'] == id) {
          userKey = key;
          break;
        }
      }
      
      if (userKey != null) {
        await _dataService.deleteData('users', userKey);
      } else {
        throw Exception('User not found for deletion');
      }
    } catch (e) {
      throw Exception('Error deleting user: ${e.toString()}');
    }
  }
}
