import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/color.dart';
import '../utils/constant.dart';
import '../utils/data.dart';
import '../widgets/lesson_item.dart';
import 'package:elearning_applicaton/widgets/custom_image.dart';

import 'PdfViewerScreen.dart';
import 'WebViewPage.dart';



class details extends StatefulWidget {
  final DocumentSnapshot offerSnap;


  details({Key? key, required this.offerSnap}) : super(key: key);

  @override
  State<details> createState() => _detailsState();
}

class _detailsState extends State<details>with SingleTickerProviderStateMixin {
  late TabController tabController;
  late var data;
  String pdfUrl = '';
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }
  

  @override
  Widget build(BuildContext context) {
    // Build the details page UI using the featureData
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Scaffold(
        appBar: buildAppbar(),
        body: buildBody(),
        bottomNavigationBar: getFooter(),
      ),
    );
  }

  buildAppbar() {
    return AppBar(
      title: Center(
        child: Text(
          "Details Page",
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

  buildBody() {
    String base64Image = widget.offerSnap['images']
        .toString()
        .split(',')
        .last;
         Uint8List decodedImage = base64Decode(base64Image);
         String base64String = base64Encode(decodedImage);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        children: [
         CustomImage(
            base64String,
            width: double.infinity,
            height: 200,
          ),
          SizedBox(height: 20,),
          getInfo(),
          SizedBox(height: 20,),
          getTabBar(),
          getTabbarPages(),
        ],
      ),
    );
  }

  Widget getTabBar() {
    return Container(
      child: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              child: Text("lessons",
                style: TextStyle(fontSize: 16, color: Colors.black),),
            ),
            Tab(
              child: Text("Exercices",
                style: TextStyle(fontSize: 16, color: Colors.black),),
            )
          ]),
    );
  }

  Widget getTabbarPages() {
    return Container(
      height: 200,
      width: double.infinity,
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          getLessons(),
          getExercises(),
        ],
      ),
    );
  }

  Widget getExercises() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.offerSnap.id)
        .collection('exercise')
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Text('No exercises available.');
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (BuildContext context, int index) {
          var exercise = snapshot.data!.docs[index];
          return GestureDetector(
            onTap: () {
              // Open the Google Form link when the exercise name is tapped
              launchGoogleForm(exercise['formLink']);
              print(exercise['formLink']);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor.withOpacity(.07),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  exercise["name"],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    // Add functionality for the icon here
                    launchGoogleForm(exercise['formLink']);
                  },
                  icon: Icon(Icons.arrow_forward_ios_rounded),
                  color: Colors.black,
                  iconSize: 24,
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  void launchGoogleForm(String formLink) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(formLink: formLink),
      ),
    );
  }
  Widget getLessons() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.offerSnap.id)
          .collection('lessons')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No lessons available.');
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            var lesson = snapshot.data!.docs[index];
            return GestureDetector(
              onTap: () {
                // Set the PDF URL when the ListTile is tapped
                setState(() {
                  pdfUrl = lesson['file_url'];
                  print(pdfUrl);// Replace 'file_url' with the actual field in your Firestore document containing the PDF URL
                }
                );
                // Open a new screen to display the PDF
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen(pdfUrl: pdfUrl),
                  ),
                );
              },
              child: Container(
  padding: EdgeInsets.all(10),
  margin: EdgeInsets.all(5),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColor.shadowColor.withOpacity(.07),
        spreadRadius: 1,
        blurRadius: 1,
        offset: Offset(1, 1),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: ListTile(
          title: Text(
            lesson["name"],
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                color: Colors.blueGrey,
                size: 14,
              ),
              Text(
                lesson["duration"],
                style: TextStyle(color: Colors.blueGrey, fontSize: 13),
              ),
            ],
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(
                lesson['images'].toString().split(',').last,
              ),
              height: 80,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          // You can add more widgets here based on your requirements
        ),
      ),
      IconButton(
        onPressed: () {
          // Add functionality for the icon here
          setState(() {
                  pdfUrl = lesson['file_url'];
                  print(pdfUrl);// Replace 'file_url' with the actual field in your Firestore document containing the PDF URL
                }
                );
          Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen(pdfUrl: pdfUrl),
                  ),
                );
        },
        icon: Icon(Icons.arrow_forward_ios_rounded),
        color: Colors.black,
        iconSize: 24,
      ),
    ],
  ),
),

            );
          },
        );
      },
    );
  }


Widget getInfo() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Course1",
                style: TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              SizedBox(height: 10,),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              getAttribute(Icons.play_circle_outline, "6 lesson", Colors.grey),
              SizedBox(width: 20,),
              getAttribute(Icons.schedule_outlined, "5 hours", Colors.grey),
              
            ],
          ),
          SizedBox(height: 20,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Course",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),
              ),
              SizedBox(height: 20,),

              ReadMoreText(
                widget.offerSnap['description'],
                trimLines: 2,
                trimMode: TrimMode.Line,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey
                ),
                trimCollapsedText: "Show more",
                moreStyle: TextStyle(fontSize: 14, color: Colors.black),

              )
            ],
          )
        ],
      ),
    );
  }

  Widget getAttribute(IconData icon, String info, Color color) {
    return
      Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          SizedBox(
            width: 5,
          ),

          Text(info, style: TextStyle(color: Colors.grey),)
        ],
      );
  }

  Widget getFooter() {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.offerSnap.id)
        .get(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      if (!snapshot.hasData || !snapshot.data!.exists) {
        return Text('Course data not found.');
      }

      var courseData = snapshot.data!;
      var price = courseData['price'] ?? 'N/A'; // Replace 'price' with your actual field name for price

      return Container(
        width: double.infinity,
        height: 80,
        padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(.05),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 0),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Price",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "\$$price",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 3, 3, 3),
                  ),
                ),
              ],
            ),
            SizedBox(width: 30),
            Expanded(
              child: ElevatedButton(
                
                onPressed: () {
                  // Handle button press
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColor.primary, 
                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),// Set the background color of the button
                ),
                child: Text('Buy Now',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      );
    },
  );
}


}
