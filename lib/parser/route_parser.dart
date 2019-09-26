// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  Hints hints;
  Info info;
  List<Path> paths;

  Welcome({
    this.hints,
    this.info,
    this.paths,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    hints: Hints.fromJson(json["hints"]),
    info: Info.fromJson(json["info"]),
    paths: List<Path>.from(json["paths"].map((x) => Path.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "hints": hints.toJson(),
    "info": info.toJson(),
    "paths": List<dynamic>.from(paths.map((x) => x.toJson())),
  };
}

class Hints {
  String visitedNodesAverage;
  String visitedNodesSum;

  Hints({
    this.visitedNodesAverage,
    this.visitedNodesSum,
  });

  factory Hints.fromJson(Map<String, dynamic> json) => Hints(
    visitedNodesAverage: json["visited_nodes.average"],
    visitedNodesSum: json["visited_nodes.sum"],
  );

  Map<String, dynamic> toJson() => {
    "visited_nodes.average": visitedNodesAverage,
    "visited_nodes.sum": visitedNodesSum,
  };
}

class Info {
  List<String> copyrights;
  int took;

  Info({
    this.copyrights,
    this.took,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    copyrights: List<String>.from(json["copyrights"].map((x) => x)),
    took: json["took"],
  );

  Map<String, dynamic> toJson() => {
    "copyrights": List<dynamic>.from(copyrights.map((x) => x)),
    "took": took,
  };
}

class Path {
  double distance;
  double weight;
  int time;
  int transfers;
  bool pointsEncoded;
  List<double> bbox;
  Points points;
  List<Instruction> instructions;
  List<dynamic> legs;
  Details details;
  int ascend;
  int descend;
  Points snappedWaypoints;

  Path({
    this.distance,
    this.weight,
    this.time,
    this.transfers,
    this.pointsEncoded,
    this.bbox,
    this.points,
    this.instructions,
    this.legs,
    this.details,
    this.ascend,
    this.descend,
    this.snappedWaypoints,
  });

  factory Path.fromJson(Map<String, dynamic> json) => Path(
    distance: json["distance"].toDouble(),
    weight: json["weight"].toDouble(),
    time: json["time"],
    transfers: json["transfers"],
    pointsEncoded: json["points_encoded"],
//    bbox: List<double>.from(json["bbox"].map((x) => x.toDouble())),
    points: Points.fromJson(json["points"]),
    instructions: List<Instruction>.from(json["instructions"].map((x) => Instruction.fromJson(x))),
    legs: List<dynamic>.from(json["legs"].map((x) => x)),
    details: Details.fromJson(json["details"]),
//    ascend: json["ascend"],
//    descend: json["descend"],
    snappedWaypoints: Points.fromJson(json["snapped_waypoints"]),
  );

  Map<String, dynamic> toJson() => {
    "distance": distance,
    "weight": weight,
    "time": time,
    "transfers": transfers,
    "points_encoded": pointsEncoded,
    "bbox": List<dynamic>.from(bbox.map((x) => x)),
    "points": points.toJson(),
    "instructions": List<dynamic>.from(instructions.map((x) => x.toJson())),
    "legs": List<dynamic>.from(legs.map((x) => x)),
    "details": details.toJson(),
    "ascend": ascend,
    "descend": descend,
    "snapped_waypoints": snappedWaypoints.toJson(),
  };
}

class Details {
  Details();

  factory Details.fromJson(Map<String, dynamic> json) => Details(
  );

  Map<String, dynamic> toJson() => {
  };
}

class Instruction {
  double distance;
  double heading;
  int sign;
  List<int> interval;
  String text;
  int time;
  String streetName;
  int exitNumber;
  bool exited;
  double turnAngle;
  double lastHeading;

  Instruction({
    this.distance,
    this.heading,
    this.sign,
    this.interval,
    this.text,
    this.time,
    this.streetName,
    this.exitNumber,
    this.exited,
    this.turnAngle,
    this.lastHeading,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) => Instruction(
    distance: json["distance"].toDouble(),
    heading: json["heading"] == null ? null : json["heading"].toDouble(),
    sign: json["sign"],
    interval: List<int>.from(json["interval"].map((x) => x)),
    text: json["text"],
    time: json["time"],
    streetName: json["street_name"],
    exitNumber: json["exit_number"] == null ? null : json["exit_number"],
    exited: json["exited"] == null ? null : json["exited"],
    turnAngle: json["turn_angle"] == null ? null : json["turn_angle"].toDouble(),
    lastHeading: json["last_heading"] == null ? null : json["last_heading"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "distance": distance,
    "heading": heading == null ? null : heading,
    "sign": sign,
    "interval": List<dynamic>.from(interval.map((x) => x)),
    "text": text,
    "time": time,
    "street_name": streetName,
    "exit_number": exitNumber == null ? null : exitNumber,
    "exited": exited == null ? null : exited,
    "turn_angle": turnAngle == null ? null : turnAngle,
    "last_heading": lastHeading == null ? null : lastHeading,
  };
}

class Points {
  String type;
  List<List<double>> coordinates;

  Points({
    this.type,
    this.coordinates,
  });

  factory Points.fromJson(Map<String, dynamic> json) => Points(
    type: json["type"],
    coordinates: List<List<double>>.from(json["coordinates"].map((x) => List<double>.from(x.map((x) => x.toDouble())))),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(coordinates.map((x) => List<dynamic>.from(x.map((x) => x)))),
  };
}
