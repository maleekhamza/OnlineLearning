
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning_applicaton/Screens/loginScreen.dart';
import 'package:elearning_applicaton/screens/Profile/editProfile.dart';
import 'package:elearning_applicaton/screens/repository/authenticationRepository.dart';
import 'package:elearning_applicaton/screens/repository/userRepository.dart';
import 'package:elearning_applicaton/widgets/profileMenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';




class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
    
 late User? _currentUser;
  late Map<String, dynamic> _userData = {};
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
   Future<void> _fetchUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      setState(() {
        _currentUser = user;
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      setState(() {
        _userData = snapshot.data() ?? {};
      
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, 
        title: Center(child: Text('profile', style: Theme.of(context).textTheme.headline4)),
        
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [

              /// -- IMAGE
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100), 
                        child:Image.asset('assets/icons/profile.png')),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.blue),
                      child: const Icon(
                      Icons.edit,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(_userData['fullName'] ?? 'Name', style: Theme.of(context).textTheme.headline4),
              Text(_currentUser?.email ?? 'Email', style: Theme.of(context).textTheme.bodyText2),
              const SizedBox(height: 20),

              /// -- BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                   Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return EditProfileScreen();
                  },
                ),
              );
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor:Colors.blue, side: BorderSide.none, shape: const StadiumBorder()),
                  child: const Text('EditProfile', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// -- MENU
              ProfileMenuWidget(title: "Settings", icon: Icons.settings, onPress: () {}),
              ProfileMenuWidget(title: "Notifications", icon: Icons.notifications, onPress: () {}),
              
              const Divider(),
             
               ProfileMenuWidget(
                title: "Se déconnecter",
                 icon: CupertinoIcons.power,
                 textColor: Colors.black,
                 endIcon: false,
                  onPress: (){
                    showDialog(
                      context: context,
                      builder: (context){
                        return Container(
                          child: AlertDialog(
                            title: Text('Voulez-vous déconnectez ?'),
                            actions: [
                       TextButton(onPressed:(){
                        Navigator.pop(context);
                              }, 
                              child: Text('Non')),
                              TextButton(onPressed:(){
                                print("pressed here");
                                AuthentificationRepository.instance.logout().
                                            then((value) {
                                  print("signed out");
                                  Navigator.push(context, 
                                  MaterialPageRoute(builder: (context)=>LoginScreen()));
                           });
                              }, 
                              child: Text('Oui',style: TextStyle(color:Colors.blue),)),
                            ],
                          ),
                        );
                      });
               
          
  })],
          ),
        ),
      ),
    );
  }
}