import 'package:equatable/equatable.dart';

class StationGenre extends Equatable {
  const StationGenre({required this.name, required this.stationCount});

  final String name;
  final int stationCount;

  @override
  List<Object?> get props => [name, stationCount];
}
