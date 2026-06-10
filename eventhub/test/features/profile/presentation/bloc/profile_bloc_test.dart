import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eventhub/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;

  setUp(() {
    mockGetProfileUseCase = MockGetProfileUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
  });

  ProfileBloc createBloc() => ProfileBloc(
        getProfileUseCase: mockGetProfileUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
      );

  group('ProfileBloc', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when getProfile succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetProfileUseCase.call())
            .thenAnswer((_) async => const Right(tProfile));
        bloc.add(const GetProfileEvent());
      },
      expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when getProfile fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetProfileUseCase.call())
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const GetProfileEvent());
      },
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileUpdated] when updateProfile succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockUpdateProfileUseCase.call('New Name', '987654321', null))
            .thenAnswer((_) async => const Right(tProfile));
        bloc.add(const UpdateProfileEvent(
          name: 'New Name',
          phone: '987654321',
        ));
      },
      expect: () => [isA<ProfileLoading>(), isA<ProfileUpdated>()],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when updateProfile fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockUpdateProfileUseCase.call('New Name', null, null))
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const UpdateProfileEvent(name: 'New Name'));
      },
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
    );
  });
}
