import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/attendance/data/datasources/attendance_local_data_source.dart';
import 'features/attendance/data/datasources/location_device_data_source.dart';
import 'features/attendance/data/repositories/attendance_repository_impl.dart';
import 'features/attendance/domain/repositories/attendance_repository.dart';
import 'features/attendance/domain/usecases/get_current_location.dart';
import 'features/attendance/domain/usecases/get_office_location.dart';
import 'features/attendance/domain/usecases/mark_attendance.dart';
import 'features/attendance/domain/usecases/set_office_location.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Setup Hive
  await Hive.initFlutter();
  final box = await Hive.openBox('attendanceBox');
  sl.registerLazySingleton<Box>(() => box);

  // Blocs
  sl.registerFactory(() => AttendanceBloc(
        getCurrentLocation: sl(),
        getOfficeLocation: sl(),
        setOfficeLocation: sl(),
        markAttendance: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => GetOfficeLocation(sl()));
  sl.registerLazySingleton(() => SetOfficeLocation(sl()));
  sl.registerLazySingleton(() => MarkAttendance(sl()));

  // Repository
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      localDataSource: sl(),
      deviceDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AttendanceLocalDataSource>(
    () => AttendanceLocalDataSourceImpl(box: sl()),
  );
  sl.registerLazySingleton<LocationDeviceDataSource>(
    () => LocationDeviceDataSourceImpl(),
  );
}
