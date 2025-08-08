import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../repo/profile_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../repo/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<FetchProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final customer = await repository.fetchProfile();
        emit(ProfileLoaded(customer));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        await repository.updateProfile(event.updatedCustomer);
        final customer = await repository.fetchProfile();
        emit(ProfileLoaded(customer));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
