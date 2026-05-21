import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/repo/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial());

  final AuthRepository _authRepository;

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
