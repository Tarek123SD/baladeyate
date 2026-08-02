import 'package:equatable/equatable.dart';
import 'package:baladeyate/features/digital_documents/models/digital_document_model.dart';

abstract class DigitalDocumentsState extends Equatable {
  const DigitalDocumentsState();

  @override
  List<Object?> get props => [];
}

class DigitalDocumentsInitial extends DigitalDocumentsState {
  const DigitalDocumentsInitial();
}

class DigitalDocumentsLoading extends DigitalDocumentsState {
  const DigitalDocumentsLoading();
}

class DigitalDocumentsSuccess extends DigitalDocumentsState {
  final List<DigitalDocumentModel> documents;

  const DigitalDocumentsSuccess({required this.documents});

  @override
  List<Object?> get props => [documents];
}

class DigitalDocumentsError extends DigitalDocumentsState {
  final String message;

  const DigitalDocumentsError({required this.message});

  @override
  List<Object?> get props => [message];
}
