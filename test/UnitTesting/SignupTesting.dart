import 'package:elearning_applicaton/screens/signUpScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {

  group('SignUpScreen', () {
    testWidgets('renders widgets', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(SignUpScreen()); // Replace MyApp with the name of your app

      // Verify that the necessary widgets are present on the screen.
      expect(find.text('Sign Up'), findsOneWidget);
    });

  });
}