import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseHelper {
  void initialize() async {
    await Firebase.initializeApp().then((value) {
      print("Initialized");
    }).catchError((e) {
      print("Firebase.initializeApp error ${e}");
    });
  }

  Future<UserCredential?> signupUser(
      name, email, password, image, context) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      var user = await addUser(name, email, image, credential.user!.uid);

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      showAlert(e.message, context);

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<UserCredential?> loginUser(email, password, context) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }

      showAlert(e.message, context);
      return null;
    }
  }

  User? getLoggedInUser() {
    return FirebaseAuth.instance.currentUser;
  }

  void logoutUser() {
    FirebaseAuth.instance.signOut();
  }

  Future<DocumentReference<Map<String, dynamic>>> addUser(
      name, email, image, uid) {
    return FirebaseFirestore.instance
        .collection('Users') // Table
        .add({"name": name, "email": email, "image": image, "uid": uid});
  }

  Future<DocumentReference<Map<String, dynamic>>> addChat(
      message, timeStamp, fromId, toId, chatId) {
    return FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection("messages") // Table
        .add({
      "message": message,
      "timeStamp": timeStamp,
      "fromId": fromId,
      "toId": toId
    });
  }

  Future<String> uploadImage(File? file) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imagesRef = storageRef.child("images");
    String fileName = file!.path.split('/').last;
    final imageRef = imagesRef.child(fileName);
    try {
      await imageRef.putFile(file);
    } on FirebaseException catch (e) {}
    return await imageRef.getDownloadURL();
  }

  void showAlert(message, context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
