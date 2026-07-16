import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_profile_family_member_card.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_state.dart';
import 'package:baladeyate/features/profile/models/household.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_empty_state.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_hero_card.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_housing_card.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_section_header.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_stats_row.dart';
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
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          (previous is ProfileLoaded &&
              current is ProfileLoaded &&
              previous.household != current.household),
      builder: (context, profileState) {
        final household =
            profileState is ProfileLoaded ? profileState.household : null;
        final isLoading = profileState is ProfileLoading;
        final errorMessage =
            profileState is ProfileFailure ? profileState.message : null;

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
                          context.read<ProfileCubit>().loadHousehold(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16.h(context),
                          horizontalPadding,
                          30.h(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileHeroCard(familyBook: household?.familyBook)
                                .animate()
                                .fadeIn(duration: 350.ms)
                                .slideY(begin: -0.1, end: 0),
                            SizedBox(height: 20.h(context)),
                            ProfileStatsRow(
                              household: household,
                              isLoading: isLoading,
                            )
                                .animate()
                                .fadeIn(duration: 350.ms, delay: 80.ms)
                                .slideY(begin: 0.08, end: 0),
                            SizedBox(height: 20.h(context)),
                            ProfileHousingCard(
                              household: household,
                              isLoading: isLoading,
                              errorMessage: errorMessage,
                              onRetry: () =>
                                  context.read<ProfileCubit>().loadHousehold(),
                            )
                                .animate()
                                .fadeIn(duration: 350.ms, delay: 120.ms)
                                .slideY(begin: 0.08, end: 0),
                            SizedBox(height: 22.h(context)),
                            _buildMembersSection(
                              context,
                              household: household,
                              isLoading: isLoading,
                              errorMessage: errorMessage,
                            ),
                          ],
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

  Widget _buildMembersSection(
    BuildContext context, {
    required Household? household,
    required bool isLoading,
    required String? errorMessage,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (household == null) {
      return ProfileEmptyState(
        icon: Icons.people_outline_rounded,
        title: 'لا توجد بيانات عائلية',
        description: errorMessage ??
            'لم يتم العثور على بيانات الأسرة. اسحب للأسفل للتحديث.',
      );
    }

    final members = household.members;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileSectionHeader(
          title: 'أفراد الأسرة',
          badge: '${members.length} فرد',
        ),
        SizedBox(height: 16.h(context)),
        if (members.isEmpty)
          const ProfileEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'لا يوجد أفراد مسجّلون',
            description:
                'لم يتم العثور على أفراد في السجل العائلي المرتبط بحسابك.',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h(context)),
                child: CustomProfileFamilyMemberCard(
                  name: member.fullName,
                  nationalId: member.nationalId,
                  role: member.roleLabel,
                  initials: member.initials,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (40 * index).ms)
                  .slideY(begin: 0.08, end: 0);
            },
          ),
      ],
    );
  }
}
