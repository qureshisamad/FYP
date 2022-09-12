import 'package:fyp/components/home_main_screen_driver.dart';
import 'package:fyp/components/login_screen.dart';
import 'package:fyp/components/pendingApproval.dart';
import 'package:fyp/components/vehicleReg.dart';

import '/components/home_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class driverOrUser extends StatefulWidget {
  final currentUser;
  const driverOrUser({Key? key, required this.currentUser}) : super(key: key);
  @override
  State<driverOrUser> createState() => _driverOrUser();
}

class _driverOrUser extends State<driverOrUser> {
  TextEditingController pin1 = TextEditingController();
  TextEditingController pin2 = TextEditingController();
  TextEditingController pin3 = TextEditingController();
  TextEditingController pin4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
        child: Container(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              child: Image.asset('assets/FYPLogo.png'),
            ),
            Container(
              child: Text(
                'Select Mode',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 35.0)),
                      onPressed: () async {
                        var status = widget.currentUser["status"];
                        if (status == "user") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VehicleDetails(
                                      currentUser: widget.currentUser)));
                        } else if (status == "driver") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreenDriver(
                                      currentUser: widget.currentUser)));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PendingApproval(
                                      currentUser: widget.currentUser)));
                        }
                      },
                      child: Text('Driver')),
                  SizedBox(
                    width: 20.0,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 35.0)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                    currentUser: widget.currentUser)));
                      },
                      child: Text('User'))
                ],
              ),
            )
          ]),
        ),
      )),
    );
  }
}

Widget InputPin(TextEditingController pin, BuildContext context) {
  return SizedBox(
    height: 68,
    width: 64,
    child: TextField(
      controller: pin,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(15))),
      style: Theme.of(context).textTheme.headline6,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        LengthLimitingTextInputFormatter(1),
        FilteringTextInputFormatter.digitsOnly
      ],
    ),
  );
}
