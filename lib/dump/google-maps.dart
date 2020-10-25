import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_tracker/model/map_point.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as geo;
import 'package:location_tracker/utils/constants.dart';



class MapLocation extends StatefulWidget{
  MapLocation({@required this.title});
  static const id = 'map_location';

  final String title;

  @override
  _MapLocationState createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation>{
  Location _myLocation;
  Set<Marker> markers = {};

  // Getting the placemarks

// Retrieving coordinates
  MapPoint startCoordinates;
  MapPoint destinationCoordinates = MapPoint(latitude: 6, longitude: -67, address: 'Sambisa Forest!!!');

// Initial location of the Map view
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0), zoom: 20,);
// For controlling the view of the Map
  GoogleMapController mapController;

  void _myLocationListener(GoogleMapController controller){
    mapController = controller;
    _myLocation.onLocationChanged.listen((LocationData currentLocation) {// Use current location
      // Move camera to the specified latitude & longitude
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              // Will be fetching in the next step
              currentLocation.latitude,
              currentLocation.longitude,
            ),
            zoom: 18.0,
          ),
        ),
      );


      startCoordinates.latitude = currentLocation.latitude;
      startCoordinates.longitude = currentLocation.longitude;
      // updateMarkers();
    });
  }



// For storing the current position
  Position _currentPosition;
  // Method for retrieving the current location
  _getCurrentLocation() async {
    // try {
    //   Position position = await getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.low);
    //
    //   var latitude = position.latitude;
    //   var longitude = position.longitude;
    // } catch (e) {
    //   print(e);
    // }
    await getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
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
    }).catchError((e) {
      print(e);
    });


  }
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }


  StreamSubscription<Position> positionStream =
  getPositionStream(desiredAccuracy: geo.LocationAccuracy.best, forceAndroidLocationManager: true, timeInterval: 2000).listen((Position position) {
    print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
  });

  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context).settings.arguments;
    // final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    if (arguments != null) print(arguments['exampleArgument']);

    // Determining the screen width & height
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
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
            // markers: markers != null ? Set<Marker>.from(markers) : null,
            // polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (GoogleMapController controller) {
              _myLocationListener(controller);
            }),
      ),
    );
  }

  void setMarkerConstraints(){
    // Define two position variables
    MapPoint _northeastCoordinates;
    MapPoint _southwestCoordinates;

// Calculating to check that
// southwest coordinate <= northeast coordinate
    if (startCoordinates.latitude <= destinationCoordinates.latitude) {
      _southwestCoordinates = startCoordinates;
      _northeastCoordinates = destinationCoordinates;
    } else {
      _southwestCoordinates = destinationCoordinates;
      _northeastCoordinates = startCoordinates;
    }

// Accommodate the two locations within the
// camera view of the map
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(
            _northeastCoordinates.latitude,
            _northeastCoordinates.longitude,
          ),
          southwest: LatLng(
            _southwestCoordinates.latitude,
            _southwestCoordinates.longitude,
          ),
        ),
        100.0, // padding
      ),
    );
  }

  void updateMarkers() {
    // Start Location Marker
    Marker startMarker = Marker(
      markerId: MarkerId('$startCoordinates'),
      position: LatLng(
        startCoordinates.latitude,
        startCoordinates.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'Start',
        snippet: startCoordinates.address,
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
        title: 'Destination',
        snippet: destinationCoordinates.address,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    // Add the markers to the list
    markers.add(startMarker);
    markers.add(destinationMarker);
  }

  void distance() async{
    // double distanceInMeters = await Geolocator().distanceBetween(
    //   startCoordinates.latitude,
    //   startCoordinates.longitude,
    //   destinationCoordinates.latitude,
    //   destinationCoordinates.longitude,
    // );
  }

  // Object for PolylinePoints
  PolylinePoints polylinePoints;

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting
// two points
  Map<PolylineId, Polyline> polylines = {};
  // Create the polylines for showing the route between two places

  void drawRoutes(Position start, Position destination) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }





// getPositionStream(desiredAccuracy: geo.LocationAccuracy.best, forceAndroidLocationManager: true, timeInterval: 1).listen((Position position) {
//   startCoordinates.latitude = position.latitude;
//   startCoordinates.longitude = position.longitude;
//   // print('CURRENT POS: $_currentPosition');
//
//   mapController.animateCamera(
//     CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: LatLng(position.latitude, position.longitude),
//         zoom: 16.0,
//       ),
//     ),
//   );
//
//   setState(() {_currentPosition = position;});
// });

}