import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/color.dart';
import '../utils/constant.dart';
import '../utils/data.dart';
import '../widgets/category_box.dart';
import '../widgets/custom_image.dart';
import '../widgets/notification_box.dart';
import '../widgets/recommend_item.dart';
import 'Details.dart';
import 'DetailsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String searchQuery = '';
  final CollectionReference courses = FirebaseFirestore.instance.collection(
      'courses');
  List<DocumentSnapshot> filteredOffers = [];


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
                profile["name"]!,
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
          _buildCategories(),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: Text(
              "Featured",
              style: TextStyle(
                color: AppColor.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
          ),
          _buildFeatured(),
          const SizedBox(
            height: 15,
          ),
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
                      color: AppColor.textColor),
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

  _buildCategories() {
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
  }

  _buildRecommended() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 5, 0, 5),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          recommends.length,
              (index) =>
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: RecommendItem(
                  data: recommends[index],
                ),
              ),
        ),
      ),
    );
  }

  _buildFeatured() {
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
                    height: 250, // Set the desired height for your slider
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: false,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal, // Set the scroll direction to horizontal
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final DocumentSnapshot offerSnap = filteredOffers[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => details(offerSnap:offerSnap),
                          ),
                        );
                      },
                      child: Container(
                        width: width, // Set the desired width for each item
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[200],

                        ),
                        child: GestureDetector(
                          onTap: onTap,
                          child: Column(
                            children: [
                              Image.network(
                                offerSnap['images'],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              _buildPrice(offerSnap),
                              _buildInfo(offerSnap),
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
          offerSnap['session'],
        ),
        const SizedBox(
          width: 12,
        ),
        _getAttribute(
          Icons.schedule_rounded,
          AppColor.labelColor,
          offerSnap['duration'],
        ),
        const SizedBox(
          width: 12,
        ),
        _getAttribute(
          Icons.star,
          AppColor.yellow,
          offerSnap['review'],
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
        offerSnap["price"],
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

