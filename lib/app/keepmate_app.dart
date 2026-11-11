import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/database/app_database.dart';
import '../core/design_system/app_theme.dart';
import '../core/notifications/notification_service.dart';
import '../core/services/lost_data_service.dart';
import '../features/settings/cubit/settings_cubit.dart';
import '../features/settings/cubit/settings_state.dart';
import '../shared/widgets/app_toast.dart';
import '../state_injector.dart';
import 'router/app_router.dart';

class KeepMateApp extends StatefulWidget {
  final AppDatabase database;
  final NotificationService notificationService;
  final GoRouter? router;

  const KeepMateApp({
    super.key,
    required this.database,
    required this.notificationService,
    this.router,
  });

  @override
  State<KeepMateApp> createState() => _KeepMateAppState();
}

class _KeepMateAppState extends State<KeepMateApp> {
  late final GoRouter _router = widget.router ?? createRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRecoveredMedia();
    });
  }

  Future<void> _checkRecoveredMedia() async {
    final file = await LostDataService.instance.checkAndRecoverLostData();
    if (file != null && mounted) {
      final navContext = rootNavigatorKey.currentContext;
      if (navContext != null && navContext.mounted) {
        showToast(
          navContext,
          'Camera photo recovered successfully!',
          type: ToastType.success,
          icon: Icons.check_circle_rounded,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: AppStateInjector.repositoryProviders(
        database: widget.database,
        notificationService: widget.notificationService,
      ),
      child: MultiBlocProvider(
        providers: AppStateInjector.blocProviders,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: settingsState.themeMode,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}

