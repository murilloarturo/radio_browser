import 'package:equatable/equatable.dart';

sealed class AppFailure extends Equatable {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Unable to connect to Radio Browser.',
    Object? cause,
  ]) : super(cause: cause);
}

final class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {this.statusCode, super.cause});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class DecodingFailure extends AppFailure {
  const DecodingFailure([
    super.message = 'Unable to read the Radio Browser response.',
    Object? cause,
  ]) : super(cause: cause);
}

final class UnavailableStationFailure extends AppFailure {
  const UnavailableStationFailure([
    super.message = 'This station is unavailable.',
    Object? cause,
  ]) : super(cause: cause);
}

final class PersistenceFailure extends AppFailure {
  const PersistenceFailure([
    super.message = 'Unable to access local storage.',
    Object? cause,
  ]) : super(cause: cause);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something went wrong.', Object? cause])
    : super(cause: cause);
}
