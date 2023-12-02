import 'dart:convert';
import 'dart:io';

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
    return Scaffold(
      appBar: buildAppbar(),
      body: buildBody(),
    );
  }

  buildAppbar() {
    return AppBar(
      title: Text(
        "Details Page",
        style: TextStyle(color: Colors.white),
      ),
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.grey,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
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
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        children: [
          Image.memory(
            base64Decode(widget.offerSnap['images']
                .toString()
                .split(',')
                .last),
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
            Container(
              child: Center(child: Text("Excercices")),
            ),


          ]),
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
                });
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
              SizedBox(width: 20,),
              getAttribute(Icons.star, "4.5", Colors.yellow)
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
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(.005),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 0),
            )
          ]
      ),
      child: Row(
          children: [
            Column(
              children: [
                Text("price"),
                Text("price"),
              ],
            ),
          ]),
    );
  }

}
