import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/color.dart';

class PurchasedCoursesScreen extends StatefulWidget {
  @override
  _PurchasedCoursesScreenState createState() => _PurchasedCoursesScreenState();
}

class _PurchasedCoursesScreenState extends State<PurchasedCoursesScreen> {
  @override
  Widget build(BuildContext context) {
      return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Scaffold(
        appBar: buildAppbar(),
        body: buildPurchasedCoursesList(),
      ),
    );


  }
  buildAppbar() {
    return AppBar(
      title: Center(
        child: Text(
          "Purchased Courses",
          style: TextStyle(color: Colors.black),
        ),
      ),
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ), onPressed: () {
        Navigator.of(context).pop();
      },
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () {}),

      ],
    );
  }
  Widget buildPurchasedCoursesList() {
    // Retrieve the current user
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // Handle the case where the user is not authenticated
      return Center(
        child: Text('User not authenticated'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('purchasedCourses')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No purchased courses.'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            var courseSnap = snapshot.data!.docs[index];

            // Extract information from the document
            String courseName = courseSnap['courseName'];
            String courseImage = courseSnap['image'];
            String courseDuration = courseSnap['duration'];
            String courseSession = courseSnap['session'];
            String coursePrice = courseSnap['price'];
            String courseDiscount = courseSnap['discount'];


            return _buildCourseCard(context,courseSnap);
          },
        );
      },
    );
  }
  int _parseDiscount(String? discount) {
    return int.tryParse(discount ?? "") ?? 0;
  }
  void _deleteCourse(String courseId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('purchasedCourses')
            .doc(courseId)
            .delete();

        // You may also want to show a success message or update the UI accordingly
      } catch (e) {
        print('Error deleting course: $e');
        // Handle the error, show an error message, or log it
      }
    }
  }
  Widget _buildCourseCard(BuildContext context,DocumentSnapshot courseSnap) {
    return Container(
      width: 250,
      height: 260,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 5, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(1, 1),
          )
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      base64Decode(courseSnap['image']
                          .toString()
                          .split(',')
                          .last),
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 10,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 9,),
                Positioned(
                  top: 160,
                  child: _buildInfo(courseSnap),
                ),
              ],
            ),
            Positioned(
              top: 5, // Adjust this value to your desired position for the discount
              right: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_parseDiscount(courseSnap['discount']) > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${courseSnap['discount']}% off',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 150, // Adjust the top value for positioning
              right: 15,
              child: _buildPrice(courseSnap),
            ),
            // Delete Icon
            Positioned(
              top: 200,

              left: 350,
              child: GestureDetector(
                onTap: () {
                  // Handle delete logic here
                  _showDeleteConfirmationDialog(courseSnap);
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
// Function to show the delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog(DocumentSnapshot courseSnap) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Card(
            margin: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Delete Confirmation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Divider(height: 0),
                ListTile(
                  title: Text('Are you sure you want to delete this course?'),
                ),
                ButtonBar(
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Perform the delete operation
                        _deleteCourse(courseSnap.id);
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(DocumentSnapshot offerSnap) {
    return Container(
      //  width: width - 20,
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offerSnap['courseName'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              color: AppColor.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          _buildAttributes(offerSnap),
        ],
      ),
    );
  }

  Widget _buildAttributes(DocumentSnapshot courseSnap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _getAttribute(
          Icons.play_circle_outlined,
          AppColor.labelColor,
          '${courseSnap['session'].toString()} lessons',
        ),
        const SizedBox(
          width: 12,
        ),
        _getAttribute(
          Icons.schedule_rounded,
          AppColor.labelColor,
          '${courseSnap['duration'].toString()} h',
        ),
        const SizedBox(
          width: 12,
        ),
        // Add more attributes if needed
      ],
    );
  }

  Widget _getAttribute(IconData icon, Color color, String info) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          info,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColor.labelColor, fontSize: 13),
        ),
      ],
    );
  }
  Widget _buildPrice(DocumentSnapshot courseSnap) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.primary, // Change color as needed
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        '${courseSnap['price'].toString()} dt',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  late GestureTapCallback onTap = () {
    // Add your custom logic here
  };

}