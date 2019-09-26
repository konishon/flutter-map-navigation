import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:navigation/parser/route_parser.dart';

class RoutePage extends StatefulWidget {
  @override
  _RoutePageState createState() => new _RoutePageState();
}

class _RoutePageState extends State<RoutePage> with TickerProviderStateMixin {
  bool _permission = false;
  String error;
  bool currentWidget = true;
  MapController mapController;
  Location location = Location();

  Map<String, double> currentLocation;
  List<LatLng> tappedPoints = [];

  var points = <LatLng>[
    LatLng(27.756469, 85.072632),
    LatLng(28.21729, 83.984985),
  ];

  var openSpaces = <LatLng>[
    LatLng(27.7092528844159, 85.34158229827881),
    LatLng(27.700248, 85.313601),
    LatLng(27.6852, 85.348835),
    LatLng(27.682882, 85.322185),
  ];

  var route;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    location.hasPermission().then((perm) => {
          print("Location start: ${location.getLocation()}"),
          location.onLocationChanged().listen((value) {
            setState(() {
              currentLocation = value;
            });
          })
        });
  }

  Future<http.Response> getRoute(LatLng startingPoint, LatLng endingPoint) {
    var url =
        "http://54.157.15.192:8989/route?point=${startingPoint.latitude},${startingPoint.longitude}"
        "&point=${startingPoint.latitude},${startingPoint.longitude}&points_encoded=false";
    print("Getting route from $url");
    url =
        "http://54.157.15.192:8989/route?points_encoded=false&point=27.756469,85.072632&point=28.21729,83.984985";
    return http.get(url);
  }

  Future<Welcome> fetchRoute(LatLng startingPoint, LatLng endingPoint) async {
    _animatedMapMove(startingPoint, 20.0);
    final response = await getRoute(startingPoint, endingPoint);
    var routePath = <LatLng>[];
    if (response.statusCode == 200) {
      parseRouteFromJson(response.body)
          .paths[0]
          .points
          .coordinates
          .forEach((latLng) => {routePath.add(LatLng(latLng[1], latLng[0]))});

      setState(() {
        points = routePath;
      });
      return parseRouteFromJson(response.body);
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load route');
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    var controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.linear);
    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Widget build(BuildContext context) {
    var markers = openSpaces.map((latLng) {
      return Marker(
        width: 80.0,
        height: 80.0,
        point: latLng,
        builder: (ctx) => Container(
          child: Icon(
            Icons.all_inclusive,
            color: Colors.red,
          ),
        ),
      );
    }).toList();

    markers.add(Marker(
      width: 50.0,
      height: 20.0,
      point: currentLocation == null
          ? LatLng(0, 0)
          : LatLng(currentLocation['latitude'], currentLocation['longitude']),
      builder: (ctx) => Container(color: Colors.amber, child: Center(child: Text("Nishon"))),
    ));

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Navigation')),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => fetchRoute(points[0], points[1]),
          icon: Icon(Icons.my_location),
          label: Text("Follow")),
      body: Column(
        children: [
          Column(
            children: <Widget>[
              currentLocation == null
                  ? Text("Loading")
                  : Text("Location:" +
                      currentLocation["latitude"].toString() +
                      " " +
                      currentLocation["longitude"].toString()),
            ],
          ),
          Flexible(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: openSpaces[0],
                onTap: (point) => print(point),
                onPositionChanged: (position, hasGesture) =>
                    print("$position $hasGesture"),
                onLongPress: (point) => print(point),
                zoom: 12.0,
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
                        isDotted: true,
                        points: points,
                        strokeWidth: 4.0,
                        color: Colors.purple),
                  ],
                ),
                MarkerLayerOptions(markers: markers)
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(LatLng latlng) {
    print("ok");
    setState(() {
      tappedPoints.add(latlng);
    });
  }
}
