import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_state.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_household_section.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_personal_details_section.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_user_header.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_verification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, profileState) {
        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(),
            body: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Dimensions.contentMaxWidth.w(context),
                    ),
                    child: RefreshIndicator(
                      color: AppColors.primaryForest,
                      onRefresh: () =>
                          context.read<ProfileCubit>().loadProfile(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16.h(context),
                          horizontalPadding,
                          30.h(context),
                        ),
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, authState) {
                            if (authState is! AuthSuccess) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 80),
                                  child: Text('الرجاء تسجيل الدخول أولاً'),
                                ),
                              );
                            }

                            final user = authState.user;
                            final loaded = profileState is ProfileLoaded
                                ? profileState
                                : null;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ProfileUserHeader(user: user)
                                    .animate()
                                    .fadeIn(duration: 350.ms)
                                    .slideY(begin: -0.1, end: 0),
                                SizedBox(height: 24.h(context)),
                                ProfileVerificationCard(user: user)
                                    .animate()
                                    .fadeIn(duration: 350.ms, delay: 100.ms)
                                    .slideY(begin: 0.08, end: 0),
                                SizedBox(height: 24.h(context)),
                                ProfilePersonalDetailsSection(user: user)
                                    .animate()
                                    .fadeIn(duration: 350.ms, delay: 200.ms)
                                    .slideY(begin: 0.08, end: 0),
                                SizedBox(height: 24.h(context)),
                                ProfileHouseholdSection(
                                  household: loaded?.household,
                                  message: loaded?.householdMessage ??
                                      (profileState is ProfileLoading
                                          ? 'جاري تحميل السجل السكني...'
                                          : null),
                                )
                                    .animate()
                                    .fadeIn(duration: 350.ms, delay: 300.ms)
                                    .slideY(begin: 0.08, end: 0),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
