import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/blocs/app_bloc_observer.dart';
import 'core/blocs/navigation_bloc.dart';
import 'core/blocs/role_bloc.dart';
import 'core/services/role_storage_service.dart';
import 'core/services/role_sync_service.dart';
import 'core/app_root.dart';
import 'features/auth/blocs/auth_bloc.dart';
import 'features/auth/blocs/user_profile_bloc.dart';
import 'features/order/blocs/active_orders_bloc.dart';
import 'features/cart/blocs/cart_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

  @override
  void initState() {
    super.initState();
    _roleStorageService = RoleStorageService();
    _roleSyncService = RoleSyncService();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
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
        BlocProvider(
          create: (context) => ActiveOrdersBloc(
            supabaseClient: Supabase.instance.client,
            authBloc: context.read<AuthBloc>(),
          )..loadActiveOrders(),
        ),
        BlocProvider(
          create: (context) => CartBloc(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Chefleet',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            home: const AppRoot(),
          );
        },
      ),
    );
  }
}