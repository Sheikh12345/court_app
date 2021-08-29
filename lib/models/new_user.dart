import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import '../methods/firebase_methods.dart';
import '../screens/complete_profile/vcomplete_profile_screen.dart';

  // ignore: deprecated_member_use
  Future<void> saveNewUser(email,context) async{
    
    final CollectionReference users = FirebaseFirestore.instance.collection('Users');
    users.doc(email).set({
      'email' : email,
       'uid' : uid,
       'status': "User Verified",
    }).then((value) => 
    Navigator.pushReplacementNamed(context, VCompleteProfileScreen.routeName)).catchError((e){
      print(e);
    });
    return null;
  }