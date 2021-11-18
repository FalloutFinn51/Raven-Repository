import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

abstract class BaseAuth {
  Stream<String> get onAuthStateChanged;
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> signOut();
  String userUIDret();
}

class Auth implements BaseAuth {
  final FirebaseAuth firebaseAuthIns = FirebaseAuth.instance;

  @override
  Stream<String> get onAuthStateChanged {
    return firebaseAuthIns.authStateChanges().map((user) => user!.uid);
  }

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    await firebaseAuthIns.signInWithEmailAndPassword(
        email: email, password: password);
    final User user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    return uid;
  }

  @override
  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    await firebaseAuthIns.createUserWithEmailAndPassword(
        email: email, password: password);
    final User user = firebaseAuthIns.currentUser!;
    final uid = user.uid;
    return uid;
  }

  @override
  Future<String> currentUser() async {
    String finalUser = "";
    if (firebaseAuthIns.currentUser != null) {
      final user = firebaseAuthIns.currentUser!;
      finalUser = user.uid;
    }
    return finalUser;
  }

  String userUIDret() {
    String finalUser = "";
    if (firebaseAuthIns.currentUser != null) {
      final user = firebaseAuthIns.currentUser!;
      finalUser = user.uid;
    }
    return finalUser;
  }

  @override
  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }
}
