import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/blocs/app_bloc_observer.dart';
import 'core/blocs/navigation_bloc.dart';
import 'core/blocs/role_bloc.dart';
import 'core/router/app_router.dart';
import 'core/services/role_storage_service.dart';
import 'core/services/role_sync_service.dart';
import 'core/services/preparation_step_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/edge_function_service.dart';
import 'core/bootstrap/bootstrap_gate.dart';
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
  late GoRouter _router;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _roleStorageService = RoleStorageService();
    _roleSyncService = RoleSyncService();
  }

  void _initializeRouter(BuildContext context, {String? initialLocation}) {
    _router = AppRouter.createRouter(
      authBloc: context.read<AuthBloc>(),
      profileBloc: context.read<UserProfileBloc>(),
      roleBloc: context.read<RoleBloc>(),
      initialLocation: initialLocation,
    );
  }

  void _onBootstrapComplete(String initialRoute) {
    setState(() {
      _initialRoute = initialRoute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (non-BLoC)
        Provider<SupabaseService>(
          create: (_) => SupabaseService(),
        ),
        Provider<EdgeFunctionService>(
          create: (_) => EdgeFunctionService(),
        ),
        Provider<OrderRealtimeService>(
          create: (context) => OrderRealtimeService(
            context.read<SupabaseService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(),
          ),
          BlocProvider(
            create: (context) => UserProfileBloc()..add(const UserProfileLoaded()),
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
        ],
      child: Builder(
        builder: (context) {
          // Use BootstrapGate to resolve auth state before navigation
          return BootstrapGate(
            onBootstrapComplete: (result) {
              // Initialize router with resolved initial route
              _initializeRouter(context, initialLocation: result.initialRoute);
              _onBootstrapComplete(result.initialRoute);
            },
            child: Builder(
              builder: (context) {
                // Only build MaterialApp after bootstrap completes
                if (_initialRoute == null) {
                  // Still bootstrapping - gate will show loading UI
                  return const SizedBox.shrink();
                }
                
                return MaterialApp.router(
                  title: 'SmthngTsty',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: ThemeMode.system,
                  debugShowCheckedModeBanner: false,
                  routerConfig: _router,
                );
              },
            ),
          );
        },
      ),
    );
  }
}