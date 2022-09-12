import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp/components/pendingApproval.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/widgets/widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../services/authService.dart';

var imageFile;

class VehicleDetails extends StatefulWidget {
  final currentUser;
  const VehicleDetails({Key? key, required this.currentUser}) : super(key: key);
  @override
  _VehicleDetailsState createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _modelNameController = TextEditingController();
  TextEditingController _vehicleNumberController = TextEditingController();
  TextEditingController _ownerNameController = TextEditingController();
  TextEditingController _colorController = TextEditingController();
  TextEditingController _aadharcardController = TextEditingController();
  TextEditingController _rentAmount = TextEditingController();

  // late File imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final selected = await ImagePicker().getImage(source: source);
    setState(() {
      imageFile = File(selected!.path);
    });
  }

  void _clear() {
    // setState(() {
    //   imageFile = null;
    // });
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return MaterialApp(
        home: LoaderOverlay(
      child: Scaffold(
        body: SingleChildScrollView(
            child: Center(
          child: Container(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 15.0, top: 5.0),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 15.0),
                        child: Text('Create Your Account'),
                      ),
                    ]),
                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(top: 5.0),
                      child: Image.asset(
                        'assets/FYPLogo.png',
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    controller: _modelNameController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      labelText: 'Vehicle Model',
                      hintText: 'Enter your vehicle model',
                      prefixIcon: Icon(
                        Icons.car_rental,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    controller: _vehicleNumberController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      labelText: 'Vehicle Number',
                      hintText: 'Enter your vehicle number',
                      prefixIcon: Icon(
                        Icons.security,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    controller: _colorController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      labelText: 'Vehicle Color',
                      hintText: 'Enter your vehicle color',
                      prefixIcon: Icon(
                        Icons.color_lens,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  child: ElevatedButton(
                    child: Text(
                      'REGISTER VEHICLE',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 100.0),
                        primary: Colors.red),
                    onPressed: () async {
                      context.loaderOverlay.show();
                      var data = {
                        "owner_id": widget.currentUser["_id"],
                        "vehicle_name": _modelNameController.text,
                        // "vehicle_make_year":
                        //     _vehicleNumberController.text,
                        "vehicle_number": _vehicleNumberController.text,
                        "vehicle_status": "pending",
                        // "status": "user"
                      };
                      print(data);
                      var result =
                          await AppDatabase().postData("registerVehicle", data);
                      print(result);
                      if (result != null) {
                        context.loaderOverlay.hide();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PendingApproval(
                                    currentUser: widget.currentUser)));
                      } else {
                        context.loaderOverlay.hide();
                        showAlertDialog(
                            context, "Cannot Register Vehicle Right Now");
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
        )),
      ),
    ));
  }
}

showAlertDialog(BuildContext context, String text) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(""),
    content: Text(text),
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
