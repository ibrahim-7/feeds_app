import 'package:feed_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:feed_app/presentation/blocs/auth/auth_state.dart';
import 'package:feed_app/presentation/pages/feed/feed_page.dart';
import 'package:feed_app/presentation/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthAuthenticated) {
          return const FeedPage(); // or your Home page after login
        } else if (state is AuthLoggedOut || state is AuthInitial) {
          return const LoginPage();
        } else if (state is AuthError) {
          return const LoginPage(); // You can show error message here if needed
        } else {
          return const LoginPage(); // default fallback
        }
      },
    );
  }
}
