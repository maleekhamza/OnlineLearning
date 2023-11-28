import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Screens/loginScreen.dart';





class StudentModel{
final String? id;
final String name;
final String email;
final String phone;


     
 static StudentModel? currentUser;
  StudentModel({
    this.id,
   
   required  this.name,
     required this.email, 
     required this.phone, required profilePick, 

     });

  String? get profilePick => null;
     
       

toJson(){
  return {
    "name":name,
  "email":email,
   "phone":phone,

    };
}

factory StudentModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
  final data = document.data()!;
  return StudentModel(
     id:document.id,
    email:data["email"],
    name: data["name"],
    phone: data["phone"],
     profilePick: null,
     
     );
}
    
}
/*class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}*/