

import '../../../domain/models/profile_models/profile_response.dart';

abstract class ProfileState {}

// State when profile request is loading
class ProfileLoadingState extends ProfileState {}

// State when profile request is loading
class ProfileRequestLoadingState extends ProfileState {}

// State for successful profile fetch with response data
class ProfileSuccessState extends ProfileState {
  final ProfileResponse response;

  ProfileSuccessState(this.response);

  @override
  String toString() => 'ProfileSuccessState(response: $response)';
}

// State for general profile errors
class ProfileErrorState extends ProfileState {
  final String? error;

  ProfileErrorState(this.error);

  @override
  String toString() => 'ProfileErrorState(error: $error)';
}


