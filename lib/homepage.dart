import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_information/device_information.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class mainPage extends StatefulWidget {
  //final String? uid;
  const mainPage({Key? key}) : super(key: key);

  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String _name, _address, _age, _district, _mail, _imeiNo, _mobileModel;
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.local_police),
              onPressed: () {
                sendLocationToDb();

                fetchUserDetails();
              },
              iconSize: 200,
              color: Colors.red,
            ),
            Padding(
              child: Text(
                "If this emergency button is pressed without any emergency, you will be fined...",
                style: TextStyle(color: Colors.black),
              ),
              padding: const EdgeInsets.only(top: 100, right: 30, left: 30),
            )
          ],
        ),
      ),
    );
  }

  sendLocationToDb() async {
    // servicestatus = await Geolocator.isLocationServiceEnabled();
    // if (servicestatus) {
    //   permission = await Geolocator.checkPermission();

    //   if (permission == LocationPermission.denied) {
    //     permission = await Geolocator.requestPermission();
    //     if (permission == LocationPermission.denied) {
    //       print('Location permissions are denied');
    //     } else if (permission == LocationPermission.deniedForever) {
    //       print("'Location permissions are permanently denied");
    //     } else {
    //       haspermission = true;
    //     }
    //   } else {
    //     haspermission = true;
    //   }

    //   if (haspermission) {
    //     setState(() {
    //       //refresh the UI
    //     });

    //     print("Permission granted");
    //   }
    // } else {
    //   print("GPS Service is not enabled, turn on GPS location");
    // }

    // setState(() {
    //   //refresh the UI
    // });

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    String long = position.longitude.toString();
    String lat = position.latitude.toString();
    //getDeviceImeiNumber();
  }

  sendNearbyDatasToDb() async {}

  loseBrightnessAndDarkScreenNavigate() {}

  fetchUserDetails() async {
    final imeiNo = await DeviceInformation.deviceIMEINumber;
    final modelName = await DeviceInformation.deviceModel;
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> firestoreInfo =
          documentSnapshot.data()! as Map<String, dynamic>;

      setState(() {
        _name = firestoreInfo['fullname'];
        _address = firestoreInfo['address'];
        _age = firestoreInfo['age'];
        _district = firestoreInfo['district'];
        _mail = firestoreInfo['email'];
        _imeiNo = imeiNo;
        _mobileModel = modelName;
      });
      FirebaseFirestore.instance
          .collection("Emergency")
          .doc(auth.currentUser!.uid)
          .set({
        "uid": auth.currentUser!.uid,
        "name": _name,
        "age": _age,
        "email": _mail,
        "address": _address,
        "district": _district,
        "imei": _imeiNo,
        "mobileModel": _mobileModel
      });
    }).onError((e) => print(e));
  }
}
