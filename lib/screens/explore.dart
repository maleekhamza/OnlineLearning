import 'package:cached_network_image/cached_network_image.dart';
import 'package:elearning_applicaton/theme/color.dart';
import 'package:elearning_applicaton/utils/data.dart';
import 'package:elearning_applicaton/widgets/category_item.dart';
import 'package:elearning_applicaton/widgets/course_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColor.appBarColor,
            pinned: true,
            title: getAppBar(),
          ),
          SliverToBoxAdapter(
            child: getSearchBox(),
          ),
          SliverToBoxAdapter(
            child: getCategories(),
          ),
          SliverList(delegate: getCourses(),)
        ],
      ),
    );
  }
  getAppBar(){
    return Container(
      child: Row(
        children: [
          Text("Explore",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600,fontSize: 24),)
        ],
      ),
    );
  }

  getSearchBox() {
    return Padding(
      padding: const EdgeInsets.only(left: 15,right: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: AppColor.shadowColor.withOpacity(.05),
                        spreadRadius: .5,
                        blurRadius: .5,
                        offset: Offset(0, 0)
                    )
                  ]
              ),
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey,),
                    border: InputBorder.none,
                    hintText: "Search"
                  // hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              "assets/icons/filter.svg",
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
  int selectedCategoryIndex=0;
  getCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 15,top: 10,bottom: 5),
      child: Row(
          children: List.generate(categories.length, (index) => CategotyItem(
            onTap: () {
              setState(() {
                selectedCategoryIndex=index;
              });
            },
            isActive: selectedCategoryIndex==index,
            data: categories[index],
          ))
      ),
    );
  }

  getCourses() {
    return SliverChildBuilderDelegate(
          (context, index) {
        return Padding(
            padding: const EdgeInsets.only(top: 10,left: 15,right: 15),
            child: CourseItem(data: courses[index])
        );

      },
      childCount:courses.length,
    );
  }

}