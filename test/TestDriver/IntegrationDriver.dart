import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:elearning_applicaton/main.dart'as app;
void main(){
  group('app test', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets("login test", (tester) async {
      // Initialize the app or do any setup
      app.main();

      // Pump widgets until the widget tree is stable
      await tester.pumpAndSettle();

      // Find widgets and interact with them
      final emailFormField = find.byType(TextFormField).first;
      final passwordFormField = find.byType(TextFormField).last;
      final loginButton = find.byType(MaterialButton).first;

      await tester.enterText(emailFormField, "maleek.hm29@gmail.com");
      await tester.pump(); // You may need to pump here, depending on the widget behavior
      await tester.enterText(passwordFormField, "123456");
      await tester.pump();

      // Trigger the login
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      // Your assertions go here
    });

  });
}