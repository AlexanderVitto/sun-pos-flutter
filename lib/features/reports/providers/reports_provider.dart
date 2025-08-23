import 'package:flutter/material.dart';
import '../data/models/transaction_widgets_model.dart';
import '../data/models/most_sold_product_model.dart';
import '../data/services/reports_api_service.dart';

class ReportsProvider extends ChangeNotifier {
  final ReportsApiService _apiService = ReportsApiService();

  TransactionWidgetsModel? _transactionWidgets;
  List<MostSoldProductModel> _mostSoldProducts = [];
  bool _isLoading = false;
  bool _isLoadingProducts = false;
  String? _error;

  TransactionWidgetsModel? get transactionWidgets => _transactionWidgets;
  List<MostSoldProductModel> get mostSoldProducts => _mostSoldProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get error => _error;

  Future<void> fetchTransactionWidgets({
    required String dateFrom,
    required String dateTo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactionWidgets = await _apiService.getTransactionWidgets(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMostSoldProducts({
    required String dateFrom,
    required String dateTo,
  }) async {
    _isLoadingProducts = true;
    _error = null;
    notifyListeners();

    try {
      _mostSoldProducts = await _apiService.getMostSoldProducts(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllReportsData({
    required String dateFrom,
    required String dateTo,
  }) async {
    await Future.wait([
      fetchTransactionWidgets(dateFrom: dateFrom, dateTo: dateTo),
      fetchMostSoldProducts(dateFrom: dateFrom, dateTo: dateTo),
    ]);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
