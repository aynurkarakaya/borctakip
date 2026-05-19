import 'package:get/get.dart';

import '../../modules/splash/splash_view.dart';
import '../../modules/auth/views/auth_selection_view.dart';
import '../../modules/auth/views/user_login_view.dart';
import '../../modules/auth/views/user_register_view.dart';
import '../../modules/auth/views/cafe_login_view.dart';
import '../../modules/auth/views/cafe_register_view.dart';
import '../../modules/auth/views/forgot_password_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/home/user_home_view.dart';
import '../../modules/home/cafe_home_view.dart';
import '../../modules/main_nav/main_nav_view.dart';
import '../../modules/friends/pages/friends_page.dart';
import '../../modules/friends/pages/add_friend_page.dart';
import '../../modules/friends/pages/friend_requests_page.dart';
import '../../modules/groups/pages/create_group_page.dart';
import '../../modules/notifications/pages/notifications_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.authSelection,
      page: () => const AuthSelectionView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.userLogin,
      page: () => const UserLoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.userRegister,
      page: () => const UserRegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.cafeLogin,
      page: () => const CafeLoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.cafeRegister,
      page: () => const CafeRegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavView(),
    ),
    GetPage(
      name: AppRoutes.userHome,
      page: () => const UserHomeView(),
    ),
    GetPage(
      name: AppRoutes.cafeHome,
      page: () => const CafeHomeView(),
    ),
    GetPage(name: AppRoutes.friends, page: () => const FriendsPage()),
    GetPage(name: AppRoutes.addFriend, page: () => const AddFriendPage()),
    GetPage(name: AppRoutes.friendRequests, page: () => const FriendRequestsPage()),
    GetPage(name: AppRoutes.createGroup, page: () => const CreateGroupPage()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsPage()),
  ];
}
