import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fyp/components/currentRideDriverPickup.dart';
import 'package:fyp/components/home_main_screen.dart';
import 'package:fyp/components/pendingApproval.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'RideRequestModelClass.dart';
import '../services/authService.dart';
import 'ListRideRequestWidget.dart';
import 'home_main_screen_driver.dart';

class RideRequests extends StatefulWidget {
  final currentUser;
  const RideRequests({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<RideRequests> createState() => _RideRequestsState();
}

class _RideRequestsState extends State<RideRequests> {
  bool isLoading = false;
  List<RideRequestModelClass> rideRequestList = [];
  AppDatabase database = AppDatabase();
  //  [
  //   RideRequestModelClass(
  //     ride_id: '123',
  //     rideSeekerName: 'Noman',
  //     rideSeekerDept: 'BSCS',
  //     rideSeekerDestination: 'Karoondi',
  //     requestedSeats: 4,
  //     status: 'pending')
  //  ];
  final listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(children: [
          SizedBox(
            height: 20,
          ),
          Text(
            'Ride Requests',
            style: TextStyle(
              fontSize: 40,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          isLoading || !rideRequestList.isEmpty
              ? BuildRequestsList()
              : Container(
                  child: SpinKitWave(
                    size: 30,
                    color: Colors.white,
                  ),
                ),
        ])),
      ),
    );
  }

  BuildRequestsList() => Container(
        //child: Text('Noman'),

        margin: EdgeInsets.symmetric(horizontal: 15.0),

        alignment: Alignment.topLeft,

        child: AnimatedList(
          key: listKey,
          initialItemCount: rideRequestList.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, index, animation) => ListRideRequestWidget(
            item: rideRequestList[index],
            animation: animation,
            onCancel: () async {
              // await removeRideRequestData(index);

              // removeVehicle(index);

              print('Ride Request Rejected!');
            },
            onDone: () async {
              print('Request line 72, here we will book ride after approval');

              await aceeptRideRequest(index);
            },
            context: context,
          ),
        ),
      );
// {
//       print('ride request is here: ${rideRequestList[0].rideSeekerName}');
//       return (

//       );
//   }

  removeRideRequestData(index) async {
    print('inside Remove ride Request');
    try {
      var response = await AppDatabase().postData('api/remove_ride_request', {
        "_id": rideRequestList[index].ride_id.toString(),
      });

      if (response != null) {
        var JsonData = jsonDecode(response);
        var res = JsonData['data'];
        print('Removed: $res');
      } else {
        print('Cannot remove');
      }
    } on Exception catch (e) {
      // TODO
      print(e.toString());
    }
  }

  removeVehicle(int index) {
    final removedItem = rideRequestList[index];
    rideRequestList.removeAt(index);
    listKey.currentState!.removeItem(
        index,
        (context, animation) => ListRideRequestWidget(
              item: removedItem,
              animation: animation,
              onCancel: () {},
              onDone: () {},
              context: context,
            ),
        duration: Duration(milliseconds: 600));
  }

  fetchData() async {
    try {
      var result = await database.postData('getBookRequests', {
        "driver_id": widget.currentUser['_id'],
      });

      print("the result is $result");
      if (result != null) {
        var JsonData = jsonDecode(result.toString());
        var vehiclesData = JsonData['data'];
        rideRequestList.clear();
        final length = vehiclesData.length;
        for (var i = 0; i < length; i++) {
          await _getRideSeekerDetails(
              vehiclesData[i]['user_id'], vehiclesData[i]);
        }
        setState(() {
          rideRequestList = rideRequestList;
          //isLoading=true;
        });
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  _getRideSeekerDetails(user_id, singleRideSeekerInfo) async {
    try {
      var result = await AppDatabase().postData('getUserInfo', {
        "_id": user_id,
      });

      print(result);
      if (result != null) {
        var JsonData = jsonDecode(result.toString());
        var data = JsonData['data'];
        print('Ride_ID is: ${singleRideSeekerInfo['_id']}');
        print('Status: ${singleRideSeekerInfo['ride_status']}');
        if (singleRideSeekerInfo['ride_status'] == 'Pending') {
          rideRequestList.add(
            RideRequestModelClass(
              rideFare: singleRideSeekerInfo['ride_fare'].toDouble(),
              totalKms: singleRideSeekerInfo['total_kms'].toDouble(),
              ridetime: singleRideSeekerInfo['ride_time'].toString(),
              rideDate: singleRideSeekerInfo['ride_date'].toString(),
              ride_id: singleRideSeekerInfo['_id'],
              driver_id: singleRideSeekerInfo['driver_id'],
              user_id: user_id,
              vehicle_id: singleRideSeekerInfo['vehicle_id'],
              userName: data['name'],
              userDestinationLon: singleRideSeekerInfo['user_destination_lon'],
              userDestinationLat: singleRideSeekerInfo['user_destination_lat'],
              userSourceLon: singleRideSeekerInfo['user_source_lon'],
              userSourceLat: singleRideSeekerInfo['user_source_lat'],
              status: singleRideSeekerInfo['ride_status'],
            ),
          );
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  aceeptRideRequest(index) async {
    var data = {
      "driver_id": widget.currentUser['_id'],
      "user_id": rideRequestList[index].user_id,
      "vehicle_id": rideRequestList[index].vehicle_id,
      "ride_id": rideRequestList[index].ride_id,
      "ride_date": rideRequestList[index].rideDate,
      "ride_time": rideRequestList[index].ridetime,
      "user_source_lat": rideRequestList[index].userSourceLat,
      "user_source_lon": rideRequestList[index].userSourceLon,
      "user_destination_lat": rideRequestList[index].userDestinationLat,
      "user_destination_lon": rideRequestList[index].userDestinationLon,
      "ride_fare": rideRequestList[index].rideFare,
      "total_kms": rideRequestList[index].totalKms,
      "ride_status": 'Approved',
    };

    if (rideRequestList[index].status == 'Pending') {
      var result = await AppDatabase().postData('bookRide', data);

      if (result != null) {
        print('Ride Approved!');
        var response = await AppDatabase().postData(
            'updateRideStatus', {"_id": rideRequestList[index].ride_id});
        print('Ride _ID is2: ${rideRequestList[index].ride_id}');
        if (response != null) {
          print('Status Updated!');
          var data2 = {
            "_id": widget.currentUser['_id'],
          };

          // var response =
          //     await AppDatabase().postData("driverUnavailable", data2);
          // if (response == null) {
          //   print(response);
          // }
          // setState(() {
          //   rideRequestList[index].status == 'Approved';
          // });

          pushNewScreen(
            context,
            screen: CurrentRideDriverPickup(
              rideData: data,
              currentUser: widget.currentUser,
            ),
            withNavBar: true, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );

          // print("object");
          // // pushNewScreen(context, screen: CurrentRideDriver(rideData: data));
        } else {
          print('cannot Updated Status!');
        }
        //  await removeRideRequestData(index);
        //  removeVehicle(index);

      } else {
        print('Cannot Approve ride got null value');
      }
    } else {
      print("Already Approved!");
    }
  }
}
