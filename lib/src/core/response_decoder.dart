import '../../restful_consumer.dart' show ModelingProtocol, Response;
import '../data/models/no_data_model.dart';
import '../data/models/paginated_response.dart';
import '../utils/either.dart';
import '../utils/networking_utilities.dart';
import 'errors/exceptions.dart';

mixin ResponseDecoder {
  Either<Exception, R> decode<R, MP extends ModelingProtocol>(
    MP decodableModel, {
    Response<dynamic>? response,
    dynamic mockingData,
    required bool mocking,
    required bool paginated,
  }) {
    try {
      if (mockingData == null && response == null)
        throw NoDataToDecodeException(StackTrace.current);

      final data = mocking ? mockingData : response?.data;

      if (data is! List && data is! StringKeyedMap)
        throw UnsupportedDataTypeException(data, StackTrace.current);

      return Right(switch ((paginated, decodableModel)) {
        (true, _) => PaginatedResponse<MP>.fromJson(data, decodableModel) as R,
        (false, _) when decodableModel is NoDataModel =>
          decodableModel.fromJson({
                'success': mocking
                    ? true
                    : (response!.statusCode! >= 200 && response.statusCode! < 300),
              })
              as R,
        (false, _) => decodableModel.fromJson(data),
      });
    } on NoDataToDecodeException catch (e) {
      return Left(e);
    } on UnsupportedDataTypeException catch (e) {
      return Left(e);
    } catch (e, s) {
      return Left(JsonParsingException(e, s));
    }
  }
}
