import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/admin/cubits/graves_cubit/graves_cubit.dart';
import 'package:baladeyate/features/admin/cubits/graves_cubit/graves_state.dart';
import 'package:baladeyate/features/admin/models/grave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class GravesSearchScreen extends StatefulWidget {
  const GravesSearchScreen({super.key});

  @override
  State<GravesSearchScreen> createState() => _GravesSearchScreenState();
}

class _GravesSearchScreenState extends State<GravesSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Dimensions.contentMaxWidth.w(context),
              ),
              child: BlocBuilder<GravesCubit, GravesState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16.h(context),
                          horizontalPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'البحث في المدافن',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppColors.primaryForest,
                                fontSize: 22.f(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 16.h(context)),
                            TextField(
                              controller: _searchController,
                              textDirection: TextDirection.rtl,
                              onChanged: context.read<GravesCubit>().updateQuery,
                              decoration: InputDecoration(
                                hintText: 'ابحث برقم القبر أو القطعة أو الحالة',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(14.r(context)),
                                  borderSide: BorderSide(
                                    color: AppColors.secondaryCharcoal
                                        .withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _buildBody(context, state)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GravesState state) {
    if (state is GravesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GravesFailure) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.s(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.message,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.secondaryCharcoal.withValues(alpha: 0.8),
                  fontSize: 14.f(context),
                ),
              ),
              SizedBox(height: 16.h(context)),
              TextButton(
                onPressed: () => context.read<GravesCubit>().loadGraves(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is! GravesLoaded) {
      return const SizedBox.shrink();
    }

    final graves = state.filteredGraves;
    if (graves.isEmpty) {
      return Center(
        child: Text(
          state.query.isEmpty
              ? 'لا توجد سجلات مدافن.'
              : 'لا توجد نتائج مطابقة لبحثك.',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
            fontSize: 14.f(context),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<GravesCubit>().loadGraves(),
      child: ListView.separated(
        padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
        itemCount: graves.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h(context)),
        itemBuilder: (context, index) => _GraveCard(grave: graves[index]),
      ),
    );
  }
}

class _GraveCard extends StatelessWidget {
  const _GraveCard({required this.grave});

  final Grave grave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.secondaryCharcoal.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            grave.displayTitle,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 15.f(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'الحالة: ${grave.displayStatus}',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
              fontSize: 13.f(context),
            ),
          ),
          if (grave.familyId != null) ...[
            SizedBox(height: 4.h(context)),
            Text(
              'معرّف العائلة: ${grave.familyId}',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.65),
                fontSize: 12.f(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
