import 'package:frontend/Core/network/api_endpoints.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/menu/data/models/menu_category_model.dart';

abstract class MenuRemoteDataSource {
  Future<List<MenuCategoryModel>> getMenuCategories();
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  MenuRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<MenuCategoryModel>> getMenuCategories() async {
    final response = await _dioClient.get(ApiEndpoints.menuCategories);
    final data = response.data;
    final list = _extractList(
      data,
      keys: const ['data', 'categories', 'items'],
    );
    return list
        .map((item) => MenuCategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractList(dynamic data, {required List<String> keys}) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        final value = data[key];
        if (value is List) return value;
      }
    }

    throw const AppException(message: 'Invalid menu response format.');
  }
}
