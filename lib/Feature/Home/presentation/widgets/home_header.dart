import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/Styles/AppTextsyles.dart';
import '../../../Auth/ViewModel/auth_cubit.dart';
import '../../../Auth/ViewModel/auth_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();

        // Read current user from cubit first, then fallback to login state
        final user =
            authCubit.currentUser ?? (state is LoginSuccess ? state.user : null);

        final firstName = user?.fullName.trim().split(' ').first ?? 'Friend';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Welcome text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: AppTextStyles.title.copyWith(
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),

                // Show real user first name
                Text(
                  'Hello, $firstName',
                  style: AppTextStyles.subtitle.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),


          ],
        );
      },
    );
  }
}