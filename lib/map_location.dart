import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_tracker/model/map_point.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as geo;
import 'package:location_tracker/utils/constants.dart';
import 'package:location_tracker/utils/gen_new_user.dart' as nUser;



class MapLocation extends StatefulWidget{
  MapLocation({@required this.title});
  static const id = 'map_location';

  final String title;

  @override
  _MapLocationState createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation>{
  String _myAddress;
  String _myName;
  nUser.User _user = nUser.User();
  Location _myLocation = Location();
  Set<Marker> markers = {};

  // Getting the placemarks

// Retrieving coordinates
  MapPoint startCoordinates = MapPoint(latitude: 0, longitude: 0);
  MapPoint destinationCoordinates = MapPoint(latitude: 6.4550651, longitude: 3.5197741, address: '');

// Initial location of the Map view
  CameraPosition _initialLocation = CameraPosition(target: LatLng(6.4550651, 3.5197741), zoom: 20,);
// For controlling the view of the Map
  GoogleMapController mapController;

  void _myLocationListener(GoogleMapController controller){
    mapController = controller;
    // _getCurrentLocation();


    _myLocation.onLocationChanged.listen((LocationData currentLocation) {// Use current location
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng( 
              // Will be fetching in the next step
              currentLocation.latitude,
              currentLocation.longitude,
            ),
            // zoom: 16.0,
          ),
        ),
      );


      setState(() {
        startCoordinates.latitude = currentLocation.latitude;
        startCoordinates.longitude = currentLocation.longitude;
        updateMarkers();
      });
    });
  }



// For storing the current position
  Position _currentPosition;
  // Method for retrieving the current location
  void _getCurrentLocation() async{
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





    await getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high).then((Position position) async {
      setState(() {
        _currentPosition = position;
        updateMarkers();
      });



      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18.0,
          ),
        ),
      );
    }).catchError((e) {
      print(e);
    });



  }
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context).settings.arguments;
    // final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    if (arguments != null) {
      try {
        _myName = arguments['my_name'];
        _myAddress = arguments['my_address'];
        _user.email = arguments['email'];
        _user.name = arguments['name'];
        _user.address = arguments['address'];
        _user.latitude = arguments['latitude'];
        _user.longitude = arguments['longitude'];

        // destinationCoordinates.latitude = _user.latitude;
        // destinationCoordinates.longitude = _user.longitude;

        destinationCoordinates.latitude = 6.6018;
        destinationCoordinates.longitude = 3.3515;
      } catch (e) {
        print(e);
        Navigator.pop(context);
      }
    }
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
            markers: markers != null ? Set<Marker>.from(markers) : null,
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (GoogleMapController controller) {
              _myLocationListener(controller);
            }),
      ),
    );
  }

  void updateMarkers() {
    setState(() {
      setMarkerConstraints();
      drawRoutes();
    });

    // Start Location Marker
    Marker startMarker = Marker(
      markerId: MarkerId('$startCoordinates'),
      position: LatLng(
        startCoordinates.latitude,
        startCoordinates.longitude,
      ),
      infoWindow: InfoWindow(
        title: '$_myName',
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
        title: _user.name,
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

  void drawRoutes() async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      API_KEY, // Google Maps API Key
      PointLatLng(startCoordinates.latitude, startCoordinates.longitude),
      PointLatLng(destinationCoordinates.latitude, destinationCoordinates.longitude),
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
}