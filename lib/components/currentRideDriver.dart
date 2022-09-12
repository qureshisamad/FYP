import 'dart:async';
import 'dart:convert';
import 'package:fyp/components/RideRequests.dart';
import 'package:fyp/components/driver_main.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fyp/services/authService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../secrets.dart'; // Stores the Google Maps API Key
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as googlePlaces;
import 'dart:math' show cos, sqrt, asin;
import 'package:rating_dialog/rating_dialog.dart';

class CurrentRideDriver extends StatefulWidget {
  final rideData;
  final currentUser;
  const CurrentRideDriver(
      {Key? key, required this.rideData, required this.currentUser})
      : super(key: key);
  @override
  _CurrentRideDriver createState() => _CurrentRideDriver();
}

class _CurrentRideDriver extends State<CurrentRideDriver> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocIcon = BitmapDescriptor.defaultMarker;

  late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String _source = '';
  String _destination = '';
  String? _placeDistance;

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late googlePlaces.GooglePlace googlePlace;
  List<googlePlaces.AutocompletePrediction> predictions = [];
  Timer? _debounce;
  googlePlaces.DetailsResult? startPosition;
  googlePlaces.DetailsResult? endPosition;

  late String startCoordinatesString;
  late String destinationCoordinatesString;

  late double startLatitude;
  late double startLongitude;
  late double destinationLatitude;
  late double destinationLongitude;
  late StreamSubscription<Position> positionStream;
  bool reached = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    setCustomMarkerIcon();
    driverUnavailable();
    setAddress();
  }

  Future<void> driverUnavailable() async {
    var data = {
      "_id": widget.rideData["driver_id"],
    };

    var response = await AppDatabase().postData("driverUnavailable", data);
  }

  void setAddress() async {
    try {
      List<Placemark> source = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      List<Placemark> dest = await placemarkFromCoordinates(
          widget.rideData["user_destination_lat"],
          widget.rideData["user_destination_lon"]);

      Placemark placeSource = source[0];
      Placemark placeDest = source[0];

      setState(() {
        _source =
            "${placeSource.name}, ${placeSource.locality}, ${placeSource.postalCode}, ${placeSource.country}";
        _destination =
            "${placeDest.name}, ${placeDest.locality}, ${placeDest.postalCode}, ${placeDest.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        timeLimit: Duration(seconds: 10),
      );
      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position? position) async {
        print(position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
        setState(() {
          _currentPosition = position!;
          if (markers.isNotEmpty) markers.clear();
          if (polylines.isNotEmpty) polylines.clear();
          if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();
          _placeDistance = null;
          print('CURRENT POS: $_currentPosition');
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 18.0,
              ),
            ),
          );
        });
        await _calculateDistance();
        // print(_placeDistance);
        if (_placeDistance == "0.00") {
          print("In IF");
          positionStream.cancel();
          setState(() {
            reached = true;
          });
        } else {
          print("In ELSE");
        }
      });
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> source = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      List<Placemark> dest = await placemarkFromCoordinates(
          widget.rideData["user_destination_lat"],
          widget.rideData["user_destination_lon"]);

      Placemark placeSource = source[0];
      Placemark placeDest = source[0];

      setState(() {
        _currentAddress = "${placeSource.name}";
        // _currentAddress =
        //     "${placeSource.name}, ${placeSource.locality}, ${placeSource.postalCode}, ${placeSource.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
        _destinationAddress = "${placeDest.name}";
      });
      // await _calculateDistance();
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      // List<Location> startPlacemark =
      //     await locationFromAddress(_currentAddress);
      // List<Location> destinationPlacemark =
      //     await locationFromAddress(_destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      // startLatitude = _currentPosition.latitude;
      // startLongitude = _currentPosition.longitude;
      startLatitude = widget.rideData["user_destination_lat"];
      startLongitude = widget.rideData["user_destination_lon"];
      print(widget.rideData);
      destinationLatitude = widget.rideData["user_destination_lat"];
      destinationLongitude = widget.rideData["user_destination_lon"];

      startCoordinatesString = '($startLatitude,$startLongitude)';
      destinationCoordinatesString =
          '($destinationLatitude,$destinationLongitude)';
      print(startCoordinatesString + destinationCoordinatesString);

      // // Start Location Marker
      // Marker startMarker = Marker(
      //     markerId: MarkerId(startCoordinatesString),
      //     position: LatLng(startLatitude, startLongitude),
      //     infoWindow: InfoWindow(
      //       title: 'Start $startCoordinatesString',
      //       snippet: _startAddress,
      //     ),
      //     icon: sourceIcon);

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: destIcon,
      );

      // Destination Location Marker
      Marker currentLocMarker = Marker(
        markerId: MarkerId("Current Loc"),
        position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        infoWindow: InfoWindow(
          title: 'Current Loc $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: currentLocIcon,
      );
      // Adding the markers to the list
      // markers.add(startMarker);
      markers.add(destinationMarker);
      markers.add(currentLocMarker);

      print(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      print(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator.bearingBetween(
      //   startLatitude,
      //   startLongitude,
      //   destinationLatitude,
      //   destinationLongitude,
      // );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        // _placeDistance = distanceInMeters.toStringAsFixed(2);
        _placeDistance = totalDistance.toStringAsFixed(2);
        print(_placeDistance);
        print('DISTANCE: $_placeDistance km');
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
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

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(0.1, 0.1)), "assets/FYPLogo2.png")
        .then((icon) {
      currentLocIcon = icon;
    });
  }

  final _dialog = RatingDialog(
    initialRating: 1.0,
    // your app's name?
    title: Text(
      'Rating Dialog',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    ),
    // encourage your user to leave a high rating?
    message: Text(
      'Your feedback matters to us, give rating to your driver.',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 15),
    ),
    // your app's logo?
    image: const FlutterLogo(size: 100),
    submitButtonText: 'Submit',
    commentHint: 'Would you recommend the driver ?',
    onCancelled: () => print('cancelled'),
    onSubmitted: (response) {
      print('rating: ${response.rating}, comment: ${response.comment}');

      // TODO: add your own logic
      if (response.rating < 3.0) {
        // send their comments to your email or anywhere you wish
        // ask the user to contact you instead of leaving a bad review
      } else {
        // _rateAndReviewApp();
      }
    },
  );

  Widget _Row({
    required String text,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(text),
        SizedBox(
          width: 5.0,
        ),
        Text(value)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: Set<Marker>.from(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
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
            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Ongoing',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Text(
                                'Source :'.toUpperCase(),
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Text(
                                _source,
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Text(
                                'DESTINATION :'.toUpperCase(),
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Text(
                                _destination,
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'DISTANCE: $_placeDistance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Visibility(
                                  visible: reached ? true : false,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // show the dialog
                                      // showDialog(
                                      //   context: context,
                                      //   barrierDismissible:
                                      //       true, // set to false if you want to force a rating
                                      //   builder: (context) => _dialog,
                                      // );
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding:
                                                    EdgeInsets.all(10),
                                                child: Container(
                                                  // width: 200,
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: Colors.white),
                                                  padding: EdgeInsets.all(10.0),
                                                  child:
                                                      Column(children: <Widget>[
                                                    Text("FINISH RIDE",
                                                        style: TextStyle(
                                                            fontSize: 24),
                                                        textAlign:
                                                            TextAlign.center),
                                                    _Row(
                                                        text: "User",
                                                        value: _source),
                                                    _Row(
                                                        text: "Destination",
                                                        value: _destination),
                                                    _Row(
                                                        text: "Total Distance",
                                                        value: widget.rideData[
                                                                "total_kms"]
                                                            .toString()),
                                                    _Row(
                                                        text: "Total Cost",
                                                        value: widget.rideData[
                                                                "ride_fare"]
                                                            .toString()),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20.0),
                                                      child: Container(
                                                        width: 100.0,
                                                        height: 40.0,
                                                        child: RaisedButton(
                                                          splashColor:
                                                              Colors.yellow,
                                                          color: Colors.red,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12.0),
                                                          shape:
                                                              StadiumBorder(),
                                                          onPressed: () async {
                                                            widget.rideData[
                                                                    "ride_status"] =
                                                                "completed";
                                                            print(widget
                                                                .rideData);
                                                            var result =
                                                                await AppDatabase()
                                                                    .postData(
                                                                        "finishRide",
                                                                        widget
                                                                            .rideData);

                                                            print(result);

                                                            if (result !=
                                                                null) {
                                                              pushNewScreen(
                                                                  context,
                                                                  withNavBar:
                                                                      true,
                                                                  screen: RideRequests(
                                                                      currentUser:
                                                                          widget
                                                                              .currentUser));
                                                            } else {
                                                              print("null");
                                                            }
                                                          },
                                                          child: Text(
                                                            'Finish Ride',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                ));
                                          });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        'Finish Ride'.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.0,
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
