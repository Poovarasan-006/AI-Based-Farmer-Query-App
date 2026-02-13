import 'package:your_package_name/your_package_name.dart';

class TextSearchService {
  // Method for full-text searching across documents
  List<Document> search(String query, List<Document> documents) {
    return documents.where((doc) => doc.content.contains(query)).toList();
  }
}