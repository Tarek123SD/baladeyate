import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/auth/delegate_work_scope.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/home/presentation/components/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateHomeQuickActions extends StatelessWidget {
  const DelegateHomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (previous is AuthSuccess && current is AuthSuccess) {
          return previous.user.fieldWorkTypes.join() !=
              current.user.fieldWorkTypes.join();
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        final tiles = _tilesFor(context, user);
        if (tiles.isEmpty) {
          return const SizedBox.shrink();
        }

        final gap = 12.s(context);
        final rows = <Widget>[];
        for (var i = 0; i < tiles.length; i += 2) {
          if (i > 0) {
            rows.add(SizedBox(height: gap));
          }
          if (i + 1 < tiles.length) {
            rows.add(
              Row(
                children: [
                  Expanded(child: tiles[i]),
                  SizedBox(width: gap),
                  Expanded(child: tiles[i + 1]),
                ],
              ),
            );
          } else {
            rows.add(
              Row(
                children: [
                  Expanded(child: tiles[i]),
                  SizedBox(width: gap),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            );
          }
        }

        return Column(children: rows);
      },
    );
  }

  List<Widget> _tilesFor(BuildContext context, User? user) {
    Widget tile(String title, IconData icon, VoidCallback onTap) {
      return CustomCard(
        title: title,
        icon: icon,
        bgColor: Colors.white,
        iconColor: AppColors.primaryForest,
        onTap: onTap,
      );
    }

    final handlesSurvey = user == null || user.handlesSurveyWork;
    final handlesComplaints = user == null || user.handlesComplaintWork;
    final handlesTransactions = user == null || user.handlesTransactionWork;
    final tiles = <Widget>[];

    if (handlesSurvey) {
      tiles.addAll([
        tile('الخريطة', AppIcons.map, () => context.go('/delegate/map')),
        tile('المهام', AppIcons.tasks, () => context.go('/delegate/tasks')),
        tile(
          'فحص الوثائق',
          AppIcons.scanDocument,
          () => context.push('/delegate/home/verify-document'),
        ),
        tile(
          'خريطة المقبرة',
          AppIcons.cemetery,
          () => context.push('/delegate/cemetery-map'),
        ),
      ]);
    }

    if (handlesTransactions) {
      tiles.add(
        tile(
          'معاينة معاملات',
          Icons.fact_check_outlined,
          () => context.push('/delegate/transactions'),
        ),
      );
    }

    if (handlesComplaints) {
      tiles.add(
        tile(
          'شكاوى ميدانية',
          AppIcons.complaint,
          () => context.push('/delegate/complaints'),
        ),
      );
    }

    return tiles;
  }
}
