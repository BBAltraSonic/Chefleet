import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/blocs/app_bloc_observer.dart';
import 'core/blocs/navigation_bloc.dart';
import 'core/blocs/role_bloc.dart';
import 'core/blocs/theme_bloc.dart';
import 'core/router/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/services/role_storage_service.dart';
import 'core/services/role_sync_service.dart';
import 'core/services/preparation_step_service.dart';
import 'core/services/edge_function_service.dart';
import 'core/services/crash_reporting_service.dart';
import 'core/services/fcm_token_manager.dart';
import 'core/services/feature_flag_service.dart';
import 'core/services/offline_queue_service.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/services/deep_link_queue.dart';
import 'core/services/deep_link_listener.dart';
import 'core/bootstrap/bootstrap_gate.dart';
import 'core/routes/deep_link_handler.dart';
import 'features/auth/blocs/auth_bloc.dart';
import 'features/auth/blocs/user_profile_bloc.dart';
import 'features/order/blocs/active_orders_bloc.dart';
import 'features/cart/blocs/cart_bloc.dart';
import 'features/orders/services/order_realtime_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize persistent storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  // Configure system UI for full screen edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  
  await AppTheme.preloadFonts();

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null || supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Missing required environment variables. '
      'Please ensure SUPABASE_URL and SUPABASE_ANON_KEY are set in .env file.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  Bloc.observer = AppBlocObserver();

  await CrashReportingService.instance.initialize();

  runApp(const ChefleetApp());
}

class ChefleetApp extends StatefulWidget {
  const ChefleetApp({super.key});

  @override
  State<ChefleetApp> createState() => _ChefleetAppState();
}

class _ChefleetAppState extends State<ChefleetApp> {
  // Initialize role services
  late final RoleStorageService _roleStorageService;
  late final RoleSyncService _roleSyncService;
  late final FCMTokenManager _fcmTokenManager;
  late final OfflineQueueService _offlineQueueService;
  late final AppLifecycleService _lifecycleService;
  late final DeepLinkQueue _deepLinkQueue;
  late final DeepLinkListener _deepLinkListener;
  DeepLinkHandler? _deepLinkHandler;
  late GoRouter _router;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _roleStorageService = RoleStorageService();
    _roleSyncService = RoleSyncService();
    _deepLinkQueue = DeepLinkQueue();
    _deepLinkListener = _deepLinkQueue.createListener();
    
    // Note: Deep link listening is initialized in _initializeSecondaryServices
    // after bootstrap completes to ensure proper sequencing
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    _deepLinkListener.dispose();
    _deepLinkQueue.dispose();
    super.dispose();
  }

  /// Initialize secondary services after first frame.
  /// These are non-critical services that don't block bootstrap.
  Future<void> _initializeSecondaryServices(BuildContext providerContext) async {
    if (!mounted) return;
    
    try {
      final roleBloc = providerContext.read<RoleBloc>();
      final authBloc = providerContext.read<AuthBloc>();
      final activeOrdersBloc = providerContext.read<ActiveOrdersBloc>();
      
      // FCM token manager
      _fcmTokenManager = FCMTokenManager(
        firebaseMessaging: FirebaseMessaging.instance,
        supabase: Supabase.instance.client,
        roleBloc: roleBloc,
      );
      await _fcmTokenManager.initialize();
      
      // Feature flags
      await FeatureFlagServiceSingleton.getInstance();
      
      // Offline queue
      _offlineQueueService = await OfflineQueueServiceSingleton.getInstance();
      
      // Start active orders listener (deferred from BLoC construction)
      activeOrdersBloc.startListening();
      
      // Initialize app lifecycle service for resume/pause handling
      _lifecycleService = AppLifecycleService(
        authBloc: authBloc,
        roleBloc: roleBloc,
        activeOrdersBloc: activeOrdersBloc,
      );
      
      // Set up session expiration listener
      _setupSessionExpirationListener(authBloc);
      
      // Initialize deep link listener
      // This is done AFTER bootstrap to ensure deep links during cold start are queued
      await _deepLinkListener.initialize();
      
      print('✓ Secondary services initialized');
    } catch (e) {
      print('⚠ Secondary service initialization failed: $e');
      // Non-critical, app continues
    }
  }
  
  /// Sets up listener for session expiration notifications.
  void _setupSessionExpirationListener(AuthBloc authBloc) {
    authBloc.stream.listen((authState) {
      if (mounted && authState.errorMessage?.contains('expired') == true) {
        _showSessionExpiredSnackbar();
      }
    });
  }
  
  /// Shows a snackbar when user session expires.
  void _showSessionExpiredSnackbar() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your session has expired. Please sign in again.'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Sign In',
          textColor: Colors.white,
          onPressed: () {
            _router.go(SharedRoutes.auth);
          },
        ),
      ),
    );
  }

  void _initializeRouter(BuildContext context, {String? initialLocation}) {
    print('🗺️ _initializeRouter called with initialLocation: $initialLocation');
    
    final roleBloc = context.read<RoleBloc>();
    
    _router = AppRouter.createRouter(
      authBloc: context.read<AuthBloc>(),
      profileBloc: context.read<UserProfileBloc>(),
      roleBloc: roleBloc,
      initialLocation: initialLocation,
    );
    
    // Create deep link handler for use after bootstrap
    _deepLinkHandler = DeepLinkHandler(
      roleBloc: roleBloc,
      goRouter: _router,
    );
    
    print('🗺️ Router created with single source of truth for navigation');
  }


  void _onBootstrapComplete(String initialRoute, BuildContext providerContext) {
    print('📍 _onBootstrapComplete called with route: $initialRoute');
    setState(() {
      _initialRoute = initialRoute;
      print('📍 _initialRoute set to: $_initialRoute');
    });
    
    // Notify deep link queue that bootstrap is complete
    // This will process any deep link that was received during bootstrap
    if (_deepLinkHandler != null && mounted) {
      print('🔗 Notifying deep link queue that bootstrap is complete');
      _deepLinkQueue.onBootstrapComplete(providerContext, _deepLinkHandler!);
    }
    
    // Initialize secondary services after bootstrap and first frame
    // Ensures providers are available before accessing them
    // Use providerContext which is from inside the provider tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSecondaryServices(providerContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (non-BLoC)
        Provider<EdgeFunctionService>(
          create: (_) => EdgeFunctionService(Supabase.instance.client),
        ),
        Provider<OrderRealtimeService>(
          create: (_) => OrderRealtimeService(Supabase.instance.client),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(),
          ),
          BlocProvider(
            create: (context) => UserProfileBloc(),
            // Event dispatch moved to BootstrapOrchestrator
          ),
          BlocProvider(
            create: (context) => NavigationBloc(),
          ),
          // RoleBloc - manages user role state and switching
          BlocProvider(
            create: (context) => RoleBloc(
              storageService: _roleStorageService,
              syncService: _roleSyncService,
            ),
          ),
          // ActiveOrdersBloc auto-loads via auth listener (non-blocking)
          // See active_orders_bloc.dart lines 28-37 for auth state subscription
          BlocProvider(
            create: (context) => ActiveOrdersBloc(
              supabaseClient: Supabase.instance.client,
              authBloc: context.read<AuthBloc>(),
              preparationStepService: PreparationStepService(
                supabaseClient: Supabase.instance.client,
              ),
            ),
          ),
          BlocProvider(
            create: (context) => CartBloc(),
          ),
          BlocProvider(
            create: (context) => ThemeBloc(),
          ),
        ],
      child: Builder(
        builder: (context) {
          // Use BootstrapGate to resolve auth state before navigation
          return BootstrapGate(
            onBootstrapComplete: (result) {
              // Initialize router with resolved initial route
              // Pass context from Builder which has access to providers
              _initializeRouter(context, initialLocation: result.initialRoute);
              _onBootstrapComplete(result.initialRoute, context);
            },
            child: Builder(
              builder: (context) {
                print('🏗️ MaterialApp builder called - _initialRoute: $_initialRoute');
                // Only build MaterialApp after bootstrap completes
                if (_initialRoute == null) {
                  // Still bootstrapping - gate will show loading UI
                  print('🏗️ Returning SizedBox.shrink() - still waiting for bootstrap');
                  return const SizedBox.shrink();
                }
                
                print('🏗️ Building MaterialApp with router');
                return BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    return MaterialApp.router(
                      title: 'SmthngTsty',
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                      debugShowCheckedModeBanner: false,
                      routerConfig: _router,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      )
    );
  }
}