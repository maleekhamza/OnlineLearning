import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:elearning_applicaton/theme/color.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/constant.dart';
import 'HomePage.dart';


class AddCourse extends StatefulWidget {
  const AddCourse({Key? key}) : super(key: key);

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController session = TextEditingController();
  TextEditingController review = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController duration = TextEditingController();
  DateTime _selecteddate = DateTime.now();
  CollectionReference ref = FirebaseFirestore.instance.collection('courses');
  Future<void> addOffer() async {
    final  imageurl= await uploadImage(_image!);
    final currentUser = FirebaseAuth.instance.currentUser;
    final data = {
      'name': name.text,
      'description': description.text,
      'session': session.text,
      'review': review.text,
      'price': price.text,
      'duration': duration.text,
      'images':imageurl,
      'timestamp': FieldValue.serverTimestamp(),
      'TeacherID': currentUser?.uid,
      'favourites':[],
    };
    ref.add(data).then((value) {
      ref.doc(value.id).update({
        "id": value.id
      });
    });
  }
  File? _image ;

  final picker = ImagePicker();
  //late String downloadUrl;
  Future imagePicker() async {

    try {
      final pick = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pick != null) {
          _image = File(pick.path);
        } else {
          print("no image selected");
        }
      });
    }  catch (e) {
      print(e.toString());

    }
  }
  Future uploadImage(File _image) async{
    String url;
    String imgId=DateTime.now().microsecondsSinceEpoch.toString();
    Reference reference=  FirebaseStorage.instance.ref().child('images').child('courses$imgId');
    await reference.putFile(_image);
    url=await reference.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text("Add Course"),
          backgroundColor: kPrimaryColor,
        ),

        body: Center(
           child: Container(
          width: 700,

           padding: const EdgeInsets.all(16),
         margin: const EdgeInsets.all(16),
         decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
           borderRadius: BorderRadius.circular(10),
           ),

          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 300,
                  height: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: _image == null?
                          Center(child: Text('no image selected')) :
                          Image.file(
                            _image! ,
                            width: 300,
                            height: 300,),
                        ),
                        MaterialButton(
                          onPressed: () {
                            imagePicker();
                          },
                          child: Text("selected image"),
                          textColor: Colors.white,
                          color: kPrimaryColor,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                    height: 20.0),
                Padding(padding: const EdgeInsets.all(8.0),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                          hintText: 'Offer Name',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,

                          ),
                          filled: true, // ajouter un fond rempli de couleur
                          fillColor: Colors.grey[200], // définir la couleur de l'arrière-plan
                          border: OutlineInputBorder( // définir une bordure de rectangle
                            borderRadius: BorderRadius.circular(8.0), // personnaliser le rayon des coins du rectangle
                            borderSide: BorderSide.none, // supprimer la bordure de ligne
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the  Name of course!';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.all(8.0),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'session',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: session,
                        decoration: InputDecoration(
                          hintText: 'session',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,

                          ),
                          filled: true, // ajouter un fond rempli de couleur
                          fillColor: Colors.grey[200], // définir la couleur de l'arrière-plan
                          border: OutlineInputBorder( // définir une bordure de rectangle
                            borderRadius: BorderRadius.circular(8.0), // personnaliser le rayon des coins du rectangle
                            borderSide: BorderSide.none, // supprimer la bordure de ligne
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the session !';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.all(8.0),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'review',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: review,
                        decoration: InputDecoration(
                          hintText: 'review',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,

                          ),
                          filled: true, // ajouter un fond rempli de couleur
                          fillColor: Colors.grey[200], // définir la couleur de l'arrière-plan
                          border: OutlineInputBorder( // définir une bordure de rectangle
                            borderRadius: BorderRadius.circular(8.0), // personnaliser le rayon des coins du rectangle
                            borderSide: BorderSide.none, // supprimer la bordure de ligne
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the review !';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.all(8.0),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'price',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: price,
                        decoration: InputDecoration(
                          hintText: 'price',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,

                          ),
                          filled: true, // ajouter un fond rempli de couleur
                          fillColor: Colors.grey[200], // définir la couleur de l'arrière-plan
                          border: OutlineInputBorder( // définir une bordure de rectangle
                            borderRadius: BorderRadius.circular(8.0), // personnaliser le rayon des coins du rectangle
                            borderSide: BorderSide.none, // supprimer la bordure de ligne
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the price !';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.all(8.0),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: duration,
                        decoration: InputDecoration(
                          hintText: 'duration ',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,

                          ),
                          filled: true, // ajouter un fond rempli de couleur
                          fillColor: Colors.grey[200], // définir la couleur de l'arrière-plan
                          border: OutlineInputBorder( // définir une bordure de rectangle
                            borderRadius: BorderRadius.circular(8.0), // personnaliser le rayon des coins du rectangle
                            borderSide: BorderSide.none, // supprimer la bordure de ligne
                          ),
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the duration Date !';
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime? pickeddate = await showDatePicker(
                            context: context,
                            initialDate: _selecteddate, // Use the current value of _selecteddate as the initial date
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (pickeddate != null && pickeddate != _selecteddate) {
                            setState(() {
                              _selecteddate = pickeddate; // Update the value of _selecteddate
                              duration.text = pickeddate.toString();
                              duration.text = DateFormat('MM/dd/yyyy').format(_selecteddate);

                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.all(8.0) ),
                SizedBox(height: 18),
                Padding(padding: const EdgeInsets.all(8.0),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10,),
                      // définir la hauteur souhaitée du TextFormField
                      TextFormField(
                        controller: description,
                        decoration: InputDecoration(

                          contentPadding: EdgeInsets.symmetric(vertical: 55.0), // définir la marge interne de la zone de saisie
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          filled: true, // ajouter un fond rempli de couleur
                          fillColor: Colors.grey[200], // définir la couleur de l'arrière-plan
                          border: OutlineInputBorder( // définir une bordure de rectangle
                            borderRadius: BorderRadius.circular(8.0), // personnaliser le rayon des coins du rectangle
                            borderSide: BorderSide.none, // supprimer la bordure de ligne
                          ),
                        ),
                        maxLines: null, // permet à l'utilisateur d'écrire autant de lignes qu'il souhaite
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the event description';
                          }
                          return null;
                        },
                      ),

                    ],
                  ),
                ),
                SizedBox(height: 18),
                ElevatedButton(onPressed: () {
                  addOffer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage();
                      },
                    ),
                  );
                },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          kPrimaryColor,)
                    ),
                    child: Text("Submit",
                      style: TextStyle(fontSize: 20),
                    )
                ),
                SizedBox(height: 12,),
              ],
            ),
          ),
        ),
        ),
      );
  }
}

