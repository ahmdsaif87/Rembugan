import 'package:get/get.dart';

import '../../../core/services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService profileService = Get.find<ProfileService>();
  final selectedTabIndex = 0.obs;

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }
}
