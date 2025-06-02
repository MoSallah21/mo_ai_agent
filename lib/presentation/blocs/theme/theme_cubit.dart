import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themePrefsKey = 'dark_mode';

  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themePrefsKey) ?? false;

    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.isDarkMode;

    await prefs.setBool(_themePrefsKey, newValue);
    emit(state.copyWith(isDarkMode: newValue));
  }
}
