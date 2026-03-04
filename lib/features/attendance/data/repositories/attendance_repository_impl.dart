import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/haversine.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_data_source.dart';
import '../datasources/location_device_data_source.dart';
import '../models/location_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource localDataSource;
  final LocationDeviceDataSource deviceDataSource;

  AttendanceRepositoryImpl({
    required this.localDataSource,
    required this.deviceDataSource,
  });

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      final location = await deviceDataSource.getCurrentLocation();
      return Right(location);
    } on LocationFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected Error: \${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, LocationEntity>> getLocationStream() {
    return deviceDataSource.getLocationStream().map((location) => Right(location));
  }

  @override
  Future<Either<Failure, LocationEntity>> getOfficeLocation() async {
    try {
      final location = await localDataSource.getCachedOfficeLocation();
      return Right(location);
    } on CacheFailure {
      return const Left(CacheFailure(message: 'Office location not set.'));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to retrieve office location.'));
    }
  }

  @override
  Future<Either<Failure, void>> setOfficeLocation(LocationEntity location) async {
    try {
      await localDataSource.cacheOfficeLocation(LocationModel.fromEntity(location));
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to cache office location.'));
    }
  }

  @override
  Future<Either<Failure, void>> markAttendance(LocationEntity currentLocation, LocationEntity officeLocation) async {
    try {
      double distance = Haversine.calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        officeLocation.latitude,
        officeLocation.longitude,
      );

      if (distance <= 50.0) {
        // Attendance successfully marked logic goes here
        return const Right(null);
      } else {
        return Left(LocationFailure(message: 'You are too far from the office. Distance is \${distance.toStringAsFixed(2)} meters.'));
      }
    } catch (e) {
      return const Left(ServerFailure(message: 'Unexpected error marking attendance.'));
    }
  }
}
