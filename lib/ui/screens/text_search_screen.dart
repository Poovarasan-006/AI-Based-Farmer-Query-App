import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_based_farmer_query_app/services/text_search_service.dart';
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/search_result_item.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/loading_indicator.dart';

class TextSearchScreen extends StatefulWidget {
  const TextSearchScreen({super.key});

  @override
  State<TextSearchScreen> createState() => _TextSearchScreenState();
}

class _TextSearchScreenState extends State<TextSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _errorMessage = '';
    });

    try {
      final ragService = Provider.of<RAGService>(context, listen: false);
      final results = await ragService.search(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error performing search: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input Section
            _buildSearchInput(),
            
            const SizedBox(height: 20),
            
            // Suggestions Section
            _buildSuggestions(),
            
            const SizedBox(height: 20),
            
            // Results Section
            Expanded(
              child: _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Type your farming query here...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: _performSearch,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.grey,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = [];
                    _errorMessage = '';
                  });
                },
              ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Color(0xFF2E7D32),
              ),
              onPressed: () => _performSearch(_searchController.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Queries',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('How to treat powdery mildew?'),
              _buildSuggestionChip('Best fertilizer for tomatoes'),
              _buildSuggestionChip('Pest control methods'),
              _buildSuggestionChip('Soil preparation techniques'),
              _buildSuggestionChip('Crop rotation benefits'),
              _buildSuggestionChip('Irrigation scheduling'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(
        suggestion,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        _searchController.text = suggestion;
        _performSearch(suggestion);
      },
      backgroundColor: const Color(0xFFE8F5E9),
      labelStyle: const TextStyle(
        color: Color(0xFF2E7D32),
        fontSize: 12,
      ),
    );
  }

  Widget _buildResults() {
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

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching with different keywords',
              style: TextStyle(
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
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return SearchResultItem(
          title: result['title'] ?? 'Query Result',
          description: result['content'] ?? result['description'] ?? '',
          category: result['category'] ?? 'General',
          onTap: () {
            // Navigate to detailed view or show dialog
            _showResultDetails(result);
          },
        );
      },
    );
  }

  void _showResultDetails(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result['title'] ?? 'Query Result'),
        content: SingleChildScrollView(
          child: Text(result['content'] ?? result['description'] ?? ''),
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
}