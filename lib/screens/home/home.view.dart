import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import 'home.binding.dart';
import 'home.controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GetX Store',
        initialBinding: HomeBinding());
  }
}
