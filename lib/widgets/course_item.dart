import 'package:cached_network_image/cached_network_image.dart';
import 'package:elearning_applicaton/theme/color.dart';
import 'package:elearning_applicaton/utils/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CourseItem extends StatelessWidget {
 CourseItem({Key ? key,required this.data}):super(key: key);
 final data;

  @override
  Widget build(BuildContext context) {
    return Container(
       width: 200,
       height: 290,
       padding: EdgeInsets.all(10),
       margin: EdgeInsets.only(top: 5,bottom: 5),
       decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColor.shadowColor.withOpacity(.05),
                  spreadRadius: .5,
                  blurRadius: .5,
                  offset: Offset(0, 0)
                )
              ]
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  child: CachedNetworkImage(
                    imageBuilder:(context, ImageProvider)=>Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(image:ImageProvider,fit: BoxFit.cover)
                      ),
                    ),
                    imageUrl: data[0]["image"],
                  ),
                ),
                Positioned(
                  top: 175,
                  right: 15,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadowColor.withOpacity(.05),
                          spreadRadius: .5,
                          blurRadius: .5,
                          offset: Offset(1,1)
                        )
                      ]
                    ),
                    child: SvgPicture.asset(
                      "assets\icons\bookmark.svg",
                      color: Colors.red,
                      width: 25,
                      height: 25,
                    ),
                  )
                ),
                Positioned(
                  top: 210,
                  child:Container(
                    width: MediaQuery.of(context).size.width -60,
                    child: Column(
                      children: [
                        Text(
                          data[0]["name"],style: TextStyle(
                        fontSize: 18,fontWeight: FontWeight.w500
                      ),),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        getAttribute(Icons.sell_outlined, data[0]["price"],Colors.grey),
                        getAttribute(Icons.play_circle_outline, data[0]["session"],Colors.grey),
                        getAttribute(Icons.schedule_outlined, data[0]["duration"],Colors.grey),
                        getAttribute(Icons.star, data[0]["review"].toString(),Colors.yellow),


                                ],)

                      ],
                    ),
                  )
                   ),
              ],
            ),

      );
  }
  getAttribute(IconData icon,String name, Color color){
    return Row(
    children: [
     Icon(
      icon
     ,size: 18,color: Colors.grey,),
    SizedBox(
    width: 5,

    ),
    Text(
      name,
      style: TextStyle(fontSize: 13,color: Colors.grey),)

    ],
  );
  }
}
