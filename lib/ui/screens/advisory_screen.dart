import 'package:flutter/material.dart';
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/services/ai_service.dart';
import 'package:ai_based_farmer_query_app/models/advisory_model.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/advisory_card.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
  List<AdvisoryModel> _advisories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentCrop = 'All Crops';
  String _currentSeason = 'All Seasons';

  final List<String> _crops = [
    'All Crops',
    'Wheat',
    'Rice',
    'Corn',
    'Soybean',
    'Cotton',
    'Sugarcane',
    'Vegetables',
    'Fruits',
  ];

  final List<String> _seasons = [
    'All Seasons',
    'Kharif',
    'Rabi',
    'Zaid',
  ];

  @override
  void initState() {
    super.initState();
    _loadAdvisories();
  }

  Future<void> _loadAdvisories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ragService = Provider.of<RAGService>(context, listen: false);
      final aiService = Provider.of<AIService>(context, listen: false);
      
      // Generate sample advisories based on datasets
      final sampleAdvisories = await _generateSampleAdvisories();
      
      setState(() {
        _advisories = sampleAdvisories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading advisories: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<AdvisoryModel>> _generateSampleAdvisories() async {
    // This would normally fetch from a database or API
    // For now, we'll create sample data based on our datasets
    
    return [
      AdvisoryModel(
        advisoryId: 'adv_001',
        farmerId: 'farmer_001',
        title: 'Wheat Crop Management for Rabi Season',
        description: 'Comprehensive guide for wheat cultivation during the Rabi season.',
        recommendations: [
          'Use certified seeds with high germination rate',
          'Apply balanced fertilization: 120:60:40 kg NPK per hectare',
          'Monitor for rust diseases and apply fungicides as needed',
          'Implement proper irrigation scheduling',
          'Practice crop rotation to maintain soil health',
        ],
        cropType: 'Wheat',
        soilType: 'Loamy',
        weatherCondition: 'Rabi Season',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AdvisoryModel(
        advisoryId: 'adv_002',
        farmerId: 'farmer_002',
        title: 'Pest Control for Cotton Crops',
        description: 'Integrated pest management strategies for cotton cultivation.',
        recommendations: [
          'Monitor for bollworm infestation regularly',
          'Use pheromone traps for early detection',
          'Apply neem-based biopesticides',
          'Encourage natural predators like ladybugs',
          'Practice field sanitation to reduce pest breeding',
        ],
        cropType: 'Cotton',
        soilType: 'Sandy Loam',
        weatherCondition: 'Kharif Season',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
      AdvisoryModel(
        advisoryId: 'adv_003',
        farmerId: 'farmer_003',
        title: 'Soil Health Management',
        description: 'Best practices for maintaining and improving soil fertility.',
        recommendations: [
          'Conduct regular soil testing every season',
          'Apply organic matter and compost regularly',
          'Use cover crops during fallow periods',
          'Practice conservation tillage',
          'Maintain proper crop rotation cycles',
        ],
        cropType: 'Mixed Crops',
        soilType: 'All Types',
        weatherCondition: 'All Seasons',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AdvisoryModel(
        advisoryId: 'adv_004',
        farmerId: 'farmer_004',
        title: 'Irrigation Optimization',
        description: 'Smart irrigation techniques for water conservation.',
        recommendations: [
          'Use drip irrigation systems where possible',
          'Monitor soil moisture levels regularly',
          'Schedule irrigation based on crop water requirements',
          'Implement rainwater harvesting',
          'Use mulching to reduce evaporation',
        ],
        cropType: 'All Crops',
        soilType: 'All Types',
        weatherCondition: 'All Seasons',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  List<AdvisoryModel> _getFilteredAdvisories() {
    return _advisories.where((advisory) {
      final cropMatch = _currentCrop == 'All Crops' || 
          advisory.cropType.toLowerCase().contains(_currentCrop.toLowerCase());
      final seasonMatch = _currentSeason == 'All Seasons' || 
          advisory.weatherCondition.toLowerCase().contains(_currentSeason.toLowerCase());
      
      return cropMatch && seasonMatch;
    }).toList();
  }

  Future<void> _generateNewAdvisory() async {
    // This would integrate with AI service to generate personalized advisories
    // For now, we'll add a sample advisory
    
    final newAdvisory = AdvisoryModel(
      advisoryId: 'adv_${DateTime.now().millisecondsSinceEpoch}',
      farmerId: 'farmer_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Personalized Crop Advisory',
      description: 'AI-generated advisory based on your specific query and conditions.',
      recommendations: [
        'Analyze your specific crop conditions',
        'Consider local weather patterns',
        'Implement recommended practices gradually',
        'Monitor results and adjust as needed',
        'Consult with local agricultural experts',
      ],
      cropType: _currentCrop,
      soilType: 'Varies',
      weatherCondition: _currentSeason,
      timestamp: DateTime.now(),
    );

    setState(() {
      _advisories.insert(0, newAdvisory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalized Advisory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _generateNewAdvisory,
            tooltip: 'Generate New Advisory',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters Section
            _buildFilters(),
            
            const SizedBox(height: 20),
            
            // Stats Section
            _buildStats(),
            
            const SizedBox(height: 20),
            
            // Advisories List
            Expanded(
              child: _buildAdvisoriesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Advisories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Crop Filter
            _buildFilterDropdown(
              label: 'Crop Type',
              value: _currentCrop,
              items: _crops,
              onChanged: (value) {
                setState(() {
                  _currentCrop = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Season Filter
            _buildFilterDropdown(
              label: 'Season',
              value: _currentSeason,
              items: _seasons,
              onChanged: (value) {
                setState(() {
                  _currentSeason = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: Container(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final filteredAdvisories = _getFilteredAdvisories();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            icon: Icons.library_books,
            label: 'Total Advisories',
            value: _advisories.length.toString(),
            color: const Color(0xFF4CAF50),
          ),
          _buildStatCard(
            icon: Icons.filter_list,
            label: 'Filtered',
            value: filteredAdvisories.length.toString(),
            color: const Color(0xFF2196F3),
          ),
          _buildStatCard(
            icon: Icons.update,
            label: 'Recent',
            value: _advisories.where((a) => 
              a.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)))
            ).length.toString(),
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvisoriesList() {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    final filteredAdvisories = _getFilteredAdvisories();

    if (filteredAdvisories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No advisories found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or ${filteredAdvisories.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: filteredAdvisories.length,
      itemBuilder: (context, index) {
        final advisory = filteredAdvisories[index];
        return AdvisoryCard(
          advisory: advisory,
          onTap: () {
            _showAdvisoryDetails(advisory);
          },
        );
      },
    );
  }

  void _showAdvisoryDetails(AdvisoryModel advisory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(advisory.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                advisory.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Recommendations:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: advisory.recommendations.map((rec) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip('Crop: ${advisory.cropType}', Colors.green),
                  const SizedBox(width: 8),
                  _buildInfoChip('Season: ${advisory.weatherCondition}', Colors.blue),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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