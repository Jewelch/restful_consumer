import '../../../restful_consumer.dart' show HttpHeaders;
import '../../utils/networking_utilities.dart';

extension HeadersInjections on StringKeyedMap {
  StringKeyedMap setupContentType(String contentType) =>
      this..addAll({HttpHeaders.contentTypeHeader: contentType});

  StringKeyedMap setupAcceptedResponseTypeTo(String acceptedFormat) =>
      this..addAll({HttpHeaders.acceptHeader: 'application/$acceptedFormat'});
}
