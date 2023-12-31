import 'dart:convert';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning_applicaton/screens/AllCourses.dart';
import 'package:elearning_applicaton/screens/FavoritesPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elearning_applicaton/screens/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../theme/color.dart';
import '../utils/data.dart';
import '../widgets/category_box.dart';
import '../widgets/notification_box.dart';
import '../widgets/recommend_item.dart';
import 'CoursesByCategory.dart';
import 'Details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late User? _currentUser;
  late Map<String, dynamic> _userData = {};

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

  String searchQuery = '';
  final CollectionReference courses = FirebaseFirestore.instance.collection(
      'courses');
  String selectedCategory = '';
  List<DocumentSnapshot> filteredOffers = [];

  Future<void> _fetchCoursesByCategory(String category) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      filteredOffers = snapshot.docs;
    });
  }
  void filterOffers(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      filteredOffers = snapshot.data!.docs.where((offerSnap) {
        final offerName = offerSnap['name'].toString().toLowerCase();
        return offerName.contains(searchQuery.toLowerCase());
      }).toList();
    }
  }


  // Initialize 'width' and 'height' here, based on your requirements.

  late GestureTapCallback onTap = () {
    // Add your custom logic here
  };


  double width = 0; // Initialize to any default value
  double height = 0; // Initialize to any default value
  @override
  void initState() {

    super.initState();
    _fetchUserData();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        width = MediaQuery.of(context).size.width;
        height = MediaQuery.of(context).size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColor.appBarColor,
            pinned: true,
            snap: true,
            floating: true,
            title: _buildAppBar(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildBody(),
              childCount: 1,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile["name"] ?? 'No Name Available',
                style: TextStyle(
                  color: AppColor.labelColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                "Good Morning!",
                style: TextStyle(
                  color: AppColor.textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        NotificationBox(
          notifiedNumber: 1,
        )
      ],
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadowColor.withOpacity(.05),
                          blurRadius: .5,
                          spreadRadius: .5,
                          offset: Offset(0, 0),
                        )
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/filter.svg",
                    color: Colors.white, // Set the desired color
                  ),

                ),
              ],
            ),
          ),
          _buildCategories(),
          const SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Featured",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllCourses(),
                      ),
                    );
                  },
                  child: Text(
                    "See all",
                    style: TextStyle(fontSize: 14, color: AppColor.darker),
                  ),
                ),
              ],
            ),
          ),
          _buildFeatured(),
          const SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recommended",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textColor,
                  ),
                ),
                Text(
                  "See all",
                  style: TextStyle(fontSize: 14, color: AppColor.darker),
                ),
              ],
            ),
          ),
          _buildRecommended(),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    bool isSelected = false;
    Color selectedColor = AppColor.actionColor; // Replace this with your desired color
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state while waiting for data
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error
          return Text('Error: ${snapshot.error}');
        } else {
          // Data loaded successfully
          List<DocumentSnapshot> categoryDocs = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categoryDocs.map((doc) {
                Map<String, dynamic> categoryData = doc.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CoursesByCategory(selectedCategory: categoryData["libelle"]),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn,
                          padding: EdgeInsets.all(0.8),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.shadowColor.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(1, 1),
                              ),
                            ],
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              categoryData["image"],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          categoryData["libelle"],
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: AppColor.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
  /*_buildCategories() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
              (index) =>
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: CategoryBox(
                  selectedColor: Colors.white,
                  data: categories[index],
                  onTap: null,
                ),
              ),
        ),
      ),
    );
  }*/

  Widget _buildRecommended() {
    return _buildFeaturedWithoutDiscount();

    /*return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 5, 0, 5),
      scrollDirection: Axis.horizontal,
      child: Container( // Wrap the Row with a Container
        child: Row(
          children: List.generate(
            recommends.length,
                (index) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Expanded(
                child: RecommendItem(
                  data: recommends[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );*/
  }
  int _parseDiscount(String? discount) {
    return int.tryParse(discount ?? "") ?? 0;
  }
  Widget _buildFeatured() {
    final bool isShadow = true;
    final Color? borderColor;
    final Color? bgColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder(
            stream: courses.orderBy('timestamp', descending: true).snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              filterOffers(snapshot);

              if (snapshot.hasData) {
                // Filter the offers that have a discount
                List<DocumentSnapshot> offersWithDiscount = filteredOffers
                    .where((offerSnap) =>
                _parseDiscount(offerSnap['discount']) > 0)
                    .toList();

                return CarouselSlider.builder(
                  itemCount: offersWithDiscount.length,
                  options: CarouselOptions(
                    height: 290,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: false,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    disableCenter: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final DocumentSnapshot offerSnap = offersWithDiscount[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                details(offerSnap: offerSnap),
                          ),
                        );
                      },
                      child: Container(
                        width: 340,
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
                                        base64Decode(offerSnap['images']
                                            .toString()
                                            .split(',')
                                            .last),
                                        width: MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.2,
                                        height: 10,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 9),
                                  Positioned(
                                    top: 160,
                                    child: _buildInfo(offerSnap),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 5, // Adjust this value to your desired position for the discount
                                right: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (_parseDiscount(offerSnap['discount']) > 0)
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
                                          '${offerSnap['discount']}% off',
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
                                child: _buildPrice(offerSnap),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedWithoutDiscount() {
    final bool isShadow=true;
    final Color? borderColor;
    final Color? bgColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder(
            stream: courses.orderBy('timestamp', descending: true).snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              filterOffers(snapshot);

              if (snapshot.hasData) {
                return CarouselSlider.builder(
                  itemCount: filteredOffers.length,
                  options: CarouselOptions(
                    height: 290,
                    enableInfiniteScroll: false,
                    reverse: false,
                    autoPlay: false,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    disableCenter: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final DocumentSnapshot offerSnap = filteredOffers[index];
                    if (_parseDiscount(offerSnap['discount']) == 0) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => details(offerSnap: offerSnap),
                            ),
                          );
                        },
                        child: Container(
                          width:340,
                          height: 260,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(bottom: 5,top: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(.1),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(1,1)
                                )
                              ]
                          ),
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
                                        base64Decode(offerSnap['images']
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
                                      child: _buildInfo(offerSnap)),
                                ],
                              ),
                              Positioned(
                                top: 150, // Adjust the top value for positioning
                                right: 15,
                                child: _buildPrice(offerSnap),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(); // Don't display if there is a discount
                    }
                  },
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(DocumentSnapshot offerSnap) {
    return Container(
      width: width - 20,
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

  Widget _buildAttributes(DocumentSnapshot offerSnap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _getAttribute(
          Icons.play_circle_outlined,
          AppColor.labelColor,
          '${offerSnap['session'].toString()} lessons',
        ),
        const SizedBox(
          width: 12,
        ),
        _getAttribute(
          Icons.schedule_rounded,
          AppColor.labelColor,
          '${offerSnap['duration'].toString()} h',
        ),
        
       
      ],
    );
  }
  _getAttribute(IconData icon, Color color, String info) {
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

  Widget _buildPrice(DocumentSnapshot offerSnap) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        '${offerSnap['price'].toString()} dt',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}