import 'package:feed_app/domain/repo/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.login(event.email, event.password);
      await authRepository.saveToken(token);
      emit(AuthAuthenticated(token));
    } catch (_) {
      emit(AuthError("Invalid email or password"));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    final token = await authRepository.getToken();
    if (token != null) {
      emit(AuthAuthenticated(token));
    } else {
      emit(AuthLoggedOut());
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.clearToken();
    emit(AuthLoggedOut());
  }
}
