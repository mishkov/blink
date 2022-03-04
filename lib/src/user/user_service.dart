import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blink/src/user/user.dart' as firebase_user;

class UserService {
  firebase_user.User? _user;
  final StreamController<firebase_user.User> _userStreamController =
      StreamController.broadcast();

  final GoogleSignIn _googleSignInConfiguration = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  static final _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal();

  firebase_user.User? get user => _user;

  Stream<firebase_user.User> get userStream => _userStreamController.stream;

  Future<void> loginWithGoogle() async {
    await _googleSignInConfiguration.signOut();
    final googleAccount = await _googleSignInConfiguration.signIn();
    if (googleAccount == null) {
      throw SignInAbortedException('Sign in process was aborted');
    }
    final googleAuthentication = await googleAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuthentication.accessToken,
      idToken: googleAuthentication.idToken,
    );

    UserCredential userCredential;
    try {
      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw InvaliCredentialException(e.message!);
      } else {
        rethrow;
      }
    }

    if (userCredential.user != null) {
      final userId = userCredential.user!.uid;
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final userDoc = usersCollection.doc(userId);
      final emptyUser = firebase_user.User.empty();
      final emptyFirebaseUser = emptyUser.getDataToFireStore();

      await userDoc.set(emptyFirebaseUser, SetOptions(merge: true));
    }

    await init();
  }

  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw NoSignedInUserExceptino('No signed in user');
    }

    final usersCollectino = FirebaseFirestore.instance.collection('users');
    final userRef = usersCollectino.doc(user.uid);
    final userSnapshot = await userRef.get();
    final firebaseUser = firebase_user.User.empty();
    firebaseUser.setDataFromFireStore(userSnapshot.data()!);
    firebaseUser.name = user.displayName;
    firebaseUser.email = user.email;
    firebaseUser.photoUrl = user.photoURL;

    _user = firebaseUser;
    _userStreamController.add(firebaseUser);

    userRef.snapshots().listen((document) {
      final data = document.data()!;

      final updatedUser = firebase_user.User.empty()
        ..setDataFromFireStore(data);
      _user
        ?..balance = updatedUser.balance
        ..highestTime = updatedUser.highestTime
        ..won = updatedUser.won
        ..lost = updatedUser.lost;
    });
  }

  Future<void> updateHighestTime(int highesTimeInMilliseconds) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw NoSignedInUserExceptino('No signed in user');
    }

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.update({'highest_time': highesTimeInMilliseconds});
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignInConfiguration.signOut();
  }
}

class SignInAbortedException implements Exception {
  final String message;

  SignInAbortedException(this.message);

  @override
  String toString() => 'SignInAbortedException: $message';
}

class NoSignedInUserExceptino implements Exception {
  final String message;

  NoSignedInUserExceptino(this.message);

  @override
  String toString() => 'NoSignedInUserException: $message';
}

class InvaliCredentialException implements Exception {
  final String message;

  InvaliCredentialException(this.message);

  @override
  String toString() => 'InvaliCredentialException: $message';
}
