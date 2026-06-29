

import 'package:matrial_1123150086_uts/core/constants/app_constants.dart';
import 'package:matrial_1123150086_uts/core/services/dio_client.dart';
import 'package:matrial_1123150086_uts/features/dashboard/data/models/product_model.dart';
import 'package:matrial_1123150086_uts/features/dashboard/domain/repositories/product_repository.dart';

class ProductRepositoryImpl extends ProductRepository {
  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    final response = await DioClient.instance.get(
      AppConstants.products,
      queryParameters: {'page': page, 'limit': limit, 'category': category},
    );

    print(response.data);
    final List<dynamic> data = response.data['data'];
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }


  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await DioClient.instance.get(
      '${AppConstants.products}/$id',
    );
    return ProductModel.fromJson(response.data['data']);
  }
}
