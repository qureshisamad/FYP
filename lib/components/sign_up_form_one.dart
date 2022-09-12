import 'dart:convert';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/services.dart';
import 'package:fyp/components/home_main_screen.dart';
import 'package:fyp/services/authService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '/components/login_screen.dart';
import 'package:flutter/material.dart';
import 'generate_otp.dart';

class SignUpScreenOne extends StatefulWidget {
  @override
  _signUpScreenOne createState() => _signUpScreenOne();
}

class _signUpScreenOne extends State<SignUpScreenOne> {
  TextEditingController uName = TextEditingController();
  TextEditingController uPhoneNumber = TextEditingController();
  TextEditingController uEmail = TextEditingController();
  TextEditingController uPassword = TextEditingController();
  // TextEditingController uEmployeeId = TextEditingController();
  TextEditingController uCNIC = TextEditingController();
  // TextEditingController uAddress = TextEditingController();
  TextEditingController uAge = TextEditingController();
  TextEditingController uGender = TextEditingController();

  late currentUserData userCurrent;

  bool setPasswordFieldVisible = true;

  File? userImage;

  bool isLoading = false;

  Widget build(BuildContext context) {
    return MaterialApp(
        home: LoaderOverlay(
      child: Scaffold(
        body: SingleChildScrollView(
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
                GestureDetector(
                  onTap: () async {
                    final image =
                        await PickImage().chooseImage(ImageSource.gallery);
                    //imageObject["fullImagePath"];
                    //var imageName = imageObject["imageName"];

                    print(image.path);
                    final splitted = image.path.split('/');
                    var userProfileImageName = splitted[splitted.length - 1];
                    setState(() {
                      userImage = image;
                    });
                  },
                  child: Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(top: 20),
                    child: userImage != null
                        ? ClipOval(
                            child: Image.file(
                            userImage!,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                          ))
                        : CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              backgroundImage: AssetImage('assets/FYPLogo.png'),
                              radius: 80,
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
                    controller: uName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.people),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    controller: uPhoneNumber,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      labelText: 'Phone Number',
                      hintText: 'Enter Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    controller: uEmail,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      labelText: 'Email',
                      hintText: 'Enter Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    controller: uPassword,
                    obscureText: setPasswordFieldVisible,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            setPasswordFieldVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              setPasswordFieldVisible =
                                  !setPasswordFieldVisible;
                            });
                          },
                        ),
                        labelText: 'Password',
                        hintText: 'Enter Password'),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    controller: uCNIC,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      labelText: 'CNIC',
                      hintText: 'Enter CNIC',
                      prefixIcon: Icon(Icons.card_membership),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            DropdownButton<String>(
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20.0),
                              underline: Container(
                                height: 2,
                                color: Colors.red,
                              ),
                              hint: uGender.text == ""
                                  ? Text('Gender')
                                  : Text(uGender.text),
                              items: <String>['Male', 'Female'].map((String e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  uGender.text = newValue!;
                                });
                              },
                            ),
                            RaisedButton(
                              splashColor: Colors.yellow,
                              color: Colors.red,
                              padding: EdgeInsets.all(12.0),
                              shape: StadiumBorder(),
                              onPressed: () {
                                BottomPicker.date(
                                        title: "Set Your Birthday",
                                        titleStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.blue),
                                        onChange: (index) {
                                          print(index);
                                        },
                                        onSubmit: (index) {
                                          print(index);
                                          uAge.text = index;
                                        },
                                        bottomPickerTheme:
                                            BottomPickerTheme.plumPlate)
                                    .show(context);
                              },
                              child: Text(
                                'Set Age',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ]),
                    )),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  child: ElevatedButton(
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 100.0),
                        primary: Colors.red),
                    onPressed: () async {
                      if (RegExp("^[0-9]{5}-[0-9]{7}-[0-9]{1}")
                              .hasMatch(uCNIC.text) &&
                          RegExp("^(?:[+0][1-9])?[0-9]{10}")
                              .hasMatch(uPhoneNumber.text) &&
                          EmailValidator.validate(uEmail.text)) {
                        context.loaderOverlay.show();
                        var uploadImage = await AppDatabase()
                            .upload(userImage, 'profileImage', uCNIC.text);

                        print('upload image: ${uploadImage}');
                        // print('statistics: ${statistics}');
                        // print('setReviews: ${setReviews}');

                        if (uploadImage != null) {
                          var data = {
                            "name": uName.text,
                            "phoneNumber": uPhoneNumber.text,
                            "email": uEmail.text,
                            "password": uPassword.text,
                            "cnic": uCNIC.text,
                            "gender": uGender.text,
                            "imageName":
                                jsonDecode(uploadImage.toString())['data']
                                    ['file'],
                            "status": "user"
                          };
                          var result =
                              await AppDatabase().postData("register", data);
                          print("this is result");
                          print(result);
                          if (result != null) {
                            userCurrent = new currentUserData(data);
                            context.loaderOverlay.hide();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          } else {
                            context.loaderOverlay.hide();
                            showAlertDialog(context, "CNIC ALREADY REGISTERED");
                          }
                        } else {}
                      } else {
                        showAlertDialog(context,
                            "Please correct the following : \n CNIC : 00000-0000000-0 \n Phone Number : 03117468602 \n Email : saq@gmail.com");
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? '),
                      new GestureDetector(
                        child: Text(
                          'Log in',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                              (route) => false);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class PickImage {
  var image;
  Future chooseImage(ImageSource source) async {
    try {
      final ImagePicker _picker = ImagePicker();
      // Pick an image
      final image = await _picker.pickImage(source: source);
      if (image == null) return;

      //final ImageTemp = File(image.path);
      final imagePerminant = await saveImagePermanently(image.path);
      //print('image name is${image.name} image path is ${image.path}');

      return imagePerminant;
      //{"fullImagePath":imagePerminant, "imageName":image.path};

    } on PlatformException catch (e) {
      // TODO
      print('Faild to pick image');
    }
    return null;
  }

  Future<File> saveImagePermanently(String path) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final name = basename(path);
    final image = File('${appDocDir.path}/${name}');
    return File(path).copy(image.path);
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
