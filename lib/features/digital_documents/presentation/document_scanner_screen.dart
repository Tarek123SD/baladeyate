import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/features/digital_documents/cubits/scanner_cubit/scanner_cubit.dart';
import 'package:baladeyate/features/digital_documents/cubits/scanner_cubit/scanner_state.dart';
import 'widgets/scanner_overlay_painter.dart';
import 'widgets/verification_result_bottom_sheet.dart';

class DocumentScannerScreen extends StatelessWidget {
  const DocumentScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScannerCubit>(),
      child: const DocumentScannerView(),
    );
  }
}

class DocumentScannerView extends StatefulWidget {
  const DocumentScannerView({super.key});

  @override
  State<DocumentScannerView> createState() => _DocumentScannerViewState();
}

class _DocumentScannerViewState extends State<DocumentScannerView> {
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isLoadingDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawCode = barcodes.first.rawValue;
    if (rawCode == null || rawCode.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Pause scanner immediately to prevent multiple scans
    _scannerController.stop();

    // Trigger verification in Cubit
    context.read<ScannerCubit>().verifyScannedCode(rawCode);
  }

  void _showLoadingDialog() {
    if (_isLoadingDialogShowing) return;
    _isLoadingDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r(dialogContext)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 28.w(dialogContext),
                vertical: 24.h(dialogContext),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48.w(dialogContext),
                    height: 48.h(dialogContext),
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      color: AppColors.primaryForest,
                    ),
                  ),
                  SizedBox(height: 20.h(dialogContext)),
                  Text(
                    'جاري التحقق من الوثيقة...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.f(dialogContext),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryForest,
                    ),
                  ),
                  SizedBox(height: 6.h(dialogContext)),
                  Text(
                    'يرجى الانتظار لحين مطابقة البيانات مع السجل البلدي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.f(dialogContext),
                      color: AppColors.secondaryCharcoal.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _dismissLoadingDialog() {
    if (_isLoadingDialogShowing && mounted) {
      _isLoadingDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _resumeScanning() {
    setState(() {
      _isProcessing = false;
    });
    context.read<ScannerCubit>().resetScanner();
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerCubit, ScannerState>(
      listener: (context, state) async {
        if (state is ScannerLoading) {
          _showLoadingDialog();
        } else if (state is ScannerSuccess) {
          _dismissLoadingDialog();
          await VerificationResultBottomSheet.showSuccess(
            context,
            document: state.document,
            onScanAnother: _resumeScanning,
          );
          if (mounted && _isProcessing) {
            _resumeScanning();
          }
        } else if (state is ScannerError) {
          _dismissLoadingDialog();
          await VerificationResultBottomSheet.showError(
            context,
            errorMessage: state.message,
            onTryAgain: _resumeScanning,
          );
          if (mounted && _isProcessing) {
            _resumeScanning();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. Fullscreen Camera Preview
            MobileScanner(
              controller: _scannerController,
              onDetect: _onBarcodeDetected,
            ),

            // 2. Custom Overlay Frame with darkened surroundings
            Positioned.fill(
              child: CustomPaint(
                painter: ScannerOverlayPainter(
                  overlayColor: const Color(0xB3000000),
                  borderColor: AppColors.primaryGoldenWheat,
                  scanWindowSize: 270.0,
                  borderRadius: 20.0,
                ),
              ),
            ),

            // 3. Guidance Text below target frame
            Positioned(
              left: 20,
              right: 20,
              bottom: 120.h(context),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w(context),
                        vertical: 10.h(context),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(30.r(context)),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primaryGoldenWheat,
                            size: 20.ic(context),
                          ),
                          SizedBox(width: 8.w(context)),
                          Text(
                            'ضع رمز QR داخل الإطار للتحقق التلقائي',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.f(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Transparent AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    height: kToolbarHeight,
                    padding: EdgeInsets.symmetric(horizontal: 12.w(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          onPressed: () => context.pop(),
                        ),

                        // Title Text
                        Text(
                          'التحقق من الوثائق',
                          style: TextStyle(
                            fontSize: 18.f(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        // Flashlight Toggle Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isTorchOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              color: _isTorchOn
                                  ? AppColors.primaryGoldenWheat
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            _scannerController.toggleTorch();
                            setState(() {
                              _isTorchOn = !_isTorchOn;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
