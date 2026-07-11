import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_chrome.dart';
import '../../home/views/home_view.dart';
import '../../explore/views/explore_view.dart';
import '../../team/views/team_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/main_shell_controller.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  static const _tabs = <Widget>[
    HomeView(),
    ExploreView(),
    TeamView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = controller.currentIndex.value;
      return Scaffold(
        body: _tabs[tab],
        bottomNavigationBar: AppBottomNav(
          current: _destinations[tab],
          onTap: controller.changeTab,
        ),
      );
    });
  }
}

const _destinations = [
  AppNavDestination.home,
  AppNavDestination.explore,
  AppNavDestination.team,
  AppNavDestination.profile,
];
