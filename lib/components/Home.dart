import 'dart:async';
import 'dart:convert';
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

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    setCustomMarkerIcon();
    googlePlace = googlePlaces.GooglePlace(Secrets.API_KEY);
    checkAvailableDrivers();
  }

  String getStringDate() {
    return DateFormat("MM/dd/yyyy").format(DateTime.now());
  }

  String getStringTime() {
    return DateFormat.jm().format(DateTime.now());
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      print(result.predictions!.first.description);
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void checkAvailableDrivers() async {
    var response = await AppDatabase().getRecords("AvailableDrivers");
    var JsonData = jsonDecode(response.toString());
    Map result = JsonData['drivers'];
    // String user = jsonEncode(result);
    result.forEach((key, value) => {
          print(key),
          print(value[0]),
          print(value[0]),
          markers.add(Marker(
            markerId: MarkerId(key),
            position: LatLng(value[0], value[1]),
            // infoWindow: InfoWindow(
            //   title: 'Start $startCoordinatesString',
            //   snippet: _startAddress,
            // ),
            icon: BitmapDescriptor.defaultMarker,
          ))
        });
  }

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
    bool? enabled,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
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
        distanceFilter: 1,
      );
      StreamSubscription<Position> positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position? position) {
        print(position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
        setState(() {
          _currentPosition = position!;
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
      });
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        // _currentAddress = "${place.name}";
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      print("in distn");
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      destinationLatitude = destinationPlacemark[0].latitude;
      destinationLongitude = destinationPlacemark[0].longitude;

      startCoordinatesString = '($startLatitude,$startLongitude)';
      destinationCoordinatesString =
          '($destinationLatitude,$destinationLongitude)';
      print(startCoordinatesString + destinationCoordinatesString);

      // Start Location Marker
      Marker startMarker = Marker(
          markerId: MarkerId(startCoordinatesString),
          position: LatLng(startLatitude, startLongitude),
          infoWindow: InfoWindow(
            title: 'Start $startCoordinatesString',
            snippet: _startAddress,
          ),
          icon: sourceIcon);

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
      markers.add(startMarker);
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
      double distanceInMeters = await Geolocator.bearingBetween(
        startLatitude,
        startLongitude,
        destinationLatitude,
        destinationLongitude,
      );

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
                  padding: const EdgeInsets.only(top: 20.0),
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
                            'E-AMBULANCE',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          _textField(
                            label: 'Start',
                            hint: 'Choose starting point',
                            prefixIcon: Icon(Icons.looks_one),
                            suffixIcon: startAddressController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.my_location),
                                    onPressed: () {
                                      startAddressController.text =
                                          _currentAddress;
                                      _startAddress = _currentAddress;
                                      predictions = [];
                                      // startAddressController.clear();
                                    },
                                  )
                                : null,
                            controller: startAddressController,
                            focusNode: startAddressFocusNode,
                            width: width,
                            locationCallback: (String value) {
                              if (_debounce?.isActive ?? false)
                                _debounce!.cancel();
                              _debounce =
                                  Timer(const Duration(milliseconds: 1000), () {
                                if (value.isNotEmpty) {
                                  //places api
                                  autoCompleteSearch(value);
                                } else {
                                  //clear out the results
                                  setState(() {
                                    predictions = [];
                                    startPosition = null;
                                  });
                                }
                              });
                              setState(() {
                                _startAddress = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Destination',
                              hint: 'Choose destination',
                              prefixIcon: Icon(Icons.looks_two),
                              controller: destinationAddressController,
                              focusNode: desrinationAddressFocusNode,
                              width: width,
                              enabled: startAddressController.text.isNotEmpty &&
                                  startPosition != null,
                              suffixIcon: destinationAddressController
                                      .text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          predictions = [];
                                          destinationAddressController.clear();
                                        });
                                      },
                                      icon: Icon(Icons.clear_outlined),
                                    )
                                  : null,
                              locationCallback: (String value) {
                                if (_debounce?.isActive ?? false)
                                  _debounce!.cancel();
                                _debounce = Timer(
                                    const Duration(milliseconds: 1000), () {
                                  if (value.isNotEmpty) {
                                    //places api
                                    autoCompleteSearch(value);
                                  } else {
                                    //clear out the results
                                    setState(() {
                                      predictions = [];
                                      endPosition = null;
                                    });
                                  }
                                });
                                setState(() {
                                  _destinationAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
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
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'COST: $_placeDistance km',
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
                              ElevatedButton(
                                onPressed: (_startAddress != '' &&
                                        _destinationAddress != '')
                                    ? () async {
                                        startAddressFocusNode.unfocus();
                                        desrinationAddressFocusNode.unfocus();
                                        setState(() {
                                          if (markers.isNotEmpty)
                                            markers.clear();
                                          if (polylines.isNotEmpty)
                                            polylines.clear();
                                          if (polylineCoordinates.isNotEmpty)
                                            polylineCoordinates.clear();
                                          _placeDistance = null;
                                        });

                                        _calculateDistance()
                                            .then((isCalculated) {
                                          if (isCalculated) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Distance Calculated Sucessfully'),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error Calculating Distance'),
                                              ),
                                            );
                                          }
                                        });
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    'Show Route'.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: (_startAddress != '' &&
                                        _destinationAddress != '')
                                    ? () async {
                                        try {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          String? userPref =
                                              prefs.getString('userData');
                                          Map<String, dynamic> userMap =
                                              jsonDecode(userPref!)
                                                  as Map<String, dynamic>;
                                          var data = {
                                            "source": {
                                              "lat": startLatitude,
                                              "lon": startLongitude
                                            },
                                            "destination": {
                                              "lat": destinationLatitude,
                                              "lon": destinationLongitude
                                            },
                                            "userDet": userMap,
                                            "rideDet": {
                                              "dist": _placeDistance,
                                              "cost": 10.0,
                                              "date": getStringDate(),
                                              "time": getStringTime()
                                            }
                                          };

                                          print(data);

                                          var response = await AppDatabase()
                                              .postData(
                                                  "requestAmbulance", data);

                                          if (response != null) {
                                            // Navigator.pushReplacement(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             HomeScreen(
                                            //                 currentUser:
                                            //                     currentUser)));
                                          } else {
                                            print(response);
                                            // showSnackBar(context, 'Invalid User CNIC or Password');
                                          }
                                        } on Exception catch (e) {
                                          print(e.toString());
                                        }
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    'Request Ambulance'.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: predictions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(
                                      Icons.pin_drop,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    predictions[index].description.toString(),
                                  ),
                                  onTap: () async {
                                    final placeId = predictions[index].placeId!;
                                    final details =
                                        await googlePlace.details.get(placeId);
                                    if (details != null &&
                                        details.result != null &&
                                        mounted) {
                                      if (startAddressFocusNode.hasFocus) {
                                        setState(() {
                                          startPosition = details.result;
                                          startAddressController.text =
                                              details.result!.name!;
                                          predictions = [];
                                        });
                                      } else {
                                        setState(() {
                                          endPosition = details.result;
                                          destinationAddressController.text =
                                              details.result!.name!;
                                          predictions = [];
                                        });
                                      }

                                      if (_startAddress != null &&
                                          _destinationAddress != null) {
                                        print('navigate');
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => MapScreen(),
                                        //   ),
                                        // );
                                      }
                                    }
                                  },
                                );
                              })
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
