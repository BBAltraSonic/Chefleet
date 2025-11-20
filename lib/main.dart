import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/blocs/app_bloc_observer.dart';
import 'core/blocs/navigation_bloc.dart';
import 'core/router/app_router.dart';
import 'features/auth/blocs/auth_bloc.dart';
import 'features/auth/blocs/user_profile_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Missing required environment variables. '
      'Please provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.\n'
      'Example: flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key',
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.initialize(context);
    });
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
      ],
      child: MaterialApp.router(
        title: 'Chefleet',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}