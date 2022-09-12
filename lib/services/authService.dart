import 'dart:io';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fyp/services/baseurl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';

class AppDatabase {
  Dio dio = new Dio();

  String BASEURL = baseurl.url;

  postData(apiUrl, dataObject) async {
    try {
      print(dataObject);
      print(BASEURL);
      var url = Uri.parse('${BASEURL}/$apiUrl');
      final response = await dio.post(url.toString(), data: dataObject);

      if (response.statusCode == 200) {
        return response;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getRecords(_api) async {
    try {
      var url = Uri.parse('${BASEURL}/$_api');
      final response = await dio.post(url.toString());

      if (response.statusCode == 200) {
        return response;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  updateData(apiUrl, dataObject) async {
    try {
      var url = Uri.parse('${BASEURL}/$apiUrl');
      final response = await dio.put(url.toString(), data: dataObject);

      if (response.statusCode == 200) {
        return response;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  upload(File? imageFile, api, userCNIC) async {
// open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile!.openRead()));

// get file length
    var length = await imageFile.length();

// string to uri
    var uri = Uri.parse('${BASEURL}/$api');

// create multipart request
    var request = new http.MultipartRequest("POST", uri);
    request.fields['userCNIC'] = userCNIC;

// multipart that takes file
    var multipartFile = new http.MultipartFile('myFile', stream, length,
        filename: basename(imageFile.path));

    request.headers.addAll({
      "userCNIC": userCNIC,
    });

// add file to multipart
    request.files.add(multipartFile);

// send
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print(response.statusCode);
// listen for response
// response.stream.transform(utf8.decoder).listen((value) {
// print(value);
// });

    return respStr;
  }
  // getSingleData(_api, data) async {
  //     try {

  //       print("im here $data");
  //       var url = Uri.parse('${BASEURL}/$_api');
  //       final response = await dio.post(url, body: data);
  //       print('body: ${response.body}');
  //       if (response.statusCode == 200) {
  //         return response.body;
  //       }

  //     } on Exception catch (e) {
  //       print(e.toString());
  //     }

  //     }

}

class AuthService {
  Dio dio = new Dio();

  login(name, password) async {
    try {
      return await dio.post("http://localhost:3000/authenticate",
          data: {"name": name, "password": password},
          options: Options(contentType: Headers.formUrlEncodedContentType));
    } on DioError catch (err) {
      print(err.response);
    }
  }

  // addUser(name,phoneNumber,email,password,cnic) async {
  //   try{
  //     return await dio.post("http://localhost:3000/addUser",
  //     data: {"name": name, "phoneNumber": phoneNumber, "em"},
  //     );

  //   }
  //   catch
  // }
}
