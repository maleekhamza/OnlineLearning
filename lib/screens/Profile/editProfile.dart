import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as Path;
import 'package:elearning_applicaton/screens/Profile/profilePage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();
class EditProfileScreen extends StatefulWidget {
   EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
TextEditingController nameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController _imageController  = TextEditingController();

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
         emailController.text = _userData['email'] ?? '';
      nameController.text = _userData['fullName'] ?? ''; // Set value to nameController
      phoneController.text = _userData['phoneNumber'] ?? '';
      });
    }
  }

 final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _imageFile;
   bool isObscure = true; // Step 1: Add isObscure variable
/*void _showImagePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            // Add more options like 'Camera' if needed
          ],
        ),
      );
    },
  );
}*/
  /*Future<void> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: source);
  if (pickedImage != null) {
    setState(() {
      _imageFile = File(pickedImage.path);
      _imageController.text = Path.basename(_imageFile!.path);
    });
  }
}*/
 
 Future<void> imagePicker(ImageSource source) async {
    try {
      final pick = await picker.pickImage(source: source);
      setState(() {
        if (pick != null) {
          _imageFile = File(pick.path);
        } else {
          print("No image selected");
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _uploadImageAndUserData() async {
    // if (_imageFile != null) {
      //String imageUrl = await _uploadImageToStorage(_imageFile!);
      String fullName = nameController.text;
      String email = emailController.text;
      String phoneNumber = phoneController.text;

      // Upload user data to Firestore
     FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).update({
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    //'imageUrl': imageUrl,
    // Add other fields as needed
  });

      // Navigate to ProfilePage after successful upload
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
   // } else {
      // Handle case where no image is selected
      // You may want to display an error message to the user
   //}
  }
  String imageUrl = '';

   

  @override
  Widget build(BuildContext context) {
    //final controller = Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 172, 212, 247), 
        title: Center(
          child: Text('Edit profile', style: TextStyle( color: Colors.white,)),),
        
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // -- IMAGE with ICON
            Stack(
  children: [
    SizedBox(
      width: 120,
      height: 120,
      child: InkWell(
        onTap: () async {
          await showModalBottomSheet(
            context: context,
            builder: (_) => BottomSheet(
              onClosing: () {},
              builder: (_) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Take a photo'),
                    leading: Icon(Icons.camera_alt),
                    onTap: () {
                       imagePicker(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text('Choose from gallery'),
                    leading: Icon(Icons.photo_library),
                    onTap: () {
                       imagePicker(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: ClipOval(
                      child: _imageFile != null && _imageFile!.existsSync()
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : imageUrl.isNotEmpty
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
                ),
    Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            // Handle edit button pressed
          },
        ),
      ),
    ),
  ],
),
              const SizedBox(height: 50),

              // -- Form Fields
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          label: Text('FullName'), prefixIcon: Icon(Icons.edit)),
                    ),
                    const SizedBox(height:5),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          label:  Text('email'), prefixIcon: Icon(Icons.email)),
                       
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                          label: Text('PhoneNumber'), prefixIcon: Icon(Icons.phone)),
                    ),
                  const SizedBox(height: 10),
                    

      

                 
                    // -- Form Submit Button
                   SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      _uploadImageAndUserData();
    },
    style: ElevatedButton.styleFrom(
      primary: const Color.fromARGB(255, 134, 196, 247), // Background color
      onPrimary: Colors.white, // Text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0), // Rounded edges
      ),
      elevation: 3, // Elevation (shadow)
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        'EditProfile',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    ),
  ),
)

                    // -- Created Date and Delete Button
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> _uploadImageToStorage(File file) async {
  final storageRef = FirebaseStorage.instance.ref().child('${Path.basename(file.path)}');
  final uploadTask = storageRef.putFile(file);
  final snapshot = await uploadTask;
  return snapshot.ref.getDownloadURL();
}
 
