import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:location/location.dart';
import 'package:location_tracker/model/map_point.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as geo;
import 'package:location_tracker/utils/constants.dart';
import 'package:location_tracker/utils/gen_new_user.dart' as nUser;

class MapLocation extends StatefulWidget {
  MapLocation({@required this.title});

  static const id = 'map_location';

  final String title;

  @override
  _MapLocationState createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  String _myAddress;
  String _myName;
  nUser.User _user = nUser.User();
  Set<Marker> markers = {};

  // Getting the placemarks

// Retrieving coordinates
  MapPoint startCoordinates = MapPoint(latitude: 0, longitude: 0);
  MapPoint destinationCoordinates =  MapPoint(latitude: 6.4550651, longitude: 3.5197741, address: '');


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
    _currentPosition = await getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high);

    startCoordinates.latitude = _currentPosition.latitude;
    startCoordinates.longitude = _currentPosition.longitude;

    updateMarkers();
    drawRoutes();
    setMarkerConstraints();
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

        destinationCoordinates.latitude = _user.latitude;
        destinationCoordinates.longitude = _user.longitude;
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
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          markers: markers,
          polylines: Set<Polyline>.of(polylines.values),
          onMapCreated: (GoogleMapController controller) {
            _myLocationListener(controller);
          },
        ),
      ),
    );
  }

  void updateMarkers() {
    // Start Location Marker
    Marker startMarker = Marker(
      markerId: MarkerId('$_currentPosition'),
      position: LatLng(
        startCoordinates.latitude,
        startCoordinates.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'ME: $_myName',
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
        title: "YOU: ${_user.name}",
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


  Future<void> updateCameraLocation(
      LatLng source,
      LatLng destination
      ) async {
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

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }



  void setMarkerConstraints() async{

    print('================================== ==========================================================================================================================================================================');

    var lats = [startCoordinates.latitude, destinationCoordinates.latitude];
    var longs = [startCoordinates.longitude, destinationCoordinates.longitude];
    lats.sort((a, b) => a.compareTo(b));//asc
    longs.sort((a, b) => a.compareTo(b));//asc

    setState(() {
      mapController.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            // southwest: LatLng(latMin, longMin),
            // northeast: LatLng(latMax, longMax),
            southwest: LatLng(lats[0], longs[0]),
            northeast: LatLng(lats[1], longs[1]),
          ),
          80
      ));
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

  void distance() async {
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

  void drawRoutes() async{

    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      API_KEY, // Google Maps API Key
      PointLatLng(_currentPosition.latitude, _currentPosition.longitude),
      PointLatLng(destinationCoordinates.latitude, destinationCoordinates.longitude)
    );
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
