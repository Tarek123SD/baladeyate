import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:baladeyate/features/cemetery_reservation/cubits/reserve_grave_cubit/reserve_grave_cubit.dart';
import 'package:baladeyate/features/cemetery_reservation/cubits/reserve_grave_cubit/reserve_grave_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GraveReservationFormScreen extends StatefulWidget {
  const GraveReservationFormScreen({super.key, required this.grave});

  final GraveModel grave;

  @override
  State<GraveReservationFormScreen> createState() =>
      _GraveReservationFormScreenState();
}

class _GraveReservationFormScreenState extends State<GraveReservationFormScreen> {
  final _deceasedController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _deceasedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final graveId = int.tryParse(widget.grave.id);
    if (graveId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('معرّف القبر غير صالح')),
      );
      return;
    }

    context.read<ReserveGraveCubit>().submit(
          graveId: graveId,
          deceasedName: _deceasedController.text,
          notes: _notesController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(showBackButton: true),
        body: BlocConsumer<ReserveGraveCubit, ReserveGraveState>(
          listener: (context, state) {
            if (state is ReserveGraveSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب الحجز — سيتم إشعارك عند المراجعة'),
                ),
              );
              context.go('/cemetery/reservations');
            } else if (state is ReserveGraveFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ReserveGraveLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'طلب حجز قبر',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryForest,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'القبر المختار: ${widget.grave.id}',
                    style: const TextStyle(
                      color: AppColors.primaryForest,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _deceasedController,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'اسم المتوفى *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    textDirection: TextDirection.rtl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryForest,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('إرسال طلب الحجز'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
