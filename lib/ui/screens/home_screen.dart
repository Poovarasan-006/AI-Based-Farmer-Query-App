import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ai_based_farmer_query_app/ui/screens/text_search_screen.dart';
import 'package:ai_based_farmer_query_app/ui/screens/voice_search_screen.dart';
import 'package:ai_based_farmer_query_app/ui/screens/image_search_screen.dart';
import 'package:ai_based_farmer_query_app/ui/screens/advisory_screen.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/search_option_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Query Support'),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFC8E6C9),
              Color(0xFFA5D6A7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              
              const SizedBox(height: 30),
              
              // Search Options Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.9,
                  children: [
                    SearchOptionCard(
                      title: 'Text Search',
                      description: 'Search by typing your query',
                      iconPath: 'assets/icons/text_search.svg',
                      color: const Color(0xFF4CAF50),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TextSearchScreen(),
                          ),
                        );
                      },
                    ),
                    SearchOptionCard(
                      title: 'Voice Search',
                      description: 'Speak your query',
                      iconPath: 'assets/icons/voice_search.svg',
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VoiceSearchScreen(),
                          ),
                        );
                      },
                    ),
                    SearchOptionCard(
                      title: 'Image Search',
                      description: 'Upload or capture an image',
                      iconPath: 'assets/icons/image_search.svg',
                      color: const Color(0xFFFF9800),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImageSearchScreen(),
                          ),
                        );
                      },
                    ),
                    SearchOptionCard(
                      title: 'Advisory',
                      description: 'Get personalized advice',
                      iconPath: 'assets/icons/advisory.svg',
                      color: const Color(0xFF9C27B0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdvisoryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Farmer Query Support',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Get instant answers to your farming queries using AI-powered search and advisory system.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildInfoChip('RAG System', Colors.blue),
            const SizedBox(width: 10),
            _buildInfoChip('Multi-Modal', Colors.green),
            const SizedBox(width: 10),
            _buildInfoChip('AI-Powered', Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}