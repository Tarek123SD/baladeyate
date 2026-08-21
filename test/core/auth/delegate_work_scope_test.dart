import 'package:baladeyate/core/auth/delegate_work_scope.dart';
import 'package:baladeyate/core/navigation/delegate_nav_destinations.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

User _delegate({List<String> types = const []}) {
  return User(
    id: 1,
    name: 'مندوب',
    email: 'delegate@example.com',
    role: 'Delegate',
    fieldWorkTypes: types,
  );
}

void main() {
  test('empty work types keep every field interface', () {
    final user = _delegate();

    expect(user.handlesComplaintWork, isTrue);
    expect(user.handlesTransactionWork, isTrue);
    expect(user.handlesSurveyWork, isTrue);
    expect(user.canAccessDelegatePath('/delegate/complaints'), isTrue);
    expect(user.canAccessDelegatePath('/delegate/map'), isTrue);
    expect(DelegateNavDestinations.forUser(user), hasLength(4));
  });

  test('complaints-only delegate sees complaints and not survey screens', () {
    final user = _delegate(types: const ['complaints']);

    expect(user.handlesComplaintWork, isTrue);
    expect(user.handlesSurveyWork, isFalse);
    expect(user.canAccessDelegatePath('/delegate/complaints'), isTrue);
    expect(user.canAccessDelegatePath('/delegate/map'), isFalse);
    expect(user.fieldWorkStatusLabel, 'مندوب الشكاوى');

    final nav = DelegateNavDestinations.forUser(user);
    expect(nav.map((item) => item.label), ['الرئيسية', 'الشكاوى']);
  });

  test('survey-only delegate cannot open complaint inbox', () {
    final user = _delegate(types: const ['survey']);

    expect(user.canAccessDelegatePath('/delegate/complaints'), isFalse);
    expect(user.canAccessDelegatePath('/delegate/tasks'), isTrue);
    expect(DelegateNavDestinations.forUser(user), hasLength(4));
  });
}
