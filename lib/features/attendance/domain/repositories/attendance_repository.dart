import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, LocationEntity>> getCurrentLocation();
  Future<Either<Failure, void>> setOfficeLocation(LocationEntity location);
  Future<Either<Failure, LocationEntity>> getOfficeLocation();
  Future<Either<Failure, void>> markAttendance(LocationEntity currentLocation, LocationEntity officeLocation);
  Stream<Either<Failure, LocationEntity>> getLocationStream();
}
