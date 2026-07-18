import 'package:baladeyate/features/donations/models/donation_case.dart';
import 'package:equatable/equatable.dart';

sealed class DonationsState extends Equatable {
  const DonationsState();

  @override
  List<Object?> get props => [];
}

final class DonationsInitial extends DonationsState {
  const DonationsInitial();
}

final class DonationsLoading extends DonationsState {
  const DonationsLoading();
}

final class DonationsLoaded extends DonationsState {
  const DonationsLoaded({required this.cases});

  final List<DonationCase> cases;

  @override
  List<Object?> get props => [cases];
}

final class DonationsFailure extends DonationsState {
  const DonationsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
