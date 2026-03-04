import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location.dart';
import '../repositories/attendance_repository.dart';

class GetOfficeLocation implements UseCase<LocationEntity, NoParams> {
  final AttendanceRepository repository;

  GetOfficeLocation(this.repository);

  @override
  Future<Either<Failure, LocationEntity>> call(NoParams params) async {
    return await repository.getOfficeLocation();
  }
}
