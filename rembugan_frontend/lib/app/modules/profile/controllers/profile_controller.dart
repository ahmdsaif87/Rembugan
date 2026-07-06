import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService profileService = Get.find<ProfileService>();
  final selectedTabIndex = 0.obs;

  final showcases = <Map<String, dynamic>>[].obs;
  final isShowcasesLoading = false.obs;

  final likedShowcaseIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    profileService.fetchProfile();
    fetchShowcases();
  }

  Future<void> fetchShowcases() async {
    isShowcasesLoading.value = true;
    try {
      final api = Get.find<ApiClient>();
      final res = await api.get('/showcase/my');
      final body = (res.data as Map<String, dynamic>?)?['data'];
      if (body is List) {
        showcases.assignAll(body.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('ProfileController.fetchShowcases error: $e');
    } finally {
      isShowcasesLoading.value = false;
    }
  }

  void toggleLike(String showcaseId) {
    final isLiked = likedShowcaseIds.contains(showcaseId);
    if (isLiked) {
      likedShowcaseIds.remove(showcaseId);
    } else {
      likedShowcaseIds.add(showcaseId);
    }
    try {
      final api = Get.find<ApiClient>();
      if (isLiked) {
        api.delete('/showcase/$showcaseId/like');
      } else {
        api.post('/showcase/$showcaseId/like');
      }
    } catch (_) {}
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    if (index == 0) fetchShowcases();
  }
}
