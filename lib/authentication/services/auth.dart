import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/utils/log.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //auth change user stream
  Stream<User?> get stream {
    return _auth.authStateChanges();
  }

  //sign in anon
  Future<User?> signInAnon() async {
    try {
      var result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      log(e.toString());
      throw Exception(e.toString());
    }
  }

  //sign in with email & password
  Future<User?> signInWithemailAndPassword(String email, String password) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      log(e.toString());
      throw Exception(e.toString());
    }
  }

  //register with email & password
  Future<User?> registerWithemailAndPassword(String email, String password) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      log(e.toString());
      throw Exception(e.toString());
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      var user = getCurrentUser();
      return await _auth.signOut().then((v) {
        FirebaseFirestore.instance.collection(Constants.users).doc(user!.uid).update({
          "isOnline": false,
        });
      });
    } catch (e) {
      log(e.toString());
      throw Exception(e.toString());
    }
  }

  static User? getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    return user;
  }
}
