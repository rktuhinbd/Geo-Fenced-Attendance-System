import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/attendance/presentation/pages/attendance_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AttendanceBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Geo Attendance',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AttendanceScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
