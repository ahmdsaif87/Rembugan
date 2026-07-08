import 'package:get/get.dart';

import '../../explore/controllers/explore_controller.dart';
import '../../explore/data/repositories/api_explore_repository.dart';
import '../../explore/domain/repositories/explore_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../team/controllers/team_controller.dart';
import '../controllers/main_shell_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().syncFromRoute(Get.currentRoute, Get.arguments);
    } else {
      Get.lazyPut<MainShellController>(() => MainShellController(), fenix: true);
    }

    Get.lazyPut<ExploreRepository>(() => ApiExploreRepository());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ExploreController>(
      () => ExploreController(Get.find<ExploreRepository>()),
    );
    Get.lazyPut<TeamController>(() => TeamController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
