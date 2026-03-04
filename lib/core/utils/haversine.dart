import 'dart:math';

class Haversine {
  static const double _earthRadius = 6371000.0; // Radius in meters

  static double calculateDistance(
      double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    if (startLatitude == endLatitude && startLongitude == endLongitude) {
      return 0.0;
    }

    final dLat = _toRadians(endLatitude - startLatitude);
    final dLon = _toRadians(endLongitude - startLongitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLatitude)) * cos(_toRadians(endLatitude)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
