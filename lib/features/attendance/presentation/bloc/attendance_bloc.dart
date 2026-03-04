import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/haversine.dart';
import '../../domain/usecases/get_current_location.dart';
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

  AttendanceBloc({
    required this.getCurrentLocation,
    required this.getOfficeLocation,
    required this.setOfficeLocation,
    required this.markAttendance,
  }) : super(AttendanceInitial()) {
    on<CheckInitialLocationEvent>(_onCheckInitialLocation);
    on<SetOfficeLocationEvent>(_onSetOfficeLocation);
    on<UpdateCurrentLocationEvent>(_onUpdateCurrentLocation);
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
        add(UpdateCurrentLocationEvent()); // Trigger immediate fetch
      },
    );
  }

  Future<void> _onSetOfficeLocation(
      SetOfficeLocationEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());

    final currentLocationEither = await getCurrentLocation(NoParams());

    await currentLocationEither.fold(
      (failure) async {
        emit(AttendanceError(message: _mapFailureToMessage(failure)));
        emit(const AttendanceLoaded(distanceInMeters: 0)); // Revert
      },
      (currentLocation) async {
        final setLocationEither = await setOfficeLocation(
            SetOfficeLocationParams(location: currentLocation));

        setLocationEither.fold(
          (failure) {
            emit(AttendanceError(message: _mapFailureToMessage(failure)));
            emit(const AttendanceLoaded(distanceInMeters: 0));
          },
          (_) {
            emit(const AttendanceSuccess(message: 'Office location set successfully!'));
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
            distance = Haversine.calculateDistance(
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

  String _mapFailureToMessage(Failure failure) {
    if (failure is LocationFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Unexpected error occurred';
  }
}
