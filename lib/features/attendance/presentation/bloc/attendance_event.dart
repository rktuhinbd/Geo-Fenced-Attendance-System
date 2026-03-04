import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class CheckInitialLocationEvent extends AttendanceEvent {}

class SetOfficeLocationEvent extends AttendanceEvent {}

class UpdateCurrentLocationEvent extends AttendanceEvent {}

class MarkAttendanceEvent extends AttendanceEvent {}
