import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location.dart';
import '../repositories/attendance_repository.dart';

class SetOfficeLocation implements UseCase<void, SetOfficeLocationParams> {
  final AttendanceRepository repository;

  SetOfficeLocation(this.repository);

  @override
  Future<Either<Failure, void>> call(SetOfficeLocationParams params) async {
    return await repository.setOfficeLocation(params.location);
  }
}

class SetOfficeLocationParams extends Equatable {
  final LocationEntity location;

  const SetOfficeLocationParams({required this.location});

  @override
  List<Object> get props => [location];
}
