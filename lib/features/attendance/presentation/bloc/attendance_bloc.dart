import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_location_stream.dart';
import '../../domain/usecases/get_office_location.dart';
import '../../domain/usecases/mark_attendance.dart';
import '../../domain/usecases/set_office_location.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetCurrentLocation getCurrentLocation;
  final GetOfficeLocation getOfficeLocation;
  final SetOfficeLocation setOfficeLocation;
  final MarkAttendance markAttendance;
  final GetLocationStream getLocationStream;

  StreamSubscription? _locationSubscription;

  AttendanceBloc({
    required this.getCurrentLocation,
    required this.getOfficeLocation,
    required this.setOfficeLocation,
    required this.markAttendance,
    required this.getLocationStream,
  }) : super(AttendanceInitial()) {
    on<CheckInitialLocationEvent>(_onCheckInitialLocation);
    on<SetOfficeLocationEvent>(_onSetOfficeLocation);
    on<UpdateCurrentLocationEvent>(_onUpdateCurrentLocation);
    on<RealTimeLocationUpdateEvent>(_onRealTimeLocationUpdate);
    on<MarkAttendanceEvent>(_onMarkAttendance);
  }

  Future<void> _onCheckInitialLocation(
      CheckInitialLocationEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());

    final officeLocationEither = await getOfficeLocation(NoParams());

    officeLocationEither.fold(
      (failure) {
        emit(const AttendanceLoaded(distanceInMeters: 0));
      },
      (officeLoc) {
        emit(AttendanceLoaded(officeLocation: officeLoc, distanceInMeters: 0));
      },
    );

    // Initial check for current location to avoid starting at 0.0 if already far
    final currentLocationEither = await getCurrentLocation(NoParams());
    currentLocationEither.fold(
      (_) => null,
      (currentLoc) {
        double dist = 0;
        if (state is AttendanceLoaded) {
          final s = state as AttendanceLoaded;
          if (s.officeLocation != null) {
            dist = Geolocator.distanceBetween(
              currentLoc.latitude, currentLoc.longitude,
              s.officeLocation!.latitude, s.officeLocation!.longitude
            );
          }
          emit(s.copyWith(currentLocation: currentLoc, distanceInMeters: dist));
        }
      }
    );

    // Start real-time tracking
    await _locationSubscription?.cancel();
    _locationSubscription = getLocationStream().listen((result) {
      result.fold(
        (failure) {
          // Silent fallback or log error if needed
        },
        (location) => add(RealTimeLocationUpdateEvent(location)),
      );
    });
  }

  Future<void> _onSetOfficeLocation(
      SetOfficeLocationEvent event, Emitter<AttendanceState> emit) async {
    final currentState = state is AttendanceLoaded ? state as AttendanceLoaded : null;
    emit(AttendanceLoading());

    final currentLocationEither = await getCurrentLocation(NoParams());

    await currentLocationEither.fold(
      (failure) async {
        emit(AttendanceError(message: _mapFailureToMessage(failure)));
        if (currentState != null) {
          emit(currentState);
        } else {
          emit(const AttendanceLoaded(distanceInMeters: 0));
        }
      },
      (currentLocation) async {
        final setLocationEither = await setOfficeLocation(
            SetOfficeLocationParams(location: currentLocation));

        setLocationEither.fold(
          (failure) {
            emit(AttendanceError(message: _mapFailureToMessage(failure)));
            if (currentState != null) {
              emit(currentState);
            } else {
              emit(const AttendanceLoaded(distanceInMeters: 0));
            }
          },
          (_) {
            emit(const AttendanceSuccess(message: 'Office location set successfully!'));
            // Important: immediately update with the new office info
            emit(AttendanceLoaded(
              officeLocation: currentLocation,
              currentLocation: currentLocation,
              distanceInMeters: 0,
            ));
          },
        );
      },
    );
  }

  void _onRealTimeLocationUpdate(
      RealTimeLocationUpdateEvent event, Emitter<AttendanceState> emit) {
    if (state is AttendanceLoaded) {
      final currentState = state as AttendanceLoaded;
      double distance = 0;
      if (currentState.officeLocation != null) {
        distance = Geolocator.distanceBetween(
          event.location.latitude,
          event.location.longitude,
          currentState.officeLocation!.latitude,
          currentState.officeLocation!.longitude,
        );
      }
      emit(currentState.copyWith(
        currentLocation: event.location,
        distanceInMeters: distance,
      ));
    }
  }

  Future<void> _onUpdateCurrentLocation(
      UpdateCurrentLocationEvent event, Emitter<AttendanceState> emit) async {
    if (state is AttendanceLoaded) {
      final currentState = state as AttendanceLoaded;
      final currentLocationEither = await getCurrentLocation(NoParams());

      currentLocationEither.fold(
        (failure) {
          emit(AttendanceError(message: _mapFailureToMessage(failure)));
          emit(currentState);
        },
        (currentLocation) {
          double distance = 0;
          if (currentState.officeLocation != null) {
            distance = Geolocator.distanceBetween(
              currentLocation.latitude,
              currentLocation.longitude,
              currentState.officeLocation!.latitude,
              currentState.officeLocation!.longitude,
            );
          }
          emit(currentState.copyWith(
            currentLocation: currentLocation,
            distanceInMeters: distance,
          ));
        },
      );
    }
  }

  Future<void> _onMarkAttendance(
      MarkAttendanceEvent event, Emitter<AttendanceState> emit) async {
    if (state is AttendanceLoaded) {
      final currentState = state as AttendanceLoaded;
      if (currentState.officeLocation == null || currentState.currentLocation == null) {
        emit(const AttendanceError(message: 'Location data is missing.'));
        emit(currentState);
        return;
      }

      emit(AttendanceLoading());
      final markAttendanceEither = await markAttendance(MarkAttendanceParams(
        currentLocation: currentState.currentLocation!,
        officeLocation: currentState.officeLocation!,
      ));

      markAttendanceEither.fold(
        (failure) {
          emit(AttendanceError(message: _mapFailureToMessage(failure)));
          emit(currentState); 
        },
        (_) {
          emit(const AttendanceSuccess(message: 'Attendance marked successfully!'));
          emit(currentState); 
        },
      );
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is LocationFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    return 'Unexpected error occurred';
  }
}
