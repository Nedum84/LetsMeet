import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:location_tracker/model/map_point.dart';
import 'package:location_tracker/model/route_direction.dart';
import 'package:location_tracker/services/network.dart';
import 'package:location_tracker/utils/colors.dart';
import 'package:location_tracker/utils/constants.dart';

class ShowDirection extends StatefulWidget {
  ShowDirection({this.from_address, this.to_address, this.start_point, this.destination_point});

  final String from_address;
  final String to_address;
  final MapPoint start_point;
  final MapPoint destination_point;



  @override
  _ShowDirectionState createState() => _ShowDirectionState();
}

class _ShowDirectionState extends State<ShowDirection> {

  var total_distance = '0.0 km';
  var total_duration = '0 min';
  List<RouteDirection> dirList = [];

  @override
  void initState(){
    super.initState();
    _getRoutes();
  }

  _getRoutes() async{
    var mapResult = await NetworkHelper(widget.start_point, widget.destination_point).getData();


    if (mapResult == null) {
      Navigator.of(context).pop();
      return;
    }
    var routes = mapResult['routes'];

    setState(() {
      total_distance = routes[0]['legs'][0]['distance']['text'];
      total_duration = routes[0]['legs'][0]['duration']['text'];
    });
    var idx = 0;
    for(var i in routes[0]['legs'][0]['steps']){
      // var route = routes[0]['legs'][0]['steps'][idx];
      var route = i;

      RouteDirection rd = RouteDirection(
          distance: route['distance']['text'],
          duration: route['duration']['text'],
          end_location: route['end_location'],
          start_location: route['start_location'],
          html_instructions: route['html_instructions'],
          polyline: route['polyline'],
          travel_mode: route['travel_mode']
      );


      setState(() {
        dirList.add(rd);
      });

      idx++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * .85,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text("${total_distance}",
                style: TextStyle(
                  fontSize: 24,
                  color: kColorAccent
                ),),
                Text(" ($total_duration)",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey
                ),),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
            child: HtmlWidget('<b>START</b>: ${widget.from_address}',
            textStyle: TextStyle(
              fontSize: 16,
            ),),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: dirList != null ? dirList.length : 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text('${index+1}.'),
                    title: HtmlWidget(
                      '${dirList[index].html_instructions}',
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${dirList[index].distance}'),
                        Text('${dirList[index].duration}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: HtmlWidget('<b>STOP</b>: ${widget.to_address}',
              textStyle: TextStyle(
                fontSize: 16,
              ),),
          ),
        ],
      ),
    );
  }
}


class HtmlHelper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
      HtmlWidget(
        // the first parameter (`html`) is required
        htmlData,
        // all other parameters are optional, a few notable params:
        // specify custom styling for an element
        // see supported inline styling below
        customStylesBuilder: (element) {
          if (element.classes.contains('foo')) {
            return {'color': 'red'};
          }
          return null;
        },

        // render a custom widget
        customWidgetBuilder: (element) {
          if (element.attributes['foo'] == 'bar') {
            // return FooBarWidget();
          }
          return null;
        },

        // this callback will be triggered when user taps a link
        onTapUrl: (url) => print('tapped $url'),
        // set the default styling for text
        textStyle: TextStyle(fontSize: 14),
      );
  }
}
