import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({this.properties = const <dynamic>[]}) : super();

  final List properties;

  @override
  List<Object> get props => [properties];

  @override
  String toString() {
    return properties.map((e) => e.toString()).join(' ');
  }
}

class ServerFailure extends Failure {
  final String? code;
  final String? message;

  ServerFailure({
    this.code,
    this.message,
  }) : super(properties: [code, message]);
}

class CacheFailure extends Failure {}
