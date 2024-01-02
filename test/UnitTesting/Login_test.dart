import 'package:elearning_applicaton/Screens/ForgotPassword.dart';
import 'package:elearning_applicaton/Screens/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {

  group('LoginScreen Widget Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    setUpAll(() async {
      // Initialize Firebase before running tests
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
    });

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
    });

    testWidgets('Entering valid email and password triggers login', (
        WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );
      // Enter email and password
      await tester.enterText(find.byKey(Key('emailField')), 'maleek.hm29@gmail.com');
      await tester.enterText(find.byKey(Key('passwordField')), '123456');

      // Tap on the login button
      await tester.tap(find.byKey(Key('loginButton')));
      await tester.pump();

      // Verify that the signIn method is called
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'maleek.hm29@gmail.com',
        password: '123456',
      )).called(1);
    });

    testWidgets('Entering invalid email shows error message', (
        WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byKey(Key('emailField')), 'invalidemail');

      // Tap on the login button
      await tester.tap(find.byKey(Key('loginButton')));
      await tester.pump();

      // Verify that the error message is displayed
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Entering invalid password shows error message', (
        WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Enter invalid password
      await tester.enterText(find.byKey(Key('passwordField')), '123');

      // Tap on the login button
      await tester.tap(find.byKey(Key('loginButton')));
      await tester.pump();

      // Verify that the error message is displayed
      expect(find.text(
          'Please enter a valid password with a minimum of 6 characters'),
          findsOneWidget);
    });


    testWidgets('Entering non-existent email and password shows error message', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Mock FirebaseAuth's signInWithEmailAndPassword to throw a 'user-not-found' exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: ('email'),
        password: ('password'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Enter non-existent email and password
      await tester.enterText(find.byKey(Key('emailField')), 'nonexistent@example.com');
      await tester.enterText(find.byKey(Key('passwordField')), '123456789');

      // Tap on the login button
      await tester.tap(find.byKey(Key('loginButton')));
      await tester.pump();

      // Verify that the error message is displayed
      expect(find.text('No user found for that email.'), findsOneWidget);
    });

    // Add more test cases as needed

  });
}
