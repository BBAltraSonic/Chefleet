import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/blocs/app_bloc_observer.dart';
import 'core/blocs/navigation_bloc.dart';
import 'core/router/app_router.dart';
import 'features/auth/blocs/auth_bloc.dart';
import 'features/auth/blocs/user_profile_bloc.dart';
import 'features/order/blocs/active_orders_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        BlocProvider(
          create: (context) => ActiveOrdersBloc(
            supabaseClient: Supabase.instance.client,
            authBloc: context.read<AuthBloc>(),
          )..loadActiveOrders(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.create(context);
          return MaterialApp.router(
            title: 'Chefleet',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          );
        },
      ),
    );
  }
}