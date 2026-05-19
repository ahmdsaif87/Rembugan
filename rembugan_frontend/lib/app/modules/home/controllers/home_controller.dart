import 'package:get/get.dart';

class HomeController extends GetxController {
  final activeTab = 0.obs; // 0 for 'Untukmu', 1 for 'Mengikuti'

  void setTab(int index) {
    activeTab.value = index;
  }
}
