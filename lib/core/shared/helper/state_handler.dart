// lib/common/utils/state_handler.dart

import 'package:baladeyate/core/services/failure_service/failure.dart';
import 'package:baladeyate/core/services/status.dart';
import 'package:baladeyate/core/shared/dialogs/loading_dialog.dart';
import 'package:flutter/material.dart';

void handleSubmissionState({
  required BuildContext context,
  required SubmissionStatus state,
  required Failure failure,
  required VoidCallback onSuccess,
  bool isShimmer = false,
  required void Function()? onRetryPressed,
}) {
  if (state == SubmissionStatus.loading && !isShimmer) {
    showLoadingDialog(context);
  } else if (state == SubmissionStatus.error) {
    failure.handle(context, onRetry: () {});
  } else if (state == SubmissionStatus.success) {
    if (isShimmer) {
      Navigator.of(context).pop();
    }
    onSuccess();
  }
}
