import 'package:get/get.dart';

class SessionService extends GetxService {
  final isGuest = false.obs;

  void enterGuestMode() {
    isGuest.value = true;
  }

  void enterAuthenticatedMode() {
    isGuest.value = false;
  }
}
