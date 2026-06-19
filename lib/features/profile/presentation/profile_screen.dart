import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_profile_family_member_card.dart';
import 'package:baladeyate/core/widgets/custom_profile_tab_button.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_state.dart';
import 'package:baladeyate/features/profile/models/household.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTab = 0;

  static const _memberColors = [
    Color(0xFFB8956A),
    Color(0xFFA0C9C3),
    Color(0xFFF4D9B8),
    Color(0xFF8FB8AE),
  ];

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.isMobile ? 16.w(context) : 24.w(context);

    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..loadHousehold(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, profileState) {
          final household =
              profileState is ProfileLoaded ? profileState.household : null;
          final isLoading = profileState is ProfileLoading;
          final errorMessage =
              profileState is ProfileFailure ? profileState.message : null;

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundWhite),
                fit: BoxFit.cover,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: const CustomAppBar(),
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: () =>
                      context.read<ProfileCubit>().loadHousehold(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeaderCard(context, household),
                        Transform.translate(
                          offset: Offset(0, -30.h(context)),
                          child: _buildAddressCard(
                            context,
                            horizontalPadding: horizontalPadding,
                            household: household,
                            isLoading: isLoading,
                            errorMessage: errorMessage,
                          ),
                        ),
                        SizedBox(height: 20.h(context)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Row(
                            children: [
                              CustomProfileTabButton(
                                label: 'الرقبة العائلية',
                                isSelected: selectedTab == 0,
                                onTap: () => setState(() => selectedTab = 0),
                              ),
                              SizedBox(width: 12.w(context)),
                              CustomProfileTabButton(
                                label: 'العقارات',
                                isSelected: selectedTab == 1,
                                onTap: () => setState(() => selectedTab = 1),
                              ),
                              SizedBox(width: 12.w(context)),
                              CustomProfileTabButton(
                                label: 'المدافن',
                                isSelected: selectedTab == 2,
                                onTap: () => setState(() => selectedTab = 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h(context)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: _buildTabContent(
                            context,
                            household: household,
                            isLoading: isLoading,
                            errorMessage: errorMessage,
                          ),
                        ),
                        SizedBox(height: 30.h(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Household? household) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5FA89D), Color(0xFF7BC9B8)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 24.w(context),
        vertical: 35.h(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            ' الملف الرقمي الموحد ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryCharcoal,
                ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'البطاقة العائلية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 8.h(context)),
          Text(
            household?.familyBook ?? '—',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required double horizontalPadding,
    required Household? household,
    required bool isLoading,
    required String? errorMessage,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.s(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'بيانات السكن',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(width: 8.w(context)),
              Icon(Icons.home, color: Colors.amber, size: 20.ic(context)),
            ],
          ),
          if (isLoading) ...[
            SizedBox(height: 20.h(context)),
            const Center(child: CircularProgressIndicator()),
          ] else if (errorMessage != null) ...[
            SizedBox(height: 16.h(context)),
            Text(
              errorMessage,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryCharcoal,
                    height: 1.5,
                  ),
            ),
          ] else ...[
            SizedBox(height: 16.h(context)),
            Row(
              children: [
                Expanded(
                  child: _infoTile(
                    context,
                    title: 'الهيئة / المقر',
                    value: household?.buildingName ?? '—',
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: _infoTile(
                    context,
                    title: 'الشارع / الحي',
                    value: household?.address ?? '—',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16.r(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 8.h(context)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context, {
    required Household? household,
    required bool isLoading,
    required String? errorMessage,
  }) {
    if (selectedTab != 0) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h(context)),
          child: Text(
            'لا توجد بيانات متاحة من الخادم لهذا القسم حالياً',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (household == null) {
      return Text(
        errorMessage ?? 'لا توجد بيانات عائلية متاحة',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      );
    }

    final members = household.members;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'الأسرة المسجلين',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 16.h(context)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 8.h(context),
          ),
          decoration: BoxDecoration(
            color: Colors.teal[200],
            borderRadius: BorderRadius.circular(20.r(context)),
          ),
          child: Text(
            '${members.length} أفراد',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.teal[800],
                  fontWeight: FontWeight.w600,
                ),
            textDirection: TextDirection.rtl,
          ),
        ),
        SizedBox(height: 16.h(context)),
        ...members.asMap().entries.map((entry) {
          final member = entry.value;
          final color = _memberColors[entry.key % _memberColors.length];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h(context)),
            child: CustomProfileFamilyMemberCard(
              member: {
                'name': member.fullName,
                'number': '${member.nationalId} : الرقم الوطني',
                'role': member.roleLabel,
                'image': member.initials,
                'bgColor': color,
              },
            ),
          );
        }),
      ],
    );
  }
}
