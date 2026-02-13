import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/services/ai_service.dart';
import 'package:ai_based_farmer_query_app/services/text_search_service.dart';
import 'package:ai_based_farmer_query_app/services/voice_search_service.dart';
import 'package:ai_based_farmer_query_app/services/image_search_service.dart';
import 'package:ai_based_farmer_query_app/ui/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<RAGService>(
          create: (_) => RAGService(),
        ),
        Provider<AIService>(
          create: (_) => AIService(),
        ),
        Provider<TextSearchService>(
          create: (_) => TextSearchService(),
        ),
        Provider<VoiceSearchService>(
          create: (_) => VoiceSearchService(),
        ),
        Provider<ImageSearchService>(
          create: (_) => ImageSearchService(),
        ),
      ],
      child: const FarmerQueryApp(),
    ),
  );
}

class FarmerQueryApp extends StatelessWidget {
  const FarmerQueryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Query Support',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF81C784),
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}