import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/admin/cubits/graves_cubit/graves_cubit.dart';
import 'package:baladeyate/features/admin/cubits/graves_cubit/graves_state.dart';
import 'package:baladeyate/features/admin/presentation/components/grave_card.dart';
import 'package:baladeyate/features/admin/presentation/components/graves_search_empty_state.dart';
import 'package:baladeyate/features/admin/presentation/components/graves_search_error_state.dart';
import 'package:baladeyate/features/admin/presentation/components/graves_search_header.dart';
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
                        child: GravesSearchHeader(
                          controller: _searchController,
                          onChanged: context.read<GravesCubit>().updateQuery,
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
      return GravesSearchErrorState(
        message: state.message,
        onRetry: () => context.read<GravesCubit>().loadGraves(),
      );
    }

    if (state is! GravesLoaded) {
      return const SizedBox.shrink();
    }

    final graves = state.filteredGraves;
    if (graves.isEmpty) {
      return GravesSearchEmptyState(hasQuery: state.query.isNotEmpty);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<GravesCubit>().loadGraves(),
      child: ListView.separated(
        padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
        itemCount: graves.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h(context)),
        itemBuilder: (context, index) => GraveCard(grave: graves[index]),
      ),
    );
  }
}
