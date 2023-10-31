import 'package:elearning_applicaton/screens/forgotPassword.dart';
import 'package:elearning_applicaton/screens/root_app.dart';
import 'package:elearning_applicaton/screens/signUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController=TextEditingController();
  final _passwordController=TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
  Future signIn() async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RootApp();
    }));
  } catch (e) {
  // Handle errors or display error messages if needed
  print("Error signing up: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/Online_world.png',height: 150,),
                SizedBox(height: 20,),
                Text(
                  'SIGN IN',
                  style: GoogleFonts.robotoCondensed(fontSize:40,fontWeight:FontWeight.bold),
                ),
                Text(
                  'Welcome back! Nice to see you again :-)',
                  style: GoogleFonts.robotoCondensed(fontSize:18,),
                ),
                SizedBox(height: 50,),

                //Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:20),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                //Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:20),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10,),
                GestureDetector(
                  onTap: () {
                    // Navigating to the new screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPassword()),
                    );
                  },
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                        'Forget Password...',
                        style: GoogleFonts.robotoCondensed(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                //sign in Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:25),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.amber[900],
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Center(
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.robotoCondensed(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),

                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20,),

                //Text(sign up)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not yet a member?',
                        style: GoogleFonts.robotoCondensed(
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    GestureDetector(
                      onTap: () {
                        // Navigating to the new screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                          'Sign up now',
                          style: GoogleFonts.robotoCondensed(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
