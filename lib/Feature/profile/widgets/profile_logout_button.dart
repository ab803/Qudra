import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: dangerColor.withOpacity(
                theme.brightness == Brightness.dark ? 0.16 : 0.08,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: dangerColor.withOpacity(0.20),
              ),
            ),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: isLoading ? null : () => context.read<AuthCubit>().logout(),
              icon: isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: dangerColor,
                  strokeWidth: 2.5,
                ),
              )
                  : Icon(Icons.logout_rounded, color: dangerColor),
              label: Text(
                context.tr("log_out"),
                style: TextStyle(
                  color: dangerColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}