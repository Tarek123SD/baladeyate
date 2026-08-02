import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Shell for login and signup — solid background, no patterned layer underneath.
class AuthScreenScaffold extends StatelessWidget {
  const AuthScreenScaffold({
    super.key,
    required this.body,
    this.showBackButton = false,
    this.onBack,
  });

  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBack;

  static const Color pageBackground = AppColors.thirdGoldenWheat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: Stack(
        children: [
          body,
          if (showBackButton)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 8.h(context),
                    right: 16.s(context),
                  ),
                  child: _AuthBackButton(onTap: onBack),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.s(context)),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18.s(context),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Branded top panel with splash imagery — content centered horizontally & vertically.
class AuthBrandedHeader extends StatelessWidget {
  const AuthBrandedHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.tagline,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final String? tagline;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 72.0 : 84.0;
    final waveHeight = 28.h(context);
    final panelHeight = compact ? 220.h(context) : 260.h(context);

    return SizedBox(
      height: panelHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Image.asset(
            AppAssets.splashWallpaper,
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryForest.withValues(alpha: 0.9),
                  AppColors.secondaryForest.withValues(alpha: 0.85),
                  AppColors.primaryForest.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: waveHeight),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 24.s(context)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppAssets.logoGold,
                                width: logoSize.s(context),
                                height: logoSize.s(context),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(
                                  height: compact ? 12.h(context) : 14.h(context)),
                              Text(
                                title,
                                style: TextStyle(
                                  color: AppColors.thirdGoldenWheat,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      compact ? 22.f(context) : 24.f(context),
                                  height: 1.2,
                                ),
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subtitle != null) ...[
                                SizedBox(height: 6.h(context)),
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    color: AppColors.secondaryGoldenWheat,
                                    fontSize:
                                        compact ? 14.f(context) : 15.f(context),
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (tagline != null) ...[
                                SizedBox(height: 6.h(context)),
                                Text(
                                  tagline!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.78),
                                    fontSize: 12.f(context),
                                    height: 1.35,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              size: Size(double.infinity, waveHeight),
              painter: _AuthWavePainter(
                color: AuthScreenScaffold.pageBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthWavePainter extends CustomPainter {
  _AuthWavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.05,
        size.width * 0.5,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.62,
        size.width,
        size.height * 0.2,
      )
      ..lineTo(size.width, size.height + 1)
      ..lineTo(0, size.height + 1)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AuthWavePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Form body panel sitting below the branded header.
class AuthFormPanel extends StatelessWidget {
  const AuthFormPanel({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AuthScreenScaffold.pageBackground,
      child: child,
    );
  }
}

/// Centered section title — no side accent bar.
class AuthSectionHeader extends StatelessWidget {
  const AuthSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryForest,
              ),
          textDirection: TextDirection.rtl,
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8.h(context)),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                  height: 1.45,
                ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor = AppColors.secondaryForest,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final radius = 28.r(context);
    final active = enabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56.h(context),
      child: ElevatedButton(
        onPressed: active ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: active ? 3 : 0,
          shadowColor: AppColors.primaryForest.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.s(context),
                height: 24.s(context),
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 20.s(context)),
                    SizedBox(width: 10.s(context)),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.f(context),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    SizedBox(width: 10.s(context)),
                    Icon(trailingIcon, size: 20.s(context)),
                  ],
                ],
              ),
      ),
    );
  }
}

class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: prompt,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
          children: [
            TextSpan(
              text: actionLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryForest,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.f(context),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthPasswordLabelRow extends StatelessWidget {
  const AuthPasswordLabelRow({
    super.key,
    required this.label,
    this.forgotPasswordOnTap,
  });

  final String label;
  final VoidCallback? forgotPasswordOnTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.f(context),
            color: Colors.black87,
          ),
          textDirection: TextDirection.rtl,
        ),
        if (forgotPasswordOnTap != null)
          GestureDetector(
            onTap: forgotPasswordOnTap,
            child: Text(
              'نسيت كلمة المرور؟',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.thirdDeepUmber,
                    fontWeight: FontWeight.w600,
                  ),
              textDirection: TextDirection.rtl,
            ),
          ),
      ],
    );
  }
}

/// Thin divider between form groups on signup.
class AuthFormDivider extends StatelessWidget {
  const AuthFormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h(context)),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.inputBorder.withValues(alpha: 0.9),
              thickness: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.s(context)),
            child: Icon(
              Icons.circle,
              size: 5.s(context),
              color: AppColors.primaryGoldenWheat,
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.inputBorder.withValues(alpha: 0.9),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
