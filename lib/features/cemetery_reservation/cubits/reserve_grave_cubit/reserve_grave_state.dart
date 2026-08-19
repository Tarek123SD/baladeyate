import 'package:equatable/equatable.dart';

sealed class ReserveGraveState extends Equatable {
  const ReserveGraveState();

  @override
  List<Object?> get props => [];
}

final class ReserveGraveInitial extends ReserveGraveState {
  const ReserveGraveInitial();
}

final class ReserveGraveLoading extends ReserveGraveState {
  const ReserveGraveLoading();
}

final class ReserveGraveSuccess extends ReserveGraveState {
  const ReserveGraveSuccess();
}

final class ReserveGraveFailure extends ReserveGraveState {
  const ReserveGraveFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
