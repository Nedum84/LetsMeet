import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker/model/map_point.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as geo;
import 'package:location_tracker/utils/constants.dart';
import 'package:location_tracker/utils/firebase_transaction.dart';
import 'package:location_tracker/utils/gen_new_user.dart' as nUser;



class TrackUser extends StatefulWidget {
  TrackUser({@required this.title});

  static const id = 'track_user';

  final String title;

  @override
  _TrackUserState createState() => _TrackUserState();
}

class _TrackUserState extends State<TrackUser> {
  String _myAddress;
  String _myName;
  String _myEmail;
  bool zoomFlag = false;
  var _distance = '0.0';
  nUser.User _user = nUser.User();
  Set<Marker> markers = {};

  // Getting the placemarks

// Retrieving coordinates
  MapPoint startCoordinates = MapPoint(latitude: 0, longitude: 0);
  MapPoint destinationCoordinates =
  MapPoint(latitude: 6.4550651, longitude: 3.5197741, address: '');

// Initial location of the Map view
  CameraPosition _initialLocation = CameraPosition(
    target: LatLng(6.4550651, 3.5197741),
    zoom: 18,
  );

// For controlling the view of the Map
  GoogleMapController mapController;

  void _myLocationListener(GoogleMapController controller) {
    mapController = controller;
    updateCurrentLocation();
  }

// For storing the current position
  Position _currentPosition;

  // Method for retrieving the current location
  void updateCurrentLocation() async {

    await getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
      _currentPosition = position;
      startCoordinates.latitude = _currentPosition.latitude;
      startCoordinates.longitude = _currentPosition.longitude;
      final coordinates = Coordinates(position.latitude, position.longitude);// From coordinates
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;

      setState(() {_myAddress = first.addressLine;});
      updateMarkers();
      drawRoutes();
      calculateDistance();

      await FirebaseTransaction.addUserToDb(position, _myEmail, first.addressLine).then((value) {

        if(!zoomFlag){
          zoomFlag= true;
          setMarkerConstraints();
        }else{
          zoomFlag = false;
          mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(startCoordinates.latitude, startCoordinates.longitude),
                zoom: 24,
              )
          ));
        }
      }).catchError((e) { print(e); });

    }).catchError((e) {
      print(e);
    });
  }


  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute
        .of(context)
        .settings
        .arguments;
    // final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    if (arguments != null) {
      try {
        _myName = arguments['my_name'];
        _myAddress = arguments['my_address'];
        _myEmail = arguments['my_email'];
        _user.email = arguments['email'];
        _user.name = arguments['name'];
        _user.address = arguments['address'];
        _user.latitude = arguments['latitude'];
        _user.longitude = arguments['longitude'];

        destinationCoordinates.latitude = _user.latitude;
        destinationCoordinates.longitude = _user.longitude;
      } catch (e) {
        print(e);
        Navigator.pop(context);
      }
    }
    // Determining the screen width & height
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
        width: width,
        height: height,
        color: Colors.blueGrey,
        child: GoogleMap(
          initialCameraPosition: _initialLocation,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: false,
          markers: markers,
          polylines: Set<Polyline>.of(polylines.values),
          onMapCreated: (GoogleMapController controller) {
            _myLocationListener(controller);
          },
        ),
      ),
        Positioned(
          top: 60,
          right: 0,
          left: 0,
          child: Container(
            width: 400,
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            margin: EdgeInsets.only(top: 6, right: 20, left: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Colors.blueGrey[100], width: 1)),
            child: Row(
              children: [
                Icon(Icons.my_location, color: Colors.blueGrey, size: 20,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _myAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 110,
          right: 0,
          left: 0,
          child: Container(
            width: 400,
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            margin: EdgeInsets.only(top: 6, right: 20, left: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Colors.blueGrey[100], width: 1)),
            child: Row(
              children: [
                Icon(Icons.location_on_sharp, color: Colors.redAccent, size: 20,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _user.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 160,
          right: 0,
          left: 0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            margin: EdgeInsets.only(top: 6, right: 60, left: 60),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.all(Radius.circular(25)),),
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'DISTANCE: $_distance km',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 20,
          child: GestureDetector(
            onTap: (){
              updateCurrentLocation();
              showModalBottomSheet(context: context, builder: (builder){
                return Container(
                  height: MediaQuery.of(context).size.height*.45,

                  // Navigator.of(context).pop();
                );
              });
            },
            child: CircleAvatar(
              radius: 30,
              child: Icon(Icons.my_location, size: 28,),
              backgroundColor: Colors.white,
            ),
          ),
        )
    ]),
    );
    }

  void updateMarkers() {
    markers.clear();

    // Start Location Marker
    Marker startMarker = Marker(
      markerId: MarkerId('$_currentPosition'),
      position: LatLng(
        startCoordinates.latitude,
        startCoordinates.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'FROM: $_myName',
        snippet: _myAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

// Destination Location Marker
    Marker destinationMarker = Marker(
      markerId: MarkerId('$destinationCoordinates'),
      position: LatLng(
        destinationCoordinates.latitude,
        destinationCoordinates.longitude,
      ),
      infoWindow: InfoWindow(
        title: "TO: ${_user.name}",
        snippet: _user.address,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    // Add the markers to the list
    setState(() {
      markers.add(startMarker);
      markers.add(destinationMarker);
    });
  }

  Future<void> updateCameraLocation(LatLng source, LatLng destination) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 80);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate,
      GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  void setMarkerConstraints() async {
    var lats = [startCoordinates.latitude, destinationCoordinates.latitude];
    var longs = [startCoordinates.longitude, destinationCoordinates.longitude];
    lats.sort((a, b) => a.compareTo(b)); //asc
    longs.sort((a, b) => a.compareTo(b)); //asc

    setState(() {
      mapController.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(lats[0], longs[0]), // LatLng(latMin, longMin)
            northeast: LatLng(lats[1], longs[1]), // LatLng(latMax, longMax)
          ),
          50));
    });

    // Define two position variables
//     MapPoint _northeastCoordinates;
//     MapPoint _southwestCoordinates;
//
// // Calculating to check that
// // southwest coordinate <= northeast coordinate
//     if (startCoordinates.latitude <= destinationCoordinates.latitude) {
//       _southwestCoordinates = startCoordinates;
//       _northeastCoordinates = destinationCoordinates;
//     } else {
//       _southwestCoordinates = destinationCoordinates;
//       _northeastCoordinates = startCoordinates;
//     }
//
// // Accommodate the two locations within the
// // camera view of the map
//     mapController.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           northeast: LatLng(
//             _northeastCoordinates.latitude,
//             _northeastCoordinates.longitude,
//           ),
//           southwest: LatLng(
//             _southwestCoordinates.latitude,
//             _southwestCoordinates.longitude,
//           ),
//         ),
//         100.0, // padding
//       ),
//     );

    // var source        = LatLng(startCoordinates.latitude, startCoordinates.longitude);
    // var destination   = LatLng(destinationCoordinates.latitude, destinationCoordinates.longitude);
    //
    // List <LatLng> list;
    // list.add(source);
    // list.add(destination);

    // await updateCameraLocation(source, destination);

    // setState(() {
    //   mapController.animateCamera(CameraUpdate.newLatLngBounds(
    //       boundsFromLatLngList(list),
    //       100
    //   ));
    // });

    // var lats = [startCoordinates.latitude, destinationCoordinates.latitude];
    // var longs = [startCoordinates.longitude, destinationCoordinates.longitude];
    // lats.sort((a, b) => a.compareTo(b));//asc
    // longs.sort((a, b) => a.compareTo(b));//asc
    //
    // setState(() {
    //   mapController.animateCamera(CameraUpdate.newLatLngBounds(
    //       LatLngBounds(
    //         // southwest: LatLng(latMin, longMin),
    //         // northeast: LatLng(latMax, longMax),
    //         southwest: LatLng(lats[0], longs[0]),
    //         northeast: LatLng(lats[1], longs[1]),
    //       ),
    //       100
    //   ));
    // });

    // // For ascending
    // var nlist = [1, 6, 8, 2, 16, 0]
    // nlist.sort((a, b) => a.compareTo(b));
    // // For descending
    // var nlist = [1, 6, 8, 2, 16, 0]
    // nlist.sort((b, a) => a.compareTo(b));
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  void calculateDistance() async {
    double distanceInMeters = distanceBetween(startCoordinates.latitude, startCoordinates.longitude, destinationCoordinates.latitude, destinationCoordinates.longitude,);
    double distanceInMeters2 = calcDistance(startCoordinates.latitude, startCoordinates.longitude, destinationCoordinates.latitude, destinationCoordinates.longitude);

    setState(() {
      _distance = (distanceInMeters/1000).toStringAsFixed(2);//to 2 dp
    });
  }

  double calcDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }






  // Object for PolylinePoints
  PolylinePoints polylinePoints;
// List of coordinates to join
  List<LatLng> polylineCoordinates = [];
// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};
  // Create the polylines for showing the route between two places
  void drawRoutes() async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        API_KEY, // Google Maps API Key
        PointLatLng(_currentPosition.latitude, _currentPosition.longitude),
        PointLatLng(destinationCoordinates.latitude, destinationCoordinates.longitude));
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    setState(() {
      // Initializing Polyline
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3,
      );

      // Adding the polyline to the map
      polylines[id] = polyline;
    });
  }
}
