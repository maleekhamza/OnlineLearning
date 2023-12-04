import 'package:elearning_applicaton/screens/root_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart'; // Add this line
import 'package:elearning_applicaton/screens/loginScreen.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {

} // Add this class

void main() {
  group('LoginScreen Widget Test', () {
    late MockFirebaseAuth mockFirebaseAuth; // Add this line
    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth(); // Add this line
    });
    setUpAll(() async {
      await Firebase.initializeApp();
      // Ensure Firebase is initialized before running tests
    });
    testWidgets('Sign in successfully', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(),
      ));

      // Enter valid email and password
      await tester.enterText(find.byKey(Key('emailField')), 'maleek.hm29@gmail.com');
      await tester.enterText(find.byKey(Key('passwordField')), '123456');

      // Tap the login button
      await tester.tap(find.byKey(Key('loginButton')));
      await tester.pump();

      // Verify that CircularProgressIndicator is visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Mock the sign-in process
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: ('maleek.hm29@gmail.com'),
        password: ('123456'),
      )).thenAnswer((_) async => MockUserCredential());

      // Trigger the sign-in function
      await tester.pump();

      // Verify that CircularProgressIndicator is no longer visible
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify that the user is navigated to the RootApp screen
      expect(find.byType(RootApp), findsOneWidget);
    });
  });
}

class MockUserCredential extends Mock implements UserCredential {} // Add this class