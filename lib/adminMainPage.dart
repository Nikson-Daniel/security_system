import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audioplayers.dart';

class adminMainPage extends StatefulWidget {
  const adminMainPage({Key? key}) : super(key: key);

  @override
  State<adminMainPage> createState() => _adminMainPageState();
}

class _adminMainPageState extends State<adminMainPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _emergency =
        FirebaseFirestore.instance.collection('Emergency').snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Handlers"),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.grey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _emergency,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    try {
                      if (snapshot.connectionState == ConnectionState.none) {
                        audioPlayer.stop();

                        return Text('No Reports');
                      }
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        //playAudio();
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                        });
                      }
                    } catch (_) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                        });
                      }
                      return Text("Something went wrong");
                    }
                    return Center(
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            // crossAxisSpacing: 5.0,
                            // mainAxisSpacing: 5.0,
                          ),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            if (snapshot.data!.docs[index].exists) {
                              playAudio();
                              String? name =
                                  snapshot.data!.docs[index].get('name');
                              String? age =
                                  snapshot.data!.docs[index].get('age');
                              String? address =
                                  snapshot.data!.docs[index].get('address');
                              String? imeiNumber =
                                  snapshot.data!.docs[index].get('imei');
                              String? mobileModel =
                                  snapshot.data!.docs[index].get('mobileModel');
                              return Container(
                                child: Card(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "ALERT!!! Someone is in Danger",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            "Name : " +
                                                name.toString() +
                                                "\n" +
                                                "Age : " +
                                                age.toString() +
                                                "\n" +
                                                "From : " +
                                                address.toString() +
                                                "\n" +
                                                "IMEI number : " +
                                                imeiNumber.toString() +
                                                "\n" +
                                                "Mobile Model : " +
                                                mobileModel.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Click here for other details",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  playAudio() async {
    final player = AudioCache(prefix: 'assets/');
    final url = await player.load('alarm_sound.mp3');
    audioPlayer.play(url.path, isLocal: true);
  }
}
