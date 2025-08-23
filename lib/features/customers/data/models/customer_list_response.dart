import 'customer.dart';

class CustomerListResponse {
  final String status;
  final String message;
  final CustomerPaginationData? data;

  const CustomerListResponse({
    required this.status,
    required this.message,
    this.data,
  });

  bool get isSuccess => status == 'success';

  factory CustomerListResponse.fromJson(Map<String, dynamic> json) {
    return CustomerListResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? CustomerPaginationData.fromJson(json['data'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }
}

class CustomerPaginationData {
  final List<Customer> data;
  final PaginationLinks links;
  final PaginationMeta meta;

  const CustomerPaginationData({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory CustomerPaginationData.fromJson(Map<String, dynamic> json) {
    return CustomerPaginationData(
      data:
          (json['data'] as List<dynamic>? ?? [])
              .map((item) => Customer.fromJson(item))
              .toList(),
      links: PaginationLinks.fromJson(json['links'] ?? {}),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((customer) => customer.toJson()).toList(),
      'links': links.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  const PaginationLinks({this.first, this.last, this.prev, this.next});

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'first': first, 'last': last, 'prev': prev, 'next': next};
  }
}

class PaginationMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final List<PaginationLink> links;
  final String path;
  final int perPage;
  final int? to;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    this.to,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPrevPage => currentPage > 1;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      links:
          (json['links'] as List<dynamic>? ?? [])
              .map((item) => PaginationLink.fromJson(item))
              .toList(),
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 15,
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'links': links.map((link) => link.toJson()).toList(),
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  const PaginationLink({this.url, required this.label, required this.active});

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'label': label, 'active': active};
  }
}
