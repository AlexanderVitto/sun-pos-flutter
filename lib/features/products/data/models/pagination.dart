class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({this.first, this.last, this.prev, this.next});

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

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({this.url, required this.label, required this.active});

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

class PaginationMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final List<PaginationLink> links;
  final String path;
  final int perPage;
  final int? to;
  final int total;

  PaginationMeta({
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
    var linksList = json['links'] as List<dynamic>? ?? [];
    List<PaginationLink> paginationLinks =
        linksList.map((linkJson) => PaginationLink.fromJson(linkJson)).toList();

    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      links: paginationLinks,
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
