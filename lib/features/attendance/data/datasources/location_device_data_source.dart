import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../../../../core/error/failures.dart';

abstract class LocationDeviceDataSource {
  Future<LocationModel> getCurrentLocation();
  Stream<LocationModel> getLocationStream();
}

class LocationDeviceDataSourceImpl implements LocationDeviceDataSource {
  @override
  Future<LocationModel> getCurrentLocation() async {
    await _checkPermissions();

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(const Duration(seconds: 15));
      return LocationModel(
          latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      throw LocationFailure(message: 'GPS Error: ${e.toString()}');
    }
  }

  @override
  Stream<LocationModel> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // Filter GPS drift; common walking threshold is ~5m
      ),
    ).map((position) => LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
        )).handleError((error) {
           throw LocationFailure(message: 'Stream GPS Error: ${error.toString()}');
        });
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(message: 'Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationFailure(message: 'Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
          message: 'Location permissions are permanently denied.');
    }
  }
}
