import 'package:elearning_applicaton/theme/color.dart';
import 'package:elearning_applicaton/utils/data.dart';
import 'package:elearning_applicaton/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class LessonItem extends StatelessWidget {
  const LessonItem({Key? key,required this.data}):super(key:key);
  final data;
  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          CustomImage(
            data["image"],
            radius: 10,
            width: 70,
            height: 70,),
          SizedBox(width: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                 data["name"],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,

                  ),
                ),

                SizedBox(height: 10,),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      color: Colors.blueGrey,
                      size: 14,
                    ),
                    Text(
                      data["duration"],
                      style: TextStyle(color: Colors.blueGrey,fontSize: 13),
                    ),
                  ],
                )
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueGrey, size: 15,)
        ],
      ),
    );
  }
}

