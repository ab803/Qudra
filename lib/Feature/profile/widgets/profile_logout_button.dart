import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/Styles/AppColors.dart';
import '../../Auth/ViewModel/auth_cubit.dart';
import '../../Auth/ViewModel/auth_state.dart';

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          // ✅ Navigate to login and clear the stack
          context.go('/login');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final dangerColor = Appcolors.EmergancyColor;

          return Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: dangerColor.withOpacity(
                theme.brightness == Brightness.dark ? 0.18 : 0.10,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: dangerColor.withOpacity(0.35),
              ),
            ),
            child: TextButton.icon(
              onPressed:
              isLoading ? null : () => context.read<AuthCubit>().logout(),
              icon: isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: dangerColor,
                  strokeWidth: 2.5,
                ),
              )
                  : Icon(Icons.logout, color: dangerColor),
              label: Text(
                "Log Out",
                style: TextStyle(
                  color: dangerColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}