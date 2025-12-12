import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_bloc.dart';

// Events
abstract class ThemeEvent extends AppEvent {
  const ThemeEvent();
}

class ThemeInitialized extends ThemeEvent {
  const ThemeInitialized();
}

class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}

class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.isDarkMode);
  
  final bool isDarkMode;
  
  @override
  List<Object?> get props => [isDarkMode];
}

// State
class ThemeState extends AppState {
  const ThemeState({
    this.isDarkMode = false,
    this.isLoading = false,
  });
  
  final bool isDarkMode;
  final bool isLoading;
  
  ThemeState copyWith({
    bool? isDarkMode,
    bool? isLoading,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  @override
  List<Object?> get props => [isDarkMode, isLoading];
}

// Bloc
class ThemeBloc extends AppBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeToggled>(_onThemeToggled);
    on<ThemeModeChanged>(_onThemeModeChanged);
    
    // Initialize theme from saved preferences
    add(const ThemeInitialized());
  }
  
  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      
      emit(state.copyWith(
        isDarkMode: isDarkMode,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
  
  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    final newMode = !state.isDarkMode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', newMode);
      
      emit(state.copyWith(isDarkMode: newMode));
    } catch (e) {
      // If saving fails, still update the UI but log the error
      print('Failed to save theme preference: $e');
      emit(state.copyWith(isDarkMode: newMode));
    }
  }
  
  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', event.isDarkMode);
      
      emit(state.copyWith(isDarkMode: event.isDarkMode));
    } catch (e) {
      print('Failed to save theme preference: $e');
      emit(state.copyWith(isDarkMode: event.isDarkMode));
    }
  }
}
