import 'package:flutter/material.dart';


class MapPoint{
  MapPoint({@required this.latitude,@required  this.longitude, this.address});
  double latitude;
  double longitude;
  final String address;

}