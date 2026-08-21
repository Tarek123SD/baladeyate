import 'package:baladeyate/core/auth/app_role.dart';
import 'package:baladeyate/features/auth/models/user.dart';

/// Field-work kinds stored on the delegate account.
///
/// An empty list means the delegate is eligible for every kind, matching
/// the API (`User::handlesWorkType`).
enum DelegateWorkType {
  complaints,
  transactions,
  survey;

  String get apiValue => switch (this) {
        DelegateWorkType.complaints => 'complaints',
        DelegateWorkType.transactions => 'transactions',
        DelegateWorkType.survey => 'survey',
      };
}

extension DelegateWorkScope on User {
  bool get handlesAllFieldWork => fieldWorkTypes.isEmpty;

  bool handlesWorkType(DelegateWorkType type) {
    if (handlesAllFieldWork) {
      return true;
    }
    return fieldWorkTypes.contains(type.apiValue);
  }

  bool get handlesComplaintWork =>
      handlesWorkType(DelegateWorkType.complaints);

  bool get handlesTransactionWork =>
      handlesWorkType(DelegateWorkType.transactions);

  bool get handlesSurveyWork => handlesWorkType(DelegateWorkType.survey);

  String get fieldWorkStatusLabel {
    if (!isDelegateLike) {
      return verificationStatusLabel ?? 'مواطن';
    }
    if (handlesAllFieldWork) {
      return 'مندوب ميداني';
    }

    final labels = <String>[];
    if (handlesComplaintWork) {
      labels.add('الشكاوى');
    }
    if (handlesTransactionWork) {
      labels.add('المعاملات');
    }
    if (handlesSurveyWork) {
      labels.add('المسح الميداني');
    }

    if (labels.isEmpty) {
      return 'مندوب ميداني';
    }
    if (labels.length == 1) {
      return 'مندوب ${labels.first}';
    }
    return 'مندوب: ${labels.join(' و ')}';
  }

  /// Whether this delegate may open [path] after the work-type split.
  bool canAccessDelegatePath(String path) {
    if (!isDelegateLike) {
      return false;
    }

    if (path == '/delegate/home') {
      return true;
    }

    final isSurveyPath = path.contains('verify-document') ||
        path == '/delegate/map' ||
        path == '/delegate/tasks' ||
        path == '/delegate/buildings' ||
        path == '/delegate/cemetery-map' ||
        path.startsWith('/tasks') ||
        path.startsWith('/info') ||
        path.startsWith('/floor') ||
        path.startsWith('/apartment') ||
        path.startsWith('/people') ||
        path.startsWith('/building/');
    if (isSurveyPath) {
      return handlesSurveyWork;
    }

    if (path.startsWith('/delegate/complaints')) {
      return handlesComplaintWork;
    }

    if (path.startsWith('/delegate/transactions')) {
      return handlesTransactionWork;
    }

    return true;
  }
}
