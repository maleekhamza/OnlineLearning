import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as Path;
import 'package:elearning_applicaton/screens/Profile/profilePage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


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


  String _selectedDomain = '';
  List<String> domainFields = [
    'Digital Marketing',
    'Information Technology',
    'Design'
        'business'
        'Language'
    // Add more domain fields as needed
  ];
  Uint8List? _imageBytes;
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
        _imageController.text=_userData['imageUrl'] ?? '';
        _selectedDomain = _userData['domain'] ?? '';

      });
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _imageFile;
  bool isObscure = true; // Step 1: Add isObscure variable


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
    if (_imageFile != null) {
      String imageUrl = await _uploadImageToStorage(_imageFile!);
      String fullName = nameController.text;
      String email = emailController.text;
      String phoneNumber = phoneController.text;
      String selectedDomain = _selectedDomain;

      // Upload user data to Firestore
      FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).update({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'domain': selectedDomain,
        'imageUrl': imageUrl,

      });

      // Navigate to ProfilePage after successful upload
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } else {
      // Handle case where no image is selected
      // You may want to display an error message to the user
    }
  }
  String imageUrl = '';



  @override
  Widget build(BuildContext context) {
    //final controller = Get.put(ProfileController());
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(child: Text('Edit Profile',
              style: TextStyle(
                  fontWeight: FontWeight.bold,color: Colors.black
              ))),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black, // Add this line to set the color to black
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
                // -- IMAGE with ICON
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: InkWell(
                        onTap: () async {
                          // Code to select image from gallery or camera
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
                                      // Call a function to handle camera logic here
                                      imagePicker(ImageSource.camera);
                                      Navigator.of(context).pop(); // Close the bottom sheet
                                    },
                                  ),
                                  ListTile(
                                    title: Text('Choose from gallery'),
                                    leading: Icon(Icons.photo_library),
                                    onTap: () {
                                      // Call a function to handle gallery logic here
                                      imagePicker(ImageSource.gallery);
                                      Navigator.of(context).pop(); // Close the bottom sheet
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: ClipOval(
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
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 235, 237, 240),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            // Handle edit button pressed
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          label: Text('Full Name'),
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Enter Full Name',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          label: Text('Email'),
                          prefixIcon: Icon(Icons.email),
                          hintText: 'Enter Email',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          label: Text('Phone Number'),
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Enter Phone Number',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedDomain.isNotEmpty ? _selectedDomain : null,
                        hint: Text('Select Domain'),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedDomain = value ?? '';
                          });
                        },
                        items: domainFields.map((String domain) {
                          return DropdownMenuItem<String>(
                            value: domain,
                            child: Text(domain),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 25),

                      // -- Form Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _uploadImageAndUserData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 243, 242, 242),
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 3,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
 
