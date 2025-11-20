import '../../src/extensions/external/safe_types.dart';
import '../protocol/modeling_protocol.dart';

class PaginatedResponse<T extends ModelingProtocol> {
  final List<T> content;
  final int currentPage;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool isLast;

  const PaginatedResponse({
    required this.content,
    required this.currentPage,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.isLast,
  });

  factory PaginatedResponse.empty(T emptyItem) => PaginatedResponse<T>(
    content: <T>[emptyItem],
    currentPage: 0,
    pageSize: 1,
    totalElements: 0,
    totalPages: 1,
    isLast: true,
  );

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T decodableModel) =>
      PaginatedResponse<T>(
        content:
            ((json['content'] as List<dynamic>?)
                    ?.map((e) => decodableModel.fromJson(e) as T)
                    .cast<T>()
                    .toList())
                .safe,
        currentPage: (json['currentPage'] as int?).safe,
        pageSize: (json['pageSize'] as int?).safe,
        totalElements: (json['totalElements'] as int?).safe,
        totalPages: (json['totalPages'] as int?).safe,
        isLast: (json['isLast'] as bool?).safe,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'content': content.map((e) => e.toJson()).toList(),
    'currentPage': currentPage,
    'pageSize': pageSize,
    'totalElements': totalElements,
    'totalPages': totalPages,
    'isLast': isLast,
  };
}
