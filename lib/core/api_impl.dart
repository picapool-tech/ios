import 'package:get/get.dart';
import 'package:picapool/core/api.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/response_model.dart';

mixin PicapoolApiClass {
  final PicapoolApi api = Get.find<PicapoolApi>();
}

// extension ApiHelpers on ResponseModel {
//   Future<T> parseWithCompute<T>(
//     String jsonString,
//     T Function(Map<String, dynamic>)
//   ) async {
//     final jsonMap = await compute
//   }
// }
