// File created by
// Lung Razvan <long1eu>
// on 22/08/2019

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:collection/collection.dart';
import 'dart:math';



const double _epsilon = 1e-9;

class GeoCoord {
  const GeoCoord({this.lat = 0.0, this.lon = 0.0});

  factory GeoCoord.degrees({double lat = 0.0, double lon = 0.0}) {
    return GeoCoord(lat: degToRad(lat), lon: degToRad(lon));
  }

  /// latitude in radians
  final double lat;

  /// longitude in radians
  final double lon;

  double get latDeg => radToDeg(lat);

  double get lonDeg => radToDeg(lon);

  Pointer<GeoCoordNative> get pointer => GeoCoordNative.create(lat, lon);

  @override
  String toString() => 'GeoCoord{lat: $latDeg, lon: $lonDeg}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! GeoCoord || runtimeType != other.runtimeType) {
      return false;
    }

    if (other is GeoCoord) {
      if ((latDeg - other.latDeg).abs() >= _epsilon) {
        return false;
      }

      return (lon - other.lon).abs() <= _epsilon;
    }
    return false;
  }

  @override
  int get hashCode => lat.hashCode ^ lon.hashCode;
}

/// cell boundary in latitude/longitude
class GeoBoundary {
  const GeoBoundary(this.vertices);

  /// vertices in ccw order
  final List<GeoCoord> vertices;

  @override
  String toString() => 'GeoBoundary{vertices: $vertices}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoBoundary &&
          runtimeType == other.runtimeType &&
          const ListEquality<GeoCoord>().equals(vertices, other.vertices);

  @override
  int get hashCode => const ListEquality<GeoCoord>().hash(vertices);
}

/// Simplified core of GeoJSON Polygon coordinates definition
class GeoPolygon {
  GeoPolygon(this.geofence, this.holes);

  /// exterior boundary of the polygon
  final List<GeoCoord> geofence;

  /// interior boundaries (holes) in the polygon
  final List<List<GeoCoord>> holes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPolygon &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality().equals(geofence, other.geofence) &&
          const DeepCollectionEquality().equals(holes, other.holes);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(geofence) ^ //
      const DeepCollectionEquality().hash(holes);
}

num degToRad(num deg) => deg * (pi / 180.0);

num radToDeg(num rad) => rad * (180.0 / pi);




class GeoCoordNative extends Struct {
  factory GeoCoordNative.allocate(double lat, double lon) {
    return allocate<GeoCoordNative>().ref
      ..lat = lat
      ..lon = lon;
  }

  static Pointer<GeoCoordNative> create(double lat, double lon) {
    var _pointer = allocate<GeoCoordNative>();
    _pointer.ref
      ..lat = lat
      ..lon = lon;
    return _pointer;
  }

  /// latitude in radians
  @Double()
  double lat;

  /// longitude in radians
  @Double()
  double lon;

  @override
  String toString() => 'GeoCoordNative{lat: $lat, lon: $lon}';
}

class GeoPolygonNative {
  GeoPolygonNative._(this.geofence, this.geofenceNum, this.holes,
      this.holesSizes, this.holesNum);

  final Pointer<GeoCoordNative> geofence;
  final int geofenceNum;
  final Pointer<Pointer<GeoCoordNative>> holes;
  final Pointer<Int32> holesSizes;
  final int holesNum;

  factory GeoPolygonNative.allocate(GeoPolygon geoPolygon) {
    final int geofenceNum = geoPolygon.geofence.length;
    final Pointer<GeoCoordNative> geofence =
        allocate<GeoCoordNative>(count: geofenceNum);
    for (int i = 0; i < geofenceNum; i++) {
      final GeoCoordNative item = geofence.elementAt(i).ref
        ..lat = geoPolygon.geofence[i].lat
        ..lon = geoPolygon.geofence[i].lon;
    }

    final int holesNum = geoPolygon.holes.length;
    final Pointer<Int32> holesSizes = allocate<Int32>(count: holesNum);
    final Pointer<Pointer<GeoCoordNative>> holes =
        allocate<Pointer<GeoCoordNative>>(count: holesNum);

    for (int i = 0; i < holesNum; i++) {
      final List<GeoCoord> hole = geoPolygon.holes[i];
      final int holeLength = hole.length;
      holesSizes.elementAt(i).value = holeLength;

      final Pointer<GeoCoordNative> holePtr =
          allocate<GeoCoordNative>(count: holeLength);
      for (int j = 0; j < holeLength; j++) {
        final GeoCoordNative item = holePtr.elementAt(j).ref;
        item.lat = hole[j].lat;
        item.lon = hole[j].lon;
      }

      holes.elementAt(i).value = holePtr;
    }

    return GeoPolygonNative._(
        geofence, geofenceNum, holes, holesSizes, holesNum);
  }

  void dispose() {
    free(geofence);
    free(holesSizes);
    for (int j = 0; j < holesNum; j++) {
      final Pointer<GeoCoordNative> item = holes.elementAt(j).value;
      free(item);
    }
    free(holes);
  }
}




