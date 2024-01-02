
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning_applicaton/screens/quiz_play.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../services/database.dart';
import '../widgets/widget.dart';


class QuizScreen extends StatefulWidget {
late final String courseId;
QuizScreen({required this.courseId});

@override
_QuizScreenState createState() => _QuizScreenState();
}


class _QuizScreenState extends State<QuizScreen> {
  late Stream<QuerySnapshot> quizStream;
  DatabaseService databaseService = new DatabaseService(uid: '');

  Widget quizList() {
    return Container(
      child: Column(
        children: [
          StreamBuilder(
            stream: quizStream,
            builder: (context, snapshot) {
              return snapshot.data == null
                  ? Container()
                  :  ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var quizData = snapshot.data!.docs[index].data() as Map<String,dynamic>; // Get the data map
                  return QuizTile(
                    noOfQuestions: snapshot.data!.docs.length,
                    imageUrl: quizData['quizImgUrl'] ,
                    title: quizData['quizTitle'] ,
                    description: quizData['quizDesc'],
                    quizid: quizData['quizId'],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    databaseService.getQuizData().then((value) {
      quizStream = value;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppLogo(),

        elevation: 0.0,
        backgroundColor: Colors.transparent,
        //brightness: Brightness.li,
      ),
      body: quizList(),

    );
  }
}

class QuizTile extends StatelessWidget {
  final String imageUrl, title, quizid, description;
  final int noOfQuestions;

  QuizTile(
      {required this.title,
        required this.imageUrl,
        required this.description,
        required this.quizid,
        required this.noOfQuestions});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => QuizPlay(quizid)
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.network(
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                imageUrl,
              ),
              Container(
                color: Colors.black26,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4,),
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}