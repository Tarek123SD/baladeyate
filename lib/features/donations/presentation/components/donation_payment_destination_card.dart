import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/features/donations/models/donation_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationPaymentDestinationCard extends StatelessWidget {
  const DonationPaymentDestinationCard({
    super.key,
    required this.donation,
  });

  final DonationModel donation;

  Future<void> _copy(BuildContext context, String value, String successMessage) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    AppSnackBar.showSuccess(context, successMessage);
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched || !context.mounted) return;
      await _copy(context, url, 'تعذر فتح الرابط، تم نسخه');
    } catch (_) {
      if (!context.mounted) return;
      await _copy(context, url, 'تعذر فتح الرابط، تم نسخه');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!donation.hasPaymentDestination) {
      return const SizedBox.shrink();
    }

    final method = donation.paymentMethod?.trim();
    final qrSize = 148.s(context);

    return Container(
      padding: EdgeInsets.all(18.s(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryForest.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.s(context)),
                decoration: BoxDecoration(
                  color: AppColors.primaryForest,
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  color: Colors.white,
                  size: 20.ic(context),
                ),
              ),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وجهة التحويل',
                      style: TextStyle(
                        color: AppColors.primaryForest,
                        fontSize: 15.5.f(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      method != null && method.isNotEmpty
                          ? 'حوّل عبر $method ثم أرفق صورة الإيصال'
                          : 'امسح الرمز أو انسخ البيانات لإرسال التبرع',
                      style: TextStyle(
                        color: AppColors.primaryForest.withValues(alpha: 0.7),
                        fontSize: 12.f(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_hasQr) ...[
            SizedBox(height: 16.h(context)),
            Center(
              child: Container(
                padding: EdgeInsets.all(10.s(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildQr(context, qrSize),
              ),
            ),
            SizedBox(height: 8.h(context)),
            Text(
              'امسح الرمز بتطبيق الدفع أو المحفظة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF757575),
                fontSize: 12.f(context),
              ),
            ),
          ],
          if (donation.paymentAccount?.isNotEmpty == true) ...[
            SizedBox(height: 14.h(context)),
            _DestinationValueRow(
              label: 'رقم الحساب / المحفظة',
              value: donation.paymentAccount!,
              icon: AppIcons.wallet,
              onCopy: () => _copy(
                context,
                donation.paymentAccount!,
                'تم نسخ رقم الحساب',
              ),
            ),
          ],
          if (donation.paymentLink?.isNotEmpty == true) ...[
            SizedBox(height: 10.h(context)),
            _DestinationValueRow(
              label: 'رابط الدفع',
              value: donation.paymentLink!,
              icon: Icons.link_rounded,
              onCopy: () => _copy(
                context,
                donation.paymentLink!,
                'تم نسخ رابط الدفع',
              ),
            ),
            if (donation.hasOpenablePaymentLink) ...[
              SizedBox(height: 10.h(context)),
              SizedBox(
                height: 44.h(context),
                child: OutlinedButton.icon(
                  onPressed: () => _openLink(context, donation.paymentLink!),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryForest,
                    side: const BorderSide(color: AppColors.primaryForest),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r(context)),
                    ),
                  ),
                  icon: Icon(Icons.open_in_new_rounded, size: 18.ic(context)),
                  label: Text(
                    'فتح رابط الدفع',
                    style: TextStyle(
                      fontSize: 13.5.f(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
          if (donation.paymentInstructions?.isNotEmpty == true) ...[
            SizedBox(height: 12.h(context)),
            Text(
              donation.paymentInstructions!,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF616161),
                fontSize: 12.5.f(context),
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasQr =>
      (donation.qrImageUrl != null && donation.qrImageUrl!.isNotEmpty) ||
      (donation.qrPayload != null && donation.qrPayload!.isNotEmpty);

  Widget _buildQr(BuildContext context, double size) {
    final imageUrl = donation.qrImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => SizedBox(
          width: size,
          height: size,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.pageProgress(context),
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          final payload = donation.qrPayload;
          if (payload != null && payload.isNotEmpty) {
            return _generatedQr(payload, size);
          }
          return SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 48.ic(context),
              color: AppColors.primaryForest,
            ),
          );
        },
      );
    }

    return _generatedQr(donation.qrPayload!, size);
  }

  Widget _generatedQr(String data, double size) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: AppColors.primaryForest,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: AppColors.primaryCharcoal,
      ),
    );
  }
}

class _DestinationValueRow extends StatelessWidget {
  const _DestinationValueRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onCopy,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w(context),
        vertical: 10.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r(context)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(width: 8.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF757575),
                    fontSize: 11.f(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryForest,
                    fontSize: 13.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'نسخ',
            onPressed: onCopy,
            icon: Icon(
              Icons.copy_outlined,
              size: 18.ic(context),
              color: AppColors.primaryForest,
            ),
          ),
        ],
      ),
    );
  }
}
