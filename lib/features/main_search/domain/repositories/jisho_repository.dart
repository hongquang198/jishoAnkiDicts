import 'package:dartz/dartz.dart';
import 'package:unofficial_jisho_api/api.dart';

import '../../../../core/error/failures.dart';

abstract class JishoRepository {
  Future<Either<Failure, JishoAPIResult>> searchForPhrase({required String phrase});
}
