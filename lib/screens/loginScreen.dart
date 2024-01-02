import 'package:elearning_applicaton/screens/root_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elearning_applicaton/models/Teacher.dart';
import 'package:elearning_applicaton/models/Student.dart';
import 'package:elearning_applicaton/screens/signUpScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ForgotPassword.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure3 = true;
  bool _isObscure = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController(text:'nour@gmail.com');
  final TextEditingController passwordController = new TextEditingController(text: '123456');

  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50,),
              Image.asset('assets/icons/Online_world.png',height: 150,),
              SizedBox(height: 20,),
              Text(
                'Sign In',
                style: GoogleFonts.robotoCondensed(fontSize:40,fontWeight:FontWeight.bold),
              ),
              SizedBox(height: 20,),
              Text(
                'Welcome ! Login To Continue Using The App ',
                style: GoogleFonts.robotoCondensed(fontSize:20,),
              ),
              SizedBox(height: 25,),
              Container(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(12),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            key: Key('emailField'),
                            controller: emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Enter your Email',
                              contentPadding: const EdgeInsets.all(18.0), // Adjust the padding to make it taller

                              enabled: true,

                              focusedBorder: OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.grey),
                                borderRadius: new BorderRadius.circular(20),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: new BorderSide(color: Colors.white),
                                borderRadius: new BorderRadius.circular(20),
                              ),
                              prefixIcon: Icon(Icons.email),

                            ),
                            validator: (value) {
                              if (value!.length == 0) {
                                return "Email cannot be empty";
                              }
                              if (!RegExp(
                                  "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                  .hasMatch(value)) {
                                return ("Please enter a valid email");
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              emailController.text = value!;
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                           // Adjust the width according to your needs
                            child: TextFormField(
                              key: Key('passwordField'), // Add this line
                              controller: passwordController,
                              obscureText: _isObscure3,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: Icon(_isObscure3
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure3 = !_isObscure3;
                                      });
                                    }),
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: 'Enter your Password',
                                enabled: true,
                                contentPadding: const EdgeInsets.all(18.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                prefixIcon: Icon(Icons.password),

                              ),
                              validator: (value) {
                                RegExp regex = RegExp(r'^.{6,}$');
                                if (value!.isEmpty) {
                                  return "Password cannot be empty";
                                }
                                if (!regex.hasMatch(value)) {
                                  return "Please enter a valid password with a minimum of 6 characters";
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (value) {
                                passwordController.text = value!;
                              },
                              keyboardType: TextInputType.emailAddress,
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
                            child: Container(
                             margin: const EdgeInsets.only(top: 10,bottom: 20),
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context){
                                    return  ForgotPassword();
                                  },
                                      ),
                                  );
                                },
                                child: Text(
                                    'Forget Password  ?',
                                    style: GoogleFonts.robotoCondensed(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Align(
                              alignment: Alignment.center,
                              child: MaterialButton(
                                key: Key('loginButton'), // Add this line
                                onPressed: () {
                                  setState(() {
                                    visible = true;
                                  });
                                  if (_formkey.currentState!.validate()) {
                                  signIn(
                                      emailController.text, passwordController.text);
                                }},

                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[900],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Sign In',
                                      style: GoogleFonts.robotoCondensed(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
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
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Visibility(
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              visible: visible,
                              child: Container(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }



  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    var kk = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('rool') == "Teacher") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  RootApp(),
            ),
          );
        }else{
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  RootApp(),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        route();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }
  }
}
