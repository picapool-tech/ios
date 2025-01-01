import 'package:get/get.dart';
import 'package:picapool/controllers/brand_controller.dart';

class BrandBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(BrandController());
  }
}
