import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final LocationEntity? officeLocation;
  final LocationEntity? currentLocation;
  final double distanceInMeters;

  const AttendanceLoaded({
    this.officeLocation,
    this.currentLocation,
    required this.distanceInMeters,
  });

  AttendanceLoaded copyWith({
    LocationEntity? officeLocation,
    LocationEntity? currentLocation,
    double? distanceInMeters,
  }) {
    return AttendanceLoaded(
      officeLocation: officeLocation ?? this.officeLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
    );
  }

  @override
  List<Object?> get props => [officeLocation, currentLocation, distanceInMeters];
}

class AttendanceSuccess extends AttendanceState {
  final String message;

  const AttendanceSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError({required this.message});

  @override
  List<Object> get props => [message];
}
