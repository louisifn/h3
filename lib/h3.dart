
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

import 'errors.dart';
import 'types.dart';

export 'types.dart';

typedef geoToH3_native_t = Uint64 Function(Pointer<GeoCoordNative> g, Int32 res);

typedef h3ToGeo_native_t = Void Function(Uint64 h3, Pointer<GeoCoordNative> g);

typedef h3ToGeoBoundary_dart_native_t = Int32 Function(Uint64 h3, Pointer<GeoCoordNative> gp);

typedef hexRange_native_t = Int32 Function(Uint64 origin, Int32 k, Pointer<Uint64> out);

typedef hexRangeDistances_native_t = Int32 Function(
    Uint64 origin, Int32 k, Pointer<Uint64> out, Pointer<Int32> distances);

typedef hexRanges_native_t = Int32 Function(Pointer<Uint64> h3Set, Int32 length, Int32 k, Pointer<Uint64> out);

typedef kRing_native_t = Void Function(Uint64 origin, Int32 k, Pointer<Uint64> out);

typedef kRingDistances_native_t = Void Function(Uint64 origin, Int32 k, Pointer<Uint64> out, Pointer<Int32> distances);

typedef hexRing_native_t = Int32 Function(Uint64 origin, Int32 k, Pointer<Uint64> out);

typedef maxPolyfillSize_dart_native_t = Int32 Function(Pointer<GeoCoordNative> geofence, Int32 geofenceNum,
    Pointer<Pointer<GeoCoordNative>> holes, Pointer<Int32> holesSizes, Int32 holesNum, Int32 res);

typedef polyfill_dart_native_t = Void Function(
    Pointer<GeoCoordNative> geofence,
    Int32 geofenceNum,
    Pointer<Pointer<GeoCoordNative>> holes,
    Pointer<Int32> holesSizes,
    Int32 holesNum,
    Int32 res,
    Pointer<Uint64> out);



class H3 {

  static H3 _instance;


  factory H3() {
    if (_instance == null) {
      _instance = H3._();
    }
    return _instance;
  }
  /// Find the H3 index of the resolution [res] cell containing the lat/lon [g]
  int Function(Pointer<GeoCoordNative> g, int res) geoToH3;

  /// Find the lat/lon center point g of the cell h3
  void Function(int h3, Pointer<GeoCoordNative> g) h3ToGeo;

  /// Give the cell boundary in lat/lon coordinates for the cell h3
  int Function(int h3, Pointer<GeoCoordNative> g) h3ToGeoBoundary;

  /// Hexagons neighbors in all directions, assuming no pentagons
  int Function(int origin, int k, Pointer<Uint64> out) hexRange;

  /// Hexagon neighbors in all directions, reporting distance from origin
  int Function(int origin, int k, Pointer<Uint64> out, Pointer<Int32> distances)
      hexRangeDistances;

  /// Collection of hex rings sorted by ring for all given hexagons
  int Function(Pointer<Uint64> h3Set, int length, int k, Pointer<Uint64> out)
      hexRanges;

  /// Hexagon neighbors in all directions
  void Function(int origin, int k, Pointer<Uint64> out) kRing;

  /// Hexagon neighbors in all directions, reporting distance from origin
  void Function(
          int origin, int k, Pointer<Uint64> out, Pointer<Int32> distances)
      kRingDistances;

  /// Hollow hexagon ring at some origin
  int Function(int origin, int k, Pointer<Uint64> out) hexRing;

  /// Maximum number of hexagons in the geofence
  int Function(
    Pointer<GeoCoordNative> geofence,
    int geofenceNum,
    Pointer<Pointer<GeoCoordNative>> holes,
    Pointer<Int32> holesSizes,
    int holesNum,
    int res,
  ) maxPolyfillSize;

  /// Hexagons within the given geofence
  void Function(
    Pointer<GeoCoordNative> geofence,
    int geofenceNum,
    Pointer<Pointer<GeoCoordNative>> holes,
    Pointer<Int32> holesSizes,
    int holesNum,
    int res,
    Pointer<Uint64> out,
  ) polyfill;

  static const MethodChannel _channel =
      const MethodChannel('h3_library');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  H3._() {
    final DynamicLibrary h3 = Platform.isAndroid
        ? DynamicLibrary.open("libh3.so")
        : DynamicLibrary.process();

    geoToH3 =
        h3.lookup<NativeFunction<geoToH3_native_t>>('geoToH3').asFunction();
    h3ToGeo =
        h3.lookup<NativeFunction<h3ToGeo_native_t>>('h3ToGeo').asFunction();
    h3ToGeoBoundary = h3
        .lookup<NativeFunction<h3ToGeoBoundary_dart_native_t>>(
            'h3ToGeoBoundary_shim')
        .asFunction();
    hexRange =
        h3.lookup<NativeFunction<hexRange_native_t>>('hexRange').asFunction();
    hexRangeDistances = h3
        .lookup<NativeFunction<hexRangeDistances_native_t>>('hexRangeDistances')
        .asFunction();
    hexRanges =
        h3.lookup<NativeFunction<hexRanges_native_t>>('hexRanges').asFunction();
    kRing = h3.lookup<NativeFunction<kRing_native_t>>('kRing').asFunction();
    kRingDistances = h3
        .lookup<NativeFunction<kRingDistances_native_t>>('kRingDistances')
        .asFunction();
    hexRing =
        h3.lookup<NativeFunction<hexRing_native_t>>('hexRing').asFunction();
    maxPolyfillSize = h3
        .lookup<NativeFunction<maxPolyfillSize_dart_native_t>>(
            'maxPolyfillSize_shim')
        .asFunction();
    polyfill = h3
        .lookup<NativeFunction<polyfill_dart_native_t>>('polyfill_shim')
        .asFunction();
  }


}



/// Encodes [g] (coordinate on the sphere) to the H3 index of the containing cell at
/// the specified [resolution].
///
/// Returns the encoded H3Index (or 0 on failure).
int geoToH3(GeoCoord g, int resolution) {


  final Pointer<GeoCoordNative> pointer = g.pointer;
  final int geoToH3 = H3().geoToH3(pointer, resolution);
  free(pointer);
  return geoToH3;
}

/// Determines the spherical coordinates of the center point of an [h3] index.
GeoCoord h3ToGeo(int h3) {

  final Pointer<GeoCoordNative> g = allocate<GeoCoordNative>();
  H3().h3ToGeo(h3, g);

  final GeoCoordNative center = g.ref;
  final GeoCoord result = GeoCoord(lat: center.lat, lon: center.lon);
  free(g);
  return result;
}

/// Determines the cell boundary in spherical coordinates for an [h3] index.
List<GeoCoord> h3ToGeoBoundary(int h3) {

  final Pointer<GeoCoordNative> gp = allocate<GeoCoordNative>(count: 100);
  final int verts = H3().h3ToGeoBoundary(h3, gp);

  final List<GeoCoord> coordinates = <GeoCoord>[];
  for (int i = 0; i < verts; i++) {
    final GeoCoordNative vert = gp.elementAt(i).ref;
    coordinates.add(GeoCoord(lat: vert.lat, lon: vert.lon));
  }
  free(gp);

  return coordinates;
}

/// Maximum number of indices that result from the kRing algorithm with the given
/// k. Formula source and proof: https://oeis.org/A003215
int maxKringSize(int k) => 3 * k * (k + 1) + 1;

/// Produces indexes within [k] distance of the origin index.
///
/// Throws [PentagonH3Error] when one of the indexes returned by this
/// function is a pentagon or [PentagonDistortionH3Error] when it is
/// in the pentagon distortion area.
///
/// k-ring 0 is defined as the origin index, k-ring 1 is defined as k-ring 0 and
/// all neighboring indexes, and so on.
///
/// Return a list of indexes in order of increasing distance from the origin.
List<int> hexRange(int origin, int k) {
  assert(k >= 0);

  final int size = maxKringSize(k);
  final Pointer<Uint64> out = allocate<Uint64>(count: size);
  final int result = H3().hexRange(origin, k, out);

  if (result == 0) {
    final List<int> list = out.asTypedList(size).buffer.asUint64List().toList();
    free(out);
    return list;
  } else {
    if (result == 1) {
      throw PentagonH3Error();
    } else {
      assert(result == 2);
      throw PentagonDistortionH3Error();
    }
  }
}

/// Produces indexes within [k] distance of the origin index.
///
/// Throws [PentagonH3Error] when one of the indexes returned by this
/// function is a pentagon or [PentagonDistortionH3Error] when it is
/// in the pentagon distortion area.
///
/// k-ring 0 is defined as the origin index, k-ring 1 is defined as k-ring 0 and
/// all neighboring indexes, and so on.
///
/// Return the indexes in order of increasing distance from the origin, mapped to
/// their respective distances.
Map<int, int> hexRangeDistances(int origin, int k) {
  assert(k >= 0);

  final int size = maxKringSize(k);
  final Pointer<Uint64> out = allocate<Uint64>(count: size);
  final Pointer<Int32> distances = allocate<Int32>(count: size);
  final int result = H3().hexRangeDistances(origin, k, out, distances);

  if (result == 0) {
    final Map<int, int> map = Map<int, int>.fromIterables(
        out.asTypedList(size).buffer.asUint64List(),
        distances.asTypedList(size).buffer.asInt32List());

    free(out);
    free(distances);

    return map;
  } else {
    if (result == 1) {
      throw PentagonH3Error();
    } else {
      assert(result == 2);
      throw PentagonDistortionH3Error();
    }
  }
}

/// Takes an set of input hex IDs and a max [k]-ring and returns an
/// list of hexagon IDs sorted first by the original hex IDs and then by the
/// k-ring (0 to max), with no guaranteed sorting within each k-ring group.
///
/// Throws [PentagonH3Error] when one of the indexes returned by this
/// function is a pentagon or [PentagonDistortionH3Error] when it is
/// in the pentagon distortion area.
List<int> hexRanges(Set<int> h3Set, int k) {
  final int size = maxKringSize(k) * h3Set.length;
  final Pointer<Uint64> out = allocate(count: size);
  final Pointer<Uint64> h3SetPtr = allocate(count: h3Set.length);
  for (int i = 0; i < h3Set.length; i++) {
    h3SetPtr.elementAt(i).value = (h3Set.elementAt(i));
  }

  final int result = H3().hexRanges(h3SetPtr, h3Set.length, k, out);

  if (result == 0) {
    final List<int> list = out.asTypedList(size).buffer.asUint64List().toList();
    free(out);
    return list;
  } else {
    if (result == 1) {
      throw PentagonH3Error();
    } else {
      assert(result == 2);
      throw PentagonDistortionH3Error();
    }
  }
}

/// k-rings produces indices within [k] distance of the [origin] index.
///
/// k-ring 0 is defined as the origin index, k-ring 1 is defined as k-ring 0 and
/// all neighboring indices, and so on.
///
/// Elements of the return list may be left zero, as can happen when crossing a
/// pentagon.
List<int> kRing(int origin, int k) {
  assert(k >= 0);

  final int size = maxKringSize(k);
  final Pointer<Uint64> out = allocate(count: size);

  H3().kRing(origin, k, out);

  final List<int> list = out.asTypedList(size).buffer.asUint64List().toList();
  free(out);
  return list;
}

/// k-rings produces indices within [k] distance of the [origin] index.
///
/// k-ring 0 is defined as the origin index, k-ring 1 is defined as k-ring 0 and
/// all neighboring indices, and so on.
///
/// Elements of the return list may be left zero, as can happen when crossing a
/// pentagon.
Map<int, int> kRingDistances(int origin, int k) {
  assert(k >= 0);

  final int size = maxKringSize(k);
  final Pointer<Uint64> out = allocate(count: size);
  final Pointer<Int32> distances = allocate(count: size);
  H3().kRingDistances(origin, k, out, distances);

  final Map<int, int> map = Map<int, int>.fromIterables(
      out.asTypedList(size).buffer.asUint64List(),
      distances.asTypedList(size).buffer.asInt32List());

  free(out);
  free(distances);

  return map;
}

/// Returns the "hollow" ring of hexagons at exactly grid distance [k] from
/// the [origin] hexagon. In particular, k=0 returns just the origin hexagon.
///
/// A nonzero failure code may be returned in some cases, for example,
/// if a pentagon is encountered.
/// Failure cases may be fixed in future versions.
///
/// Throws [PentagonH3Error] when one of the indexes returned by this
/// function is a pentagon or [PentagonDistortionH3Error] when it is
/// in the pentagon distortion area.
List<int> hexRing(int origin, int k) {
  assert(k >= 0);

  final int size = k == 0 ? 1 : 6 * k;
  final Pointer<Uint64> out = allocate(count: size);

  final int result = H3().hexRing(origin, k, out);

  if (result == 0) {
    final List<int> list = out.asTypedList(size).buffer.asUint64List().toList();
    free(out);
    return list;
  } else {
    if (result == 1) {
      throw PentagonH3Error();
    } else {
      assert(result == 2);
      throw PentagonDistortionH3Error();
    }
  }
}

/// The number of hexagons to allocate space for when performing a polyfill on
/// the [geoPolygon], a GeoJSON-like data structure at a give [resolution].
int maxPolyfillSize(GeoPolygon geoPolygon, int resolution) {
  assert(resolution >= 0 && resolution <= 15);

  final GeoPolygonNative native = GeoPolygonNative.allocate(geoPolygon);
  final int result = H3().maxPolyfillSize(
      native.geofence,
      native.geofenceNum,
      native.holes,
      native.holesSizes,
      native.holesNum,
      resolution);
  native.dispose();

  return result;
}

/// Takes a given GeoJSON-like data structure returns the hexagons that are
/// contained by the GeoJSON-like data structure.
///
/// The current implementation is very primitive and slow, but correct,
/// performing a point-in-poly operation on every hexagon in a k-ring defined
/// around the given geofence.
List<int> polyfill(GeoPolygon geoPolygon, int resolution) {
  assert(resolution >= 0 && resolution <= 15);

  final GeoPolygonNative native = GeoPolygonNative.allocate(geoPolygon);
  final int size = H3().maxPolyfillSize(native.geofence, native.geofenceNum,
      native.holes, native.holesSizes, native.holesNum, resolution);

  final Pointer<Uint64> out = allocate(count: size);
  for (int i = 0; i < size; i++) {
    out.elementAt(i).value = 0;
  }

  H3().polyfill(native.geofence, native.geofenceNum, native.holes,
      native.holesSizes, native.holesNum, resolution, out);

  final Uint64List uint64list = out.asTypedList(size);
  final List<int> result = <int>[];
  uint64list.forEach(result.add);

  free(out);
  native.dispose();

  return result;
}
