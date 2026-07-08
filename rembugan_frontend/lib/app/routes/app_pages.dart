import 'package:get/get.dart';

import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_shell/bindings/main_shell_binding.dart';
import '../modules/main_shell/views/main_shell_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/personalization/bindings/personalization_binding.dart';
import '../modules/personalization/views/personalization_view.dart';
import '../modules/profile/views/profile_qr_view.dart';
import '../modules/room_chat/views/room_chat_view.dart';
import '../modules/social/views/connections_list_view.dart';
import '../modules/social/views/create_post_view.dart';
import '../modules/social/views/edit_profile_view.dart';
import '../modules/social/views/other_profile_view.dart';
import '../modules/social/views/project_history_view.dart';
import '../modules/social/views/saved_view.dart';
import '../modules/social/views/search_view.dart';
import '../modules/social/views/settings_view.dart';
import '../modules/team/views/scan_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ONBOARDING;

  static final routes = [
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: _Paths.EXPLORE,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: _Paths.TEAM,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.ROOM_CHAT,
      page: () => const RoomChatView(),
    ),
    GetPage(
      name: _Paths.OTHER_PROFILE,
      page: () => const OtherProfileView(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
    ),
    GetPage(
      name: _Paths.CREATE_POST,
      page: () => const CreatePostView(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.SAVED,
      page: () => const SavedView(),
    ),
    GetPage(
      name: _Paths.PERSONALIZATION,
      page: () => const PersonalizationView(),
      binding: PersonalizationBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.CONNECTIONS_LIST,
      page: () => const ConnectionsListView(),
    ),
    GetPage(
      name: _Paths.PROJECT_HISTORY,
      page: () => const ProjectHistoryView(),
    ),
    GetPage(
      name: _Paths.SCAN,
      page: () => const ScanView(),
    ),
    GetPage(
      name: _Paths.PROFILE_QR,
      page: () => const ProfileQrView(),
    ),
  ];
}
