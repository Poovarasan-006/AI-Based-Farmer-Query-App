// Soil Management Dataset

class SoilManagementDataset {
  static const List<Map<String, dynamic>> soilTypes = [
    {
      'type': 'Sandy',
      'characteristics': 'Light, dry, and warm, quick to drain',
      'amendments': ['Organic matter', 'Compost'],
      'testingGuidelines': 'Test pH and nutrient levels, amend as needed'
    },
    {
      'type': 'Clay',
      'characteristics': 'Heavy, dense, retains water',
      'amendments': ['Gypsum', 'Organic matter'],
      'testingGuidelines': 'Test compaction and drainage, amend accordingly'
    },
    {
      'type': 'Silty',
      'characteristics': 'Smooth, nutrient-rich, retains moisture',
      'amendments': ['Compost', 'Mulch'],
      'testingGuidelines': 'Regular testing for nutrient levels necessary'
    },
    {
      'type': 'Loamy',
      'characteristics': 'Balanced, ideal for agriculture',
      'amendments': ['Organic matter', 'Cover crops'],
      'testingGuidelines': 'Standard testing for nutrients and pH'
    }
  ];

  static const List<String> amendments = [
    'Compost',
    'Mulch',
    'Organic matter',
    'Gypsum',
    'Cover crops',
  ];

  static const List<String> testingGuidelines = [
    'Test soil pH regularly',
    'Check nutrient levels every season',
    'Evaluate soil structure and drainage'
  ];
}