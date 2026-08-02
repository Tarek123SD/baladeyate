import 'package:baladeyate/config/constants/storage_keys.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/cache_service.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Shows the signup success dialog on the main screen when pending.
Future<void> maybeShowPendingSignupSuccessDialog(BuildContext context) async {
  final cacheService = sl<CacheService>();
  final isPending = cacheService.getData(
        key: StorageKeys.pendingSignupVerificationNotice,
      ) ==
      'true';
  final alreadyShown = cacheService.getData(
        key: StorageKeys.signupVerificationNoticeShown,
      ) ==
      'true';

  if (!isPending || alreadyShown || !context.mounted) return;

  await showSignupSuccessDialog(context);

  await cacheService.saveData(
    key: StorageKeys.signupVerificationNoticeShown,
    value: 'true',
  );
  await cacheService.removeData(
    key: StorageKeys.pendingSignupVerificationNotice,
  );
}

/// One-time dialog shown after the user completes signup.
Future<void> showSignupSuccessDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'تم إنشاء الحساب',
    barrierColor: AppColors.primaryForest.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: Center(
            child: PopScope(
              canPop: false,
              child: _SignupSuccessDialogCard(
                onConfirm: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _SignupSuccessDialogCard extends StatelessWidget {
  const _SignupSuccessDialogCard({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 24.w(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: (MediaQuery.sizeOf(context).width - 48.w(context))
            .clamp(280.0, 420.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r(context)),
          border: Border.all(
            color: AppColors.secondaryGoldenWheat.withValues(alpha: 0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryForest.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: AppColors.thirdGoldenWheat),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.16,
                child: SvgPicture.asset(
                  AppAssets.patternExact,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                28.h(context),
                horizontalPadding,
                24.h(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72.s(context),
                    height: 72.s(context),
                    decoration: BoxDecoration(
                      color: AppColors.primaryForest.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGoldenWheat.withValues(alpha: 0.45),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      size: 38.ic(context),
                      color: AppColors.primaryGoldenWheat,
                    ),
                  ),
                  SizedBox(height: 20.h(context)),
                  Text(
                    'تم إنشاء الحساب بنجاح',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.primaryForest,
                      fontSize: 20.f(context),
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 14.h(context)),
                  Text(
                    'سيصلك إشعار عند اكتمال توثيق الحساب لتتمكن من إرسال الشكاوي',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.secondaryCharcoal.withValues(alpha: 0.82),
                      fontSize: 14.f(context),
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 26.h(context)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.thirdGoldenWheat,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r(context)),
                        ),
                      ),
                      child: Text(
                        'حسناً',
                        style: TextStyle(
                          fontSize: 16.f(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
