import 'dart:convert';
import 'package:http/http.dart' as http;

/// Comprehensive external agricultural datasets integration
class ExternalDatasets {
  static const String usdaApiUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String faoApiUrl = 'https://faostat.fao.org/beta/api/v1';
  static const String weatherApiUrl = 'https://api.openweathermap.org/data/2.5';
  
  final String usdaApiKey;
  final String weatherApiKey;

  ExternalDatasets({required this.usdaApiKey, required this.weatherApiKey});

  /// Fetch crop yield data from USDA
  Future<List<Map<String, dynamic>>> fetchCropYieldData(String cropType, String region) async {
    try {
      final response = await http.get(
        Uri.parse('$usdaApiUrl/foods/search?query=$cropType&api_key=$usdaApiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseUSDAData(data, 'crop_yield');
      } else {
        return _getFallbackCropYieldData(cropType);
      }
    } catch (e) {
      return _getFallbackCropYieldData(cropType);
    }
  }

  /// Fetch pest and disease data from FAO
  Future<List<Map<String, dynamic>>> fetchPestDiseaseData(String cropType) async {
    try {
      final response = await http.get(
        Uri.parse('$faoApiUrl/data/crop_protection?crop=$cropType'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseFAOData(data, 'pest_disease');
      } else {
        return _getFallbackPestDiseaseData(cropType);
      }
    } catch (e) {
      return _getFallbackPestDiseaseData(cropType);
    }
  }

  /// Fetch weather data for agricultural planning
  Future<Map<String, dynamic>> fetchWeatherData(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$weatherApiUrl/weather?q=$location&appid=$weatherApiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseWeatherData(data);
      } else {
        return _getFallbackWeatherData(location);
      }
    } catch (e) {
      return _getFallbackWeatherData(location);
    }
  }

  /// Fetch soil data from global soil databases
  Future<List<Map<String, dynamic>>> fetchSoilData(String region) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.soilgrids.org/v2/table?region=$region'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseSoilData(data);
      } else {
        return _getFallbackSoilData(region);
      }
    } catch (e) {
      return _getFallbackSoilData(region);
    }
  }

  /// Fetch market price data
  Future<List<Map<String, dynamic>>> fetchMarketPrices(String cropType, String region) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.agmarknet.gov.in/api/v1/prices?commodity=$cropType&region=$region'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseMarketData(data);
      } else {
        return _getFallbackMarketData(cropType);
      }
    } catch (e) {
      return _getFallbackMarketData(cropType);
    }
  }

  /// Parse USDA API response
  List<Map<String, dynamic>> _parseUSDAData(dynamic data, String dataType) {
    final results = <Map<String, dynamic>>[];
    
    if (data is Map && data.containsKey('foods')) {
      for (var food in data['foods']) {
        results.add({
          'name': food['description'] ?? 'Unknown',
          'nutrients': food['foodNutrients'] ?? [],
          'dataType': dataType,
          'source': 'USDA',
        });
      }
    }
    
    return results;
  }

  /// Parse FAO API response
  List<Map<String, dynamic>> _parseFAOData(dynamic data, String dataType) {
    final results = <Map<String, dynamic>>[];
    
    if (data is Map && data.containsKey('data')) {
      for (var item in data['data']) {
        results.add({
          'pest_name': item['pest_name'] ?? 'Unknown',
          'description': item['description'] ?? '',
          'control_methods': item['control_methods'] ?? [],
          'dataType': dataType,
          'source': 'FAO',
        });
      }
    }
    
    return results;
  }

  /// Parse weather API response
  Map<String, dynamic> _parseWeatherData(dynamic data) {
    return {
      'temperature': data['main']['temp'] ?? 0,
      'humidity': data['main']['humidity'] ?? 0,
      'precipitation': data['rain']?['1h'] ?? 0,
      'wind_speed': data['wind']['speed'] ?? 0,
      'weather': data['weather']?[0]['description'] ?? 'Unknown',
      'source': 'OpenWeather',
    };
  }

  /// Parse soil data
  List<Map<String, dynamic>> _parseSoilData(dynamic data) {
    final results = <Map<String, dynamic>>[];
    
    if (data is Map && data.containsKey('layers')) {
      for (var layer in data['layers']) {
        results.add({
          'soil_type': layer['type'] ?? 'Unknown',
          'ph_level': layer['ph'] ?? 0,
          'organic_matter': layer['organic_matter'] ?? 0,
          'nutrient_content': layer['nutrients'] ?? {},
          'source': 'SoilGrids',
        });
      }
    }
    
    return results;
  }

  /// Parse market data
  List<Map<String, dynamic>> _parseMarketData(dynamic data) {
    final results = <Map<String, dynamic>>[];
    
    if (data is Map && data.containsKey('prices')) {
      for (var price in data['prices']) {
        results.add({
          'market': price['market'] ?? 'Unknown',
          'price': price['price'] ?? 0,
          'date': price['date'] ?? '',
          'variety': price['variety'] ?? '',
          'source': 'Agmarknet',
        });
      }
    }
    
    return results;
  }

  /// Fallback crop yield data
  List<Map<String, dynamic>> _getFallbackCropYieldData(String cropType) {
    return [
      {
        'crop': cropType,
        'yield_per_hectare': 3.5,
        'season': 'Kharif',
        'region': 'India',
        'dataType': 'crop_yield',
        'source': 'Fallback Data',
      },
      {
        'crop': cropType,
        'yield_per_hectare': 4.2,
        'season': 'Rabi',
        'region': 'India',
        'dataType': 'crop_yield',
        'source': 'Fallback Data',
      },
    ];
  }

  /// Fallback pest disease data
  List<Map<String, dynamic>> _getFallbackPestDiseaseData(String cropType) {
    return [
      {
        'pest_name': 'Aphids',
        'description': 'Small sap-sucking insects that cause leaf curling',
        'control_methods': ['Neem oil', 'Ladybugs', 'Insecticidal soap'],
        'dataType': 'pest_disease',
        'source': 'Fallback Data',
      },
      {
        'pest_name': 'Powdery Mildew',
        'description': 'Fungal disease causing white powdery coating on leaves',
        'control_methods': ['Sulfur fungicides', 'Proper spacing', 'Resistant varieties'],
        'dataType': 'pest_disease',
        'source': 'Fallback Data',
      },
    ];
  }

  /// Fallback weather data
  Map<String, dynamic> _getFallbackWeatherData(String location) {
    return {
      'temperature': 25.0,
      'humidity': 60,
      'precipitation': 0,
      'wind_speed': 5.0,
      'weather': 'Clear',
      'location': location,
      'source': 'Fallback Data',
    };
  }

  /// Fallback soil data
  List<Map<String, dynamic>> _getFallbackSoilData(String region) {
    return [
      {
        'soil_type': 'Loamy',
        'ph_level': 6.5,
        'organic_matter': 2.5,
        'nutrient_content': {
          'nitrogen': 200,
          'phosphorus': 50,
          'potassium': 150,
        },
        'region': region,
        'source': 'Fallback Data',
      },
    ];
  }

  /// Fallback market data
  List<Map<String, dynamic>> _getFallbackMarketData(String cropType) {
    return [
      {
        'market': 'Local Market',
        'price': 2500,
        'date': '2024-01-01',
        'variety': cropType,
        'source': 'Fallback Data',
      },
      {
        'market': 'Wholesale Market',
        'price': 3000,
        'date': '2024-01-01',
        'variety': cropType,
        'source': 'Fallback Data',
      },
    ];
  }

  /// Comprehensive agricultural data fetcher
  Future<Map<String, dynamic>> fetchComprehensiveData({
    required String cropType,
    required String region,
    String? location,
  }) async {
    final data = <String, dynamic>{};

    // Fetch all external datasets
    data['crop_yield'] = await fetchCropYieldData(cropType, region);
    data['pest_disease'] = await fetchPestDiseaseData(cropType);
    data['soil_data'] = await fetchSoilData(region);
    data['market_prices'] = await fetchMarketPrices(cropType, region);
    
    if (location != null) {
      data['weather'] = await fetchWeatherData(location);
    }

    return data;
  }
}

/// Pre-loaded comprehensive datasets for offline functionality
class ComprehensiveDatasets {
  /// Extensive crop database
  static final List<Map<String, dynamic>> extensiveCropData = [
    {
      'crop_name': 'Wheat',
      'scientific_name': 'Triticum aestivum',
      'family': 'Poaceae',
      'growing_season': ['Rabi'],
      'water_requirement': 'Moderate',
      'optimal_ph': [6.0, 7.5],
      'optimal_temperature': [15, 21],
      'yield_per_hectare': 3.5,
      'harvest_time': 'April-May',
      'nutritional_value': {
        'protein': 13.2,
        'carbohydrates': 71.2,
        'fiber': 10.7,
        'calories': 340,
      },
      'major_uses': ['Flour', 'Bread', 'Pasta', 'Cereal'],
      'storage_life': '12-18 months',
    },
    {
      'crop_name': 'Rice',
      'scientific_name': 'Oryza sativa',
      'family': 'Poaceae',
      'growing_season': ['Kharif'],
      'water_requirement': 'High',
      'optimal_ph': [5.5, 6.5],
      'optimal_temperature': [20, 35],
      'yield_per_hectare': 4.0,
      'harvest_time': 'September-October',
      'nutritional_value': {
        'protein': 7.1,
        'carbohydrates': 80.0,
        'fiber': 1.3,
        'calories': 365,
      },
      'major_uses': ['Food grain', 'Flour', 'Starch', 'Alcohol'],
      'storage_life': '6-12 months',
    },
    {
      'crop_name': 'Corn',
      'scientific_name': 'Zea mays',
      'family': 'Poaceae',
      'growing_season': ['Kharif', 'Rabi'],
      'water_requirement': 'Moderate',
      'optimal_ph': [5.8, 6.8],
      'optimal_temperature': [18, 27],
      'yield_per_hectare': 5.0,
      'harvest_time': 'September-October',
      'nutritional_value': {
        'protein': 9.4,
        'carbohydrates': 74.0,
        'fiber': 7.3,
        'calories': 365,
      },
      'major_uses': ['Food', 'Animal feed', 'Biofuel', 'Starch'],
      'storage_life': '6-12 months',
    },
    {
      'crop_name': 'Soybean',
      'scientific_name': 'Glycine max',
      'family': 'Fabaceae',
      'growing_season': ['Kharif'],
      'water_requirement': 'Moderate',
      'optimal_ph': [6.0, 7.0],
      'optimal_temperature': [18, 27],
      'yield_per_hectare': 2.5,
      'harvest_time': 'October-November',
      'nutritional_value': {
        'protein': 36.5,
        'carbohydrates': 30.2,
        'fiber': 9.3,
        'calories': 446,
        'fat': 19.9,
      },
      'major_uses': ['Oil', 'Protein', 'Animal feed', 'Tofu'],
      'storage_life': '6-12 months',
    },
    {
      'crop_name': 'Cotton',
      'scientific_name': 'Gossypium hirsutum',
      'family': 'Malvaceae',
      'growing_season': ['Kharif'],
      'water_requirement': 'Moderate',
      'optimal_ph': [6.0, 7.5],
      'optimal_temperature': [21, 30],
      'yield_per_hectare': 1500,
      'harvest_time': 'October-December',
      'fiber_length': '25-35 mm',
      'fiber_strength': '25-35 g/tex',
      'major_uses': ['Textile', 'Clothing', 'Home textiles'],
      'storage_life': '12-24 months',
    },
  ];

  /// Comprehensive pest database
  static final List<Map<String, dynamic>> extensivePestData = [
    {
      'pest_name': 'Aphids',
      'scientific_name': 'Aphidoidea',
      'type': 'Insect',
      'affected_crops': ['Wheat', 'Corn', 'Soybean', 'Vegetables'],
      'damage_symptoms': [
        'Leaf curling',
        'Stunted growth',
        'Honeydew secretion',
        'Sooty mold growth',
      ],
      'life_cycle': 'Egg → Nymph → Adult (2-3 weeks)',
      'natural_predators': ['Ladybugs', 'Lacewings', 'Parasitic wasps'],
      'chemical_control': ['Imidacloprid', 'Acephate', 'Malathion'],
      'organic_control': ['Neem oil', 'Insecticidal soap', 'Diatomaceous earth'],
      'preventive_measures': [
        'Crop rotation',
        'Resistant varieties',
        'Proper spacing',
        'Weed control',
      ],
    },
    {
      'pest_name': 'Armyworm',
      'scientific_name': 'Spodoptera frugiperda',
      'type': 'Insect',
      'affected_crops': ['Corn', 'Wheat', 'Rice', 'Sorghum'],
      'damage_symptoms': [
        'Leaf defoliation',
        'Skeletonized leaves',
        'Silk clipping',
        'Ear damage',
      ],
      'life_cycle': 'Egg → Larva → Pupa → Adult (3-4 weeks)',
      'natural_predators': ['Birds', 'Spiders', 'Parasitic wasps'],
      'chemical_control': ['Chlorpyrifos', 'Cypermethrin', 'Lambda-cyhalothrin'],
      'organic_control': ['Bt (Bacillus thuringiensis)', 'Neem oil', 'Spinosad'],
      'preventive_measures': [
        'Early planting',
        'Field sanitation',
        'Monitoring traps',
        'Crop rotation',
      ],
    },
    {
      'pest_name': 'Bollworm',
      'scientific_name': 'Helicoverpa armigera',
      'type': 'Insect',
      'affected_crops': ['Cotton', 'Soybean', 'Tomato', 'Chili'],
      'damage_symptoms': [
        'Boll damage',
        'Fruit boring',
        'Flower damage',
        'Stem boring',
      ],
      'life_cycle': 'Egg → Larva → Pupa → Adult (4-6 weeks)',
      'natural_predators': ['Trichogramma wasps', 'Birds', 'Spiders'],
      'chemical_control': ['Quinalphos', 'Monocrotophos', 'Endosulfan'],
      'organic_control': ['Bt spray', 'Neem oil', 'Pheromone traps'],
      'preventive_measures': [
        'Resistant varieties',
        'Pheromone traps',
        'Field sanitation',
        'Crop rotation',
      ],
    },
    {
      'pest_name': 'Whitefly',
      'scientific_name': 'Bemisia tabaci',
      'type': 'Insect',
      'affected_crops': ['Cotton', 'Vegetables', 'Fruits', 'Flowers'],
      'damage_symptoms': [
        'Leaf yellowing',
        'Honeydew secretion',
        'Sooty mold',
        'Virus transmission',
      ],
      'life_cycle': 'Egg → Nymph → Pupa → Adult (2-3 weeks)',
      'natural_predators': ['Ladybugs', 'Lacewings', 'Minute pirate bugs'],
      'chemical_control': ['Imidacloprid', 'Thiamethoxam', 'Acetamiprid'],
      'organic_control': ['Neem oil', 'Insecticidal soap', 'Yellow sticky traps'],
      'preventive_measures': [
        'Yellow sticky traps',
        'Resistant varieties',
        'Proper spacing',
        'Weed control',
      ],
    },
  ];

  /// Comprehensive disease database
  static final List<Map<String, dynamic>> extensiveDiseaseData = [
    {
      'disease_name': 'Powdery Mildew',
      'pathogen': 'Fungi (Erysiphales)',
      'affected_crops': ['Wheat', 'Barley', 'Grapes', 'Cucurbits'],
      'symptoms': [
        'White powdery coating on leaves',
        'Leaf yellowing',
        'Stunted growth',
        'Reduced yield',
      ],
      'favorable_conditions': [
        'Temperature: 15-27°C',
        'High humidity',
        'Poor air circulation',
        'Shaded areas',
      ],
      'chemical_control': ['Sulfur', 'Triadimefon', 'Myclobutanil'],
      'organic_control': ['Neem oil', 'Baking soda spray', 'Milk spray'],
      'preventive_measures': [
        'Resistant varieties',
        'Proper spacing',
        'Good air circulation',
        'Avoid overhead watering',
      ],
    },
    {
      'disease_name': 'Rust',
      'pathogen': 'Fungi (Pucciniales)',
      'affected_crops': ['Wheat', 'Corn', 'Coffee', 'Beans'],
      'symptoms': [
        'Orange/brown pustules on leaves',
        'Leaf yellowing',
        'Premature defoliation',
        'Reduced photosynthesis',
      ],
      'favorable_conditions': [
        'Temperature: 15-25°C',
        'High humidity',
        'Leaf wetness',
        'Dense planting',
      ],
      'chemical_control': ['Triadimefon', 'Propiconazole', 'Difenoconazole'],
      'organic_control': ['Copper fungicides', 'Neem oil', 'Compost tea'],
      'preventive_measures': [
        'Resistant varieties',
        'Crop rotation',
        'Field sanitation',
        'Proper spacing',
      ],
    },
    {
      'disease_name': 'Blast Disease',
      'pathogen': 'Fungi (Magnaporthe oryzae)',
      'affected_crops': ['Rice', 'Wheat', 'Barley'],
      'symptoms': [
        'Diamond-shaped lesions on leaves',
        'Lesions with gray centers',
        'Collar rot in seedlings',
        'Panicle blight',
      ],
      'favorable_conditions': [
        'Temperature: 25-28°C',
        'High humidity',
        'Excessive nitrogen',
        'Dense planting',
      ],
      'chemical_control': ['Tricyclazole', 'Carbendazim', 'Mancozeb'],
      'organic_control': ['Copper fungicides', 'Neem oil', 'Bacillus subtilis'],
      'preventive_measures': [
        'Resistant varieties',
        'Balanced fertilization',
        'Field sanitation',
        'Proper water management',
      ],
    },
  ];

  /// Comprehensive soil database
  static final List<Map<String, dynamic>> extensiveSoilData = [
    {
      'soil_type': 'Sandy Soil',
      'texture': 'Coarse',
      'drainage': 'Fast',
      'water_retention': 'Low',
      'nutrient_retention': 'Low',
      'ph_range': [5.5, 7.0],
      'organic_matter': 'Low',
      'suitable_crops': ['Carrots', 'Potatoes', 'Onions', 'Peanuts'],
      'challenges': [
        'Poor water retention',
        'Low nutrient content',
        'Rapid drying',
      ],
      'improvement_methods': [
        'Add organic matter',
        'Mulching',
        'Cover cropping',
        'Compost application',
      ],
    },
    {
      'soil_type': 'Clay Soil',
      'texture': 'Fine',
      'drainage': 'Slow',
      'water_retention': 'High',
      'nutrient_retention': 'High',
      'ph_range': [6.0, 8.0],
      'organic_matter': 'High',
      'suitable_crops': ['Rice', 'Wheat', 'Sugarcane', 'Corn'],
      'challenges': [
        'Poor drainage',
        'Compaction',
        'Slow warming',
        'Difficult tillage',
      ],
      'improvement_methods': [
        'Add sand and organic matter',
        'Deep plowing',
        'Raised beds',
        'Cover cropping',
      ],
    },
    {
      'soil_type': 'Loamy Soil',
      'texture': 'Medium',
      'drainage': 'Moderate',
      'water_retention': 'Moderate',
      'nutrient_retention': 'High',
      'ph_range': [6.0, 7.0],
      'organic_matter': 'Moderate',
      'suitable_crops': ['Most crops', 'Vegetables', 'Fruits', 'Grains'],
      'advantages': [
        'Good drainage',
        'High fertility',
        'Easy to work with',
        'Good water retention',
      ],
      'maintenance_methods': [
        'Regular organic matter addition',
        'Crop rotation',
        'Cover cropping',
        'Balanced fertilization',
      ],
    },
    {
      'soil_type': 'Silty Soil',
      'texture': 'Medium-fine',
      'drainage': 'Moderate',
      'water_retention': 'High',
      'nutrient_retention': 'Moderate',
      'ph_range': [6.0, 7.5],
      'organic_matter': 'Moderate',
      'suitable_crops': ['Vegetables', 'Berries', 'Flowers', 'Grasses'],
      'challenges': [
        'Erosion prone',
        'Compaction',
        'Poor structure',
      ],
      'improvement_methods': [
        'Add organic matter',
        'Cover cropping',
        'Mulching',
        'Reduced tillage',
      ],
    },
  ];

  /// Weather and climate data
  static final List<Map<String, dynamic>> climateData = [
    {
      'region': 'North India',
      'climate_type': 'Continental',
      'summer_temp': [25, 45],
      'winter_temp': [2, 15],
      'rainfall': [500, 1000],
      'best_crops': ['Wheat', 'Barley', 'Mustard', 'Potatoes'],
      'challenges': ['Extreme heat', 'Cold winters', 'Water scarcity'],
    },
    {
      'region': 'South India',
      'climate_type': 'Tropical',
      'summer_temp': [25, 35],
      'winter_temp': [18, 28],
      'rainfall': [1000, 2500],
      'best_crops': ['Rice', 'Coconut', 'Banana', 'Spices'],
      'challenges': ['High humidity', 'Heavy rainfall', 'Pests'],
    },
    {
      'region': 'East India',
      'climate_type': 'Humid subtropical',
      'summer_temp': [25, 38],
      'winter_temp': [10, 22],
      'rainfall': [1500, 2500],
      'best_crops': ['Rice', 'Tea', 'Jute', 'Sugarcane'],
      'challenges': ['Heavy monsoon', 'Flooding', 'High humidity'],
    },
    {
      'region': 'West India',
      'climate_type': 'Arid/Semi-arid',
      'summer_temp': [30, 48],
      'winter_temp': [10, 25],
      'rainfall': [250, 750],
      'best_crops': ['Cotton', 'Groundnut', 'Millets', 'Pulses'],
      'challenges': ['Water scarcity', 'High temperatures', 'Desertification'],
    },
  ];

  /// Fertilizer and nutrient database
  static final List<Map<String, dynamic>> fertilizerData = [
    {
      'fertilizer_name': 'Urea',
      'type': 'Nitrogen',
      'n_content': 46,
      'p_content': 0,
      'k_content': 0,
      'application_rate': '100-200 kg/ha',
      'best_for': ['Leafy vegetables', 'Cereals', 'Sugarcane'],
      'application_time': 'Basal and top dressing',
      'precautions': [
        'Avoid direct contact with seeds',
        'Apply in moist soil',
        'Don\'t apply before heavy rain',
      ],
    },
    {
      'fertilizer_name': 'DAP (Diammonium Phosphate)',
      'type': 'Phosphatic',
      'n_content': 18,
      'p_content': 20,
      'k_content': 0,
      'application_rate': '50-100 kg/ha',
      'best_for': ['All crops', 'Root crops', 'Pulses'],
      'application_time': 'Basal application',
      'precautions': [
        'Apply at planting time',
        'Don\'t mix with urea directly',
        'Avoid alkaline soils',
      ],
    },
    {
      'fertilizer_name': 'MOP (Muriate of Potash)',
      'type': 'Potassic',
      'n_content': 0,
      'p_content': 0,
      'k_content': 60,
      'application_rate': '25-50 kg/ha',
      'best_for': ['Fruit crops', 'Tuber crops', 'Oilseeds'],
      'application_time': 'Basal and top dressing',
      'precautions': [
        'Avoid chloride-sensitive crops',
        'Apply in split doses',
        'Don\'t apply on alkaline soils',
      ],
    },
    {
      'fertilizer_name': 'Compost',
      'type': 'Organic',
      'n_content': 1-2,
      'p_content': 0.5-1,
      'k_content': 1-2,
      'application_rate': '5-10 tons/ha',
      'best_for': ['All crops', 'Organic farming'],
      'application_time': 'Basal application',
      'benefits': [
        'Improves soil structure',
        'Increases water retention',
        'Adds beneficial microorganisms',
        'Slow release of nutrients',
      ],
    },
  ];

  /// Irrigation methods database
  static final List<Map<String, dynamic>> irrigationData = [
    {
      'method': 'Drip Irrigation',
      'efficiency': 90,
      'water_savings': 40,
      'best_for': ['Vegetables', 'Fruits', 'Flowers'],
      'advantages': [
        'High water use efficiency',
        'Reduces weed growth',
        'Prevents soil erosion',
        'Can apply fertilizers',
      ],
      'disadvantages': [
        'High initial cost',
        'Requires filtration',
        'Clogging issues',
        'Technical knowledge needed',
      ],
      'suitable_regions': ['Arid', 'Semi-arid', 'Water scarce areas'],
    },
    {
      'method': 'Sprinkler Irrigation',
      'efficiency': 75,
      'water_savings': 30,
      'best_for': ['Cereals', 'Pulses', 'Oilseeds'],
      'advantages': [
        'Uniform water distribution',
        'Suitable for undulating land',
        'Reduces labor',
        'Can apply chemicals',
      ],
      'disadvantages': [
        'High energy requirement',
        'Wind affects distribution',
        'Evaporation losses',
        'High maintenance',
      ],
      'suitable_regions': ['Undulating terrain', 'Medium rainfall areas'],
    },
    {
      'method': 'Furrow Irrigation',
      'efficiency': 50,
      'water_savings': 0,
      'best_for': ['Row crops', 'Vegetables', 'Cereals'],
      'advantages': [
        'Low initial cost',
        'Simple to operate',
        'No technical knowledge needed',
        'Suitable for most crops',
      ],
      'disadvantages': [
        'Water wastage',
        'Labor intensive',
        'Soil erosion',
        'Uneven distribution',
      ],
      'suitable_regions': ['Flat lands', 'Areas with adequate water'],
    },
    {
      'method': 'Flood Irrigation',
      'efficiency': 35,
      'water_savings': -20,
      'best_for': ['Rice', 'Pastures', 'Some vegetables'],
      'advantages': [
        'Very low cost',
        'Simple method',
        'No technical skills needed',
        'Suitable for rice cultivation',
      ],
      'disadvantages': [
        'High water wastage',
        'Water logging',
        'Soil salinity',
        'Uneven distribution',
      ],
      'suitable_regions': ['Rice growing areas', 'Areas with abundant water'],
    },
  ];
}