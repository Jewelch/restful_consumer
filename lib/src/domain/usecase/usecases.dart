import 'package:equatable/equatable.dart';
import 'package:restful_consumer/restful_consumer.dart' show Either, Failure;

export 'package:dio/dio.dart';
export 'package:equatable/equatable.dart';

abstract class UseCase<E, Params> {
  Future<Either<Failure, E>> call(Params params);
}

final class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

typedef UseCaseResult<T> = Future<Either<Failure, T>>;
