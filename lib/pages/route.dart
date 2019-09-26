import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:navigation/parser/route_parser.dart';

class RoutePage extends StatefulWidget {
  @override
  _RoutePageState createState() => new _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  bool _permission = false;
  String error;
  bool currentWidget = true;

  var points = <LatLng>[
    LatLng(27.693712, 85.321283),
    LatLng(27.70589, 85.319824),
  ];

  var route;

  @override
  void initState() {
    super.initState();
  }

  Future<http.Response> getRoute(LatLng startingPoint, LatLng endingPoint) {
    var url =
        "http://54.157.15.192:8989/route?point=${startingPoint.latitude}%2C${startingPoint.longitude}"
        "&point=${startingPoint.latitude}%2C${startingPoint.longitude}&points_encoded=false";
    print("Getting route from $url");
    return http.get(url);
  }

  Future<Welcome> fetchRoute(LatLng startingPoint, LatLng endingPoint) async {
    final response = await getRoute(startingPoint, endingPoint);
    var routePath = <LatLng> [];
    if (response.statusCode == 200) {
      welcomeFromJson(response.body)
          .paths[0]
          .points
          .coordinates
          .forEach((latLng) => {routePath.add(LatLng(latLng[1], latLng[0]))});

      setState(() {
        points = routePath;
      });
      return welcomeFromJson(response.body);
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load route');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Navigation')),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => fetchRoute(points[0], points[1]),
          label: Text("Route")),
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
                PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: points, strokeWidth: 4.0, color: Colors.purple),
                  ],
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
