import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
}

class ServerFailure extends Failure {
  final String message;
  const ServerFailure({this.message = 'Server Error'});

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  final String message;
  const CacheFailure({this.message = 'Cache Error'});

  @override
  List<Object> get props => [message];
}

class LocationFailure extends Failure {
  final String message;
  const LocationFailure({this.message = 'Location Error'});

  @override
  List<Object> get props => [message];
}
