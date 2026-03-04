import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../../../../core/error/failures.dart';

abstract class LocationDeviceDataSource {
  Future<LocationModel> getCurrentLocation();
}

class LocationDeviceDataSourceImpl implements LocationDeviceDataSource {
  @override
  Future<LocationModel> getCurrentLocation() async {
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

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      return LocationModel(
          latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      throw const LocationFailure(message: 'Failed to get current location.');
    }
  }
}
