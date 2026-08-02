import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/cemetery_map/cubits/cemetery_map_cubit/cemetery_map_cubit.dart';
import 'package:baladeyate/features/cemetery_map/cubits/cemetery_map_cubit/cemetery_map_state.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Intrinsic size of the drone orthophoto (must match the source image).
const double mapWidth = 2000;
const double mapHeight = 1500;

/// Placeholder high-res URL simulating a drone orthophoto until the backend
/// serves the real cemetery map.
const String _droneOrthophotoUrl =
    'https://baladeyate.me/cemeteries/map_v1.jpg';

/// Interactive cemetery map with pan/zoom over a drone orthophoto overlay.
class CemeteryMapScreen extends StatefulWidget {
  const CemeteryMapScreen({super.key});

  @override
  State<CemeteryMapScreen> createState() => _CemeteryMapScreenState();
}

class _CemeteryMapScreenState extends State<CemeteryMapScreen> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CemeteryMapCubit, CemeteryMapState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.successMessage;
        if (message == null) return;

        final isError = state.errorMessage != null;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              elevation: 6,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              duration: const Duration(seconds: 3),
              content: _CemeterySnackBarContent(
                message: message,
                isError: isError,
              ),
            ),
          );
        context.read<CemeteryMapCubit>().clearMessages();
      },
      buildWhen: (previous, current) =>
          previous.graves != current.graves ||
          previous.isAddingMode != current.isAddingMode ||
          previous.isLoading != current.isLoading ||
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(showBackButton: true),
          floatingActionButton: FloatingActionButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.read<CemeteryMapCubit>().toggleAddingMode(),
            backgroundColor: state.isAddingMode
                ? AppColors.primaryGoldenWheat
                : AppColors.primaryForest,
            tooltip:
                state.isAddingMode ? 'إلغاء وضع الإضافة' : 'إضافة قبر جديد',
            child: Icon(
              state.isAddingMode
                  ? Icons.close_rounded
                  : Icons.add_location_alt_rounded,
              color: Colors.white,
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.1,
                  maxScale: 4.0,
                  constrained: false,
                  child: SizedBox(
                    width: mapWidth,
                    height: mapHeight,
                    child: Directionality(
                      // Absolute map coords must ignore app RTL layout.
                      textDirection: TextDirection.ltr,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _DroneImageLayer(
                            isAddingMode: state.isAddingMode,
                            onMapTap: _onMapTapped,
                          ),
                          ...state.graves.map(
                            (grave) => Positioned(
                              left: grave.x,
                              top: grave.y,
                              width: grave.width,
                              height: grave.height,
                              child: _GraveMarker(
                                key: ValueKey('grave-${grave.id}'),
                                grave: grave,
                                onTap: state.isAddingMode
                                    ? null
                                    : () => _showGraveDetails(grave),
                              ),
                            ),
                          ),
                          if (state.isLoading || state.isSubmitting)
                            Positioned.fill(
                              child: ColoredBox(
                                color: const Color(0x33000000),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      if (state.isLoading) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          'جاري تحميل القبور...',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.95),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (state.isAddingMode)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: AppColors.primaryGoldenWheat.withValues(alpha: 0.92),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            const Icon(
                              Icons.touch_app_rounded,
                              color: AppColors.primaryDeepUmber,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'اضغط على الخريطة لتحديد موقع القبر الجديد',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: AppColors.primaryDeepUmber,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onMapTapped(Offset localPosition) async {
    final cubit = context.read<CemeteryMapCubit>();
    if (!cubit.state.isAddingMode || cubit.state.isSubmitting) return;

    const defaultWidth = GraveModel.defaultGraveWidth;
    const defaultHeight = GraveModel.defaultGraveHeight;
    final centeredX = localPosition.dx - (defaultWidth / 2);
    final centeredY = localPosition.dy - (defaultHeight / 2);

    final result = await showDialog<_AddGraveDialogResult>(
      context: context,
      builder: (dialogContext) => _AddGraveDialog(
        x: centeredX,
        y: centeredY,
        width: defaultWidth,
        height: defaultHeight,
      ),
    );

    if (result == null || !mounted) return;

    await cubit.createGraveAt(
      x: centeredX,
      y: centeredY,
      width: defaultWidth,
      height: defaultHeight,
      status: result.status,
      deceasedName: result.deceasedName,
    );
  }

  void _showGraveDetails(GraveModel grave) {
    final deceasedName = grave.deceasedName?.trim();
    final showDeceasedName = grave.status == 'occupied' &&
        deceasedName != null &&
        deceasedName.isNotEmpty;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _GraveDetailsSheet(
          grave: grave,
          statusLabel: _statusLabel(grave.status),
          deceasedName: showDeceasedName ? deceasedName : null,
        );
      },
    );
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'available' => 'متاح',
      'occupied' => 'مشغول',
      'booked' => 'محجوز',
      _ => status,
    };
  }
}

class _DroneImageLayer extends StatelessWidget {
  const _DroneImageLayer({
    required this.isAddingMode,
    required this.onMapTap,
  });

  final bool isAddingMode;
  final ValueChanged<Offset> onMapTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:
          isAddingMode ? (details) => onMapTap(details.localPosition) : null,
      child: CachedNetworkImage(
        imageUrl: _droneOrthophotoUrl,
        width: mapWidth,
        height: mapHeight,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      ),
    );
  }
}

class _GraveMarker extends StatelessWidget {
  const _GraveMarker({
    super.key,
    required this.grave,
    this.onTap,
  });

  final GraveModel grave;
  final VoidCallback? onTap;

  Color get _fillColor {
    return switch (grave.status) {
      'available' => Colors.green.withValues(alpha: 0.4),
      'occupied' => const Color(0xFF8B1A1A).withValues(alpha: 0.55),
      'booked' => const Color(0xFF8B1A1A).withValues(alpha: 0.7),
      _ => Colors.grey.withValues(alpha: 0.4),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: grave.width,
        height: grave.height,
        decoration: BoxDecoration(
          color: _fillColor,
          border: Border.all(color: Colors.white, width: 1),
        ),
      ),
    );
  }
}

class _GraveDetailsSheet extends StatelessWidget {
  const _GraveDetailsSheet({
    required this.grave,
    required this.statusLabel,
    this.deceasedName,
  });

  final GraveModel grave;
  final String statusLabel;
  final String? deceasedName;

  Color get _statusColor {
    return switch (grave.status) {
      'available' => AppColors.primaryForest,
      'occupied' => const Color(0xFF8B1A1A),
      'booked' => const Color(0xFF8B1A1A),
      _ => AppColors.secondaryCharcoal,
    };
  }

  IconData get _statusIcon {
    return switch (grave.status) {
      'available' => Icons.check_circle_rounded,
      'occupied' => Icons.person_rounded,
      'booked' => Icons.bookmark_rounded,
      _ => Icons.info_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryForest.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_statusIcon, color: _statusColor, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'قبر ${grave.id}',
                            style: const TextStyle(
                              color: AppColors.primaryForest,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تفاصيل موقع القبر على الخريطة',
                            style: TextStyle(
                              color: AppColors.secondaryCharcoal
                                  .withValues(alpha: 0.65),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.thirdGoldenWheat.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryForest.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'الحالة',
                        value: statusLabel,
                        valueColor: _statusColor,
                        icon: _statusIcon,
                      ),
                      if (deceasedName != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color:
                                AppColors.primaryForest.withValues(alpha: 0.12),
                          ),
                        ),
                        _DetailRow(
                          label: 'اسم المتوفى',
                          value: deceasedName!,
                          icon: Icons.badge_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryForest,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: valueColor ?? AppColors.primaryForest,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: valueColor ?? AppColors.primaryCharcoal,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CemeterySnackBarContent extends StatelessWidget {
  const _CemeterySnackBarContent({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final background = isError ? AppColors.alertRed : AppColors.primaryForest;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddGraveDialogResult {
  const _AddGraveDialogResult({
    required this.status,
    this.deceasedName,
  });

  final String status;
  final String? deceasedName;
}

class _AddGraveDialog extends StatefulWidget {
  const _AddGraveDialog({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  @override
  State<_AddGraveDialog> createState() => _AddGraveDialogState();
}

class _AddGraveDialogState extends State<_AddGraveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _deceasedNameController = TextEditingController();

  String _status = 'available';

  static InputDecoration _fieldDecoration({
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.secondaryCharcoal.withValues(alpha: 0.45),
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primaryForest.withValues(alpha: 0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primaryForest.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primaryForest,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.alertRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.alertRed, width: 1.6),
      ),
    );
  }

  @override
  void dispose() {
    _deceasedNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final deceasedName =
        _status == 'occupied' ? _deceasedNameController.text.trim() : null;

    Navigator.of(context).pop(
      _AddGraveDialogResult(
        status: _status,
        deceasedName: deceasedName?.isEmpty == true ? null : deceasedName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryForest.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add_location_alt_rounded,
                          color: AppColors.primaryForest,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إضافة قبر جديد',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryForest,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الموقع: (${widget.x.toStringAsFixed(0)}, '
                              '${widget.y.toStringAsFixed(0)}) · '
                              '${widget.width.toInt()}×${widget.height.toInt()}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryCharcoal
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'حالة القبر',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: _fieldDecoration(
                      prefixIcon: Icon(
                        _status == 'occupied'
                            ? Icons.person_off_outlined
                            : Icons.check_circle_outline,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    dropdownColor: AppColors.surfaceWhite,
                    iconEnabledColor: AppColors.primaryForest,
                    style: const TextStyle(
                      color: AppColors.primaryCharcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'available',
                        child: Text('متاح'),
                      ),
                      DropdownMenuItem(
                        value: 'occupied',
                        child: Text('مشغول'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _status = value);
                    },
                  ),
                  if (_status == 'occupied') ...[
                    const SizedBox(height: 16),
                    Text(
                      'اسم المتوفى',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryCharcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _deceasedNameController,
                      textDirection: TextDirection.rtl,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        color: AppColors.primaryCharcoal,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _fieldDecoration(
                        hintText: 'أدخل اسم المتوفى',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primaryForest,
                        ),
                      ),
                      validator: (value) {
                        if (_status != 'occupied') return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'اسم المتوفى مطلوب للقبر المشغول';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryForest,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'تأكيد',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondaryCharcoal,
                            side: BorderSide(
                              color: AppColors.primaryForest
                                  .withValues(alpha: 0.25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
