import 'package:baladeyate/core/auth/app_role.dart';
import 'package:baladeyate/core/auth/delegate_work_scope.dart';
import 'package:baladeyate/core/navigation/delegate_navigation_screen.dart';
import 'package:baladeyate/core/navigation/main_navigation_screen.dart';

import 'package:baladeyate/core/services/service_locator.dart';

import 'package:baladeyate/features/admin/presentation/graves_search_screen.dart';
import 'package:baladeyate/features/delegate/presentation/apartment_screen.dart';

import 'package:baladeyate/features/admin/cubits/graves_cubit/graves_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';

import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';

import 'package:baladeyate/features/auth/presentation/forgot_password_screen.dart';
import 'package:baladeyate/features/auth/presentation/reset_password_screen.dart';
import 'package:baladeyate/features/auth/cubits/auth_form_cubit/auth_form_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';

import 'package:baladeyate/features/auth/presentation/auth_screen.dart';

import 'package:baladeyate/features/auth/presentation/signup_screen.dart';

import 'package:baladeyate/features/auth/presentation/splash_screen.dart';

import 'package:baladeyate/features/delegate/presentation/building_complex_screen.dart';

import 'package:baladeyate/features/delegate/presentation/building_hub_screen.dart';

import 'package:baladeyate/features/delegate/presentation/floor_hub_screen.dart';

import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';

import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/presentation/complaints_guard_screen.dart';
import 'package:baladeyate/features/complaints/presentation/delegate_complaint_details_screen.dart';
import 'package:baladeyate/features/complaints/presentation/delegate_complaints_screen.dart';

import 'package:baladeyate/features/complaints/presentation/identity_verification_screen.dart';

import 'package:baladeyate/features/complaints/presentation/track_complaints_screen.dart';
import 'package:baladeyate/core/widgets/custom_complaint_map_box.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:baladeyate/features/cemetery_map/cubits/cemetery_map_cubit/cemetery_map_cubit.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:baladeyate/features/cemetery_map/presentation/cemetery_map_screen.dart';
import 'package:baladeyate/features/cemetery_reservation/cubits/grave_reservations_cubit/grave_reservations_cubit.dart';
import 'package:baladeyate/features/cemetery_reservation/cubits/reserve_grave_cubit/reserve_grave_cubit.dart';
import 'package:baladeyate/features/cemetery_reservation/presentation/citizen_cemetery_map_screen.dart';
import 'package:baladeyate/features/cemetery_reservation/presentation/grave_reservation_form_screen.dart';
import 'package:baladeyate/features/cemetery_reservation/presentation/my_grave_reservations_screen.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';

import 'package:baladeyate/features/digital_documents/presentation/document_scanner_screen.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';


import 'package:baladeyate/features/delegate/models/survey_location.dart';

import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';

import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_cubit.dart';
import 'package:baladeyate/features/donations/models/donation_case.dart';
import 'package:baladeyate/features/donations/presentation/donation_payment_screen.dart';
import 'package:baladeyate/features/donations/presentation/donations_screen.dart';

import 'package:baladeyate/features/delegate/presentation/floor_screen.dart';

import 'package:baladeyate/features/home/presentation/home_screen.dart';

import 'package:baladeyate/features/notifications/presentation/notifications_screen.dart';

import 'package:baladeyate/features/delegate/presentation/people_screen.dart';

import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';

import 'package:baladeyate/features/profile/presentation/profile_screen.dart';
import 'package:baladeyate/features/transactions/cubits/submit_transaction_cubit/submit_transaction_cubit.dart';
import 'package:baladeyate/features/transactions/cubits/transactions_cubit/transactions_cubit.dart';
import 'package:baladeyate/features/transactions/presentation/delegate_transactions_screen.dart';
import 'package:baladeyate/features/transactions/presentation/submit_transaction_screen.dart';
import 'package:baladeyate/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:baladeyate/features/transactions/presentation/transactions_screen.dart';
import 'package:baladeyate/features/digital_documents/cubits/digital_documents_cubit/digital_documents_cubit.dart';
import 'package:baladeyate/features/digital_documents/presentation/digital_documents_screen.dart';

import 'package:baladeyate/features/settings/presentation/privacy_policy_screen.dart';
import 'package:baladeyate/features/settings/presentation/settings_screen.dart';

import 'package:baladeyate/features/daily_tasks/presentation/delegate_map_screen.dart';
import 'package:baladeyate/features/daily_tasks/presentation/delegate_tasks_screen.dart';
import 'package:baladeyate/features/daily_tasks/presentation/delegate_buildings_screen.dart';
import 'package:baladeyate/features/delegate_home/presentation/delegate_home_screen.dart';

import 'package:baladeyate/routes/app_route_observer.dart';

import 'package:baladeyate/routes/auth_navigation.dart';

import 'package:baladeyate/routes/auth_refresh_notifier.dart';

import 'package:baladeyate/routes/navigation_logger.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';



final _authRefreshNotifier = AuthRefreshNotifier(sl<AuthCubit>());



final GoRouter appRouter = _createAppRouter();



GoRouter _createAppRouter() {

  final router = GoRouter(

    initialLocation: '/splash',

    debugLogDiagnostics: kDebugMode,

    observers: [appRouteObserver],

    refreshListenable: _authRefreshNotifier,

    redirect: _authRedirect,

    routes: [

      GoRoute(

        path: '/splash',

        builder: (context, state) => const SplashScreen(),

      ),

      GoRoute(

        path: '/settings',

        builder: (context, state) => BlocProvider(

          create: (_) => sl<ProfileCubit>(),

          child: const SettingsScreen(),

        ),

      ),

      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      GoRoute(

        path: '/verify-identity',

        builder: (context, state) {

          final authState = sl<AuthCubit>().state;

          final user = authState is AuthSuccess ? authState.user : null;

          return BlocProvider(

            create: (_) => sl<ProfileCubit>(),

            child: IdentityVerificationScreen(

              promptText:

                  'يرجى توثيق هويتك الوطنية لإرسال طلب المراجعة الحكومية.',

              initialNationalId: user?.nationalId ?? user?.nationalNumber,

            ),

          );

        },

      ),

      GoRoute(

        path: '/forgot-password',

        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final fromSettings = state.uri.queryParameters['fromSettings'] == '1';

          return BlocProvider(

            create: (_) => sl<PasswordResetCubit>(),

            child: ForgotPasswordScreen(
              initialEmail: email,
              fromSettings: fromSettings,
            ),

          );
        },

      ),

      GoRoute(

        path: '/reset-password',

        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final fromSettings = state.uri.queryParameters['fromSettings'] == '1';

          return BlocProvider(

            create: (_) => sl<PasswordResetCubit>(),

            child: ResetPasswordScreen(
              initialEmail: email,
              fromSettings: fromSettings,
            ),

          );
        },

      ),

      GoRoute(

        path: '/login',

        builder: (context, state) => BlocProvider(

          create: (_) => sl<AuthFormCubit>(),

          child: const AuthScreen(),

        ),

      ),

      GoRoute(

        path: '/signup',

        builder: (context, state) => BlocProvider(

          create: (_) => sl<AuthFormCubit>(),

          child: const SignupScreen(),

        ),

      ),

      GoRoute(

        path: '/graves',

        builder: (context, state) => BlocProvider(

          create: (_) => sl<GravesCubit>()..loadGraves(),

          child: const GravesSearchScreen(),

        ),

      ),

      GoRoute(
        path: '/transactions/submit',
        builder: (context, state) {
          final buildingIdParam = state.uri.queryParameters['buildingId'];
          final buildingId = buildingIdParam == null
              ? null
              : int.tryParse(buildingIdParam);
          return BlocProvider(
            create: (_) => sl<SubmitTransactionCubit>(),
            child: SubmitTransactionScreen(buildingId: buildingId),
          );
        },
      ),

      GoRoute(
        path: '/transactions/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return TransactionDetailScreen(transactionId: id);
        },
      ),

      GoRoute(
        path: '/digital-documents',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<DigitalDocumentsCubit>()..fetchDigitalDocuments(),
          child: const DigitalDocumentsScreen(),
        ),
      ),

      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Outside the delegate shell — must be pushable from notifications
      // without duplicating StatefulShellRoute GlobalKeys.
      GoRoute(
        path: '/delegate/transactions',
        builder: (context, state) => const DelegateTransactionsScreen(),
      ),

      GoRoute(
        path: '/delegate/complaints',
        builder: (context, state) => const DelegateComplaintsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              final extra = state.extra;
              return DelegateComplaintDetailsScreen(
                complaintId: id,
                initialComplaint: extra is Complaint ? extra : null,
              );
            },
          ),
        ],
      ),

      GoRoute(
        path: '/complains',

        builder: (context, state) => MultiBlocProvider(

          providers: [

            BlocProvider(create: (_) => sl<ComplaintsCubit>()),

            BlocProvider(create: (_) => sl<ProfileCubit>()),

          ],

          child: const ComplaintsGuardScreen(),

        ),

        routes: [
          GoRoute(
            path: 'map-picker',
            builder: (context, state) {
              final extra = state.extra;
              final initialLocation = extra is LatLng ? extra : null;
              return MapPickerScreen(initialLocation: initialLocation);
            },
          ),
        ],

      ),

      GoRoute(
        path: '/cemetery/map',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CemeteryMapCubit>(),
          child: const CitizenCemeteryMapScreen(),
        ),
      ),
      GoRoute(
        path: '/cemetery/reservations',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<GraveReservationsCubit>(),
          child: const MyGraveReservationsScreen(),
        ),
      ),
      GoRoute(
        path: '/cemetery/reserve',
        builder: (context, state) {
          final extra = state.extra;
          final grave = extra is GraveModel ? extra : null;
          if (grave == null) {
            return const Scaffold(
              body: Center(child: Text('لم يتم تحديد قبر')),
            );
          }
          return BlocProvider(
            create: (_) => sl<ReserveGraveCubit>(),
            child: GraveReservationFormScreen(grave: grave),
          );
        },
      ),

      GoRoute(

        path: '/tasks',

        redirect: (_, __) => '/delegate/tasks',

      ),

      GoRoute(

        path: '/info',

        builder: (context, state) {

          final location = state.extra is SurveyLocation

              ? state.extra! as SurveyLocation

              : null;



          return BlocProvider(

            create: (_) {

              final cubit = sl<BuildingSurveyCubit>();

              if (location != null) {

                cubit.initFromPin(location);

              }

              return cubit;

            },

            child: BuildingComplexScreen(surveyLocation: location),

          );

        },

      ),

      GoRoute(

        path: '/building/:pinId',

        builder: (context, state) {

          final pinId = state.pathParameters['pinId']!;



          return BlocProvider(

            create: (_) => sl<BuildingSurveyCubit>()..loadSurvey(pinId),

            child: BuildingHubScreen(pinId: pinId),

          );

        },

        routes: [

          GoRoute(

            path: 'floor/:floorLocalId',

            builder: (context, state) {

              final pinId = state.pathParameters['pinId']!;

              final floorLocalId = state.pathParameters['floorLocalId']!;



              return BlocProvider(

                create: (_) => sl<BuildingSurveyCubit>()..loadSurvey(pinId),

                child: FloorHubScreen(

                  pinId: pinId,

                  floorLocalId: floorLocalId,

                ),

              );

            },

          ),

        ],

      ),

      GoRoute(

        path: '/floor',

        builder: (context, state) {

          final nav = state.extra is SurveyNavigationContext

              ? state.extra! as SurveyNavigationContext

              : null;



          return BlocProvider(

            create: (_) {

              final cubit = sl<BuildingSurveyCubit>();

              if (nav != null) {

                cubit.loadSurvey(nav.pinId);

              }

              return cubit;

            },

            child: FloorScreen(navigationContext: nav),

          );

        },

      ),

      GoRoute(

        path: '/apartment',

        builder: (context, state) {

          final nav = state.extra is SurveyNavigationContext

              ? state.extra! as SurveyNavigationContext

              : null;



          return BlocProvider(

            create: (_) {

              final cubit = sl<BuildingSurveyCubit>();

              if (nav != null) {

                cubit.loadSurvey(nav.pinId);

              }

              return cubit;

            },

            child: ApartmentScreen(
              navigationContext: nav,
              apartmentsCount: nav?.apartmentsCount ?? 0,
            ),

          );

        },

      ),

      GoRoute(

        path: '/people',

        builder: (context, state) {

          final nav = state.extra is SurveyNavigationContext

              ? state.extra! as SurveyNavigationContext

              : null;



          return BlocProvider(

            create: (_) {

              final cubit = sl<BuildingSurveyCubit>();

              if (nav != null) {

                cubit.loadSurvey(nav.pinId);

              }

              return cubit;

            },

            child: PeopleScreen(navigationContext: nav),

          );

        },

      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final cubit = sl<DailyTasksCubit>()..initialize();
          return BlocProvider.value(
            value: cubit,
            child: DelegateNavigationScreen(
              navigationShell: navigationShell,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/delegate/home',
                builder: (context, state) => const DelegateHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'verify-document',
                    builder: (context, state) => const DocumentScannerScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: '/delegate/verify-document',
                builder: (context, state) => const DocumentScannerScreen(),
              ),
              GoRoute(
                path: '/delegate/cemetery-map',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<CemeteryMapCubit>()..loadGraves(),
                  child: const CemeteryMapScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/delegate/tasks',
                builder: (context, state) => const DelegateTasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/delegate/map',
                builder: (context, state) => const DelegateMapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/delegate/buildings',
                builder: (context, state) => const DelegateBuildingsScreen(),
              ),
            ],
          ),
        ],
      ),

      StatefulShellRoute.indexedStack(

        builder: (context, state, navigationShell) {

          return MainNavigationScreen(

            navigationShell: navigationShell,

          );

        },

        branches: [

          StatefulShellBranch(

            routes: [

              GoRoute(

                path: '/main',

                builder: (context, state) => const HomeScreen(),

              ),

            ],

          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<TransactionsCubit>()..fetchTransactions(),
                  child: const TransactionsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/track',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<ComplaintsCubit>()..loadComplaints(),
                  child: const TrackComplaintsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(

            routes: [

              GoRoute(

                path: '/donations',

                builder: (context, state) => BlocProvider(
                  create: (_) => sl<DonationsCubit>()..loadCases(),
                  child: const DonationsScreen(),
                ),

                routes: [
                  GoRoute(
                    path: 'pay',
                    builder: (context, state) {
                      final extra = state.extra;
                      final donationCase = extra is DonationCase ? extra : null;
                      final campaignTitle = extra is String ? extra : null;
                      return BlocProvider(
                        create: (_) => sl<DonateCubit>(),
                        child: DonationPaymentScreen(
                          donationCase: donationCase,
                          campaignTitle: campaignTitle,
                        ),
                      );
                    },
                  ),
                ],

              ),

            ],

          ),

          StatefulShellBranch(

            routes: [

              GoRoute(

                path: '/profile',

                builder: (context, state) => BlocProvider(

                  create: (_) => sl<ProfileCubit>()..loadProfile(),

                  child: const ProfileScreen(),

                ),

              ),

            ],

          ),
        ],

      ),

    ],

  );



  NavigationLogger.attach(router);

  return router;

}



String? _authRedirect(BuildContext context, GoRouterState state) {

  final authState = sl<AuthCubit>().state;

  final path = state.uri.path;



  if (authState is AuthInitial) {

    if (isPublicRoute(path)) return null;

    return '/splash';

  }



  // Logout (and other in-app auth actions) emit AuthLoading while the user is

  // on a protected route — send them to login, not splash, to avoid re-running

  // session restore and briefly landing back on home.

  if (authState is AuthLoading) {

    if (isPublicRoute(path)) return null;

    return '/login';

  }



  if (authState is! AuthSuccess) {

    if (isPublicRoute(path)) return null;

    return '/login';

  }



  final user = authState.user;

  final home = homeRouteFor(user);



  if (path == '/login' || path == '/signup') {

    return home;

  }



  if (user.isCitizen && isDelegateRoute(path)) {

    return '/main';

  }



  if (user.isDelegateLike && (isCitizenRoute(path) || path == '/signup')) {

    return '/delegate/home';

  }

  if (user.isDelegateLike && isDelegateRoute(path) && !user.canAccessDelegatePath(path)) {
    return '/delegate/home';
  }


  return null;

}


