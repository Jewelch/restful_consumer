import '../definition/model.dart';

final class NoDataModel extends ModelingProtocol {
  final bool success;

  const NoDataModel({required this.success});

  factory NoDataModel.empty() => const NoDataModel(success: true);

  @override
  NoDataModel fromJson(dynamic json) => NoDataModel(success: json['success'] as bool);

  @override
  List<Object?> get props => [success];
}
