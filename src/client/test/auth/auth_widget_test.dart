import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stashed/auth/auth.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';

import '../app_mock.dart';

class MockAuthCubit extends MockBloc<AuthCubit, AuthState> implements AuthCubit {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthWidget', () {
    late MockAuthCubit mockAuthCubit;
    late User mockUser;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      mockUser = const User(id: '1', username: 'test');
    });

    tearDown(() {
      mockAuthCubit.close();
    });

    testWidgets('displays loading state initially', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState(status: AuthStatus.loading));

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: const AppMock(
            child: AuthWidgetView(),
          ),
        ),
      );

      expect(find.text('loading'), findsOneWidget);
    });

    testWidgets('displays login button when unauthenticated', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState(status: AuthStatus.unauthenticated));

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: const AppMock(
            child: AuthWidgetView(),
          ),
        ),
      );

      expect(find.text('login'), findsOneWidget);
    });

    testWidgets('displays username when authenticated', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthState(status: AuthStatus.authenticated, user: mockUser));

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: const AppMock(
            child: AuthWidgetView(),
          ),
        ),
      );

      expect(find.text(mockUser.username), findsOneWidget);
    });

    testWidgets('open confirmation popup when logout button is pressed', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthState(status: AuthStatus.authenticated, user: mockUser));

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: const AppMock(
            child: AuthWidgetView(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.logout_outlined));

      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('logout is called when confirmation popup is confirmed', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthState(status: AuthStatus.authenticated, user: mockUser));
      when(() => mockAuthCubit.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: const AppMock(
            child: AuthWidgetView(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.logout_outlined));

      await tester.pumpAndSettle();

      await tester.tap(find.text('yes, logout'));

      await tester.pumpAndSettle();

      verify(() => mockAuthCubit.logout()).called(1);
    });

    testWidgets('logout is not called when confirmation popup is declined', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthState(status: AuthStatus.authenticated, user: mockUser));
      when(() => mockAuthCubit.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: const AppMock(
            child: AuthWidgetView(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.logout_outlined));

      await tester.pumpAndSettle();

      await tester.tap(find.text('no, stay logged in'));

      await tester.pumpAndSettle();

      verifyNever(() => mockAuthCubit.logout());
    });

    testWidgets('open login page when login button is pressed', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState(status: AuthStatus.unauthenticated));

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthRepository>.value(value: MockAuthRepository()),
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: const AppMock(
            child: AuthWidgetView(),
          ),
        ),
      );

      await tester.tap(find.text('login'));

      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
