import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateMapHeader extends StatelessWidget {
  const DelegateMapHeader({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
  });

  final int completedTasks;
  final int totalTasks;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (previous is AuthSuccess && current is AuthSuccess) {
          return previous.user.name != current.user.name;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, authState) {
        final userName =
            authState is AuthSuccess ? authState.user.name : 'مندوب';
        final initial = userName.isNotEmpty ? userName.characters.first : 'م';
        final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20.r(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w(context),
              vertical: 10.h(context),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                CircleAvatar(
                  radius: 20.s(context),
                  backgroundColor:
                      AppColors.thirdForest.withValues(alpha: 0.18),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: AppColors.primaryForest,
                      fontSize: 16.f(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primaryForest,
                          fontSize: 15.f(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h(context)),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r(context)),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6.h(context),
                                backgroundColor: AppColors.thirdGoldenWheat
                                    .withValues(alpha: 0.7),
                                color: AppColors.primaryForest,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w(context)),
                          Text(
                            '$completedTasks/$totalTasks',
                            style: TextStyle(
                              color: AppColors.primaryForest,
                              fontSize: 11.f(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w(context)),
                Material(
                  color: AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.push('/notifications'),
                    child: Padding(
                      padding: EdgeInsets.all(9.s(context)),
                      child: Icon(
                        AppIcons.notification,
                        color: AppColors.primaryForest,
                        size: 20.ic(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
