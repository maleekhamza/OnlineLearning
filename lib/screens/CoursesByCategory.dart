import 'dart:convert';



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/color.dart';

class CoursesByCategory extends StatefulWidget {
  final String selectedCategory;

  CoursesByCategory({required this.selectedCategory});

  @override
  State<CoursesByCategory> createState() => _CoursesByCategoryState();
}
class _CoursesByCategoryState extends State<CoursesByCategory> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Scaffold(
        appBar: buildAppbar(),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _buildCoursesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search by course name',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          // Implement filtering logic here
          // You may want to use a separate method to filter the courses based on the search input
          setState(() {
            // Update the UI based on the filtered courses
          });
        },
      ),
    );
  }
  buildAppbar() {
    return AppBar(
      title: Center(
        child: Text(
          "Courses Of ${widget.selectedCategory}'",
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

  Widget _buildCoursesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('category', isEqualTo: widget.selectedCategory)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No courses available for this category.'));
        } else {
          List<DocumentSnapshot> filteredCourses = snapshot.data!.docs
              .where((courseSnap) {
            String courseName = courseSnap['name'].toString().toLowerCase();
            String searchTerm = searchController.text.toLowerCase();
            return courseName.contains(searchTerm);
          })
              .toList();

          return ListView.builder(
            itemCount: filteredCourses.length,
            itemBuilder: (context, index) {
              DocumentSnapshot courseSnap = filteredCourses[index];
              return _buildCourseCard(context, courseSnap);
            },
          );
        }
      },
    );
  }

  int _parseDiscount(String? discount) {
    return int.tryParse(discount ?? "") ?? 0;
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
                    base64Decode(courseSnap['images']
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
        ],
      ),
    ),
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
            offerSnap['name'],
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