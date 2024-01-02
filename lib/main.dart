
import 'package:elearning_applicaton/screens/root_app.dart';
import 'package:elearning_applicaton/theme/color.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';


import 'Screens/loginScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_51OLNMIBzAbSEjHLBcvugXi7aMEQL3DxzYr6YYRJq8TEJmCHVi24wkvVjc3DUmJ6yPTSohUtVsiryGpNQULraWCWz00qMCb2ZSX";
  await Firebase.initializeApp(

  options: FirebaseOptions(
      apiKey: "AIzaSyCuWj56amY8-ZMlSpxrikf9wFZ39vf4604",
      appId: "1:515471366120:android:ff35e039862cba3f06765d",
      messagingSenderId: "515471366120",
      projectId: "elearningapp-6cb37",
    ),
   );
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),

    androidProvider: AndroidProvider.debug,

    appleProvider: AppleProvider.appAttest,
  );

 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Course App',
      theme: ThemeData(
        primaryColor: AppColor.primary,
      ),
      home: LoginScreen(),
    );
  }
}


