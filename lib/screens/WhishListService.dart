import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WhishListService {
  CollectionReference courses = FirebaseFirestore.instance.collection('courses');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final user = FirebaseAuth.instance.currentUser;

  updateFavourite(context, _isLiked, donId) {
    if (_isLiked) {
      courses.doc(donId).update({
        'favourites': FieldValue.arrayUnion([user!.uid]),
      });
      print(user!.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajouté au favoirs'),
        ),
      );
    } else {
      courses.doc(donId).update({
        'favourites': FieldValue.arrayRemove([user!.uid]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retiré de la liste des favoirs'),
        ),
      );
    }
  }
}