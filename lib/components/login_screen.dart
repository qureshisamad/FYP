import 'dart:convert';

import 'package:awesome_loader/awesome_loader.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fyp/components/driveroruser.dart';
import 'package:fyp/services/authService.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/authService.dart';
import '/components/home_main_screen.dart';
import '/components/sign_up_form_one.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LoginScreen> {
  TextEditingController uCNIC = TextEditingController();
  TextEditingController uPassword = TextEditingController();
  bool setPasswordFieldVisible = true;
  late currentUserData userCurrent;
  bool isLoading = false;

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  saveTokenToDatabase(String? token) async {
    final result = AppDatabase().postData('save_device_token', {
      "user_id": uCNIC.text,
      "device_token": token,
    });
    if (result != null) {
      print('Saved the token! $result');
    } else {
      print('couldnot save the token');
    }
  }

  _getDeviceToken() async {
    String? deviceToken = await firebaseMessaging.getToken();

    print('device token is: $deviceToken');
    await saveTokenToDatabase(deviceToken);
    firebaseMessaging.subscribeToTopic("promotion");
    firebaseMessaging.onTokenRefresh.listen(saveTokenToDatabase);
    await firebaseMessaging.setAutoInitEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: LoaderOverlay(
      child: Scaffold(
          backgroundColor: Colors.red,
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 200.0,
                  child: ClipPath(
                    clipper: MyClipper(),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 540.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
                ),
                Positioned(
                  top: 100.0,
                  left: MediaQuery.of(context).size.width - 170.0,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 180.0,
                        height: 180.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/FYPLogo2.png'))),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 290.0,
                  left: 40.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Welcome to',
                        style: TextStyle(color: Colors.black, fontSize: 20.0),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'E-AMBULANCE',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 27.0),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please sign in to continue',
                          style: TextStyle(color: Colors.black, fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Container(
                          width: 250.0,
                          child: TextField(
                            controller: uCNIC,
                            decoration: InputDecoration(
                                labelText: 'CNIC',
                                hintText: 'Enter Your CNIC',
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            // onChanged: (v) => {
                            //   uEmail.text = v.toString(),
                            // },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: 250.0,
                          child: TextField(
                            controller: uPassword,
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(
                                  Icons.security,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            // onChanged: (v) => {
                            //   uPassword.text = v.toString(),
                            // },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          'Forgot Password ?',
                          style: TextStyle(color: Colors.black, fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                          width: 100.0,
                          height: 40.0,
                          child: RaisedButton(
                            splashColor: Colors.yellow,
                            color: Colors.red,
                            padding: EdgeInsets.all(12.0),
                            shape: StadiumBorder(),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreenOne()));
                            },
                            child: Text(
                              'REGISTER',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                          width: 100.0,
                          height: 40.0,
                          child: RaisedButton(
                            splashColor: Colors.yellow,
                            color: Colors.red,
                            padding: EdgeInsets.all(12.0),
                            shape: StadiumBorder(),
                            onPressed: () {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: EdgeInsets.all(10),
                                        child: Container(
                                          // width: 200,
                                          height: 200,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white),
                                          padding: EdgeInsets.all(10.0),
                                          child: Column(children: <Widget>[
                                            Text("FINISH RIDE",
                                                style: TextStyle(fontSize: 24),
                                                textAlign: TextAlign.center),
                                          ]),
                                        ));
                                  });
                              // showDialog(
                              //     context: context,
                              //     builder: (BuildContext context) {
                              //       return AlertDialog(
                              //         title: Text(
                              //           "FINISH RIDE",
                              //           textAlign: TextAlign.center,
                              //         ),
                              //         content: Column(
                              //           children: <Widget>[
                              //             InkResponse(
                              //               onTap: () {
                              //                 Navigator.of(context).pop();
                              //               },
                              //               child: CircleAvatar(
                              //                 child: Icon(Icons.close),
                              //                 backgroundColor: Colors.red,
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       );
                              //     });
                            },
                            child: Text(
                              'TEST',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 + 150.0,
                  left: MediaQuery.of(context).size.width - 200.0,
                  child: Container(
                    width: 100.0,
                    height: 40.0,
                    child: RaisedButton(
                      splashColor: Colors.yellow,
                      color: Colors.red,
                      padding: EdgeInsets.all(12.0),
                      shape: StadiumBorder(),
                      onPressed: () async {
                        var data = {
                          "cnic": uCNIC.text,
                          "password": uPassword.text,
                        };

                        try {
                          if (RegExp("^[0-9]{5}-[0-9]{7}-[0-9]{1}")
                              .hasMatch(uCNIC.text)) {
                            print("YES");
                            context.loaderOverlay.show();
                            setState(() {
                              isLoading = true;
                            });
                            var response =
                                await AppDatabase().postData("login", data);
                            if (response != null) {
                              var JsonData = jsonDecode(response.toString());
                              var currentUser = JsonData['data'];

                              String user = jsonEncode(currentUser);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                  'token', JsonData['token'].toString());
                              await prefs.setString('userData', user);
                              userCurrent = new currentUserData(currentUser);

                              setState(() {
                                isLoading = false;
                              });
                              await _getDeviceToken();
                              context.loaderOverlay.hide();

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => driverOrUser(
                                          currentUser: currentUser)));
                            } else {
                              context.loaderOverlay.hide();

                              showAlertDialog(
                                  context,
                                  "We are having some technical difficulties",
                                  "Please try again");
                            }
                          } else {
                            print("NO");
                            showAlertDialog(context, "Correct the following",
                                "Enter a valid CNIC in format 00000-0000000-0");
                          }
                        } on Exception catch (e) {
                          print(e.toString());
                        }
                      },
                      child: Text(
                        'LOGIN',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    ));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height - 80.0);

    var firstControlPoint = new Offset(50.0, size.height);
    var firstEndPoint = new Offset(size.width / 3.5, size.height - 45.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    path.lineTo(size.width - 30.0, size.height / 2);

    var secondControlPoint =
        new Offset(size.width + 15.0, size.height / 2 - 60.0);
    var secondEndPoint = new Offset(140.0, 50.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    var thirdControlPoint = new Offset(50.0, 0.0);
    var thirdEndPoint = new Offset(0.0, 100.0);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy,
        thirdEndPoint.dx, thirdEndPoint.dy);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class currentUserData {
  var id;
  var name;
  var phoneNumber;
  var email;
  var cnic;

  currentUserData(currentUser) {
    id = currentUser["_id"];
    name = currentUser["name"];
    email = currentUser["email"];
    phoneNumber = currentUser["phoneNumber"].toString();
    cnic = currentUser["cnic"].toString();
  }
}

showAlertDialog(BuildContext context, String title, String content) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      // okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
