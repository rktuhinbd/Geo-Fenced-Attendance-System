import 'dart:io';
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
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      throw LocationFailure(message: 'GPS Error: ${e.toString()}');
    }
  }

  @override
  Stream<LocationModel> getLocationStream() {
    LocationSettings settings;
    
    // Using platform-specific settings for maximum frequency and reliability
    try {
      if (Platform.isAndroid) {
        settings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 1), // Only for AndroidSettings
        );
      } else if (Platform.isIOS || Platform.isMacOS) {
        settings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          activityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      } else {
        settings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        );
      }
    } catch (e) {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    return Geolocator.getPositionStream(locationSettings: settings)
        .map((position) => LocationModel(
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
            ))
        .handleError((error) {
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
