class UpdateModel {
  final String id;
  final String title;
  final String subtitle;
  final String type; // 'transaction', 'complaint', 'alert'
  final String date;
  final bool hasAction;

  const UpdateModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.date,
    this.hasAction = false,
  });
}

/// Dummy data list for Latest Updates section
final List<UpdateModel> dummyUpdatesList = [
  const UpdateModel(
    id: '1',
    title: 'تم الموافقة على رخصة البناء',
    subtitle: 'تمت المراجعة والاعتماد لطلب رخصة البناء رقم #4582 بنجاح.',
    type: 'transaction',
    date: 'منذ ساعتين',
    hasAction: true,
  ),
  const UpdateModel(
    id: '2',
    title: 'تحديث بشأن الشكوى #1092',
    subtitle: 'تمت إحالة الشكوى إلى قسم صيانة الطرق والإنارة لبدء التنفيذ.',
    type: 'complaint',
    date: 'اليوم، 10:30 ص',
    hasAction: true,
  ),
  const UpdateModel(
    id: '3',
    title: 'تنبيه: انقطاع مؤقت للمياه',
    subtitle: 'سيتم قطع المياه لأعمال الصيانة الدورية في حي الأندلس غداً.',
    type: 'alert',
    date: 'أمس',
    hasAction: false,
  ),
  const UpdateModel(
    id: '4',
    title: 'إصدار شهادة الإشغال',
    subtitle: 'شهادتك الرقمية جاهزة الآن للتحميل والطباعة عبر التطبيق.',
    type: 'transaction',
    date: 'منذ 3 أيام',
    hasAction: true,
  ),
  const UpdateModel(
    id: '5',
    title: 'تنبيه: تحديث المنظومة',
    subtitle: 'ستتوقف الخدمات الإلكترونية لساعتين مساء اليوم لأغراض الصيانة.',
    type: 'alert',
    date: 'منذ 4 أيام',
    hasAction: false,
  ),
];
