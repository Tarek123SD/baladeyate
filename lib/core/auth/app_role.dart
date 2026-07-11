import 'package:baladeyate/features/auth/models/user.dart';

enum AppRole {
  citizen,
  delegate,
  admin;

  String get homeRoute => switch (this) {
        AppRole.citizen => '/main',
        AppRole.delegate || AppRole.admin => '/delegate/home',
      };

  bool get isCitizen => this == AppRole.citizen;

  bool get isDelegateLike => this == AppRole.delegate || this == AppRole.admin;
}

AppRole appRoleFromString(String? role) {
  return switch (role?.toLowerCase()) {
    'delegate' => AppRole.delegate,
    'admin' => AppRole.admin,
    _ => AppRole.citizen,
  };
}

extension UserRoleX on User {
  AppRole get appRole => appRoleFromString(role);

  bool get isCitizen => appRole.isCitizen;

  bool get isDelegateLike => appRole.isDelegateLike;
}
