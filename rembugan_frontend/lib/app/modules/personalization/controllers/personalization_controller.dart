import 'package:get/get.dart';

class PersonalizationController extends GetxController {
  var isUploading = false.obs;
  var isScanned = false.obs;
  var interests = <String>[].obs;
  var bio = ''.obs;

  void simulateUpload() async {
    isUploading.value = true;
    await Future.delayed(const Duration(seconds: 3)); // Simulate AI processing
    isUploading.value = false;
    isScanned.value = true;
    
    // Mock AI Results
    interests.assignAll(['Flutter', 'Dart', 'UI/UX Design', 'Firebase', 'State Management']);
    bio.value = 'Seorang pengembang aplikasi mobile yang antusias dengan pengalaman dalam membangun solusi inovatif menggunakan Flutter.';
  }

  void reset() {
    isUploading.value = false;
    isScanned.value = false;
    interests.clear();
    bio.value = '';
  }
}
