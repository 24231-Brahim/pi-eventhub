part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {
  const GetProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String? phone;
  final String? photoUrl;
  const UpdateProfileEvent({
    required this.name,
    this.phone,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [name, phone, photoUrl];
}
