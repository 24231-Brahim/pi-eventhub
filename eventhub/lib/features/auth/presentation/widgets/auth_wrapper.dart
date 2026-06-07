import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';

class AuthWrapper extends StatelessWidget {
  final Widget authenticatedChild;
  const AuthWrapper({super.key, required this.authenticatedChild});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return authenticatedChild;
        }
        return const SizedBox();
      },
    );
  }
}
