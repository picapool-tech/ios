import 'package:get/get.dart';
import 'package:picapool/controllers/live_offer_controller.dart';

class LiveOfferBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(LiveOfferController());
  }
}
