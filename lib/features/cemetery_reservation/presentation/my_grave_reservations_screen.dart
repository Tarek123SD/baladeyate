import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/cemetery_reservation/cubits/grave_reservations_cubit/grave_reservations_cubit.dart';
import 'package:baladeyate/features/cemetery_reservation/cubits/grave_reservations_cubit/grave_reservations_state.dart';
import 'package:baladeyate/features/cemetery_reservation/models/grave_reservation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyGraveReservationsScreen extends StatefulWidget {
  const MyGraveReservationsScreen({super.key});

  @override
  State<MyGraveReservationsScreen> createState() =>
      _MyGraveReservationsScreenState();
}

class _MyGraveReservationsScreenState extends State<MyGraveReservationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GraveReservationsCubit>().loadReservations();
  }

  Future<void> _cancelReservation(GraveReservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل تريد إلغاء طلب حجز هذا القبر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await context
        .read<GraveReservationsCubit>()
        .cancelReservation(reservation.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم إلغاء الطلب' : 'تعذر إلغاء الطلب'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(showBackButton: true),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/cemetery/map'),
          backgroundColor: AppColors.primaryForest,
          icon: const Icon(Icons.map_outlined),
          label: const Text('خريطة القبور'),
        ),
        body: BlocBuilder<GraveReservationsCubit, GraveReservationsState>(
          builder: (context, state) {
            if (state is GraveReservationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GraveReservationsFailure) {
              return Center(child: Text(state.message));
            }

            if (state is GraveReservationsLoaded) {
              if (state.reservations.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    Text(
                      'طلبات حجز القبور',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryForest,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 32),
                    Center(child: Text('لا توجد طلبات حجز حتى الآن')),
                  ],
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<GraveReservationsCubit>().loadReservations(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: state.reservations.length + 1,
                  separatorBuilder: (_, index) =>
                      index == 0 ? const SizedBox(height: 16) : const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Text(
                        'طلبات حجز القبور',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryForest,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      );
                    }
                    final item = state.reservations[index - 1];
                    return _ReservationCard(
                      reservation: item,
                      onCancel: item.canCancel
                          ? () => _cancelReservation(item)
                          : null,
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    this.onCancel,
  });

  final GraveReservation reservation;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.reservationNumber,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryForest,
              ),
            ),
            const SizedBox(height: 8),
            Text('المتوفى: ${reservation.deceasedName}'),
            if (reservation.graveId != null)
              Text('القبر: ${reservation.graveId}'),
            const SizedBox(height: 4),
            Text('الحالة: ${reservation.statusLabel}'),
            if (reservation.isRejected &&
                reservation.adminNotes != null &&
                reservation.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'سبب الرفض: ${reservation.adminNotes}',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 13,
                ),
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onCancel,
                  child: const Text('إلغاء الطلب'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
