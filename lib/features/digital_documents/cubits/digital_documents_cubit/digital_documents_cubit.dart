import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/digital_documents/repo/digital_documents_repository.dart';
import 'digital_documents_state.dart';

class DigitalDocumentsCubit extends Cubit<DigitalDocumentsState> {
  final DigitalDocumentsRepository _digitalDocumentsRepository;

  DigitalDocumentsCubit({
    required DigitalDocumentsRepository digitalDocumentsRepository,
  })  : _digitalDocumentsRepository = digitalDocumentsRepository,
        super(const DigitalDocumentsInitial());

  Future<void> fetchDigitalDocuments() async {
    emit(const DigitalDocumentsLoading());
    try {
      final documents = await _digitalDocumentsRepository.getDigitalDocuments();
      emit(DigitalDocumentsSuccess(documents: documents));
    } catch (e) {
      emit(DigitalDocumentsError(
        message: ApiResponseParser.toUserMessage(
          e,
          fallback: 'فشل تحميل الوثائق الرقمية',
        ),
      ));
    }
  }
}
