import 'package:baladeyate/features/cemetery_reservation/models/grave_reservation.dart';
import 'package:equatable/equatable.dart';

sealed class GraveReservationsState extends Equatable {
  const GraveReservationsState();

  @override
  List<Object?> get props => [];
}

final class GraveReservationsInitial extends GraveReservationsState {
  const GraveReservationsInitial();
}

final class GraveReservationsLoading extends GraveReservationsState {
  const GraveReservationsLoading();
}

final class GraveReservationsLoaded extends GraveReservationsState {
  const GraveReservationsLoaded({required this.reservations});

  final List<GraveReservation> reservations;

  @override
  List<Object?> get props => [reservations];
}

final class GraveReservationsFailure extends GraveReservationsState {
  const GraveReservationsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
