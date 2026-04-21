import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../Auth/ViewModel/auth_cubit.dart';
import '../../Auth/ViewModel/auth_state.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_menu_item.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthRestoring) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final authCubit = context.read<AuthCubit>();
            final user =
                authCubit.currentUser ?? (state is LoginSuccess ? state.user : null);

            final fullName = user?.fullName ?? 'Unknown';
            final disabilityType = user?.disabilityType ?? 'Unknown';

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 28,
                      bottom: 30,
                      left: 20,
                      right: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 58,
                              backgroundColor: Colors.black,
                              child: CircleAvatar(
                                radius: 56,
                                backgroundColor: Colors.grey.shade200,
                                child: Text(
                                  fullName.isNotEmpty
                                      ? fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          fullName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          disabilityType,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Account Section ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(title: 'Account'),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ProfileMenuItem(
                                icon: Icons.person,
                                title: "Personal Info",
                                iconColor: Colors.orange,
                                iconBg: Colors.orange.shade100,
                                ontap: () => context.push('/personal'),
                              ),
                              const SizedBox(height: 12),
                              ProfileMenuItem(
                                icon: Icons.book_online,
                                title: "My Bookings",
                                iconColor: Colors.deepPurple,
                                iconBg: Colors.deepPurple.shade100,
                                ontap: () => context.push('/my-bookings'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  // ── Support Section ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(title: 'Support'),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ProfileMenuItem(
                                icon: Icons.info_outline,
                                title: "App Guidelines",
                                iconColor: Colors.teal.shade100,
                                iconBg: Colors.teal,
                                ontap: () => context.go('/AppGuidelines'),
                              ),
                              const SizedBox(height: 12),
                              ProfileMenuItem(
                                icon: Icons.chat_bubble,
                                title: "Feedback",
                                iconColor: Colors.blue.shade100,
                                iconBg: Colors.blue,
                                ontap: () => context.push('/feedback'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  const ProfileLogoutButton(),
                  const SizedBox(height: 26),
                  const Center(
                    child: Text(
                      "«With you to discover your ability»",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}