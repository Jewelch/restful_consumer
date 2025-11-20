import '../../restful_consumer.dart' show Either;

//* Enums
enum RestfulMethods {
  get("GET"),
  post("POST"),
  put("PUT"),
  delete("DELETE"),
  patch("PATCH"),
  connect("CONNECT"),
  options("OPTIONS"),
  trace("TRACE");

  final String name;

  const RestfulMethods(this.name);
}

//* TypeDefs
typedef FutureRequestResult<T> = Future<Either<Exception, T>>;
typedef StringKeyedMap = Map<String, dynamic>;
