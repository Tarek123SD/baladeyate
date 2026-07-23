import 'package:equatable/equatable.dart';

sealed class DonateState extends Equatable {
  const DonateState();

  @override
  List<Object?> get props => [];
}

final class DonateInitial extends DonateState {
  const DonateInitial();
}

final class DonateLoading extends DonateState {
  const DonateLoading();
}

final class DonateSuccess extends DonateState {
  const DonateSuccess();
}

final class DonateFailure extends DonateState {
  const DonateFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
