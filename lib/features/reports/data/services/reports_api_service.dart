import 'dart:convert';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/config/app_config.dart';
import '../models/transaction_widgets_model.dart';
import '../models/most_sold_product_model.dart';

class ReportsApiService {
  static final ReportsApiService _instance = ReportsApiService._internal();
  factory ReportsApiService() => _instance;
  ReportsApiService._internal();

  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  Future<TransactionWidgetsModel> getTransactionWidgets({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final queryParameters = {'date_from': dateFrom, 'date_to': dateTo};

      final response = await _apiClient.get(
        '/reports/transaction-widgets',
        headers: AppConfig.getAuthHeaders(token),
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return TransactionWidgetsModel.fromJson(data['data']);
        } else {
          throw Exception(
            data['message'] ?? 'Failed to get transaction widgets',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to get transaction widgets');
      }
    } catch (e) {
      if (e.toString().contains('No internet connection')) {
        throw Exception('Tidak ada koneksi internet');
      } else if (e.toString().contains('Unauthorized')) {
        throw Exception('Sesi telah berakhir, silakan login kembali');
      }
      throw Exception('Gagal mengambil data laporan: ${e.toString()}');
    }
  }

  Future<List<MostSoldProductModel>> getMostSoldProducts({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final queryParameters = {'date_from': dateFrom, 'date_to': dateTo};

      final response = await _apiClient.get(
        '/reports/most-sold-products',
        headers: AppConfig.getAuthHeaders(token),
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          List<dynamic> productsData = data['data'];
          return productsData
              .map((product) => MostSoldProductModel.fromJson(product))
              .toList();
        } else {
          throw Exception(
            data['message'] ?? 'Failed to get most sold products',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to get most sold products');
      }
    } catch (e) {
      if (e.toString().contains('No internet connection')) {
        throw Exception('Tidak ada koneksi internet');
      } else if (e.toString().contains('Unauthorized')) {
        throw Exception('Sesi telah berakhir, silakan login kembali');
      }
      throw Exception('Gagal mengambil data produk terlaris: ${e.toString()}');
    }
  }
}
