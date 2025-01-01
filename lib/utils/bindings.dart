import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:picapool/controllers/category_controller.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/controllers/product_controller.dart';
import 'package:picapool/controllers/sell_form_controller.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies(){
    Get.put(ProductController());
    Get.put(CategoryController());
    Get.put(FormController());
    Get.put(LiveOfferController());
  }
}