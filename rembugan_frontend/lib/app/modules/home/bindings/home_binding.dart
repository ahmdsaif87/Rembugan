import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../explore/data/repositories/api_explore_repository.dart';
import '../../explore/domain/repositories/explore_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExploreRepository>(() => ApiExploreRepository());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
