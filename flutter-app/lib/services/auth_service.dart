import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location_poll/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on FirebaseUser
  User? _userFromFirebaseUser(firebase.User? user) {
    if(user == null) {
      return null;
    }
    return User(
      uuid: user.uid,
      userName: user.displayName ?? '',
    );
  }

  // auth change user stream
  Stream<User?> get user {
    return _auth
        .authStateChanges()
        .map((firebase.User? user) => _userFromFirebaseUser(user));
    // in other words: return only user ID
  }

  User? loggedInUser() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return _userFromFirebaseUser(firebaseUser);
  }

  // sign in with E-Mail & Password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      firebase.User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle(
      GoogleSignInAuthentication googleSignInAuthentication) async {
    try {
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      firebase.User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Register with E-Mail & Password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      firebase.User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
