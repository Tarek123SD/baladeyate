import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/home/presentation/components/greeting_card.dart';
import 'package:baladeyate/features/home/presentation/components/section_header.dart';
import 'package:baladeyate/features/home/presentation/components/stats_overview.dart';
import 'package:baladeyate/features/home/presentation/components/verification_banner.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class HomeTopSection extends StatelessWidget {
  const HomeTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) {
            if (previous is AuthSuccess && current is AuthSuccess) {
              return previous.user.name != current.user.name ||
                  previous.user.verificationStatus !=
                      current.user.verificationStatus;
            }
            return previous.runtimeType != current.runtimeType;
          },
          builder: (context, state) {
            final userName =
                state is AuthSuccess ? state.user.name : 'مواطن';
            final statusLabel = state is AuthSuccess
                ? (state.user.verificationStatusLabel ??
                    'حالة التوثيق غير معروفة')
                : 'سجّل الدخول لعرض حالتك';
            final isVerified =
                state is AuthSuccess && state.user.isVerified;
            final showVerification =
                state is AuthSuccess && state.user.canSubmitVerification;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GreetingCard(
                  greeting: timeAwareGreeting(),
                  name: 'أهلا بك، $userName',
                  statusLabel: statusLabel,
                  statusColor: isVerified ? Colors.amber : Colors.orange,
                ),
                if (showVerification) ...[
                  SizedBox(height: 16.h(context)),
                  VerificationBanner(
                    wasRejected: state.user.verificationStatus == 'rejected',
                  ),
                ],
              ],
            );
          },
        ),
        SizedBox(height: 32.h(context)),
        BlocProvider(
          create: (_) => sl<ComplaintsCubit>()..loadComplaints(),
          child: const StatsOverview(),
        ),
        SizedBox(height: 32.h(context)),
        const SectionHeader(title: 'الخدمات السريعة'),
        SizedBox(height: 16.h(context)),
      ],
    );
  }
}
