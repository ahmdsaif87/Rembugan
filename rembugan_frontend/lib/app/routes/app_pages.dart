import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/room_chat/bindings/room_chat_binding.dart';
import '../modules/room_chat/views/room_chat_view.dart';
import '../modules/explore/bindings/explore_binding.dart';
import '../modules/explore/views/explore_view.dart';
import '../modules/team/bindings/team_binding.dart';
import '../modules/team/views/team_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/social/views/comment_view.dart';
import '../modules/social/views/create_post_view.dart';
import '../modules/social/views/edit_profile_view.dart';
import '../modules/social/views/empty_state_view.dart';
import '../modules/social/views/loading_state_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/social/views/other_profile_view.dart';
import '../modules/social/views/connections_list_view.dart';
import '../modules/social/views/project_history_view.dart';
import '../modules/social/views/saved_view.dart';
import '../modules/social/views/settings_view.dart';
import '../modules/personalization/bindings/personalization_binding.dart';
import '../modules/personalization/views/personalization_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';

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
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.ROOM_CHAT,
      page: () => const RoomChatView(),
      binding: RoomChatBinding(),
    ),
    GetPage(
      name: _Paths.EXPLORE,
      page: () => const ExploreView(),
      binding: ExploreBinding(),
    ),
    GetPage(
      name: _Paths.TEAM,
      page: () => const TeamView(),
      binding: TeamBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(name: _Paths.OTHER_PROFILE, page: () => const OtherProfileView()),
    GetPage(name: _Paths.COMMENTS, page: () => const CommentView()),
    GetPage(name: _Paths.CREATE_POST, page: () => const CreatePostView()),
    GetPage(name: _Paths.EDIT_PROFILE, page: () => const EditProfileView()),
    GetPage(name: _Paths.SETTINGS, page: () => const SettingsView()),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(name: _Paths.SAVED, page: () => const SavedView()),
    GetPage(name: _Paths.EMPTY_STATE, page: () => const EmptyStateView()),
    GetPage(name: _Paths.LOADING_STATE, page: () => const LoadingStateView()),
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
<<<<<<< Updated upstream
=======
    GetPage(name: _Paths.SCAN, page: () => const ScanView()),
    GetPage(
      name: _Paths.CONNECTIONS_LIST,
      page: () => const ConnectionsListView(),
    ),
    GetPage(
      name: _Paths.PROJECT_HISTORY,
      page: () => const ProjectHistoryView(),
    ),
>>>>>>> Stashed changes
  ];
}
