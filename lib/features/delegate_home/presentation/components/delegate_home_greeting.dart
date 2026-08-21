import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/auth/delegate_work_scope.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/home/presentation/components/greeting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DelegateHomeGreeting extends StatelessWidget {
  const DelegateHomeGreeting({super.key});

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (previous is AuthSuccess && current is AuthSuccess) {
          return previous.user.name != current.user.name ||
              previous.user.fieldWorkTypes.join() !=
                  current.user.fieldWorkTypes.join();
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final userName = state is AuthSuccess ? state.user.name : 'مندوب';
        final statusLabel = state is AuthSuccess
            ? state.user.fieldWorkStatusLabel
            : 'مندوب ميداني';
        return GreetingCard(
          greeting: _timeGreeting(),
          name: 'أهلاً، $userName',
          statusLabel: statusLabel,
          statusColor: AppColors.primaryGoldenWheat,
        );
      },
    );
  }
}
