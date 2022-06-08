import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:security_system/adminLogin.dart';
import 'package:security_system/homepage.dart';
import 'package:security_system/signupPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  runApp(Loginpage());
}

class Loginpage extends StatefulWidget {
  const Loginpage({Key? key}) : super(key: key);

  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  late String _email, _password;

  var currentUser = FirebaseAuth.instance.currentUser;
  User? user = FirebaseAuth.instance.currentUser;

  void signIn(BuildContext context) async {
    // await FirebaseAuth.instance
    //     .signInWithEmailAndPassword(email: _email, password: _password)
    //     .catchError((onError) {
    //   print(onError);
    // }).then((authUser) {
    //   if ((user != null)) {
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => mainPage(),
    //         ));
    //   } else {}
    // });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);

      if (user != null && !user!.emailVerified) {
        await user!.sendEmailVerification();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Email verification"),
                content: Text(
                    "Email link send sucessfully... Please verify your email to go ahead"),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      } else {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("email", _email);
        checkGps();

        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(builder: (builder) => mainPage()),
        //     (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                  child: TextFormField(
                    validator: (email) {
                      if (email!.isEmpty) {
                        return "Please enter your email";
                      }
                      bool _isValid = EmailValidator.validate(email);
                      if (_isValid == false) {
                        return "Your email is invalid";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _email = value.toString().trim();
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                        labelText: "Enter your email",
                        labelStyle: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 3.0,
                            fontSize: 12.0),
                        prefixIcon: Icon(
                          Icons.supervised_user_circle_rounded,
                          color: Colors.grey,
                        )),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                  child: TextFormField(
                    validator: (password) {
                      if (password!.isEmpty) {
                        return "Please enter your password";
                      } else if (password.length < 8 || password.length > 30) {
                        return "Your password length is invalid";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _password = value.toString();
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                        labelText: "Enter your password",
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          letterSpacing: 3.0,
                          fontSize: 12.0,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.grey,
                        )),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                      onPressed: () {},
                      child: Text(
                        "Forget Password?",
                        style: TextStyle(color: Colors.lightBlueAccent[400]),
                      )),
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width - 100,
                  child: FlatButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        signIn(context);
                      }
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(letterSpacing: 3.0, color: Colors.black),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    color: Colors.yellowAccent[700],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => signUp()));
                        },
                        child: Text(
                          "Dont have account? create account",
                          style: TextStyle(color: Colors.grey),
                        )),
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => adminLogin()));
                        },
                        child: Text(
                          "If you are an admin, Click here",
                          style: TextStyle(color: Colors.red),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });
        askPermission();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  askPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      //add more permission to request here.
    ].request();

    if (statuses[Permission.phone]!.isGranted) {
      navigate();
    } else {
      //storage permissions required
    }
  }

  navigate() {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (builder) => mainPage()), (route) => false);
  }
}
