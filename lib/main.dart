import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/blocs/app_bloc_observer.dart';
import 'core/blocs/navigation_bloc.dart';
import 'features/auth/blocs/auth_bloc.dart';
import 'features/auth/blocs/user_profile_bloc.dart';
import 'shared/widgets/auth_guard.dart';
import 'shared/widgets/profile_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://psaseinpeedxzydinifx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzYXNlaW5wZWVkeHp5ZGluaWZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3MTU1ODUsImV4cCI6MjA3ODI5MTU4NX0.JEznxunBL4f9tjLz3GNd1Yu3aTuUbUeaywIhGC-V88A',
  );

  Bloc.observer = AppBlocObserver();

  runApp(const ChefleetApp());
}

class ChefleetApp extends StatelessWidget {
  const ChefleetApp({super.key});

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
      child: MaterialApp(
        title: 'Chefleet',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const ProfileGuard(
          child: AuthGuard(),
          requireProfile: false, // Allow access to app without profile initially
        ),
      ),
    );
  }
}