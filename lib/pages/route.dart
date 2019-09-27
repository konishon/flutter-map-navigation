import 'dart:async';
import 'dart:math';

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

  var paths = [];

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
  bool altRoute = false;
  bool isLocationOn = false;

  List<Polyline> polylines = [];
  bool loadingRoute = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    location.hasPermission().then((perm) => {
          print("Location start: ${location.getLocation()}"),
          location.onLocationChanged().listen((value) {
            setState(() {
              currentLocation = value;
//              _animatedMapMove(LatLng(currentLocation['latitude'], currentLocation['longitude']), mapController.zoom);
            });
          })
        });
  }

  Future<http.Response> getRoute(
      LatLng startingPoint, LatLng endingPoint, bool selectAltRoute) {
    var url;
    var baseUrl = "http://54.157.15.192:8989/route";
    if (selectAltRoute) {
      url =
          "$baseUrl?point=${startingPoint.latitude},${startingPoint.longitude}"
          "&point=${endingPoint.latitude},${endingPoint.longitude}"
          "&points_encoded=false"
          "&ch.disable=true"
          "&algorithm=alternative_route";
    } else {
      url =
          "$baseUrl?point=${startingPoint.latitude},${startingPoint.longitude}"
          "&point=${endingPoint.latitude},${endingPoint.longitude}"
          "&points_encoded=false";
    }
    print("Getting route from $url");
    return http.get(url);
  }

  navigationDownloadProgress(bool showProgress) {
    setState(() {
      loadingRoute = showProgress;
    });
  }

  fetchRoute(LatLng startingPoint, LatLng endingPoint) async {
    paths.clear();
    navigationDownloadProgress(true);

    final optimalPath = await getRoute(startingPoint, endingPoint, true);
    final altPath = await getRoute(startingPoint, endingPoint, false);

    var responses = [];
    responses.add(optimalPath);
    responses.add(altPath);

    for (var i = 0; i < responses.length; i++) {
      var routePath = <LatLng>[];
      var response = responses[i];
      if (response.statusCode == 200) {
        parseRouteFromJson(response.body)
            .paths[0]
            .points
            .coordinates
            .forEach((latLng) => {routePath.add(LatLng(latLng[1], latLng[0]))});

        paths.add(routePath);
      } else {
        throw Exception('Failed to load route');
      }
    }
    var colors = [Colors.red, Colors.purple];
    var colorIndex = 0;
    polylines = paths.map((path) {
      var polyline = Polyline(
          isDotted: colorIndex == 0 ? false : true,
          points: path,
          strokeWidth: colorIndex == 0 ? 5.0 : 4.0,
          color: colors[colorIndex]);
      colorIndex++;
      return polyline;
    }).toList();

    navigationDownloadProgress(false);
    mapController.fitBounds(LatLngBounds(startingPoint, endingPoint));
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
            child: Column(
          children: <Widget>[
            Text(
              "Open Space",
            ),
            Icon(
              Icons.all_inclusive,
              color: Colors.red,
            ),
          ],
        )),
      );
    }).toList();

    markers.add(Marker(
      width: 50.0,
      height: 20.0,
      point: currentLocation == null
          ? LatLng(0, 0)
          : LatLng(currentLocation['latitude'], currentLocation['longitude']),
      builder: (ctx) =>
          Container(color: Colors.amber, child: Center(child: Text("Nishon"))),
    ));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Navigation'),
        actions: <Widget>[],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton.extended(
            onPressed: () => fetchRoute(
                LatLng(
                    currentLocation['latitude'], currentLocation['longitude']),
                openSpaces[Random().nextInt(openSpaces.length)]),
            icon: Center(
              child: loadingRoute
                  ? CircularProgressIndicator(
                      backgroundColor: Colors.green,
                    )
                  : Icon(Icons.my_location),
            ),
            label: Text("NAVIGATE")),
      ),
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
                PolylineLayerOptions(polylines: polylines),
                MarkerLayerOptions(markers: markers)
              ],
            ),
          ),
          SwitchListTile(
            title: isLocationOn
                ? Text('Turn off tracking')
                : Text('Turn on tracking'),
            value: isLocationOn,
            onChanged: (bool value) {
              setState(() {
                isLocationOn = value;
              });
            },
            secondary: isLocationOn
                ? Icon(
                    Icons.location_searching,
                    color: Colors.green,
                  )
                : Icon(Icons.location_disabled),
          ),
        ],
      ),
    );
  }

  void _handleTap(LatLng latlng) {
    setState(() {
      tappedPoints.add(latlng);
    });
  }
}
