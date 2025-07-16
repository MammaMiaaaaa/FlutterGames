import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/memory_match_screen.dart';
import 'screens/game_selection_screen.dart';
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
          ).apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.fredoka(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.black,
            ),
            toolbarTextStyle: GoogleFonts.fredoka(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
            ),
          ),
          useMaterial3: true,
        ),
        home: const GameSelectionScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
} 