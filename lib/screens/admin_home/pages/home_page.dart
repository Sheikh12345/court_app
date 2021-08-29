import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:court_app/utils/constants.dart';
import '../../../methods/firebase_methods.dart';
import 'package:search_page/search_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/progress_dialog.dart';
import 'chat_screen.dart';
import 'locationModel.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'distance_model.dart';
import '../../../models/BModel.dart';

// import 'package:vector_math/vector_math_geometry.dart';

class HomePage extends StatefulWidget {
  final String routeName = '/admin_tracking_page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double starSize = 25;

  String name;
  String phoneNo;
  String address;
  String currentUser;
  double lat;
  double lon;

  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print(' could not launch $command');
    }
  }

  Future<bool> checkRequest(dynamic email) async {
    //
    bool isRequested = false;
    await FirebaseFirestore.instance
        .collection("Booking Requests")
        .where('user Email', isEqualTo: FirebaseAuth.instance.currentUser.email)
        .get()
        .then((value) {
      var data = value.docs;
      data.forEach((element) {
        // print("email===>>>> ${email}");
        if (email == element['Lawyer Email']) {
          isRequested = true;
        }
      });
    });
    return isRequested;
  }

  Future getUserData() async {
    await FirebaseFirestore.instance
        .collection('Vendors')
        .doc(auth.currentUser.email)
        .get()
        .then((value) {
      var user = value.data();
      name = (user['Name']);
      phoneNo = (user['PhoneNo']);
      address = (user['Address']);
    });
  }

  var lat1;
  var lon1;
  Future<LocationModel> getUserLocation() async {
    await FirebaseFirestore.instance
        .collection('Vendors')
        .doc(auth.currentUser.email)
        .get()
        .then((value) {
      var user = value.data();
      lat1 = (user['VLatitude']);
      lon1 = (user['VLongitude']);
      return LocationModel(user['VLatitude'], user['VLongitude']);
    });
    return LocationModel(lat1, lon1);
  }

  var locationMessage = "";
// List<double> list;
  Future<LawyerDistance> getCurrentLocation(double lat1, double lon1) async {
    // var position = await Geolocator().
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
// Position lastPosition = await Geolocator.getLastKnownPosition();

// print(position.toString());

// var lat2 =34.1023;
// var long2 = 71.4804;

// var lat3=31.4024;
// var long3 = 76.1151;

// FirebaseFirestore.instance.collection("Vendors").doc(auth.currentUser.email).update({
//   "VLatitude":position.latitude,
//   "VLongitude":position.longitude
// });
    var distance = Geolocator.distanceBetween(
        position.latitude, position.longitude, lat1, lon1);
// print("Mathra Distance# $distance");
// setState(() {
//   locationMessage = "$position.latitude , $position.longitude";
// });

// setState(() {
//  list=[position.latitude,position.longitude];
// });

// print(position.latitude.toString());

    if (distance <= 1000) {
      return LawyerDistance(
          distance: (distance).toStringAsFixed(2) == null
              ? "0"
              : (distance).toStringAsFixed(2),
          isNear: true,
          isNormalUnit: "m");
    } else if (distance >= 1000 && distance <= 10000) {
      return LawyerDistance(
          distance: (distance).toStringAsFixed(2) == null
              ? "0"
              : (distance / 1000).toStringAsFixed(2),
          isNear: true,
          isNormalUnit: "km");
    } else if (distance >= 10000) {
      return LawyerDistance(
          distance: (distance).toStringAsFixed(2) == null
              ? "0"
              : (distance / 1000).toStringAsFixed(2),
          isNear: false,
          isNormalUnit: "KM");
    } else {
      return LawyerDistance(distance: "0", isNear: true, isNormalUnit: "");
    }

    //LocationModel(position.latitude, position.longitude);
  }

  bList(DocumentSnapshot jsnapshot, index) {
    // bool isNear = true;

    // isNear = snapshot.data.isNear;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(7),
      child: ExpansionTile(
        onExpansionChanged: (value) async {
          if (value) {
            // await checkRequest();
          }
        },
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: kPrimaryColor.withOpacity(0.8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(70),
            child: FadeInImage.assetNetwork(
              image: jsnapshot['User Photo'],
              placeholder: 'assets/images/Bubble-Loader-Icon.gif',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 100.0,
              child: Text(
                jsnapshot['Name'].toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
            // Text("$distance2 m")
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 120.0,
              child: Text(jsnapshot['city'], overflow: TextOverflow.ellipsis),
            ),
            Text(
              jsnapshot['overAllRating'].substring(0, 3) + "🌟",
              style: TextStyle(color: kPrimaryColor),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Phone No: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${jsnapshot['PhoneNo']}'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Address: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${jsnapshot['Address']}'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Details of my work are following:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Specialization: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${jsnapshot['Specialization']}'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'BarCouncil: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${jsnapshot['BarCouncil']}'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Court Type: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${jsnapshot['CourtType']}'),
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: FutureBuilder(
                      future: getRole(jsnapshot['Email']),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.data == "Admin") {
                          return Text("You can't block, warn or delete Admin",
                              style: TextStyle(
                                color: Colors.red,
                              ));
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // FutureBuilder(
                              //     future: checkRequest(jsnapshot['Email']),
                              //     builder: (context, snapshotData) {
                              //       // print("Bucking Email === > ${snapshotData.data}");

                              //       return MaterialButton(
                              //         color: kPrimaryColor,
                              //         onPressed: () async {
                              //           // print(snapshot['Email'].toString());
                              //           showDialog(
                              //             context: context,
                              //             builder: (BuildContext context) =>
                              //                 ProgressDialog(message: "Please wait..."),
                              //           );
                              //           try {
                              //             await getUserData().then((value) {
                              //               //  var user = value.data();
                              //               // name = (user['displayName']);
                              //               // phoneNo = (user['phoneNo']);
                              //               // address = (user['Address']);

                              //               if (name == null ||
                              //                   address == null ||
                              //                   phoneNo == null ||
                              //                   jsnapshot['Email'] == null ||
                              //                   auth.currentUser.email == null) {
                              //                 var snackBar = SnackBar(
                              //                     content: Text("Details not correct"));
                              //                 ScaffoldMessenger.of(context)
                              //                     .showSnackBar(snackBar);
                              //               } else {
                              //                 FirebaseFirestore.instance
                              //                     .collection('Booking Requests')
                              //                     .add({
                              //                   'Customer Name': name,
                              //                   'Customer Address': address,
                              //                   'Customer PhoneNo': phoneNo,
                              //                   'user Email': auth.currentUser.email,
                              //                   'Lawyer Name': jsnapshot['Name'],
                              //                   'Lawyer PhoneNo': jsnapshot['PhoneNo'],
                              //                   'Lawyer Email': jsnapshot['Email'],
                              //                   'Lawyer Address': jsnapshot['Address'],
                              //                   'status': "pending",
                              //                   'rating': "0"
                              //                 }).then((value) {
                              //                   setState(() {});
                              //                 });
                              //               }
                              //             });
                              //           } catch (e) {
                              //             print(e);
                              //           }
                              //           Navigator.pop(context);
                              //         },
                              //         child: Text("Book", style: txtlight),
                              //       );
                              //     }),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                              ),

                              //print(" its from navigation button ${sender}");

                              IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, ChatScreen.routeName,
                                        arguments: jsnapshot['Email']);
                                  },
                                  color: kPrimaryColor,
                                  icon: Icon(Icons.chat)
                                  //Text('Chat', style: txtlight),
                                  ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                              ),

                              IconButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(jsnapshot['Email'])
                                        .update(
                                      {
                                        'Role': 'Lawyer',
                                      },
                                    ).then((value) {
                                      _onAlertSuccessPressed(
                                          context, "Activated");
                                    });
                                  },
                                  color: kPrimaryColor,
                                  icon: Icon(Icons.check, color: Colors.green)
                                  //Text('Activate', style: txtlight),
                                  ),
                              IconButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(jsnapshot['Email'])
                                        .update(
                                      {
                                        'Role': 'Deleted',
                                      },
                                    ).then((value) {
                                      _onAlertButtonPressed(context, "Deleted");
                                    });
                                  },
                                  color: kPrimaryColor,
                                  icon: Icon(
                                    Icons.close,
                                  )
                                  //Text('Delete', style: txtlight),
                                  ),

                              IconButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(jsnapshot['Email'])
                                        .update(
                                      {
                                        'Role': 'Blocked',
                                      },
                                    ).then((value) {
                                      _onAlertButtonPressed(context, "Blocked");
                                    });
                                  },
                                  color: kPrimaryColor,
                                  icon: Icon(Icons.block)
                                  //Text('Blocked', style: txtlight),
                                  ),
                            ],
                          );
                        }
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  customerListCard(DocumentSnapshot jsnapshot, index) {
    print("this is the emaim ${jsnapshot.data()}");
    // bool isNear = true;

    // isNear = snapshot.data.isNear;
    // if(jsnapshot['Role']=="Deleted")
    //   {
    //     return Container();
    //   }
    // else
    //   {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(7),
      child: ExpansionTile(
        onExpansionChanged: (value) async {
          if (value) {
            // await checkRequest();
          }
        },
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: kPrimaryColor.withOpacity(0.8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(70),
            child: FadeInImage.assetNetwork(
              image: 'assets/images/Bubble-Loader-Icon.gif',
              //jsnapshot['User Photo'],
              placeholder: 'assets/images/Bubble-Loader-Icon.gif',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 100.0,
              child: Text(
                jsnapshot['Name'].toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
            // Text("$distance2 m")
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 120.0,
              //  child: Text(jsnapshot['city'], overflow: TextOverflow.ellipsis),
            ),
            Text(
              "",
              // jsnapshot['overAllRating'].substring(0, 3) + "🌟",
              style: TextStyle(color: kPrimaryColor),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Phone No: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${jsnapshot['PhoneNo']}'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Address: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${jsnapshot['Address']}'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),

                      //print(" its from navigation button ${sender}");

                      IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, ChatScreen.routeName,
                                arguments: jsnapshot['Email']);
                          },
                          color: kPrimaryColor,
                          icon: Icon(Icons.chat)
                          //Text('Chat', style: txtlight),
                          ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),

                      IconButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(jsnapshot['Email'])
                                .update(
                              {
                                'Role': 'Customer',
                              },
                            ).then((value) {
                              _onAlertSuccessPressed(context, "Activated");
                            });
                          },
                          color: kPrimaryColor,
                          icon: Icon(Icons.check, color: Colors.green)
                          //Text('Activate', style: txtlight),
                          ),
                      IconButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(jsnapshot['Email'])
                                .update(
                              {
                                'Role': 'Deleted',
                              },
                            ).then((value) {
                              _onAlertButtonPressed(context, "Deleted");
                            });
                          },
                          color: kPrimaryColor,
                          icon: Icon(
                            Icons.close,
                          )
                          //Text('Delete', style: txtlight),
                          ),

                      IconButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(jsnapshot['Email'])
                                .update(
                              {
                                'Role': 'Blocked',
                              },
                            ).then((value) {
                              _onAlertButtonPressed(context, "Blocked");
                            });
                          },
                          color: kPrimaryColor,
                          icon: Icon(Icons.block)
                          //Text('Blocked', style: txtlight),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // }
  }

  // rejectedListCard(DocumentSnapshot snapshot) {
  //   print(snapshot.id.toString());
  //   if (snapshot['status'] != null && snapshot['status'] == "pending" ||
  //       snapshot['status'] == "rejected") {
  //     return Card(
  //       elevation: 3,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       margin: EdgeInsets.all(7),
  //       child: ExpansionTile(
  //         leading: CircleAvatar(
  //           radius: 22,
  //           backgroundColor: kPrimaryColor.withOpacity(0.8),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(70),
  //             child: Image.asset(
  //               'assets/images/User.jpeg',
  //               width: 40,
  //               height: 40,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //         ),
  //         title: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //                 snapshot['Lawyer Name'] == null
  //                     ? "Name not correct"
  //                     : snapshot['Lawyer Name'].toString(),
  //                 style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black.withOpacity(0.7))),
  //             Text(
  //               snapshot['status'] == null
  //                   ? "Nil"
  //                   : snapshot['status'].toString(),
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 // color: Colors.black.withOpacity(0.7),
  //                 color: snapshot['status'] == "pending"
  //                     ? Colors.black
  //                     : Colors.red,
  //               ),
  //             ),
  //           ],
  //         ),
  //         subtitle: Text(snapshot['Lawyer Address'].toString()),
  //         children: [
  //           Padding(
  //             padding: EdgeInsets.only(bottom: 10),
  //             child: Text('Phone No: ${snapshot['Lawyer PhoneNo']}'),
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               // Padding(
  //               //   padding: EdgeInsets.symmetric(horizontal: 20),
  //               // ),
  //               Padding(
  //                 padding: EdgeInsets.only(bottom: 10),
  //                 child: MaterialButton(
  //                   color: kPrimaryColor,
  //                   onPressed: () async {
  //                     showDialog(
  //                       context: context,
  //                       builder: (BuildContext context) =>
  //                           ProgressDialog(message: "Please wait..."),
  //                     );
  //                     try {
  //                       FirebaseFirestore.instance
  //                           .collection('Booking Requests')
  //                           .doc(snapshot.id)
  //                           .delete()
  //                           .then((value) {
  //                         setState(() {});
  //                       });
  //                     } catch (e) {
  //                       print(e);
  //                     }
  //                     Navigator.pop(context);
  //                   },
  //                   child: Text(
  //                     "Delete",
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                 ),

  //                 // child: Text('Accept'),
  //                 // ),
  //               ),
  //               //                Padding(
  //               //   padding: EdgeInsets.symmetric(horizontal: 20),
  //               // ),

  //               // Padding(
  //               //   padding: EdgeInsets.only(bottom: 10),
  //               //   child: MaterialButton(
  //               //     onPressed: () {
  //               //       customLaunch('tel:${snapshot['Customer PhoneNo']}');
  //               //     },
  //               //     color: kPrimaryColor,
  //               //     child: Text('Call', style:TextStyle(color: Colors.white)),
  //               //   ),
  //               // ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     return Center(
  //       child: SizedBox(),
  //     ); //No Bookings Request Found
  //   }
  // }

  acceptedListCard(DocumentSnapshot snapshot) {
    // print(snapshot.id.toString());
    if (snapshot['status'] == null && snapshot['status'] == "started" ||
        snapshot['status'] == "completed") {
      return Column(
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(7),
            child: ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: kPrimaryColor.withOpacity(0.8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: Image.asset(
                    'assets/images/User.jpeg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      snapshot['Lawyer Name'] == null
                          ? "Name not correct"
                          : snapshot['Lawyer Name'].toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.7))),
                  Text(
                    snapshot['status'] == null
                        ? "Nil"
                        : snapshot['status'].toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // color: Colors.black.withOpacity(0.7),
                      color: snapshot['status'] == "started"
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              subtitle: SizedBox(),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: SizedBox(),
      ); //No Bookings Request Found
    }
  }

  List<Lawyer> listLawyers = [];
  mySearchFunction() async {
   await FirebaseFirestore.instance
        .collection('Lawyers')
        .get()
        .then((value) {
      var maps = value.docs;
      maps.forEach((element) {
        listLawyers.add(Lawyer(
          email: element.data()["Email"],
          bLatitude: element.data()["BLatitude"],
          address: element.data()["Address"],
          city: element.data()["city"],
          barCouncil: element.data()["BarCouncil"],
          userPhoto: element.data()["User Photo"],
          name: element.data()["Name"],
          overAllRating: element.data()["overAllRating"],
          courtType: element.data()["CourtType"],
          specialization: element.data()["Specialization"],
          phoneNo: element.data()["PhoneNo"],
          cnic: element.data()["CNIC"],
          bLongitude: element.data()["BLongitude"],
        ));
      });
    });
    print(listLawyers[0].city);
    return listLawyers;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mySearchFunction();
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

// Alert with single button.
  _onAlertButtonPressed(context, message) {
    Alert(
      context: context,
      type: AlertType.error,
      closeIcon: SizedBox(),
      //onWillPopActive: true,
      title: "ALERT",
      desc: "This Account is $message",
      buttons: [
        DialogButton(
          color: Colors.red,
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          //_onCustomAnimationAlertPressed(context),
          width: 120,
        ),
      ],
    ).show();
  }

  _onAlertSuccessPressed(context, message) {
    Alert(
      context: context,
      type: AlertType.success,
      closeIcon: SizedBox(),
      //onWillPopActive: true,
      title: "ALERT",
      desc: "This Account is $message",
      buttons: [
        DialogButton(
          color: Colors.red,
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          //_onCustomAnimationAlertPressed(context),
          width: 120,
        ),
      ],
    ).show();
  }

  Widget fadeAlertAnimation(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Align(
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 2,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text(
              'Admin: Home Page',
              style: TextStyle(
                  fontFamily: 'Muli', color: Color(0XFF8B8B8B), fontSize: 18),
            ),
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications, color: kPrimaryColor),
                ),
                IconButton(
                  onPressed: () {
                    scaffoldKey.currentState.openEndDrawer();
                  },
                  icon: Icon(Icons.search_sharp, color: kPrimaryColor),
                ),
              ],
            )
          ],
          backgroundColor: hexColor,
          bottom: TabBar(
              labelColor: kPrimaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: kPrimaryColor,
              tabs: [
                Tab(text: "Lawyers"),
                Tab(text: "Customers"),
                Tab(text: "Others"),
              ]),
        ),
        endDrawer: Container(
          width: 220.0,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // height: 150.0,
                width: 220.0,
                color: Colors.black,
                child: Column(
                  children: [
                    SizedBox(height: 25.0),
                    Stack(
                      children: [
                        SizedBox(height: 25.0),
                        Image.asset("assets/images/lawyer_4.jpg"),
                        Positioned(
                          // alignment: Alignment.center,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.red.withOpacity(0.7), BlendMode.darken),
                            child: SizedBox(
                              child: Text(
                                "Find Lawyers",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Find Lawyers",
                  style: TextStyle(
                      fontWeight: FontWeight.w900, color: Colors.black),
                ),
              ),
              MaterialButton(
                // style:ButtonStyle(
                //   backgroundColor: Colors.grey,
                // ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search, size: 15.0, //color: kPrimaryColor,
                    ),
                    SizedBox(width: 10.0),
                    Text("Search By City"),
                  ],
                ),
                onPressed: () => showSearch(
                  context: context,
                  delegate: SearchPage<Lawyer>(
                    barTheme: ThemeData.dark(),
                    items: listLawyers,
                    searchLabel: 'Search by City',
                    suggestion: Center(
                      child: Text('Filter Lawyer by city'),
                    ),
                    failure: Center(
                      child: Text('No person found :('),
                    ),
                    filter: (person) => [
                      person.specialization,
                      person.city,
                      person.courtType,
                    ],
                    builder: (nrLawyer) => Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(7),
                      child: ExpansionTile(
                        onExpansionChanged: (value) async {
                          if (value) {
                            // await checkRequest();
                          }
                        },
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: kPrimaryColor.withOpacity(0.8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: FadeInImage.assetNetwork(
                              image: nrLawyer.userPhoto,
                              placeholder:
                                  'assets/images/Bubble-Loader-Icon.gif',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 100.0,
                              child: Text(
                                nrLawyer.name.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ),
                            // Text("$distance2 m")
                            // FutureBuilder(
                            //   future: getCurrentLocation(snapshot['BLatitude'],snapshot['BLongitude']),
                            //   builder: (context,snapshot){
                            //     return Text(" ${snapshot.data} KM",
                            //     style: TextStyle(color: Colors.green),
                            //     );
                            //   })
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: 120.0,
                                child: Text(nrLawyer.city,
                                    overflow: TextOverflow.ellipsis)),
                            Text(
                              nrLawyer.overAllRating.substring(0, 3) + "🌟",
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('Phone No: ${nrLawyer.phoneNo}'),
                          ),
                          Text(nrLawyer.address,
                              overflow: TextOverflow.ellipsis),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('Details of my work are following:'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('bar Council: ${nrLawyer.barCouncil}'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('courtType: ${nrLawyer.courtType}'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                                'specialization: ${nrLawyer.specialization}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder(
                                    future: checkRequest(nrLawyer.email),
                                    builder: (context, snapshotData) {
                                      // print("Bucking Email === > ${snapshotData.data}");

                                      return MaterialButton(
                                        color: kPrimaryColor,
                                        onPressed: () async {
                                          // print(snapshot['Email'].toString());
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                ProgressDialog(
                                                    message: "Please wait..."),
                                          );
                                          try {
                                            await getUserData().then((value) {
                                              //  var user = value.data();
                                              // name = (user['displayName']);
                                              // phoneNo = (user['phoneNo']);
                                              // address = (user['Address']);

                                              if (name == null ||
                                                  address == null ||
                                                  phoneNo == null ||
                                                  nrLawyer.email == null ||
                                                  auth.currentUser.email ==
                                                      null) {
                                                var snackBar = SnackBar(
                                                    content: Text(
                                                        "Details not correct"));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else {
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'Booking Requests')
                                                    .add({
                                                  'Customer Name': name,
                                                  'Customer Address': address,
                                                  'Customer PhoneNo': phoneNo,
                                                  'user Email':
                                                      auth.currentUser.email,
                                                  'Lawyer Name': nrLawyer.name,
                                                  'Lawyer PhoneNo':
                                                      nrLawyer.phoneNo,
                                                  'Lawyer Email':
                                                      nrLawyer.email,
                                                  'Lawyer Address':
                                                      nrLawyer.address,
                                                  'status': "pending",
                                                  'rating': "0"
                                                }).then((value) {
                                                  setState(() {});
                                                });
                                              }
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Text("Book"),
                                      );
                                    }),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    customLaunch('tel:${nrLawyer.phoneNo}');
                                  },
                                  color: kPrimaryColor,
                                  child: Text('Call'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              MaterialButton(
                // style:ButtonStyle(
                //   backgroundColor: Colors.grey,
                // ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 15.0),
                    SizedBox(width: 10.0),
                    Text("Search By Court"),
                  ],
                ),
                onPressed: () => showSearch(
                  context: context,
                  delegate: SearchPage<Lawyer>(
                    barTheme: ThemeData.dark(),
                    items: listLawyers,
                    searchLabel: 'Search Lawyers Court',
                    suggestion: Center(
                      child: Text('Filter Lawyers by Court'),
                    ),
                    failure: Center(
                      child: Text('No person found :('),
                    ),
                    filter: (person) => [
                      person.courtType,
                      person.city,
                      person.specialization,
                    ],
                    builder: (nrLawyer) => Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(7),
                      child: ExpansionTile(
                        onExpansionChanged: (value) async {
                          if (value) {
                            // await checkRequest();
                          }
                        },
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: kPrimaryColor.withOpacity(0.8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: FadeInImage.assetNetwork(
                              image: nrLawyer.userPhoto,
                              placeholder:
                                  'assets/images/Bubble-Loader-Icon.gif',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 100.0,
                              child: Text(
                                nrLawyer.name.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ),
                            // Text("$distance2 m")
                            // FutureBuilder(
                            //   future: getCurrentLocation(snapshot['BLatitude'],snapshot['BLongitude']),
                            //   builder: (context,snapshot){
                            //     return Text(" ${snapshot.data} KM",
                            //     style: TextStyle(color: Colors.green),
                            //     );
                            //   })
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: 120.0,
                                child: Text(nrLawyer.address,
                                    overflow: TextOverflow.ellipsis)),
                            Text(
                              nrLawyer.overAllRating.substring(0, 3) + "🌟",
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('Phone No: ${nrLawyer.phoneNo}'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('Details of my work are following:'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('bar Council: ${nrLawyer.barCouncil}'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('court Type: ${nrLawyer.courtType}'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                                'specialization: ${nrLawyer.specialization}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder(
                                    future: checkRequest(nrLawyer.email),
                                    builder: (context, snapshotData) {
                                      // print("Bucking Email === > ${snapshotData.data}");

                                      return MaterialButton(
                                        color: kPrimaryColor,
                                        onPressed: () async {
                                          // print(snapshot['Email'].toString());
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                ProgressDialog(
                                                    message: "Please wait..."),
                                          );
                                          try {
                                            await getUserData().then((value) {
                                              //  var user = value.data();
                                              // name = (user['displayName']);
                                              // phoneNo = (user['phoneNo']);
                                              // address = (user['Address']);

                                              if (name == null ||
                                                  address == null ||
                                                  phoneNo == null ||
                                                  nrLawyer.email == null ||
                                                  auth.currentUser.email ==
                                                      null) {
                                                var snackBar = SnackBar(
                                                    content: Text(
                                                        "Details not correct"));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else {
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'Booking Requests')
                                                    .add({
                                                  'Customer Name': name,
                                                  'Customer Address': address,
                                                  'Customer PhoneNo': phoneNo,
                                                  'user Email':
                                                      auth.currentUser.email,
                                                  'Lawyer Name': nrLawyer.name,
                                                  'Lawyer PhoneNo':
                                                      nrLawyer.phoneNo,
                                                  'Lawyer Email':
                                                      nrLawyer.email,
                                                  'Lawyer Address':
                                                      nrLawyer.address,
                                                  'status': "pending",
                                                  'rating': "0"
                                                }).then((value) {
                                                  setState(() {});
                                                });
                                              }
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Text("Book"),
                                      );
                                    }),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    customLaunch('tel:${nrLawyer.phoneNo}');
                                  },
                                  color: kPrimaryColor,
                                  child: Text('Call'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              MaterialButton(
                // style:ButtonStyle(
                //   backgroundColor: Colors.grey,
                // ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 15.0),
                    SizedBox(width: 10.0),
                    Text("By Specialization"),
                  ],
                ),
                onPressed: () => showSearch(
                  context: context,
                  delegate: SearchPage<Lawyer>(
                    barTheme: ThemeData.dark(),
                    items: listLawyers,
                    searchLabel: 'Search Lawyers by Specialization.',
                    suggestion: Center(
                      child: Text('Filter Lawyers by Specialization'),
                    ),
                    failure: Center(
                      child: Text('No person found :('),
                    ),
                    filter: (person) => [
                      person.courtType,
                      person.city,
                      person.specialization,
                    ],
                    builder: (nrLawyer) => Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(7),
                      child: ExpansionTile(
                        onExpansionChanged: (value) async {
                          if (value) {
                            // await checkRequest();
                          }
                        },
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: kPrimaryColor.withOpacity(0.8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: FadeInImage.assetNetwork(
                              image: nrLawyer.userPhoto,
                              placeholder:
                                  'assets/images/Bubble-Loader-Icon.gif',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 100.0,
                              child: Text(
                                nrLawyer.name.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ),
                            // Text("$distance2 m")
                            // FutureBuilder(
                            //   future: getCurrentLocation(snapshot['BLatitude'],snapshot['BLongitude']),
                            //   builder: (context,snapshot){
                            //     return Text(" ${snapshot.data} KM",
                            //     style: TextStyle(color: Colors.green),
                            //     );
                            //   })
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: 120.0,
                                child: Text(nrLawyer.address,
                                    overflow: TextOverflow.ellipsis)),
                            Text(
                              nrLawyer.overAllRating.substring(0, 3) + "🌟",
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('Phone No: ${nrLawyer.phoneNo}'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('Details of my work are following:'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('barCouncil: ${nrLawyer.barCouncil}'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('court Type: ${nrLawyer.courtType}'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                                'specialization: ${nrLawyer.specialization}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder(
                                    future: checkRequest(nrLawyer.email),
                                    builder: (context, snapshotData) {
                                      // print("Bucking Email === > ${snapshotData.data}");

                                      return MaterialButton(
                                        color: kPrimaryColor,
                                        onPressed: () async {
                                          // print(snapshot['Email'].toString());
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                ProgressDialog(
                                                    message: "Please wait..."),
                                          );
                                          try {
                                            await getUserData().then((value) {
                                              //  var user = value.data();
                                              // name = (user['displayName']);
                                              // phoneNo = (user['phoneNo']);
                                              // address = (user['Address']);

                                              if (name == null ||
                                                  address == null ||
                                                  phoneNo == null ||
                                                  nrLawyer.email == null ||
                                                  auth.currentUser.email ==
                                                      null) {
                                                var snackBar = SnackBar(
                                                    content: Text(
                                                        "Details not correct"));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else {
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'Booking Requests')
                                                    .add({
                                                  'Customer Name': name,
                                                  'Customer Address': address,
                                                  'Customer PhoneNo': phoneNo,
                                                  'user Email':
                                                      auth.currentUser.email,
                                                  'Lawyer Name': nrLawyer.name,
                                                  'Lawyer PhoneNo':
                                                      nrLawyer.phoneNo,
                                                  'Lawyer Email':
                                                      nrLawyer.email,
                                                  'Lawyer Address':
                                                      nrLawyer.address,
                                                  'status': "pending",
                                                  'rating': "0"
                                                }).then((value) {
                                                  setState(() {});
                                                });
                                              }
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Text("Book"),
                                      );
                                    }),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    customLaunch('tel:${nrLawyer.phoneNo}');
                                  },
                                  color: kPrimaryColor,
                                  child: Text('Call'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //               MaterialButton(

              //      child: Text("Search By City"),
              //  onPressed:()=>Navigator.of(context).push(
              //    MaterialPageRoute(
              //      builder: (context)=>
              //      AboutUs()
              //      )
              //      )

              // ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            availableLawyers(),
            availableCustomers(),
            acceptedOrders(),
          ],
        ),
      ),
    );
  }

  availableLawyers() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Lawyers').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return SpinKitRing(lineWidth: 5, color: Colors.blue);
        if (snapshot.data.docs.length == 0)
          return Center(
            child: Text(
              'No Lawyers Yet',
            ),
          );
        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return bList(snapshot.data.docs[index], index);
          },
        );
      },
    );
  }

  availableCustomers() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Vendors').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return SpinKitRing(lineWidth: 5, color: Colors.blue);
        if (snapshot.data.docs.length == 0)
          return Center(
            child: Text(
              'No Customers Yet',
            ),
          );
        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            //  print(snapshot.data.docs[index]['status']);
            // if(snapshot.data.docs[index]['Role']=="Deleted")
            // {
            //
            // }
            // else
            //   {
            //
            //   }
            return customerListCard(snapshot.data.docs[index], index);
          },
        );
      },
    );
  }

  // rejectedOrders() {
  //   return StreamBuilder(
  //     stream: FirebaseFirestore.instance
  //         .collection('Booking Requests')
  //         .where('user Email',
  //             isEqualTo: FirebaseAuth.instance.currentUser.email)
  //         .snapshots(),
  //     builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting)
  //         return SpinKitRing(lineWidth: 5, color: Colors.blue);
  //       if (snapshot.data.docs.length == 0)
  //         return Center(
  //           child: Text(
  //             'No Booking Requests',
  //           ),
  //         );
  //       return ListView.builder(
  //         itemCount: snapshot.data.docs.length,
  //         itemBuilder: (context, index) {
  //           return rejectedListCard(snapshot.data.docs[index], index);
  //         },
  //       );
  //     },
  //   );
  // }

  acceptedOrders() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Booking Requests')
          .where('user Email',
              isEqualTo: FirebaseAuth.instance.currentUser.email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return SpinKitRing(lineWidth: 5, color: Colors.blue);
        if (snapshot.data.docs.length == 0)
          return Center(
            child: Text(
              'No Booking Requests',
            ),
          );
        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return acceptedListCard(snapshot.data.docs[index]);
          },
        );
      },
    );
  }

  // acceptedOrders() {
  //   return Center(child: Text('Accepted Requests'));
  // }
}
