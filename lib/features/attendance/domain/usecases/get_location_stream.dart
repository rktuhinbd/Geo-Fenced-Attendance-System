import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location.dart';
import '../repositories/attendance_repository.dart';

class GetLocationStream {
  final AttendanceRepository repository;

  GetLocationStream(this.repository);

  Stream<Either<Failure, LocationEntity>> call() {
    return repository.getLocationStream();
  }
}
