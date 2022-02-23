import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
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

  UserBloc() : super(UserState());

  Future<void> loginWithGoogle() async {
    try {
      final googleAccount = await _googleSignInConfiguration.signIn();
      if (googleAccount == null) {
        throw AuthException('Sign in process was aborted');
      }
      final googleAuthentication = await googleAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      );

      FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((userCredential) {
        if (userCredential.user != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(
                firebase_user.User.empty().getDataToFireStore(),
                SetOptions(merge: true),
              );
        }
        initData();
      });
    } catch (e) {
      log(e.toString());
      emit(UserState(errorMessage: e.toString()));
    }
  }

  Future<void> initData() async {
    if (FirebaseAuth.instance.currentUser == null) {
      emit(UserState(errorMessage: 'user is null'));
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    firebase_user.User firebaseUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    firebaseUser = firebase_user.User.empty()
      ..setDataFromFireStore(snapshot.data()!);
    emit(UserState(
      user: firebase_user.User(
        name: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        balance: firebaseUser.balance,
        highestTime: firebaseUser.highestTime,
        won: firebaseUser.won,
        lost: firebaseUser.lost,
      ),
    ));
  }

  Future<void> logout() async {
    FirebaseAuth.instance.signOut();
    _googleSignInConfiguration.signOut();
  }
}

class UserState {
  firebase_user.User? user;

  String errorMessage;

  UserState({required this.user}) : errorMessage = '';

  UserState.error({required this.errorMessage}) : user = null;
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
