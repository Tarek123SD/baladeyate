import 'package:baladeyate/features/transactions/models/transaction_document_catalog.dart';

class TransactionFormFieldConfig {
  const TransactionFormFieldConfig({
    required this.key,
    required this.label,
    this.input = 'text',
    this.isRequired = true,
    this.hint,
  });

  final String key;
  final String label;
  final String input;
  final bool isRequired;
  final String? hint;

  factory TransactionFormFieldConfig.fromJson(Map<String, dynamic> json) {
    return TransactionFormFieldConfig(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      input: json['input'] as String? ?? 'text',
      isRequired: json['required'] as bool? ?? true,
      hint: json['hint'] as String?,
    );
  }
}

class TransactionTypeConfig {
  const TransactionTypeConfig({
    required this.type,
    required this.label,
    this.description,
    this.formFields = const [],
    this.documents = const [],
    this.minimumRequiredAttachments = 0,
  });

  final String type;
  final String label;
  final String? description;
  final List<TransactionFormFieldConfig> formFields;
  final List<TransactionDocumentItem> documents;
  final int minimumRequiredAttachments;

  TransactionDocumentGuide get guide => TransactionDocumentGuide(
        type: type,
        typeLabel: label,
        documents: documents,
        notes: description,
      );

  int get requiredCount => documents.where((item) => item.isRequired).length;

  factory TransactionTypeConfig.fromJson(Map<String, dynamic> json) {
    final rawFields = json['form_fields'] ?? json['formFields'];
    final fields = <TransactionFormFieldConfig>[];
    if (rawFields is List) {
      for (final item in rawFields) {
        if (item is Map<String, dynamic>) {
          final field = TransactionFormFieldConfig.fromJson(item);
          if (field.key.isNotEmpty && field.label.isNotEmpty) {
            fields.add(field);
          }
        }
      }
    }

    final rawDocuments = json['documents'];
    final documents = <TransactionDocumentItem>[];
    if (rawDocuments is List) {
      for (final item in rawDocuments) {
        if (item is Map<String, dynamic>) {
          final title = item['title'] as String? ?? '';
          if (title.isEmpty) continue;
          documents.add(
            TransactionDocumentItem(
              title: title,
              hint: item['hint'] as String?,
              isRequired: item['required'] as bool? ?? true,
            ),
          );
        }
      }
    }

    final minRequired = json['minimum_required_attachments'] is int
        ? json['minimum_required_attachments'] as int
        : documents.where((item) => item.isRequired).length;

    return TransactionTypeConfig(
      type: json['type'] as String? ?? json['slug'] as String? ?? '',
      label: json['label'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String?,
      formFields: fields,
      documents: documents,
      minimumRequiredAttachments: minRequired,
    );
  }
}
