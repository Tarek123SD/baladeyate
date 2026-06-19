import 'package:baladeyate/core/services/failure_service/failure.dart';
import 'package:baladeyate/core/shared/dialogs/login_dialog.dart';
import 'package:flutter/widgets.dart';

class AuthFailure extends Failure {
  AuthFailure(super.message);

  @override
  Future<void> handle(BuildContext context, {void Function()? onRetry}) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    showLoginRequiredDialog(context, () {});
  }
}
