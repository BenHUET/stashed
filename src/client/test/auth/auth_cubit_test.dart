import 'package:auth_repository/auth_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stashed/auth/cubits/auth/auth_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  group('AuthCubit', () {
    late MockAuthRepository mockAuthRepository;
    late AuthCubit authCubit;
    late MockUser mockUser;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockUser = MockUser();
      authCubit = AuthCubit(authRepository: mockAuthRepository);
    });

    tearDown(() {
      authCubit.close();
    });

    test('initial state is correct', () {
      expect(authCubit.state, const AuthState(status: AuthStatus.initial));
    });

    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when getUser succeeds',
      build: () {
        when(mockAuthRepository.getUser).thenAnswer((_) => Stream.value(mockUser));
        return authCubit;
      },
      act: (cubit) => cubit.getUser(),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        AuthState(status: AuthStatus.authenticated, user: mockUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, unauthenticated] when getUser returns null',
      build: () {
        when(mockAuthRepository.getUser).thenAnswer((_) => Stream.value(null));
        return authCubit;
      },
      act: (cubit) => cubit.getUser(),
      expect: () => const [
        AuthState(status: AuthStatus.loading),
        AuthState(status: AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [unauthenticated] when getUser fails',
      build: () {
        when(mockAuthRepository.getUser).thenAnswer((_) => Stream.error(Exception()));
        return authCubit;
      },
      seed: () => AuthState(status: AuthStatus.authenticated, user: mockUser),
      act: (cubit) => cubit.getUser(),
      expect: () => [
        AuthState(status: AuthStatus.loading, user: mockUser),
        const AuthState(status: AuthStatus.unauthenticated, user: null),
      ],
    );
  });
}
