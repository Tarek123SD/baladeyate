/// Catalog of required citizen documents per municipal transaction type.
class TransactionDocumentItem {
  const TransactionDocumentItem({
    required this.title,
    this.hint,
    this.isRequired = true,
  });

  final String title;
  final String? hint;
  final bool isRequired;
}

class TransactionDocumentGuide {
  const TransactionDocumentGuide({
    required this.type,
    required this.typeLabel,
    required this.documents,
    this.notes,
  });

  final String type;
  final String typeLabel;
  final List<TransactionDocumentItem> documents;
  final String? notes;

  int get requiredCount =>
      documents.where((document) => document.isRequired).length;
}

/// Single source of document requirements for the Flutter app.
class TransactionDocumentCatalog {
  static const String formatNote =
      'الصيغ المقبولة: PDF أو JPG أو PNG — بحد أقصى 5 ميغابايت لكل ملف.';

  static const List<TransactionDocumentGuide> all = [
    TransactionDocumentGuide(
      type: 'commercial_license',
      typeLabel: 'رخصة تجارية',
      notes: 'ارفع كل وثيقة في ملف مستقل وواضح القراءة.',
      documents: [
        TransactionDocumentItem(
          title: 'صورة الهوية الشخصية لصاحب الطلب',
          hint: 'وجه الهوية أو بطاقة شخصية سارية',
        ),
        TransactionDocumentItem(
          title: 'سند ملكية المحل أو عقد الإيجار',
          hint: 'عقد ساري يوضح عنوان المحل',
        ),
        TransactionDocumentItem(
          title: 'صورة أو مخطط موقع المحل',
          hint: 'صورة الواجهة أو مخطط تقريبي للموقع',
        ),
        TransactionDocumentItem(
          title: 'أي ترخيص سابق أو وثيقة نشاط (إن وجدت)',
          hint: 'اختياري إن كان النشاط قائماً مسبقاً',
          isRequired: false,
        ),
      ],
    ),
    TransactionDocumentGuide(
      type: 'building_permit',
      typeLabel: 'رخصة بناء',
      notes: 'يجب أن تكون المخططات مقروءة وحديثة قدر الإمكان.',
      documents: [
        TransactionDocumentItem(
          title: 'صورة الهوية الشخصية للمالك',
        ),
        TransactionDocumentItem(
          title: 'سند ملكية الأرض أو العقار',
        ),
        TransactionDocumentItem(
          title: 'المخططات الهندسية للبناء',
          hint: 'مخططات معمارية/إنشائية إن توفرت',
        ),
        TransactionDocumentItem(
          title: 'موافقة الجيران أو إفادة محلية (إن لزم)',
          isRequired: false,
        ),
      ],
    ),
    TransactionDocumentGuide(
      type: 'general_service',
      typeLabel: 'خدمة عامة',
      notes: 'ارفع ما يدعم طلبك بوضوح حسب نوع الخدمة.',
      documents: [
        TransactionDocumentItem(
          title: 'صورة الهوية الشخصية',
        ),
        TransactionDocumentItem(
          title: 'مستند داعم للطلب',
          hint: 'مثل كتاب رسمي، صورة موقع، أو أي إثبات ذي صلة',
        ),
        TransactionDocumentItem(
          title: 'مرفقات إضافية توضيحية',
          isRequired: false,
        ),
      ],
    ),
  ];

  static TransactionDocumentGuide? forType(String? type) {
    if (type == null || type.isEmpty) return null;
    for (final guide in all) {
      if (guide.type == type) return guide;
    }
    return null;
  }

  static int minimumRequiredAttachments(String? type) {
    return forType(type)?.requiredCount ?? 0;
  }
}
