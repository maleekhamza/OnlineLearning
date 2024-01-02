import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:elearning_applicaton/screens/quizScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http ;

import '../utils/constant.dart';
import '../theme/color.dart';

import 'package:elearning_applicaton/widgets/custom_image.dart';
import 'PaymentPage.dart';
import 'PdfViewerScreen.dart';
import 'PurchasedCoursesScreen.dart';
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
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    checkIfCoursePurchased();
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



  /*return
    StreamBuilder<QuerySnapshot>(
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
  );*/

    Widget getExercises() {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Quiz')
            .where('courseId', isEqualTo: widget.offerSnap.id)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No quizzes available.');
          }

          // Use FutureBuilder to handle the asynchronous operation
          return FutureBuilder<bool>(
            future: checkIfCoursePurchased(),
            builder: (BuildContext context, AsyncSnapshot<bool> purchasedSnapshot) {
              if (purchasedSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              // Check if the user has purchased the course
              bool isCoursePurchased = purchasedSnapshot.data ?? false;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var quiz = snapshot.data!.docs[index];

                  // Check if the quiz is accessible based on the purchase status
                  bool isQuizAccessible = isCoursePurchased;

                  // Set the background color based on the accessibility of the quiz
                  Color backgroundColor = isQuizAccessible
                      ? Colors.white
                      : Colors.grey.withOpacity(0.1);

                  return GestureDetector(
                    onTap: () {
                      // Add functionality when the quiz is tapped
                      // For example, navigate to the quiz screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(courseId: widget.offerSnap.id),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: backgroundColor,
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
                          quiz["quizTitle"],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          quiz["quizDesc"],
                          style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                        ),
                      ),
                    ),
                  );
                },
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

        // Use FutureBuilder to handle the asynchronous operation
        return FutureBuilder<bool>(
          future: checkIfCoursePurchased(),
          builder: (BuildContext context, AsyncSnapshot<bool> purchasedSnapshot) {
            if (purchasedSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            // Check if the user has purchased the course
            bool isCoursePurchased = purchasedSnapshot.data ?? false;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var lesson = snapshot.data!.docs[index];

                // Check if the lesson is accessible based on the purchase status
                bool isLessonAccessible = isCoursePurchased || index == 0;

                // Set the background color based on the accessibility of the lesson
                Color backgroundColor = isLessonAccessible
                    ? Colors.white
                    : Colors.grey.withOpacity(0.1);

                return GestureDetector(
                  onTap: () {
                    // Set the PDF URL when the ListTile is tapped
                    setState(() {
                      pdfUrl = lesson['file_url'];
                      print(pdfUrl);
                    });
                    // Open a new screen to display the PDF only if the lesson is accessible
                    if (isLessonAccessible) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerScreen(pdfUrl: pdfUrl),
                        ),
                      );
                    } else {
                      // Show an alert indicating that the lesson is not accessible
                      _showBuyCourseAlert(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: backgroundColor,
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
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Add functionality for the icon here
                            setState(() {
                              pdfUrl = lesson['file_url'];
                              print(pdfUrl);
                            });
                            // Navigate to the PDF viewer screen only if the lesson is accessible
                            if (isLessonAccessible) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfViewerScreen(pdfUrl: pdfUrl),
                                ),
                              );
                            } else {
                              // Show a message or perform an action indicating that the lesson is not accessible
                              print('You need to purchase the course to access this lesson.');
                            }
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
      },
    );
  }
  // Function to show an alert to buy the course
  Future<void> _showBuyCourseAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Alert',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Divider(height: 0),
              ListTile(
                title: Text('You can\'t access this lesson.'),
                subtitle: Text('You should buy the course first.'),
              ),
              ButtonBar(
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  Future<bool> checkIfCoursePurchased() async {
    // Retrieve the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check if the user has purchased the course by querying the 'purchasedCourses' subcollection
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('purchasedCourses')
          .where('courseId', isEqualTo: widget.offerSnap.id)
          .get();
      return snapshot.docs.isNotEmpty;
    }

    return false; // Return false if the user is not authenticated
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
                widget.offerSnap['name'],
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
              getAttribute(Icons.play_circle_outline,  '${widget.offerSnap['session'].toString()} lessons', Colors.grey),
              SizedBox(width: 20,),
              getAttribute(Icons.schedule_outlined, '${widget.offerSnap['duration'].toString()} H', Colors.grey),

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
                onPressed: () async {
                  print('Make payment button cliked');
                  await makePayment();
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


  Future<void> makePayment() async {
    try {
      // Fetch the course data from Firestore
      DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.offerSnap.id)
          .get();

      // Get the price from the course data
      var price = courseSnapshot['price'];

      // Convert the price to the required format (e.g., '10.00' for $10.00)
      String formattedPrice = calculateAmount(price.toString());

        // Create a payment intent using the retrieved price
        paymentIntent = await createPaymentIntent(formattedPrice, 'USD');
        // Payment Sheet
        await Stripe.instance
            .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            style: ThemeMode.dark,
            merchantDisplayName: 'Adnan',
          ),
        )
            .then((value) {});

        // Display the payment sheet
        displayPaymentSheet();
     // Handle the case where the user is not authenticated or the email is null.

    } catch (e, s) {
      print('exception:$e$s');
    }
  }
  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Text("Payment Successful"),
                  ],
                ),
              ],
            ),
          ),
        );

        // Retrieve the current user
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Add the course ID to the user's subcollection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('purchasedCourses')
              .add({'courseId': widget.offerSnap.id,
            'courseName': widget.offerSnap['name'],
            'duration': widget.offerSnap['duration'],
            'session': widget.offerSnap['session'],
            'price': widget.offerSnap['price'],
            'image': widget.offerSnap['images'],
            'discount': widget.offerSnap['discount'],
          });
          // Navigate to the PurchasedCoursesScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PurchasedCoursesScreen(),
            ),
          );

        }

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled "),
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

// Modify the createPaymentIntent function to accept the userId parameter
  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',

      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $SECRET_KEY',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
      rethrow;
    }
  }
  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }



}