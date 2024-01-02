
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning_applicaton/Screens/loginScreen.dart';
import 'package:elearning_applicaton/screens/Profile/editProfile.dart';


import 'package:elearning_applicaton/widgets/profileMenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _imageController  = TextEditingController();
  late User? _currentUser;
  File? _imageFile;
  String imageUrl = '';
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
        _imageController.text = _userData['imageUrl'] ?? '';

        // Update the imageUrl variable with the value from Firestore
        imageUrl = _userData['imageUrl'] ?? '';
        // Debugging: Print the image URL
        print('Image URL: $imageUrl');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Scaffold(
        appBar:  AppBar(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
                      child:ClipOval(
                        child: (_imageFile != null && _imageFile!.existsSync())
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : (imageUrl.isNotEmpty)
                            ? Image.network(
                          imageUrl,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                            : Image.asset('assets/icons/profile.png'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Color.fromARGB(255, 235, 237, 240)),
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

                ElevatedButton(
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

                      backgroundColor:Color.fromARGB(255, 243, 242, 242), side: BorderSide.none, shape: const StadiumBorder()),
                  child: const Text('EditProfile', style: TextStyle(color: Colors.black)),
                ),

                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),

                /// -- MENU
                ProfileMenuWidget(
                  title: "Courses in progress",
                  icon: Icons.class_,
                  endIcon: Icons.arrow_forward_ios,
                  textColor: Colors.black,
                  onPress: () {
                    // Action to perform when "Courses in progress" card is tapped
                  },
                ),
                ProfileMenuWidget(
                  title: "Results",
                  icon: Icons.assessment,
                  endIcon: Icons.arrow_forward_ios,
                  textColor: Colors.black,
                  onPress: () {
                    // Action to perform when "Results" card is tapped
                  },
                ),
                const Divider(),

                ProfileMenuWidget(
                    title: "Se déconnecter",
                    icon: CupertinoIcons.power,
                    endIcon: Icons.arrow_forward_ios,
                    textColor: Colors.black,

                    onPress: (){

                      showDialog(
                          context: context,
                          builder: (context){
                            return Container(

                            );
                          });


                    })
              ],
            ),
          ),
        ),
      ),
    );
  }


}


