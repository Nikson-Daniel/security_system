import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:security_system/loginpage.dart';

void main() {
  runApp(signUp());
}

class signUp extends StatefulWidget {
  const signUp({Key? key}) : super(key: key);

  @override
  _signUpState createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var confirmPasswordd;
  late String _email, _password, _fullname, _address, _district, _age;

  FirebaseDatabase database = FirebaseDatabase.instance;
  //REALTIME DATABASE REFERENCE
  DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child("Security system users");

  CollectionReference firestore =
      FirebaseFirestore.instance.collection('users');

  void signUpToFb() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: _email, password: confirmPasswordd)
        .then((result) {
      // dbRef.child(result.user!.uid).set({
      //   "email": _email,
      //   "fullname": _fullname,
      //   "username": _username
      // })

      firestore.doc(auth.currentUser!.uid).set({
        "email": _email,
        "fullname": _fullname,
        "address": _address,
        "age": _age,
        "district": _district
      }).then((res) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Loginpage()));
      });
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
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
    });
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
                    validator: (fullname) {
                      _fullname = fullname.toString().trim();
                      if (fullname!.isEmpty) {
                        return "Please enter your fullname";
                      }
                    },
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                        labelText: "Enter your full name",
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
                    validator: (username) {
                      _address = username.toString().trim();
                      if (username!.isEmpty) {
                        return "Please enter a valid address";
                      }
                    },
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                        labelText: "Enter your address",
                        labelStyle: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 3.0,
                            fontSize: 12.0),
                        prefixIcon: Icon(
                          Icons.home,
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
                    validator: (age) {
                      _age = age.toString().trim();
                      if (age!.isEmpty) {
                        return "Please enter your age";
                      }
                    },
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                        labelText: "Enter your age",
                        labelStyle: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 3.0,
                            fontSize: 12.0),
                        prefixIcon: Icon(
                          Icons.child_care,
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
                    validator: (district) {
                      setState(() {
                        _district = district.toString().trim();
                      });

                      if (district!.isEmpty) {
                        return "Please enter your age";
                      }
                    },
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                        labelText: "Enter your District",
                        labelStyle: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 3.0,
                            fontSize: 12.0),
                        prefixIcon: Icon(
                          Icons.child_care,
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
                      _email = email.toString().trim();
                      if (email!.isEmpty) {
                        return "Please enter your email";
                      }
                      bool _isValid = EmailValidator.validate(email);
                      if (_isValid == false) {
                        return "Your email is invalid";
                      }
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
                          Icons.email,
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
                    validator: (createpassword) {
                      confirmPasswordd = createpassword;

                      if (createpassword!.isEmpty) {
                        return "Please enter your password";
                      } else if (createpassword.length < 8 ||
                          createpassword.length > 30) {
                        return "Your password length is invalid";
                      } else {
                        return null;
                      }
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                        labelText: "Create password",
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
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                  child: TextFormField(
                    validator: (confirmpassword) {
                      if (confirmpassword != confirmPasswordd) {
                        return "your password is not matching";
                      }
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                        labelText: "Confirm password",
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
                  height: 40.0,
                ),
                SizedBox(
                  height: 40,
                  width: width - 90,
                  child: FlatButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        (_formKey.currentState!.save());
                        FocusScope.of(context).unfocus();
                        signUpToFb();
                      }
                    },
                    child: Text(
                      "Create account",
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
