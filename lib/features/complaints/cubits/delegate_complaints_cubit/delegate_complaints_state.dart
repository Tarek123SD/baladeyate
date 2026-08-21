import 'package:equatable/equatable.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';

abstract class DelegateComplaintsState extends Equatable {
  const DelegateComplaintsState();

  @override
  List<Object?> get props => [];
}

class DelegateComplaintsInitial extends DelegateComplaintsState {}

class DelegateComplaintsLoading extends DelegateComplaintsState {}

class DelegateComplaintsLoaded extends DelegateComplaintsState {
  final List<Complaint> complaints;

  const DelegateComplaintsLoaded(this.complaints);

  @override
  List<Object?> get props => [complaints];
}

class DelegateComplaintsError extends DelegateComplaintsState {
  final String message;

  const DelegateComplaintsError(this.message);

  @override
  List<Object?> get props => [message];
}
