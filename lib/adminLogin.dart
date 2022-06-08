import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:security_system/adminMainPage.dart';
import 'package:security_system/homepage.dart';
import 'package:security_system/signupPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(adminLogin());
}

class adminLogin extends StatefulWidget {
  const adminLogin({Key? key}) : super(key: key);

  @override
  _adminLoginState createState() => _adminLoginState();
}

class _adminLoginState extends State<adminLogin> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  late String _email, _password, _userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => mainPage()),
            (route) => false);
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
                    validator: (userId) {
                      if (userId!.isEmpty) {
                        return "Please enter your user ID";
                      }
                    },
                    onSaved: (value) {
                      _userId = value.toString().trim();
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                        labelText: "Enter your user ID",
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
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width - 100,
                  child: FlatButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        FirebaseFirestore.instance
                            .collection('Admins')
                            .doc(_userId)
                            .snapshots()
                            .listen((DocumentSnapshot documentSnapshot) {
                          Map<String, dynamic> firestoreInfo =
                              documentSnapshot.data()! as Map<String, dynamic>;
                          print(firestoreInfo['email']);
                          print(firestoreInfo['password']);
                          if (_email == firestoreInfo['email'] &&
                              _password == firestoreInfo['password']) {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => adminMainPage()),
                                (Route<dynamic> route) => false);
                          }
                        }).onError((e) => print(e));
                      }
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(letterSpacing: 3.0, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
