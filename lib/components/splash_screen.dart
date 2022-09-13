// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fyp/components/home_main_screen.dart';
import 'package:fyp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/components/login_screen.dart';
import 'package:awesome_loader/awesome_loader.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    print("befor3");
    _navigateToNext();
    print("fter");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      // RemoteNotification? notification = jsonDecode(message.data['notification']);
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.data['notification'];
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body.toString())],
                  ),
                ),
              );
            });
      }
    });
  }

  bool isLoading = false;
  String? token = null;
  var JsonData;

  _navigateToNext() async {
    print("here");
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    String? userData = prefs.getString('userData');

    print('before decode $userData');
    JsonData = jsonDecode(userData.toString());
    print('After decode $JsonData');

    print(token);

    // here you can fetch data from API then goto the next screen.
    await Future.delayed(Duration(milliseconds: 4000), () {});

    setState(() {
      isLoading = false;
    });
  }

// Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MyApp()));
  Widget build(BuildContext context) {
    return isLoading ? LoadingPage() : checkUser(context);
  }

  Widget checkUser(BuildContext context) {
    return this.token != null
        ? HomeScreen(currentUser: JsonData)
        : LoginScreen();
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              height: 400,
              child: Image.asset('assets/FYPLogo.png'),
            ),
            SizedBox(
              height: 100,
            ),
            Container(
              child: AwesomeLoader(
                loaderType: AwesomeLoader.AwesomeLoader3,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      )),
    );
  }
}
