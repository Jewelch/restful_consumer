import '../../data/definition/model.dart';
import '../../data/models/paginated_response.dart';
import '../../utils/either.dart';

extension PaginatedResponseFutureExtension<M extends ModelingProtocol>
    on Future<Either<Exception, PaginatedResponse<M>>> {
  Future<Either<Exception, List<M>>> foldPaginated() async => await then(
    (result) => result.fold(
      (exception) => Left(exception),
      (paginatedResponse) => Right(paginatedResponse.content),
    ),
  );
}
