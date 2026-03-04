import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location.dart';
import '../repositories/attendance_repository.dart';

class MarkAttendance implements UseCase<void, MarkAttendanceParams> {
  final AttendanceRepository repository;

  MarkAttendance(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkAttendanceParams params) async {
    return await repository.markAttendance(params.currentLocation, params.officeLocation);
  }
}

class MarkAttendanceParams extends Equatable {
  final LocationEntity currentLocation;
  final LocationEntity officeLocation;

  const MarkAttendanceParams({
    required this.currentLocation,
    required this.officeLocation,
  });

  @override
  List<Object> get props => [currentLocation, officeLocation];
}
