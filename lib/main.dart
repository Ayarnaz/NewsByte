import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'service/bookmark_service.dart';
import 'service/reading_history_service.dart';

import 'screen/main_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Custom error handling for Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
  };
  // Run the app with multiple providers for state management
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarkState()), // Provides the BookmarkState to the app
        ChangeNotifierProvider(create: (_) => ReadingHistoryState()), // Provides the ReadingHistoryState to the app
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsByte',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
