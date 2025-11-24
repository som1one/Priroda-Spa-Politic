import '../models/custom_content.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

class CustomContentService {
  final _apiService = ApiService();

  Future<List<CustomContentBlock>> getCustomContentBlocks() async {
    try {
      final response = await _apiService.get('/custom-content');
      if (response is List) {
        return (response as List)
            .map((item) => CustomContentBlock.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

