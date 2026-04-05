import 'package:flutter/material.dart';

import '../services/emergency_location_service.dart';
import '../services/emergency_profile_service.dart';
import '../viewmodel/emergency_entry_viewmodel.dart';
import '../viewmodel/emergency_profile_setup_viewmodel.dart';
import 'emergency_profile_setup_view.dart';
import 'permission_empty_states_view.dart';

class EmergencyEntryView extends StatefulWidget {
  const EmergencyEntryView({
    super.key,
    this.mainScreenBuilder,
  });

  final WidgetBuilder? mainScreenBuilder;

  @override
  State<EmergencyEntryView> createState() => _EmergencyEntryViewState();
}

class _EmergencyEntryViewState extends State<EmergencyEntryView>
    with WidgetsBindingObserver {
  late final EmergencyEntryViewModel _viewModel;

  bool _isOpeningProfileSetup = false;
  bool _shouldRefreshOnResume = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _viewModel = EmergencyEntryViewModel(
      profileService: EmergencyProfileService(),
      locationService: EmergencyLocationService(),
    );

    _viewModel.initialize();

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _shouldRefreshOnResume) {
      _shouldRefreshOnResume = false;
      _viewModel.refreshEntryFlow();
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openProfileSetup() async {
    if (_isOpeningProfileSetup || !mounted) return;

    _isOpeningProfileSetup = true;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) {
          final setupViewModel = EmergencyProfileSetupViewModel(
            profileService: EmergencyProfileService(),
          );

          return EmergencyProfileSetupView(
            viewModel: setupViewModel,
            onSavedSuccessfully: () async {
              Navigator.of(routeContext).pop(true);
            },
          );
        },
      ),
    );

    _isOpeningProfileSetup = false;

    if (!mounted) return;
    await _viewModel.refreshEntryFlow();
  }

  void _handleNavigation(EmergencyEntryStatus status) {
    if (status == EmergencyEntryStatus.needProfileSetup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openProfileSetup();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          _handleNavigation(_viewModel.status);

          switch (_viewModel.status) {
            case EmergencyEntryStatus.loading:
              return const Scaffold(
                backgroundColor: Color(0xFFF6F7F9),
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );

            case EmergencyEntryStatus.needProfileSetup:
              return const Scaffold(
                backgroundColor: Color(0xFFF6F7F9),
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );

            case EmergencyEntryStatus.needLocationPermission:
              return PermissionEmptyStatesView(
                isLoading: _viewModel.isRequestingPermission,
                helperMessage: _viewModel.permissionHelperMessage,
                showOpenLocationSettingsButton:
                _viewModel.isLocationServiceDisabled,
                onEnableLocationPressed: () async {
                  await _viewModel.requestLocationPermission();
                },
                onOpenLocationSettingsPressed: () async {
                  _shouldRefreshOnResume = true;
                  await _viewModel.openLocationSettings();
                },
                onSkipPressed: () {
                  _viewModel.skipLocationForNow();
                },
              );

            case EmergencyEntryStatus.ready:
              if (widget.mainScreenBuilder != null) {
                // ✅ بدل pushReplacement: اعرض الشاشة الرئيسية مباشرة
                return widget.mainScreenBuilder!(context);
              }

              return Scaffold(
                backgroundColor: const Color(0xFFF6F7F9),
                appBar: AppBar(
                  backgroundColor: const Color(0xFFF6F7F9),
                  elevation: 0,
                  surfaceTintColor: const Color(0xFFF6F7F9),
                  centerTitle: true,
                  title: const Text(
                    'الطوارئ',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                body: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'تم اجتياز Phase 2 بنجاح.\nاربط هنا الشاشة الرئيسية في Phase 3.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              );

            case EmergencyEntryStatus.error:
              return Scaffold(
                backgroundColor: const Color(0xFFF6F7F9),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _viewModel.errorMessage ?? 'حدث خطأ غير متوقع.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            await _viewModel.refreshEntryFlow();
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}