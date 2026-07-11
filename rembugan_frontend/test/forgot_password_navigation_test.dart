import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rembugan/app/core/theme/theme.dart';
import 'package:rembugan/app/modules/forgot_password/bindings/forgot_password_binding.dart';
import 'package:rembugan/app/modules/forgot_password/controllers/forgot_password_controller.dart';
import 'package:rembugan/app/modules/forgot_password/views/forgot_password_view.dart';
import 'package:rembugan/app/modules/login/bindings/login_binding.dart';
import 'package:rembugan/app/modules/login/controllers/login_controller.dart';
import 'package:rembugan/app/modules/login/views/login_view.dart';

import 'package:rembugan/app/core/services/api_client.dart';
import 'package:rembugan/app/core/services/auth_service.dart';

class FakeApiClient extends ApiClient {
  @override
  void onInit() {}
}

void main() {
  tearDown(Get.reset);

  testWidgets('back to login does not reuse disposed text controllers', (
    tester,
  ) async {
    Get.put<ApiClient>(FakeApiClient());
    Get.put(AuthService());
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 260),
        getPages: [
          GetPage(
            name: '/forgot-password',
            page: () => const ForgotPasswordView(),
            binding: ForgotPasswordBinding(),
          ),
          GetPage(
            name: '/login',
            page: () => const LoginView(),
            binding: LoginBinding(),
          ),
        ],
      ),
    );

    final originalLoginController = Get.find<LoginController>();
    await tester.tap(find.text('Lupa kata sandi'));
    await tester.pumpAndSettle();

    Get.find<ForgotPasswordController>().step.value = 3;
    await tester.pump();

    await tester.tap(find.text('Masuk kembali'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(Get.find<LoginController>(), same(originalLoginController));
    expect(tester.takeException(), isNull);
  });
}
