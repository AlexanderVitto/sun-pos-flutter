import 'cash_flow.dart';

class CreateCashFlowResponse {
  final bool success;
  final String message;
  // final CashFlow? cashFlow;

  CreateCashFlowResponse({
    required this.success,
    required this.message,
    // this.cashFlow,
  });

  factory CreateCashFlowResponse.fromJson(Map<String, dynamic> json) {
    return CreateCashFlowResponse(
      success: json['status'] == 'success' || json['success'] == true,
      message: json['message'] ?? '',
      // cashFlow: json['data'] != null ? CashFlow.fromJson(json['data']) : null,
    );
  }
}

class CashFlowListResponse {
  final bool success;
  final String message;
  final List<CashFlow> cashFlows;
  final PaginationMeta? pagination;

  CashFlowListResponse({
    required this.success,
    required this.message,
    required this.cashFlows,
    this.pagination,
  });

  factory CashFlowListResponse.fromJson(Map<String, dynamic> json) {
    List<CashFlow> cashFlowsList = [];

    if (json['data'] != null) {
      if (json['data']['data'] != null) {
        // Paginated response
        cashFlowsList =
            (json['data']['data'] as List)
                .map((item) => CashFlow.fromJson(item))
                .toList();
      } else if (json['data'] is List) {
        // Direct list response
        cashFlowsList =
            (json['data'] as List)
                .map((item) => CashFlow.fromJson(item))
                .toList();
      }
    }

    PaginationMeta? paginationMeta;
    if (json['data'] != null && json['data']['meta'] != null) {
      paginationMeta = PaginationMeta.fromJson(json['data']['meta']);
    }

    return CashFlowListResponse(
      success: json['status'] == 'success' || json['success'] == true,
      message: json['message'] ?? '',
      cashFlows: cashFlowsList,
      pagination: paginationMeta,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}
