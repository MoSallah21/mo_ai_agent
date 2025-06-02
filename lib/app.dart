import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mo_ai_agent/presentation/blocs/chat/chat_cubit.dart';
import 'package:mo_ai_agent/presentation/blocs/theme/theme_cubit.dart';
import 'package:mo_ai_agent/presentation/pages/welcome_page.dart';

import 'core/di/dependency_injection.dart';


class MoAiAgentApp extends StatelessWidget {
  const MoAiAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => getIt<ThemeCubit>(),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => getIt<ChatCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'AI Assistant',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: state.isDarkMode ? Brightness.dark : Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const WelcomePage(),
          );
        },
      ),
    );
  }
}