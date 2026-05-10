import 'package:get/get.dart';

class ExploreController extends GetxController {
  // 0: Proyek, 1: Lomba, 2: Orang
  var activeTab = 0.obs;

  void changeTab(int index) {
    activeTab.value = index;
  }
}
