import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fyp/secrets.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  static const LatLng Source = LatLng(27.705794, 68.857099);
  static const LatLng Dest = LatLng(28.705794, 67.857099);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor trIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    // GoogleMapController googleMapController = await mapController.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          zoom: 13.5, target: LatLng(newLoc.latitude!, newLoc.longitude!))));
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Secrets.API_KEY,
        PointLatLng(Source.latitude, Source.longitude),
        PointLatLng(Dest.latitude, Dest.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(0.5, 0.5)), "assets/FYPLogo.png")
        .then((icon) {
      sourceIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(0.1, 0.1)), "assets/FYPLogo.png")
        .then((icon) {
      destIcon = icon;
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    setCustomMarkerIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            body: Stack(
      children: <Widget>[
        currentLocation == null
            ? const Center(child: Text("Loading"))
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 14.5),
                polylines: {
                  Polyline(
                      polylineId: PolylineId("route"),
                      points: polylineCoordinates,
                      color: Colors.red,
                      width: 5)
                },
                markers: {
                  Marker(
                      icon: sourceIcon,
                      markerId: MarkerId("Current Location"),
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!)),
                  Marker(
                      icon: destIcon,
                      markerId: MarkerId("Source"),
                      position: Source),
                  Marker(
                      icon: destIcon,
                      markerId: MarkerId("Dest"),
                      position: Dest)
                },
                onMapCreated: (controller) {
                  mapController = controller;
                  // _controller.complete(controller);
                },
              ),

        // Show zoom buttons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ClipOval(
                  child: Material(
                    color: Colors.blue.shade100, // button color
                    child: InkWell(
                      splashColor: Colors.blue, // inkwell color
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.add),
                      ),
                      onTap: () {
                        mapController.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ClipOval(
                  child: Material(
                    color: Colors.blue.shade100, // button color
                    child: InkWell(
                      splashColor: Colors.blue, // inkwell color
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.remove),
                      ),
                      onTap: () {
                        mapController.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        // // Show the place input fields & button for
        // // showing the route
        // SafeArea(
        //   child: Align(
        //     alignment: Alignment.topCenter,
        //     child: Padding(
        //       padding: const EdgeInsets.only(top: 10.0),
        //       child: Container(
        //         decoration: BoxDecoration(
        //           color: Colors.white70,
        //           borderRadius: BorderRadius.all(
        //             Radius.circular(20.0),
        //           ),
        //         ),
        //         width: width * 0.9,
        //         child: Padding(
        //           padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        //           child: Column(
        //             mainAxisSize: MainAxisSize.min,
        //             children: <Widget>[
        //               Text(
        //                 'Places',
        //                 style: TextStyle(fontSize: 20.0),
        //               ),
        //               SizedBox(height: 10),
        //               _textField(
        //                   label: 'Start',
        //                   hint: 'Choose starting point',
        //                   prefixIcon: Icon(Icons.looks_one),
        //                   suffixIcon: IconButton(
        //                     icon: Icon(Icons.my_location),
        //                     onPressed: () {
        //                       startAddressController.text = _currentAddress;
        //                       _startAddress = _currentAddress;
        //                     },
        //                   ),
        //                   controller: startAddressController,
        //                   focusNode: startAddressFocusNode,
        //                   width: width,
        //                   locationCallback: (String value) {
        //                     setState(() {
        //                       _startAddress = value;
        //                     });
        //                   }),
        //               SizedBox(height: 10),
        //               _textField(
        //                   label: 'Destination',
        //                   hint: 'Choose destination',
        //                   prefixIcon: Icon(Icons.looks_two),
        //                   controller: destinationAddressController,
        //                   focusNode: desrinationAddressFocusNode,
        //                   width: width,
        //                   locationCallback: (String value) {
        //                     setState(() {
        //                       _destinationAddress = value;
        //                     });
        //                   }),
        //               SizedBox(height: 10),
        //               Visibility(
        //                 visible: _placeDistance == null ? false : true,
        //                 child: Text(
        //                   'DISTANCE: $_placeDistance km',
        //                   style: TextStyle(
        //                     fontSize: 16,
        //                     fontWeight: FontWeight.bold,
        //                   ),
        //                 ),
        //               ),
        //               SizedBox(height: 5),
        //               ElevatedButton(
        //                 onPressed: (_startAddress != '' &&
        //                         _destinationAddress != '')
        //                     ? () async {
        //                         startAddressFocusNode.unfocus();
        //                         desrinationAddressFocusNode.unfocus();
        //                         setState(() {
        //                           if (markers.isNotEmpty) markers.clear();
        //                           if (polylines.isNotEmpty) polylines.clear();
        //                           if (polylineCoordinates.isNotEmpty)
        //                             polylineCoordinates.clear();
        //                           _placeDistance = null;
        //                         });

        //                         _calculateDistance().then((isCalculated) {
        //                           if (isCalculated) {
        //                             ScaffoldMessenger.of(context).showSnackBar(
        //                               SnackBar(
        //                                 content: Text(
        //                                     'Distance Calculated Sucessfully'),
        //                               ),
        //                             );
        //                           } else {
        //                             ScaffoldMessenger.of(context).showSnackBar(
        //                               SnackBar(
        //                                 content:
        //                                     Text('Error Calculating Distance'),
        //                               ),
        //                             );
        //                           }
        //                         });
        //                       }
        //                     : null,
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     'Show Route'.toUpperCase(),
        //                     style: TextStyle(
        //                       color: Colors.white,
        //                       fontSize: 20.0,
        //                     ),
        //                   ),
        //                 ),
        //                 style: ElevatedButton.styleFrom(
        //                   primary: Colors.red,
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.circular(20.0),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    )));
  }
}
