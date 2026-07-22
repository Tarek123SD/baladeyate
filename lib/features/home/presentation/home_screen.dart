import 'package:baladeyate/features/auth/presentation/widgets/signup_success_dialog.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/home/models/update_model.dart';
import 'package:baladeyate/features/home/presentation/components/greeting_card.dart';
import 'package:baladeyate/features/home/presentation/components/section_header.dart';
import 'package:baladeyate/features/home/presentation/components/stats_overview.dart';
import 'package:baladeyate/features/home/presentation/components/verification_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'all';
  late List<UpdateModel> _updates;

  static const Map<String, String> _filterOptions = {
    'all': 'الكل',
    'transaction': 'المعاملات',
    'complaint': 'الشكاوى',
    'alert': 'تنبيهات',
  };

  @override
  void initState() {
    super.initState();
    _updates = List<UpdateModel>.from(dummyUpdatesList);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      maybeShowPendingSignupSuccessDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final paddingVal = Dimensions.pad(24, context);
    final filteredUpdates = _selectedFilter == 'all'
        ? _updates
        : _updates.where((u) => u.type == _selectedFilter).toList();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Dimensions.contentMaxWidth.w(context),
              ),
              child: CustomScrollView(
                slivers: [
                  // Top Section: Greeting, Verification, Stats, and Quick Services Header
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      paddingVal,
                      paddingVal,
                      paddingVal,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Hero banner + verification CTA
                          BlocBuilder<AuthCubit, AuthState>(
                            buildWhen: (previous, current) {
                              if (previous is AuthSuccess &&
                                  current is AuthSuccess) {
                                return previous.user.name !=
                                        current.user.name ||
                                    previous.user.verificationStatus !=
                                        current.user.verificationStatus;
                              }
                              return previous.runtimeType !=
                                  current.runtimeType;
                            },
                            builder: (context, state) {
                              final userName = state is AuthSuccess
                                  ? state.user.name
                                  : 'مواطن';
                              final statusLabel = state is AuthSuccess
                                  ? (state.user.verificationStatusLabel ??
                                      'حالة التوثيق غير معروفة')
                                  : 'سجّل الدخول لعرض حالتك';
                              final isVerified =
                                  state is AuthSuccess && state.user.isVerified;
                              final showVerification = state is AuthSuccess &&
                                  state.user.canSubmitVerification;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  GreetingCard(
                                    greeting: timeAwareGreeting(),
                                    name: 'أهلا بك، $userName',
                                    statusLabel: statusLabel,
                                    statusColor: isVerified
                                        ? Colors.amber
                                        : Colors.orange,
                                  ),
                                  if (showVerification) ...[
                                    SizedBox(height: 16.h(context)),
                                    VerificationBanner(
                                      wasRejected:
                                          state.user.verificationStatus ==
                                              'rejected',
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 32.h(context)),
                          // Complaint stats overview
                          BlocProvider(
                            create: (_) =>
                                sl<ComplaintsCubit>()..loadComplaints(),
                            child: const StatsOverview(),
                          ),
                          SizedBox(height: 32.h(context)),
                          // Quick Services Header
                          const SectionHeader(title: 'الخدمات السريعة'),
                          SizedBox(height: 16.h(context)),
                        ],
                      ),
                    ),
                  ),

                  // Quick Services SliverGrid
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingVal,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.s(context),
                        crossAxisSpacing: 16.s(context),
                        childAspectRatio: 1.1,
                      ),
                      delegate: SliverChildListDelegate(
                        [
                          _buildServiceCard(
                            title: 'تقديم معاملة',
                            icon: Icons.assignment_add,
                            onTap: () => context.push('/transactions/submit'),
                          ),
                          _buildServiceCard(
                            title: 'الوثائق الرقمية',
                            icon: Icons.qr_code_scanner,
                            onTap: () => context.push('/profile'),
                          ),
                          _buildServiceCard(
                            title: 'تقديم شكوى',
                            icon: Icons.campaign_outlined,
                            onTap: () => context.push('/complains'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Latest Updates Section Header & Filter Row
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      paddingVal,
                      32.h(context),
                      paddingVal,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader(
                            title: 'آخر التحديثات',
                            actionText: 'عرض الكل',
                            onActionTap: () => context.push('/notifications'),
                          ),
                          SizedBox(height: 12.h(context)),
                          _buildFilterChips(),
                          SizedBox(height: 16.h(context)),
                        ],
                      ),
                    ),
                  ),

                  // Dynamic Latest Updates SliverList or Empty State
                  if (filteredUpdates.isEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: paddingVal),
                      sliver: SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: paddingVal),
                      sliver: SliverList.builder(
                        itemCount: filteredUpdates.length,
                        itemBuilder: (context, index) {
                          return _buildDismissibleUpdateCard(
                            filteredUpdates[index],
                          );
                        },
                      ),
                    ),

                  // Heritage Section
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      paddingVal,
                      24.h(context),
                      paddingVal,
                      paddingVal,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.r(context)),
                            child: Stack(
                              children: [
                                Container(
                                  height: 200.h(context),
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        AppAssets.splashWallpaper,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.7),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    padding: EdgeInsets.all(16.s(context)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'تراثنا، هويتنا',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.f(context),
                                              ),
                                          textDirection: TextDirection.rtl,
                                        ),
                                        SizedBox(height: 4.h(context)),
                                        Text(
                                          'اكتشف المزيد عن الخدمات السياحية والثقافية للمدن الأثرية بمنصة المواطن',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.white70,
                                                fontSize: 12.f(context),
                                              ),
                                          textDirection: TextDirection.rtl,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Horizontal filter row containing ChoiceChips
  Widget _buildFilterChips() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filterOptions.entries.map((entry) {
          final isSelected = _selectedFilter == entry.key;
          return Padding(
            padding: EdgeInsets.only(left: 8.s(context)),
            child: ChoiceChip(
              label: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 13.f(context),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = entry.key;
                  });
                }
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.grey[200],
              elevation: isSelected ? 1 : 0,
              padding: EdgeInsets.symmetric(
                horizontal: 10.s(context),
                vertical: 6.s(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r(context)),
                side: BorderSide(
                  color: isSelected ? primaryColor : Colors.transparent,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Wrap card with Dismissible for swipe-to-remove animation
  Widget _buildDismissibleUpdateCard(UpdateModel update) {
    return Dismissible(
      key: ValueKey(update.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(bottom: 16.h(context)),
        padding: EdgeInsets.symmetric(horizontal: 20.s(context)),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(16.r(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'حذف',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.f(context),
              ),
            ),
            SizedBox(width: 8.w(context)),
            Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 24.ic(context),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        final removedIndex = _updates.indexWhere((e) => e.id == update.id);
        setState(() {
          _updates.removeWhere((e) => e.id == update.id);
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إزالة التحديث "${update.title}"',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 13.f(context)),
            ),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {
                setState(() {
                  if (removedIndex >= 0 && removedIndex <= _updates.length) {
                    _updates.insert(removedIndex, update);
                  } else {
                    _updates.add(update);
                  }
                });
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      },
      child: _buildUpdateCard(update),
    );
  }

  /// Material 3 Update Card component
  Widget _buildUpdateCard(UpdateModel update) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (update.type) {
      case 'transaction':
        icon = Icons.check_circle_outline;
        iconColor = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'complaint':
        icon = Icons.radar_outlined;
        iconColor = const Color(0xFF1565C0);
        bgColor = const Color(0xFFE3F2FD);
        break;
      case 'alert':
      default:
        icon = Icons.campaign_outlined;
        iconColor = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        break;
    }

    final String ctaText =
        update.type == 'transaction' ? 'تحميل الوثيقة' : 'عرض التفاصيل';

    return Card(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r(context)),
        side: BorderSide(
          color: Colors.grey.withValues(alpha: 0.15),
          width: 0.8.w(context),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.s(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored Circular Container (Icon)
                Container(
                  width: 48.s(context),
                  height: 48.s(context),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24.ic(context),
                  ),
                ),
                SizedBox(width: 16.w(context)),
                // Text Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Title & Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              update.title,
                              style: TextStyle(
                                fontSize: 14.f(context),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF212121),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 8.w(context)),
                          Text(
                            update.date,
                            style: TextStyle(
                              fontSize: 11.f(context),
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h(context)),
                      // Subtitle
                      Text(
                        update.subtitle,
                        style: TextStyle(
                          fontSize: 12.f(context),
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (update.hasAction) ...[
              SizedBox(height: 12.h(context)),
              Divider(
                height: 1.h(context),
                thickness: 0.6,
                color: Colors.grey[200],
              ),
              SizedBox(height: 8.h(context)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: () {
                    // Navigate to details if needed
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.s(context),
                      vertical: 4.s(context),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.chevron_left,
                    size: 18.ic(context),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    ctaText,
                    style: TextStyle(
                      fontSize: 12.f(context),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Empty state widget when filter yields no updates
  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36.h(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.s(context)),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 64.ic(context),
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 16.h(context)),
          Text(
            'لا توجد تحديثات حالياً',
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 4.h(context)),
          Text(
            'تأكد من اختيار تصنيف آخر أو تفقد الإشعارات لاحقاً',
            style: TextStyle(
              fontSize: 12.f(context),
              color: Colors.grey[400],
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color.fromARGB(255, 245, 243, 243),
      surfaceTintColor: Colors.white,
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56.w(context),
              height: 56.h(context),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0B4D3C),
                size: 28.ic(context),
              ),
            ),
            SizedBox(height: 12.h(context)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.s(context)),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF212121),
                  fontSize: 15.f(context),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
