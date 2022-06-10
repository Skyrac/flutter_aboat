import 'package:get/get.dart';
import 'package:talkaboat/screens/home/home.controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
