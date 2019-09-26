import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class RoutePage extends StatefulWidget {
  @override
  _RoutePageState createState() => new _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  static const String route = 'polyline';

  bool _permission = false;
  String error;
  bool currentWidget = true;

  @override
  void initState() {
    super.initState();
  }



  Widget build(BuildContext context) {
    var points = <LatLng>[
      LatLng(27.7297, 85.3290),
      LatLng(27.7010, 85.3150),
    ];

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Navigation')),
      body: Column(
        children: [
          Flexible(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(27.7297, 85.3290),
                zoom: 18.0,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: "https://api.mapbox.com/v4/"
                      "{id}/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1Ijoibml5byIsImEiOiJjazEwNnh4YTcwMmtpM2N0ODVqNm0xcWg1In0.afnQfiPu4aHjy21HTjR5mA",
                  additionalOptions: {
                    'accessToken':
                        'pk.eyJ1Ijoibml5byIsImEiOiJjazEwNnh4YTcwMmtpM2N0ODVqNm0xcWg1In0.afnQfiPu4aHjy21HTjR5mA',
                    'id': 'mapbox.streets',
                  },
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                        width: 80.0,
                        height: 80.0,
                        point: points[0],
                        builder: (ctx) => Container(
                              child: Icon(
                                Icons.star,
                                color: Colors.green,
                              ),
                            )),
                    Marker(
                        width: 80.0,
                        height: 80.0,
                        point: points[1],
                        builder: (ctx) => Container(
                              child: Icon(
                                Icons.star_border,
                                color: Colors.red,
                              ),
                            )),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
