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

  @override
  String toString() {
    return 'PaginationLinks(first: $first, last: $last, prev: $prev, next: $next)';
  }
}

class MetaLink {
  final String? url;
  final String label;
  final bool active;

  const MetaLink({this.url, required this.label, required this.active});

  factory MetaLink.fromJson(Map<String, dynamic> json) {
    return MetaLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'label': label, 'active': active};
  }

  @override
  String toString() {
    return 'MetaLink(url: $url, label: $label, active: $active)';
  }
}

class PaginationMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final List<MetaLink> links;
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

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      links:
          (json['links'] as List<dynamic>? ?? [])
              .map((item) => MetaLink.fromJson(item))
              .toList(),
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
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

  @override
  String toString() {
    return 'PaginationMeta(currentPage: $currentPage, total: $total, perPage: $perPage, lastPage: $lastPage)';
  }
}
