import 'package:http/http.dart' as http;
import 'package:location_tracker/model/map_point.dart';
import 'dart:convert';
import 'package:location_tracker/utils/constants.dart';


// const String baseUrl = 'https://maps.googleapis.com/maps/api/directions/json?origin=6.4584,7.5464&destination=6.5244,3.3792&key=$API_KEY';
const String baseUrl = 'https://maps.googleapis.com/maps/api/directions/json?key=$API_KEY';

class NetworkHelper {
  NetworkHelper(this.origin, this.destination);

  final MapPoint origin;
  final MapPoint destination;

  Future getData() async {
    String url = baseUrl+'&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}';

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}
