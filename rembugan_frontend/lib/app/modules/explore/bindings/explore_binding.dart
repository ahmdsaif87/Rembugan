import 'package:get/get.dart';

import '../controllers/explore_controller.dart';
import '../data/repositories/api_explore_repository.dart';
import '../domain/repositories/explore_repository.dart';

class ExploreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExploreRepository>(() => ApiExploreRepository());
    Get.lazyPut<ExploreController>(
      () => ExploreController(Get.find<ExploreRepository>()),
    );
  }
}
