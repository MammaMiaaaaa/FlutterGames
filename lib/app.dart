import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/memory_match_screen.dart';
import 'models/memory_game_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemoryGameProvider(),
      child: MaterialApp(
        title: 'Animal Edu Games',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.fredokaTextTheme(
            Theme.of(context).textTheme,
          ),
          useMaterial3: true,
        ),
        home: const MemoryMatchScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
} 