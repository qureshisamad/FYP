import 'package:fyp/components/login_screen.dart';

import '/components/home_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenerateOTP extends StatefulWidget {
  @override
  State<GenerateOTP> createState() => _GenerateOTPState();
}

class _GenerateOTPState extends State<GenerateOTP> {
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
              child: Image.asset('assets/OTP.png'),
            ),
            Container(
              child: Text(
                'Verification',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              child: Text('An OTP has been sent to your mobile number'),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InputPin(pin1, context),
                  InputPin(pin2, context),
                  InputPin(pin3, context),
                  InputPin(pin4, context),
                ],
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: 'Resend Code after ',
                  style: TextStyle(color: Colors.black)),
              TextSpan(text: '00:00', style: TextStyle(color: Colors.blue))
            ])),
            SizedBox(
              height: 35.0,
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
                      onPressed: () {},
                      child: Text('Resend')),
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
                                builder: (context) => LoginScreen()));
                      },
                      child: Text('Confirm'))
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
