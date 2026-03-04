import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class CheckInitialLocationEvent extends AttendanceEvent {}

class SetOfficeLocationEvent extends AttendanceEvent {}

class UpdateCurrentLocationEvent extends AttendanceEvent {}

class RealTimeLocationUpdateEvent extends AttendanceEvent {
  final LocationEntity location;
  const RealTimeLocationUpdateEvent(this.location);

  @override
  List<Object> get props => [location];
}

class MarkAttendanceEvent extends AttendanceEvent {}
