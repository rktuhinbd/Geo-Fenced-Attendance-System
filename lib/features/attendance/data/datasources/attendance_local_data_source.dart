import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../models/location_model.dart';

abstract class AttendanceLocalDataSource {
  Future<void> cacheOfficeLocation(LocationModel locationToCache);
  Future<LocationModel> getCachedOfficeLocation();
}

const cachedOfficeLocation = 'CACHED_OFFICE_LOCATION';

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final Box box;

  AttendanceLocalDataSourceImpl({required this.box});

  @override
  Future<void> cacheOfficeLocation(LocationModel locationToCache) {
    return box.put(
      cachedOfficeLocation,
      json.encode(locationToCache.toJson()),
    );
  }

  @override
  Future<LocationModel> getCachedOfficeLocation() {
    final jsonString = box.get(cachedOfficeLocation);
    if (jsonString != null) {
      return Future.value(LocationModel.fromJson(json.decode(jsonString)));
    } else {
      throw const CacheFailure(message: 'No cached location found');
    }
  }
}
