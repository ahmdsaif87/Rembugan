part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const LOGIN = _Paths.LOGIN;
  static const CHAT = _Paths.CHAT;
  static const ROOM_CHAT = _Paths.ROOM_CHAT;
  static const EXPLORE = _Paths.EXPLORE;
  static const TEAM = _Paths.TEAM;
  static const PROFILE = _Paths.PROFILE;
  static const OTHER_PROFILE = _Paths.OTHER_PROFILE;
  static String otherProfileRoute(String userId) => '/other-profile/$userId';
  static const CREATE_POST = _Paths.CREATE_POST;
  static const EDIT_PROFILE = _Paths.EDIT_PROFILE;
  static const SETTINGS = _Paths.SETTINGS;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const SEARCH = _Paths.SEARCH;
  static const SAVED = _Paths.SAVED;
  static const PERSONALIZATION = _Paths.PERSONALIZATION;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const SCAN = _Paths.SCAN;
  static const PROFILE_QR = _Paths.PROFILE_QR;
  static const CONNECTIONS_LIST = _Paths.CONNECTIONS_LIST;
  static const PROJECT_HISTORY = _Paths.PROJECT_HISTORY;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const CHAT = '/chat';
  static const ROOM_CHAT = '/room-chat';
  static const EXPLORE = '/explore';
  static const TEAM = '/team';
  static const PROFILE = '/profile';
  static const OTHER_PROFILE = '/other-profile/:userId';
  static const CREATE_POST = '/create-post';
  static const EDIT_PROFILE = '/edit-profile';
  static const SETTINGS = '/settings';
  static const NOTIFICATIONS = '/notifications';
  static const SEARCH = '/search';
  static const SAVED = '/saved';
  static const PERSONALIZATION = '/personalization';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const SCAN = '/scan';
  static const PROFILE_QR = '/profile-qr';
  static const CONNECTIONS_LIST = '/connections-list';
  static const PROJECT_HISTORY = '/project-history';
}
