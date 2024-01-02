import 'package:elearning_applicaton/screens/loginScreen.dart';
import 'package:elearning_applicaton/screens/loginScreen.dart';
import 'package:elearning_applicaton/screens/root_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth extends StatelessWidget {
  const Auth({super.key, required Type auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: ((Context, snapshot){
              if(snapshot.hasData){
                return RootApp();
              }else{
                return LoginScreen();
              }
            }


            ))



    );

  }
}