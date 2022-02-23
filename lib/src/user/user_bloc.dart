import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blink/src/user/user.dart' as firebase_user;

class UserBloc extends Cubit<UserState> {
  final GoogleSignIn _googleSignInConfiguration = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  UserBloc() : super(NoUserState());

  Future<void> loginWithGoogle() async {
    try {
      emit(UserInLogin(inProgress: true));
      final googleAccount = await _googleSignInConfiguration.signIn();
      if (googleAccount == null) {
        emit(ErrorUserState(message: 'Sign in process was aborted'));
        return;
      }
      final googleAuthentication = await googleAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        final usersCollection = FirebaseFirestore.instance.collection('users');
        final userDoc = usersCollection.doc(userId);
        final emptyUser = firebase_user.User.empty();
        final emptyFirebaseUser = emptyUser.getDataToFireStore();

        userDoc.set(emptyFirebaseUser, SetOptions(merge: true));
      }
      initUserFields();
    } catch (e) {
      log(e.toString());
      emit(ErrorUserState(message: e.toString()));
    } finally {
      emit(UserInLogin(inProgress: true));
    }
  }

  Future<void> initUserFields() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(ErrorUserState(message: 'No signed in user'));
      return;
    }

    final usersCollectino = FirebaseFirestore.instance.collection('users');
    final userSnapshot = await usersCollectino.doc(user.uid).get();
    final firebaseUser = firebase_user.User.empty();
    firebaseUser.setDataFromFireStore(userSnapshot.data()!);
    firebaseUser.name = user.displayName;
    firebaseUser.email = user.email;
    firebaseUser.photoUrl = user.photoURL;

    emit(ReadyUserState(user: firebaseUser));
  }

  Future<void> logout() async {
    FirebaseAuth.instance.signOut();
    _googleSignInConfiguration.signOut();
  }
}

abstract class UserState {}

class ReadyUserState extends UserState {
  firebase_user.User user;

  ReadyUserState({required this.user});
}

class NoUserState extends UserState {
  firebase_user.User user;

  NoUserState() : user = firebase_user.User();
}

class ErrorUserState extends UserState {
  final String message;

  ErrorUserState({required this.message});
}

class UserInLogin extends UserState {
  final bool inProgress;

  UserInLogin({required this.inProgress});
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
