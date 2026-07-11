import 'package:baladeyate/features/admin/models/grave.dart';
import 'package:equatable/equatable.dart';

sealed class GravesState extends Equatable {
  const GravesState();

  @override
  List<Object?> get props => [];
}

final class GravesInitial extends GravesState {
  const GravesInitial();
}

final class GravesLoading extends GravesState {
  const GravesLoading();
}

final class GravesLoaded extends GravesState {
  const GravesLoaded({
    required this.graves,
    this.query = '',
  });

  final List<Grave> graves;
  final String query;

  List<Grave> get filteredGraves {
    return graves.where((grave) => grave.matchesQuery(query)).toList();
  }

  GravesLoaded copyWith({
    List<Grave>? graves,
    String? query,
  }) {
    return GravesLoaded(
      graves: graves ?? this.graves,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [graves, query];
}

final class GravesFailure extends GravesState {
  const GravesFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
